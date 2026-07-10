#' @title NIRWise PLUS cross-validation function
#' @description
#'
#' Perform cross-validation for a model based on given settings.
#'
#' @usage
#' .calibrate_cv(X, Y, group = NULL, method, control, verbose = TRUE)
#'
#' @param X a numeric matrix of spectral data.
#' @param Y a matrix of one column with the response variable.
#' @param group an optional factor (or character vector that can be coerced to
#' \code{\link[base]{factor}} via \code{\link{as.factor}}) that assigns a
#' group/class label to each observation in \code{X}. The labels are taken into
#' account for cross-validation for factor optimization to avoid
#' pseudo-replication. When an observation is selected for validation during the
#' cross-validation procedure, all observations of the same group are assigned
#' to validation set. For example, groups can be given by spectra collected from
#' the same batch of measurements, from the same observation, from observations
#' with very similar origin, etc. The length of this argument must be equal to
#' the number of observations in \code{Y}.
#' @param method an object of class \code{\link{fit_constructors}} indicating what type of regression
#' method to use along with its parameters. See \code{\link{fit_constructors}}.
#' @param control a \code{\link{calibration_control}} object indicating how the
#' calibration process should be conducted (e.g. cross-validation, outlier
#' detection, parallel computing, etc).
#' @param verbose a logical indicating whether or not to print a progress bar
#' for the iterations of the validation along with messages of the execution of
#' the cross-validation. Default is \code{TRUE}. Note: In case parallel
#' processing is used, these progress bars are not printed.
#' @author Leonardo Ramirez-Lopez
#' @examples
#' data("NIRcannabis")
#' # Convert THCA to matrix
#' Y <- matrix(NIRcannabis$THCA, ncol = 1)
#' X <- NIRcannabis$spc
#' method <- fit_plsr(10)
#'
#' # Control for leave-group-out CV 100 times with 90% sample retainment, with replacements
#' control_rlgo <- calibration_control(
#'   validation_type = "lgo", number = 100,
#'   p = 0.9, replacements = TRUE
#' )
#' # Control for leave-group-out CV 5 times with 80% sample retainment, no replacements
#' control_lgo <- calibration_control("lgo", number = 5, p = 0.8, replacements = FALSE)
#' # Control for leave-one-out CV
#' control_loo <- calibration_control("loo")
#' # Control for 10-fold CV with random sampling
#' control_kfold <- calibration_control("kfold", number = 10, folds = "random")
#'
#' model1 <- .calibrate_cv(X, Y, method = method, control = control_rlgo, verbose = FALSE)
#' # Leave-group-out with samples split in half
#' model2 <- .calibrate_cv(X, Y,
#'   group = rep(1:2, 40), method = method,
#'   control = control_lgo, verbose = FALSE
#' )
#' model3 <- .calibrate_cv(X, Y, method = method, control = control_loo, verbose = FALSE)
#' model4 <- .calibrate_cv(X, Y, method = method, control = control_kfold, verbose = FALSE)
#' @return A list with up to two elements, dependent on the chosen
#' \code{validation_type} inside the \code{control} argument.\cr
#' For leave-one-out (\code{"loo"}) and k-fold (\code{"kfold"}): a list with
#' two elements: \itemize{
#'      \item{\code{grid}:} { A matrix, containing information on the performance
#'      of the applied cross-validation procedure with the following columns:
#'      \itemize{
#'           \item{\code{ncomp}:} { The number of components included.}
#'           \item{\code{rsq}:} { The coefficient of determination based on the
#'           cross-validation estimates for every component.}
#'           \item{\code{rmse}:} { The root mean-squared-error of the
#'           cross-validation estimates for every component.}
#'           \item{\code{largest_residual}:} { The largest residual based on the
#'           cross-validation estimates for every component.}
#'           }
#'      }
#'      \item{\code{predicted}:} { A matrix, containing the cross-validation
#'      predictions for every observation and component. These estimates are
#'      calculated while the corresponding observations are in the validation
#'      set, i.e. the model was trained without these specific observations.}
#' }
#' For leave-group-one (\code{"lgo"}):
#' a list with one element: \itemize{
#'      \item{\code{grid}:} {A matrix, containing information on the performance
#'      of the applied procedure with the following columns:
#'      \itemize{
#'           \item{\code{ncomp}:} { The number of components included.}
#'           \item{\code{rsq}:} { The mean of the obtained coefficients of
#'           determination in all iterations.}
#'           \item{\code{rmse}:} { The mean of the obtained root
#'           mean-squared-errors in all iterations.}
#'           \item{\code{largest_residual}:} { The mean of the obtained largest
#'           residuals in all iterations.}
#'           \item{\code{rsq_sd}:} { The standard deviation of the obtained
#'           coefficients of determination in all iterations.}
#'           \item{\code{rmse_sd}:} { The standard deviation of the obtained
#'           root mean-squared-errors in all iterations.}
#'           \item{\code{largest_residual_sd}:} { The standard deviation of the
#'           obtained largest residuals in all iterations.}
#'           }
#'      }
#' }
#' @details
#' This function performs cross-validation for parameter-tuning of a partial
#' least squares (pls) or extended partial least squares (xls). Cross-validation
#' can also provide reasonable insights in how well the model might perform on
#' a new dataset.
#'
#' Note that this function will throw an error if called directly with
#' \code{validation_type} set to \code{"none"}.
#'
#' For more details on the specific cross-validation types, see the details of
#' \code{\link{calibration_control}}.
#'
#' For more details on the specific method, see \code{\link{fit_plsr}},
#' \code{\link{fit_xlsr}}.
#' @noRd
.calibrate_cv <- function(X, Y, group = NULL, method, control, verbose = TRUE) {
  if (any(is.na(X))) {
    stop("Missing values in X are not allowed")
  }
  if (any(is.na(Y))) {
    stop("Missing values in Y are not allowed")
  }
  if (!is.matrix(X)) {
    stop("'X' must be a matrix.")
  }
  if (!is.matrix(Y)) {
    stop("'Y' must be a matrix.")
  }
  if (!inherits(method, "fit_constructor")) {
    stop("'method' must be of class 'fit_constructor'")
  }
  if (!inherits(control, "calibration_control")) {
    stop("'control' must be of class 'calibration_control'")
  }
  if (!is.logical(verbose)) {
    stop("'verbose' must be a logical")
  }
  if (control$validation_type == "none") {
    stop("This function requires a 'validation_type' in 'control' that is not 'none'.")
  }
  "%mydo%" <- get("%do%")
  if (control$allow_parallel & getDoParRegistered()) {
    "%mydo%" <- get("%dopar%")
  }
  if (control$validation_type == "lgo") {
    cv_sets <- sample_stratified(
      y = Y,
      p = control$p,
      number = control$number,
      group = group,
      replacement = control$replacements,
      seed = control$seed
    )
  }

  if (control$validation_type == "loo") {
    cv_sets <- sample_loo(nrow(X), group = group)
  }
  if (control$validation_type == "kfold") {
    cv_sets <- sample_kfold(
      nrow(X),
      group = group,
      number = control$number,
      sampling = control$folds,
      seed = control$seed
    )
  }
  cv_residuals <- cv_preds <- NULL
  # if (control$validation_type %in% c("loo", "kfold")) {
  #   cv_preds_template <- matrix(NA, nrow(X), method$ncomp)
  # }

  if (verbose) {
    cat("\033[3mCross-validating...\n\033[23m\033[39m")
    pb <- txtProgressBar(min = 0, max = ncol(cv_sets$hold_in), char = "-", style = 3)
  }
  results_template <- matrix(NA, method$ncomp, 4)
  results_template[, 1] <- 1:method$ncomp
  colnames(results_template) <- c("ncomp", "rsq", "rmse", "largest_residual")
  ith <- NULL
  pred_results <- foreach(
    ith = 1:ncol(cv_sets$hold_in),
    .inorder = FALSE,
    .export = c(
      "estimate_basic_pls", "predict.spectral_fit"
    )
  ) %mydo% {
    ith_results <- results_template
    ith_cal_set <- cv_sets$hold_in[, ith]
    ith_val_set <- cv_sets$hold_out[, ith]

    ith_cal_set <- ith_cal_set[!is.na(ith_cal_set)]
    ith_val_set <- ith_val_set[!is.na(ith_val_set)]

    ith_fit <- estimate_basic_pls(
      X = X[ith_cal_set, , drop = FALSE], Y = Y[ith_cal_set, , drop = FALSE],
      method = method
    )
    ith_pred <- predict.spectral_fit(ith_fit, X[ith_val_set, , drop = FALSE])
    result <- list(iteration = ith)

    if (control$validation_type %in% c("loo", "kfold")) {
      cv_preds <- matrix(
        NA,
        length(ith_val_set),
        1 + method$ncomp
      )
      cv_preds[, 1] <- ith_val_set
      cv_preds[, -1] <- ith_pred$predictions
      result$cv_preds <- cv_preds
    } else {
      ith_cv_rsqs <- cor(Y[ith_val_set], ith_pred$predictions)^2
      ith_residuals <- sweep(ith_pred$predictions, MARGIN = 1, FUN = "-", STATS = Y[ith_val_set])
      ith_cv_max <- apply(abs(ith_residuals), MARGIN = 2, FUN = function(x) x[which.max(x)])
      ith_cv_rmse <- sqrt(colSums(ith_residuals^2) / max((nrow(ith_residuals) - 1), 1))
      ith_results[, 2] <- ith_cv_rsqs
      ith_results[, 3] <- ith_cv_rmse
      ith_results[, 4] <- ith_cv_max
      result$ith_results <- ith_results
    }
    if (verbose) {
      setTxtProgressBar(pb, ith)
    }
    result
  }
  list_order <- sapply(pred_results, FUN = function(x) x[[1]])
  pred_results <- lapply(list_order, FUN = function(x, ith) x[[ith]][[2]], x = pred_results)
  pred_results <- do.call("rbind", pred_results)
  results_cv <- NULL
  if (control$validation_type %in% c("loo", "kfold")) {
    pred_results <- pred_results[order(pred_results[, 1]), -1, drop = FALSE]
    results_template[, 2] <- cor(Y, pred_results)^2

    residuals <- sweep(pred_results, MARGIN = 1, FUN = "-", STATS = Y)
    results_template[, 4] <- apply(abs(residuals), MARGIN = 2, FUN = function(x) x[which.max(x)])
    results_template[, 3] <- sqrt(colSums(residuals^2) / max(nrow(residuals) - 1, 1))
    results_cv$grid <- results_template
    results_cv$predicted <- pred_results
  } else {
    results_cv_mean <- aggregate(pred_results[, -1],
      by = list(ncomp = pred_results[, "ncomp"]),
      FUN = "mean"
    )

    results_cv_sd <- aggregate(pred_results[, -1],
      by = list(ncomp = pred_results[, "ncomp"]),
      FUN = "sd"
    )[, -1]
    colnames(results_cv_sd) <- paste0(colnames(results_cv_sd), "_sd")
    results_cv$grid <- cbind(results_cv_mean, results_cv_sd)
  }
  rownames(results_cv$grid) <- 1:nrow(results_cv$grid)
  if (verbose) {
    close(pb)
  }
  results_cv
}
