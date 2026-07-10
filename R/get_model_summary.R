#' @title Summary of \code{spectral_model}
#' @description Gets a summary of an object of class \code{spectral_model}
#' @usage get_model_summary(x, ...)
#' @param x an object of class \code{spectral_model} (as returned by the
#' \code{\link{calibrate}} function).
#' @param ... arguments to be passed to methods (not functional).
#' @return A list containing a summary of the model.
#' @author Leonardo Ramirez-Lopez
#' @keywords internal
get_model_summary <- function(x, ...) {
  smr <- NULL
  smr$target_var <- x$target_variable
  smr$d_predictors <- length(x$predictor_variables)
  smr$n_observations <- nrow(x$final_model$model$scores)
  smr$y_range <- signif(range(x$final_model$model$y_quantiles), digits = 3)
  smr$tuning_param <- x$control$tuning_parameter

  if (smr$tuning_param %in% "rmse") {
    smr$tuning_param <- "Root mean square error (rmse)"
  }
  if (smr$tuning_param == "rsq") {
    smr$tuning_param <- "Coefficient of determination (rsq)"
  }
  smr$preprocessing <- NULL
  smr$preprocessing$xp <- x$preprocess$preprocessing_order
  smr$preprocessing$detail <- x$preprocess

  smr$formula <- x$formula
  smr$method_used <- c(sub("r$", "", x$method$fit_method), x$method$type)
  smr$ncomp <- x$method$ncomp
  smr$final_ncomp <- x$final_ncomp


  if (!is.null(x$final_model$model_cv)) {
    smr$train_stats <- x$final_model$model_cv$grid
    smr$train_stats <- smr$train_stats[, !colnames(smr$train_stats) %in% c("largest_residual", "largest_residual_sd")]
  } else {
    smr$train_stats <- NULL
  }
  smr
}
