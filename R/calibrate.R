#' @title Calibrate a spectral model
#' @aliases calibrate
#' @aliases calibrate.default
#' @aliases calibrate.formula
#' @aliases predict.spectral_model
#'
#' @description
#'
#' \loadmathjax
#'
#' Produce calibrations for predictive partial least squares (pls) or extended
#' partial least squares (xls) models using cross-validation and outlier
#' detection. Reproduces the modeling methods in NIRWise PLUS calibration
#' software.
#'
#' @usage
#'
#' \method{calibrate}{formula}(formula, data, group = NULL,
#'           preprocess = preprocess_recipe(prep_snv()),
#'           method,
#'           metadata = NULL,
#'           return_inputs = TRUE,
#'           ...,
#'           na_action = na.pass)
#'
#' \method{calibrate}{default}(X, Y, data = NULL, group = NULL,
#'           preprocess = preprocess_recipe(prep_snv()),
#'           method = fit_plsr(ncomp = min(15, dim(X))),
#'           control = calibration_control(),
#'           metadata = NULL,
#'           skip_indices = NULL,
#'           return_inputs = TRUE,
#'           verbose = TRUE,
#'           ...)
#'
#' \method{predict}{spectral_model}(object, newdata, ncomp = object$final_ncomp, verbose = TRUE, ...)
#'
#' @param formula an object of class \code{\link[stats]{formula}} which represents the
#' basic model to be calibrated.
#' @param data a data.frame containing the data of the variables in
#' the model. Must be provided if using S3 method for class \code{\link[stats]{formula}}.
#' Otherwise, optional; however, if using \code{\link{proximate_write_nax}} for the
#' returned object, this parameter will be required.
#' @param X a numeric matrix of spectral data. The names of the columns must be
#' equivalent to wavelengths, such that they can be coerced to class numeric.
#' @param Y a matrix of one column with the response variable. The column must
#' be named.
#' @param group an optional factor (or character vector that can be coerced to
#' \code{\link[base]{factor}} by \code{as.factor}) that assigns a group/class
#' label to each observation in \code{X} (e.g. groups can be given by spectra
#' collected from the same batch of measurements, from the same observation,
#' from observations with very similar origin, etc). This is taken into account
#' for cross-validation for pls tuning (factor optimization) to avoid pseudo-
#' replication. When one observation is selected for cross-validation, all
#' observations of the same group are removed and assigned to validation.
#' The length of the vector must be equal to the number of observations in
#' \code{X}.
#' @param preprocess a \code{preprocess_recipe} object as returned by the
#' \code{\link{preprocess_recipe}} function, indicating the pretreatments to
#' be applied on the spectra before the regression steps.
#' @param method an object of class \code{fit_constructor}, as returned by
#' \code{\link{fit_plsr}} or \code{\link{fit_xlsr}}, indicating what type of
#' regression method to use along with its parameters.
#' @param control a \code{calibration_control} object as returned by the
#' \code{\link{calibration_control}} function, indicating how some aspects of
#' the calibration process must be conducted (e.g. cross-validation and outlier
#' detection).
#' @param metadata either \code{NULL} or an object as returned by method
#' \code{\link{add_model_metadata}}. Contains the specifications for the metadata
#' of the model. Defaults to \code{NULL}.
#' @param skip_indices a vector of integers for the indices in the input data to be
#' skipped for the regression. Defaults to \code{NULL}
#' @param return_inputs a logical. For \code{calibrate} methods, indicates if
#' the input data should be attached to the returned object. Note that this data
#' is crucial for creating an application file.
#' @param verbose a logical indicating whether or not to print a progress bar
#' for the iterations of the validation along with messages of the execution of
#' the cross-validation. For the predict method, messages about the progress are
#' printed. Default is \code{TRUE}. Note: In case parallel processing is used,
#' these progress bars are not printed.
#' @param object an object of class \code{spectral_model}.
#' @param newdata a data.frame containing the new spectral data of the variables
#' in the model, of similar form as \code{data}. Alternatively, can also be
#' a matrix of spectra.
#' @param ncomp a vector for the number of components to be used in the prediction.
#' Default is \code{object$final_ncomp} i.e. the optimized number of components
#' found in the object passed to \code{predict}.
#' @param ... not currently used.
#' @param na_action  a function to specify the action to be taken if \code{NA}s are
#' found in the object passed in \code{data}. Default is \code{\link{na.pass}}.
#'
#' @author Leonardo Ramirez-Lopez and Claudio Orellano
#'
#' @return For \code{calibrate()}, an object of class \code{spectral_model} which
#' is a list with the following elements:
#' \itemize{
#'     \item \strong{\code{formula}}: The formula used (only output if the S3 method
#'     for class \code{'formula'} was used).
#'     \item \strong{\code{dataclasses}}: The data classes in the model (only output
#'     if the S3 method for class \code{'formula'} was used).
#'     \item \strong{\code{target_variable}}: A character for the name of the
#'     target/response variable for which the predictive model was built.
#'     \item \strong{\code{predictor_variables}}: A character vector for names of the
#'     predictor variables (wavelengths) used to build the model.
#'     \item \strong{\code{final_model}}: A list with: \itemize{
#'         \item \strong{\code{model_cv}}: A list of cross-validation results.
#'         \item \strong{\code{ncomp}}: The number of components used for the model.
#'         If cross-validation is used, this is the optimal number of components
#'         for the chosen tuning parameter and learning rates (see
#'         \code{\link{calibration_control}}).
#'         \item \strong{\code{model}}: An object of class \code{spectral_fit}.
#'         See \code{\link{spectral_fit}} for the full structure.
#'         \item \strong{\code{calibration_statistics}}: A matrix showing the
#'         prediction statistics for each calibration sample for the
#'         optimal number of components used in the model (if cross-validation
#'         is used, see \code{\link{calibration_control}}). It contains the
#'         following columns: \itemize{
#'              \item \strong{\code{Sample_index}}: The indices of the samples.
#'              \item \strong{\code{Target}}: The target/response variable of the
#'              samples.
#'              \item \strong{\code{fitted_y}}: The fitted values of the model of each
#'              sample. This row is equivalent to the row of the optimal
#'              component of \code{fitted_y} inside the fitted model in
#'              \code{model}.
#'              \item \strong{\code{residual}}: The residuals of the fitted values of
#'              each sample. Note that the residuals are obtained as the
#'              difference of targets and fitted values.
#'              \item \strong{\code{predicted_y_in_cv}}: The predicted values as
#'              computed in the cross-validation. Only available for k-fold
#'              and leave-one-out cross-validation.
#'              \item \strong{\code{cv_residual}}: The residuals of the predicted
#'              values of the cross-validation. Only available for k-fold
#'              and leave-one-out cross-validation.
#'              \item \strong{\code{Mahalanobis}}: The squared Mahalanobis distance of each
#'              sample in the score space to the origin.
#'              \item \strong{\code{Q_value}}: The Q-value of each sample. See details
#'              }
#'         \item \strong{\code{calibration_statistics_all}}: A list of matrices with
#'         the same information as in \code{calibration_statistics}, but for all
#'         components.
#'         \item \strong{\code{detected_outliers_all}}: A list of lists, each
#'         containing the same information as in the \code{detected_outliers$model_*}
#'         mentioned below, but for all components in the fitted model.
#'         }
#'     \item \strong{\code{detected_outliers}}: A named list, containing the following
#'     entries:
#'         \itemize{
#'             \item \strong{\code{model_*}}: A named list, containing all detected outliers
#'             of the particular model, identified based on the calibration residual
#'             limit (\code{"calibration"}), the Mahalanobis distance limit
#'             (\code{"Mahalanobis"}), and the validation residual limit
#'             (\code{"validation"}). The number of such \code{model_*} entries
#'             depends on the number selected in \code{remove_outliers} of the
#'             \code{control} argument; if it is selected to be \code{0}, then
#'             only one model is fitted,  so only \code{model_1} exists; for higher
#'             choices of \code{remove_outliers}, the number of models of this list
#'             is at most \code{remove_outliers + 1}: for every time a model
#'             is fitted, a new entry in the \code{detected_outliers} is generated.
#'             \item \strong{\code{all}}: A named list, containing all detected outliers of
#'             all models produced, similarly to \code{model_*}. In particular,
#'             this entry is the combination of all detected outliers in the \code{model_*}
#'             entries of the list, where the specific type of outlier is retained.
#'             \item \strong{\code{removed}}: A single vector, containing all removed
#'             outliers of the final model. This vector is empty whenever the
#'             \code{remove_outliers} of the \code{control} argument is set to 0
#'             or if no outlier has been found. Otherwise, this vector is a combination
#'             of all different outliers that were removed whenever a new model
#'             has been fitted, while ignoring the specific type of the outlier.
#'             In particular, in case the last model still contains at least one
#'             outlier, this vector is a combination of all but the last entry of
#'             the \code{model_*} lists. If the last fitted model does not contain
#'             any outlier, this vector is a combination of all \code{model_*} lists,
#'             and hence the vectorized form of the \code{all} entry of the list.
#'             }
#'         See \code{\link{calibration_control}} for more information on the
#'         limits and the outlier removal procedure.
#'     \item \strong{\code{initial_fit}}: A list similar to
#'     \code{final_model}, but before any outliers were removed. Only stored
#'     if outlier removal is requested (i.e. \code{remove_outliers} in the
#'     \code{control} argument is larger than 0). In that case, the model
#'     here contains only the very first model that was fitted without any detected
#'     outliers removed.
#'     \item \strong{\code{final_ncomp}}: An integer, indicating the final/optimal
#'     number of components to be used.
#'     \item \strong{\code{preprocess}}: A \code{preprocess_recipe} object mirroring the
#'     input of the \code{preprocess} argument.
#'     \item \strong{\code{processed_wavs}}: A \code{processed_wavs} object
#'     providing the spectral variables that existed in the data right before
#'     each preprocessing step.
#'     \item \strong{\code{method}}: A \code{fit_constructor} object mirroring the input of
#'     the \code{method} argument.
#'     \item \strong{\code{control}}: A \code{calibration_control} object mirroring
#'     the input of the \code{control} argument.
#'     \item \strong{\code{preprocessed_X}}: The preprocessed spectral data for
#'     the observations of the final model. Spectra with missing values, skipped
#'     indices and removed outliers are discarded from the matrix.
#'     \item \strong{\code{skipped_indices}}: A list with two objects: \itemize{
#'          \item \strong{\code{missing_response}}: A vector of indices of observations
#'          with missing response values.
#'          \item \strong{\code{manually_skipped}}: A vector of indices mirroring the
#'          input of the \code{skip_indices} argument.
#'          }
#'     \item \strong{\code{input_data}}: A list, which is only returned if
#'     \code{return_inputs} is set to \code{TRUE}. Mirrors the input of the
#'     \code{data} argument.
#' }
#'
#' For \code{predict()}, the output is an object
#' of class \code{spectral_prediction}, which is a list with the following elements:
#' \itemize{
#'     \item \strong{\code{predictions}}: A matrix with the predictions of the response
#'     variable using the new spectral data (\code{newdata}), based on the
#'     provided model (\code{object}). Contains only the predictions of the
#'     requested number of components (\code{ncomp}).
#'     \item \strong{\code{scores}}: A matrix with the projected new data onto the
#'     score space of the provided model. Contains the scores of all possible
#'      number of components.
#'     \item \strong{\code{model_information}}: A list, containing information on the
#'     model input of \code{object}: \itemize{
#'          \item \strong{\code{target_var}}: A character, indicating the name of the
#'          target variable.
#'          \item \strong{\code{preprocess_recipe}}: A character, indicating the spectral
#'          preprocessing recipe and its order.
#'          \item \strong{\code{model_grid}}: A matrix, containing the grid of the model
#'          object, such as the coefficient of determination and the RMSE of the
#'          validation for the requested number of components.
#'          \item \strong{\code{unit}}: A character, indicating the units of the model.
#'          \item \strong{\code{opt_comp}}: An integer, signifying the optimal number
#'          of components as computed by the validation process of the model.
#'     }}
#' @details
#' The resulting object of the \code{calibrate} functions provides a
#' complete list of calibration results.
#'
#' By using the \code{group} argument one can specify groups of observations that
#' have something in common (e.g. observations with very similar origin).
#' The purpose of \code{group} is to avoid biased cross-validation results due
#' to pseudo-replication. This argument allows to select calibration points
#' that are independent from the validation ones. In this regard, the \code{p}
#' argument used in object passed to \code{control} (and created with the
#' \code{\link{calibration_control}} function), refers to the percentage of
#' groups of observations (rather than single observations) to be retained in
#' each sampling iteration.
#'
#' The regression algorithms implemented here correspond to the partial least
#' squares ("pls") and extended partial least squares ("xls") methods in NIRWise
#' PLUS calibration software. Note that in these particular regression
#' algorithms, the Y-loading of each component is constantly equal to 1, and
#' therefore not considered.
#'
#' The \code{calibration_statistics} matrix retrieved in the \code{final_model}
#' and also in the \code{initial_fit} outputs includes a column named
#' \code{Q_value}. This value can be used to asses model overfitting. For each
#' observation, \mjeqn{q_i}{q_i} is computed as follows:
#'
#' \mjdeqn{s = \sqrt{ \frac{\sum_{i=1}^{n} (y_j - \hat{y}_j)^2} {n - 1}}}{s = sqrt({sum(y_i - haty_i)^2}/(n - 1))}
#'
#' \mjdeqn{q_i = \frac{\left |2 y_i - \hat{y}_i -  \ddot{y}_i  \right |} {s}}{q_i = abs(2 y_i - haty_i -  ddoty_i)/s}
#'
#' where for ith observation, \mjeqn{y}{y} is the observed value,
#' \mjeqn{\hat{y}}{haty} is the fitted value (using a model with all the
#' observations) and \mjeqn{\ddot{y}}{ddoty} is the predicted value during
#' cross-validation.
#'
#' @section Parallel cross-validation:
#' The cross-validation loop is implemented with
#' \code{\link[foreach]{foreach}}, so it can be parallelised transparently by
#' registering a parallel backend before calling \code{calibrate}. Set
#' \code{allow_parallel = TRUE} in \code{\link{calibration_control}} (the
#' default) and register a backend, for example:
#'
#' \preformatted{
#' cl <- parallel::makeCluster(parallel::detectCores() - 1L)
#' doParallel::registerDoParallel(cl)
#'
#' model <- calibrate(...)
#'
#' parallel::stopCluster(cl)
#' }
#'
#' When no parallel backend is registered, \code{foreach} falls back silently to
#' sequential execution regardless of the \code{allow_parallel} setting.
#' Note that progress bars are suppressed during parallel execution.
#'
#' @seealso
#' \code{\link{preprocess_recipe}},
#'
#' \code{\link{fit_plsr}},
#'
#' \code{\link{fit_xlsr}},
#'
#' \code{\link{calibration_control}},
#'
#' \code{\link{calibrate_models}}
#'
#' @examples
#' \donttest{
#' data("NIRcannabis")
#' simple_model <- calibrate(CBDA ~ spc,
#'   data = NIRcannabis, preprocess = preprocess_recipe(prep_snv()),
#'   method = fit_xlsr(5), control = calibration_control("kfold"),
#'   verbose = FALSE
#' )
#'
#' method <- fit_plsr(15)
#' control <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential")
#' pretreats <- preprocess_recipe(
#'   prep_resample(grid = c(1001, 1700, 5)),
#'   prep_derivative(m = 2, w = 9, p = 5, algorithm = "nwp"),
#'   prep_snv(),
#'   prep_smooth(w = 5, algorithm = "moving-average"),
#'   device = "proximate"
#' )
#' skip_indices <- c(5, 13, 21, 73)
#' # With formula
#' complex_model_formula <- calibrate(
#'   CBDA ~ spc,
#'   data = NIRcannabis, preprocess = pretreats, method = method,
#'   control = control, skip_indices = skip_indices, verbose = FALSE
#' )
#' # Default, need care with Y
#' Y <- matrix(NIRcannabis$CBDA)
#' colnames(Y) <- "CBDA"
#' complex_model_default <- calibrate(
#'   X = NIRcannabis$spc, Y = Y, data = NIRcannabis, preprocess = pretreats,
#'   method = method, control = control, skip_indices = skip_indices, verbose = FALSE
#' )
#'
#' # Predict the skipped indices
#' predict(complex_model_formula,
#'   newdata = NIRcannabis[skip_indices, ],
#'   ncomp = complex_model_formula$final_ncomp,
#'   verbose = FALSE
#' )
#' }
#' @export


"calibrate" <-
  function(...) {
    UseMethod("calibrate")
  }


#' @aliases calibrate
#' @export
calibrate.default <- function(X, Y, data = NULL, group = NULL,
                              preprocess = preprocess_recipe(prep_snv()),
                              method = fit_plsr(ncomp = min(15, dim(X))),
                              control = calibration_control(),
                              metadata = NULL,
                              skip_indices = NULL,
                              return_inputs = TRUE,
                              verbose = TRUE, ...) {
  if (!is.matrix(Y)) {
    stop("Y must be a matrix of one column")
  }

  if (!is.matrix(X)) {
    stop("X must be a matrix")
  }

  if (ncol(Y) > 1) {
    stop("Y must be a matrix of one column")
  }

  if (is.null(colnames(Y))) {
    stop("Missing variable/column name in Y")
  }
  if (!is.null(data)) {
    if (!any(c("proximate_data", "proxiscout_data") %in% class(data))) {
      warning("Object 'data' is not of class 'proximate_data' or 'proxiscout_data'. This can result in errors when creating an application.\n")
    }
  }
  if (!inherits(preprocess, "preprocess_recipe")) {
    stop("Parameter 'preprocess' must be of class 'preprocess_recipe'.")
  }
  if (!inherits(method, "fit_constructor")) {
    stop("Parameter 'method' must be of class 'fit_constructor'.")
  }
  if (!inherits(control, "calibration_control")) {
    stop("Parameter 'control' must be of class 'calibration_control'.")
  }
  if (!is.null(metadata)) {
    if (!any(class(metadata) %in% "model_metadata")) {
      stop("'metadata' must be of class 'model_metadata' if provided.")
    }
  }
  if (!is.null(skip_indices)) {
    if (any(!is.numeric(skip_indices))) {
      stop("'skip_indices' must be a numeric vector.")
    }
  }
  if (!is.logical(return_inputs)) {
    stop("'return_inputs' must be a logical.")
  }
  if (!is.logical(verbose)) {
    stop("'verbose' must be a logical.")
  }

  original_indices <- 1:nrow(Y)
  missing_response <- which(is.na(Y))
  to_skip <- unique(sort(c(missing_response, skip_indices)))

  if (any(!skip_indices %in% original_indices)) {
    wh <- which(!skip_indices %in% original_indices)
    warning(paste0("Unable to skip index ", skip_indices[wh], ", as it lies outside the considered indices."))
  }

  indices_for_fit <- original_indices[!original_indices %in% to_skip]
  if (verbose) {
    if (any(is.na(Y))) {
      mss <- paste0(
        "\033[0;33m\033[3m", sum(is.na(Y)),
        " observation(s) with missing response value(s). ",
        "Holding this data out for fitting. \n\033[23m\033[39m"
      )

      cat(mss)
    }
  }

  X_sub <- X[indices_for_fit, , drop = FALSE]
  Y <- Y[indices_for_fit, , drop = FALSE]

  Xp <- process(X_sub, preprocess)

  processed_wavs <- attr(Xp, "processed_wavs")

  wavs <- colnames(X)
  if (is.null(wavs)) {
    stop("Missing variable/column names in X")
  }

  if (any(!is_numeric_like(wavs))) {
    stop("Column names in X must be formed only by numbers")
  }

  results <- NULL
  results$target_variable <- colnames(Y)
  results$predictor_variables <- colnames(Xp)

  if (nrow(X) <= method$ncomp) {
    stop("The number of observations is less than (or equal to) the number of components in 'method'")
  }

  if (control$validation_type %in% c("kfold", "lgo")) {
    n_per_group <- ifelse(control$validation_type == "kfold",
      floor(nrow(Xp) / control$number),
      floor(nrow(Xp) * control$p)
    )
    if (n_per_group <= method$ncomp) {
      if (!control$validation_type %in% "lgo" || !control$replacements) {
        stop("The number of observations in each cross-validation segment is less than the number of components in 'method'")
      }
    }
  }

  if (verbose) {
    cat("\033[1;32m\033[3mFitting model...\n\033[0m")
  }

  fitted_model <- .calibrate_basic(
    X = Xp, Y = Y, group = group,
    method = method,
    control = control,
    return_inputs = return_inputs,
    sample_labels = indices_for_fit,
    verbose = verbose
  )

  results$final_model <- fitted_model

  cal_stats <- fitted_model$calibration_statistics
  fit_outliers <- which(abs(scale(cal_stats[, "residual"], TRUE, TRUE)) >= control$cal_residual_limit)
  mahal_outliers <- which(cal_stats[, "Mahalanobis"] >= control$mahalanobis_limit)

  val_outliers <- NULL
  if (control$validation_type %in% c("loo", "kfold")) {
    val_outliers <- which(abs(scale(cal_stats[, "cv_residual"], TRUE, TRUE)) >= control$val_residual_limit)
  }
  detected_outliers <- list(
    calibration = fit_outliers,
    Mahalanobis = mahal_outliers,
    validation = val_outliers
  )

  detected_outliers_ini <- list(
    calibration = indices_for_fit[fit_outliers],
    Mahalanobis = indices_for_fit[mahal_outliers],
    validation = indices_for_fit[val_outliers]
  )

  cal_stats_all <- fitted_model$calibration_statistics_all
  detected_outliers_all <- list()
  for (i in 1:method$ncomp) {
    fit_outliers <- which(abs(scale(cal_stats_all$residual[, i], TRUE, TRUE)) >= control$cal_residual_limit)
    mahal_outliers <- which(cal_stats_all$Mahalanobis[, i] >= control$mahalanobis_limit)

    val_outliers <- NULL
    if (control$validation_type %in% c("loo", "kfold")) {
      val_outliers <- which(abs(scale(cal_stats_all$cv_residual[, i], TRUE, TRUE)) >= control$val_residual_limit)
    }
    detected_outliers_all[[paste0("ncomp_", i)]] <- list(
      calibration = indices_for_fit[fit_outliers],
      Mahalanobis = indices_for_fit[mahal_outliers],
      validation = indices_for_fit[val_outliers]
    )
  }
  results$detected_outliers <- list()
  # Stores all detected outliers over all iterations.
  results$detected_outliers$all <- detected_outliers_ini
  results$detected_outliers$removed <- integer()
  # Store detected outliers for the first iteration.
  results$detected_outliers[["model_1"]] <- detected_outliers_ini
  # Store all outliers for each component for the initial model. This is only
  # used in the report generation. In case reports are changed such that this
  # information is not needed, this may be removed.
  results$final_model$detected_outliers_all <- detected_outliers_all

  remove_outliers <- control$remove_outliers
  results$final_ncomp <- fitted_model$ncomp

  # Iterator to count the number of models computed during refitting.
  refit_iter <- 2
  final_indices_xp <- 1:nrow(Xp)


  # Start refitting models if requested
  while (remove_outliers > 0) {
    # Indices of outliers, internal indexing used.
    indices_outliers <- sort(unique(unlist(detected_outliers)))
    # Indices corresponding to the Xp that is passed to .calibrate_basic.
    indices_in_xp <- setdiff(1:nrow(Xp), indices_outliers)

    if (length(indices_outliers) > 0) {
      if (verbose) {
        cat("\033[0;91m\033[3mRe-fitting model (removed a total of", length(indices_outliers), "detected outliers)...\n\033[23m\033[39m")
      }
      rem_len <- length(indices_in_xp)
      if (rem_len <= method$ncomp) {
        if (verbose) {
          msg <- paste(
            "\033[0;91m\033[3mThe number of samples for fitting without outliers fell below",
            "the number of components, therefore the outlier removal has",
            "been aborted.\n\033[23m\033[39m"
          )
          cat(msg)
        }
        break
      }

      if (control$validation_type %in% c("kfold", "lgo")) {
        n_per_group <- ifelse(
          control$validation_type == "kfold",
          floor(rem_len / control$number),
          floor(rem_len * control$p)
        )
        if (n_per_group <= method$ncomp) {
          if (!control$validation_type %in% "lgo" || !control$replacements) {
            if (verbose) {
              msg <- paste(
                "\033[0;91m\033[3mThe number of samples for fitting without outliers fell below",
                "the number of components, therefore the outlier removal has",
                "been aborted.\n\033[23m\033[39m"
              )
              cat(msg)
            }
            break
          }
        }
      }

      # Record the removed outliers
      results$detected_outliers$removed <- indices_for_fit[indices_outliers]

      refitted_model <- .calibrate_basic(
        X = Xp[indices_in_xp, ],
        Y = Y[indices_in_xp, , drop = FALSE],
        group = group[indices_in_xp],
        method = method,
        control = control,
        return_inputs = FALSE,
        verbose = verbose
      )

      # Store indices for final Xp
      final_indices_xp <- indices_in_xp

      # Indices correspond to original matrix X passed to the function
      indices_for_refit <- indices_for_fit[indices_in_xp]
      refitted_model$calibration_statistics[, 1] <- indices_for_refit
      refitted_model$calibration_statistics_all$Sample_index <- indices_for_refit


      re_cal_stats <- refitted_model$calibration_statistics
      re_fit_outliers <- which(abs(scale(re_cal_stats[, "residual"], TRUE, TRUE)) >= control$cal_residual_limit)
      re_mahal_outliers <- which(re_cal_stats[, "Mahalanobis"] >= control$mahalanobis_limit)

      re_val_outliers <- NULL
      if (control$validation_type %in% c("loo", "kfold")) {
        re_val_outliers <- which(abs(scale(re_cal_stats[, "cv_residual"], TRUE, TRUE)) >= control$val_residual_limit)
      }

      detected_outliers_refit <- list(
        calibration = indices_in_xp[re_fit_outliers],
        Mahalanobis = indices_in_xp[re_mahal_outliers],
        validation = indices_in_xp[re_val_outliers]
      )
      detected_outliers_refit_ini <- list(
        calibration = indices_for_refit[re_fit_outliers],
        Mahalanobis = indices_for_refit[re_mahal_outliers],
        validation = indices_for_refit[re_val_outliers]
      )

      re_cal_stats_all <- refitted_model$calibration_statistics_all
      detected_outliers_refit_all <- list()
      for (i in 1:method$ncomp) {
        re_fit_outliers <- which(abs(scale(re_cal_stats_all$residual[, i], TRUE, TRUE)) >= control$cal_residual_limit)
        re_mahal_outliers <- which(re_cal_stats_all$Mahalanobis[, i] >= control$mahalanobis_limit)

        re_val_outliers <- NULL
        if (control$validation_type %in% c("loo", "kfold")) {
          re_val_outliers <- which(abs(scale(re_cal_stats_all$cv_residual[, i], TRUE, TRUE)) >= control$val_residual_limit)
        }

        detected_outliers_refit_all[[paste0("ncomp_", i)]] <- list(
          calibration = indices_for_refit[re_fit_outliers],
          Mahalanobis = indices_for_refit[re_mahal_outliers],
          validation = indices_for_refit[re_val_outliers]
        )
      }

      # Update detected outliers all
      cumulative_outliers <- Map(c, results$detected_outliers$all, detected_outliers_refit_ini)
      results$detected_outliers$all <- Map(sort, cumulative_outliers)
      results$detected_outliers[[paste0("model_", refit_iter)]] <- detected_outliers_refit_ini

      # At this point, we overwrite the final model and store the original model
      # in results$initial_fit if it does not yet exist.
      if (is.null(results$initial_fit)) {
        results$initial_fit <- results$final_model
      }

      results$final_model <- refitted_model
      results$final_ncomp <- refitted_model$ncomp
      results$final_model$detected_outliers_all <- detected_outliers_refit_all

      detected_outliers <- Map(c, detected_outliers, detected_outliers_refit)
      detected_outliers <- Map(sort, detected_outliers)

      # Loop iterators
      remove_outliers <- remove_outliers - 1
      refit_iter <- refit_iter + 1

      # Break loop if no additional outliers found
      if (length(unique(unlist(detected_outliers_refit_ini))) < 1) {
        if (verbose) {
          cat("\033\033[3mNo further outliers detected!\n\033[23m\033[39m")
        }
        break
      }
    } else {
      results$final_ncomp <- fitted_model$ncomp
      if (verbose) {
        cat("\033\033[3mNo outliers detected!\n\033[23m\033[39m")
      }
      break
    }
  }

  results$preprocess <- preprocess
  results$processed_wavs <- processed_wavs
  results$method <- method
  results$control <- control

  if (!is.null(metadata)) {
    if (metadata$Name == "") {
      metadata$Name <- results$target_variable
    }
  }
  results$metadata <- metadata

  results$preprocessed_X <- Xp[final_indices_xp, , drop = FALSE]
  results$skipped_indices <- list(
    missing_response = missing_response,
    manually_skipped = skip_indices
  )

  if (return_inputs) {
    results$input_data <- NULL
    results$input_data$data <- data
  }

  class(results) <- c("spectral_model", "list")

  rownames(X) <- NULL
  attr(results, "data_hash") <- digest::digest(X, "md5")
  results
}


#' @aliases calibrate
#' @export
calibrate.formula <- function(formula, data, group = NULL,
                              preprocess = preprocess_recipe(prep_snv()),
                              method,
                              metadata = NULL,
                              return_inputs = TRUE,
                              ...,
                              na_action = na.pass) {
  if (!inherits(formula, "formula")) {
    stop("'formula' is only for formula objects")
  }
  if (!any(c("proximate_data", "proxiscout_data") %in% class(data))) {
    warning("Object 'data' is not of class 'proximate_data' or 'proxiscout_data'. This can result in errors when creating an application.\n")
  }

  # NEEDS REVIEW. Reason: Changes
  # definition <- sys.function(sys.parent())
  call_f <- match.call(expand.dots = TRUE)
  formals <- formals()
  # formals <- formals(definition)

  if (!"na_action" %in% names(call_f)) {
    call_f[["na_action"]] <- formals[["na_action"]]
    match.call(call = call_f, expand.dots = TRUE)
    # match.call(definition, call_f, TRUE)
  }

  if (missing(method)) {
    stop("'method' is missing")
  }

  ## Get the model frame
  mf <- call_f

  mr <- match(x = c("formula", "data", "na_action"), table = names(mf))

  mfr <- mf[c(1, mr)]
  names(mfr)[names(mfr) %in% "na_action"] <- "na.action"
  yname <- all.vars(formula, functions = FALSE, max.names = 1)

  mfr[[1]] <- as.name("model.frame")

  mfr <- mf[c(1, mr)]
  names(mfr)[names(mfr) %in% "na_action"] <- "na.action"
  yname <- all.vars(formula, functions = FALSE, max.names = 1)

  mfr[[1]] <- as.name("model.frame")

  input_list <- list(...)

  mfr <- eval(mfr, parent.frame())
  trms <- attr(mfr, "terms")

  formulaclasses <- attr(trms, "dataClasses")

  attr(trms, "intercept") <- 0

  xr <- model.matrix(trms, model.frame(mfr, drop.unused.levels = TRUE))
  rmn <- paste0(names(attr(trms, "dataClasses")), collapse = "|")
  colnames(xr) <- gsub(rmn, "", colnames(xr))

  predvars <- attr(delete.response(trms), "term.labels")

  if (!predvars %in% colnames(data)) {
    stop("Predictor variables not found in data. \nNote: this function does not allow for interactions between terms.")
  }

  yr <- model.extract(mfr, "response")
  yr <- as.matrix(yr)
  colnames(yr) <- yname

  model_results <- NULL
  model_results$formula <- formula
  model_results$dataclasses <- attr(trms, "dataClasses")

  model_results <- c(
    model_results,
    calibrate(xr, yr,
      group = group,
      preprocess = preprocess,
      method = method,
      metadata = metadata,
      return_inputs = FALSE,
      ...
    )
  )

  if (return_inputs) {
    model_results$input_data <- NULL
    model_results$input_data$data <- data
  }
  class(model_results) <- c("spectral_model", "list")
  x_hash <- data[[attr(trms, "term.labels")]]
  rownames(x_hash) <- NULL
  attr(model_results, "data_hash") <- digest::digest(x_hash, "md5")
  model_results
}


#' @title NIRWise PLUS modeling methods (basic)
#' @description internal function
#' @return An internal object containing the fitted model and validation results.
#' @keywords internal
.calibrate_basic <- function(X, Y, group = NULL,
                             method = fit_plsr(ncomp = min(15, dim(X))),
                             control = calibration_control(),
                             return_inputs = TRUE,
                             sample_labels = NULL,
                             verbose = TRUE) {
  results <- NULL
  if (control$validation_type != "none") {
    results$model_cv <- .calibrate_cv(
      X = X,
      Y = Y,
      group = group,
      method = method,
      control = control,
      verbose = verbose
    )
  }
  if (control$fixed_components == 0) {
    index_optimal <- method$ncomp
    if (control$validation_type != "none" & control$tuning_parameter != "none") {
      is_rsq <- (-1)^(control$tuning_parameter == "rsq")
      tuning_vec <- is_rsq * results$model_cv$grid[, control$tuning_parameter]
      lr <- control$learning_rates^is_rsq
      index_optimal <- unname(which.min(tuning_vec))
      if (index_optimal > 2) {
        min_tuning_vec <- tuning_vec[index_optimal]
        for (i in (index_optimal - 1):2) {
          if (tuning_vec[i] < min_tuning_vec * lr[1] & tuning_vec[i] < tuning_vec[index_optimal] * lr[2]) {
            index_optimal <- i
          }
        }
      }
    }
  } else {
    index_optimal <- control$fixed_components
  }
  sel_method <- method
  sel_method$ncomp <- index_optimal

  results$ncomp <- index_optimal
  results$model <- .estimate_model(X = X, Y = Y, method = method)
  all_cal_stats <- .calibration_statistics(
    y = Y,
    fitted_y = results$model$fitted_y,
    predicted_y_in_cv = results$model_cv$predicted,
    scaled_scores = results$model$scaled_scores,
    ncomp = 1:method$ncomp
  )
  if (!is.null(sample_labels)) {
    s_labels <- sample_labels[all_cal_stats$Sample_index]
    all_cal_stats$Sample_index <- sample_labels[all_cal_stats$Sample_index]
  } else {
    s_labels <- all_cal_stats$Sample_index
  }
  optimal_cal_stats <- list(
    s_labels,
    all_cal_stats$Target,
    all_cal_stats$fitted_y[, index_optimal],
    all_cal_stats$residual[, index_optimal],
    all_cal_stats$predicted_y_in_cv[, index_optimal],
    all_cal_stats$cv_residual[, index_optimal],
    all_cal_stats$Mahalanobis[, index_optimal],
    all_cal_stats$Q_value[, index_optimal]
  )
  names(optimal_cal_stats) <- names(all_cal_stats)
  to_rm <- !sapply(optimal_cal_stats, FUN = is.null)

  nms <- names(optimal_cal_stats)[to_rm]
  optimal_cal_stats <- do.call("cbind", optimal_cal_stats)
  colnames(optimal_cal_stats) <- nms
  rownames(optimal_cal_stats) <- 1:nrow(optimal_cal_stats)

  results$calibration_statistics <- optimal_cal_stats
  results$calibration_statistics_all <- all_cal_stats[to_rm]
  results
}

#' @aliases calibrate
#' @importFrom stats .MFclass terms delete.response
#' @export
predict.spectral_model <- function(
  object, newdata,
  ncomp = object$final_ncomp,
  verbose = TRUE, ...
) {
  if (missing(newdata)) {
    stop("newdata is missing")
  }
  if (!inherits(object, "spectral_model")) {
    stop("'object' must be of class 'spectral_model'.")
  }
  if (!is.logical(verbose)) {
    stop("'verbose' must a logical.")
  }
  if (any(!is.numeric(ncomp))) {
    stop("The component(s) for prediction must be a (vector of) numerical.")
  }

  if (ncol(object$final_model$model$scores) < max(ncomp)) {
    if (length(ncomp) == 1) {
      stop("'ncomp' is larger than the number of components in the model")
    } else {
      stop("The maximum of 'ncomp' is larger than the number of components in the model")
    }
  }

  if (!is.null(object$formula)) {
    dcls <- object$dataclasses[-1]

    if (!("matrix" %in% class(newdata) || "data.frame" %in% class(newdata))) {
      stop(paste0(
        "When predicting from objects of class 'calibrate' fitted with ",
        "formula, the argument 'newdata' must be a 'data.frame' ",
        "or alternatively a 'matrix'"
      ))
    }

    if ("data.frame" %in% class(newdata)) {
      if (!all(names(dcls) %in% names(newdata))) {
        mss <- names(dcls)[!names(dcls) %in% names(newdata)]
        stop(paste(
          "The following predictor variables are missing:",
          paste(mss, collapse = ", ")
        ))
      }
    }

    oterms <- terms(object$formula)
    oterms <- delete.response(oterms)
    attr(oterms, "intercept") <- 0
    if ("data.frame" %in% class(newdata)) {
      mf <- model.frame(oterms, newdata)
      newdata <- model.matrix(oterms, model.frame(mf, drop.unused.levels = TRUE))
    }
    colnames(newdata) <- gsub(attr(oterms, "term.labels"), "", colnames(newdata))

    if (object$preprocess$device == "proxiscout") {
      hw_wavs <- range(get_proxiscout_wavenumbers())
      rng_model <- range(object$processed_wavs$step_0)
      wav_incomimg <- as.numeric(colnames(newdata))
      rng_incomimg <- range(wav_incomimg)
      to_exclude <- NULL
      if (min(rng_incomimg) < min(rng_model)) {
        to_exclude <- -which(min(rng_model) > wav_incomimg)
      }

      if (max(rng_incomimg) > max(rng_model)) {
        to_exclude <- c(to_exclude, -which(max(rng_model) < wav_incomimg))
      }

      # wav_sel <- which(
      #   is_close_to_any(hw_wavs, object$processed_wavs$step_0, tol = 0.1)
      # )
      # newdata <- newdata[, wav_sel]
      if (!is.null(to_exclude)) {
        newdata <- newdata[, to_exclude]
      }
    }

    if (length(object$preprocess$steps) > 0) {
      if (verbose) {
        prep_nms <- sapply(
          object$preprocess$steps,
          FUN = function(x) x[[1]]
        )
        prep_nms <- gsub("prep_", "", prep_nms)
        prep_steps_print <- paste(prep_nms, collapse = " > ")
        cat(
          "\033[1;32m\033[3mProcessing 'newdata': ",
          prep_steps_print,
          "\n\033[0m"
        )
      }

      mss <- "\033[1;32m\033[3mPredicting from preprocessed 'newdata'...\n\033[0m"
      newdata <- process(newdata, object$preprocess)
    } else {
      mss <- "\033[1;32m\033[3mPredicting from 'newdata'...\n\033[0m"
    }
    if (verbose) {
      cat(mss)
    }

    if (any(dcls != "numeric")) {
      if ("matrix" %in% class(newdata) & length(dcls) == 1) {
        if (.MFclass(newdata) == dcls) {
          pnames <- gsub(
            names(dcls), "",
            object$predictor_variables
          )
          if (all(pnames %in% colnames(newdata))) {
            newdata_temp <- newdata
            newdata <- data.frame(rep(NA, nrow(newdata)))
            colnames(newdata) <- names(dcls)[1]
            newdata[[names(dcls)]] <- newdata_temp[, pnames]
          } else {
            stop("Missing predictor variables")
          }
        }
      }
    }
  } else {
    response_var <- object$target_variable
    if ("data.frame" %in% class(newdata)) {
      rownms <- rownames(newdata)
      newdata <- newdata$spc
      rownames(newdata) <- rownms
      raw_data <- newdata
    }
    if (length(object$preprocess$steps) > 0) {
      if (verbose) {
        prep_nms <- sapply(
          object$preprocess$steps,
          FUN = function(x) x[[1]]
        )
        prep_nms <- gsub("prep_", "", prep_nms)
        prep_steps_print <- paste(prep_nms, collapse = " > ")
        cat(
          "\033[1;32m\033[3mProcessing 'newdata': ",
          prep_steps_print,
          "\n\033[0m"
        )
      }

      mss <- "\033[1;32m\033[3mPredicting from preprocessed 'newdata'...\n\033[0m"
      newdata <- process(newdata, object$preprocess)
    } else {
      mss <- "\033[1;32m\033[3mPredicting from 'newdata'...\n\033[0m"
    }
    if (verbose) {
      cat(mss)
    }
  }
  if (identical(colnames(newdata), all.vars(object$formula)[-1]) & (length(all.vars(object$formula)[-1]) == 1)) {
    newdata <- newdata[[all.vars(object$formula)[-1]]]
  }

  new_data <- scale(newdata[, object$predictor_variables], center = object$final_model$model$x_means, FALSE)
  relevant_coefs <- object$final_model$model$coefficients[ncomp, , drop = FALSE]


  predictions <- new_data %*% t(relevant_coefs) + object$final_model$model$intercept


  if (!is.null(rownames(newdata))) {
    rownames(predictions) <- rownames(newdata)
  } else {
    rownames(predictions) <- 1:nrow(newdata)
  }
  if (!is.null(rownames(object$final_model$model$coefficients))) {
    colnames(predictions) <- rownames(object$final_model$model$coefficients)[ncomp]
  } else {
    colnames(predictions) <- paste0("ncomp_", ncomp)
  }

  model_information <- list(
    target_var = object$target_variable,
    preprocess_recipe = object$preprocess,
    model_grid = object$final_model$model_cv$grid[ncomp, , drop = FALSE],
    unit = object$metadata$Unit,
    opt_comp = object$final_ncomp
  )

  scores <- new_data %*% t(object$final_model$model$projection_m)
  rownames(scores) <- rownames(predictions)
  results <- list(
    predictions = predictions,
    scores = scores,
    model_information = model_information
  )
  class(results) <- c("spectral_prediction", "list")
  results
}
