#' @title Write the model info into a JSON for ProxiScout devices
#' @name proxiscout_write_model_info
#' @description
#' 
#' \loadmathjax
#' 
#' Writes a JSON for the provided \code{object} that contains information about the model,
#' in the style of ProxiScout devices.
#'
#' @usage
#' proxiscout_write_model_info(object, n_measurements = 1L, file = NULL)
#'
#' @param object An object of class \code{spectral_model} that contains the
#' preprocessing recipe and final model details.
#' @param n_measurements An integer for the number of measurements. This value is
#' directly written into the JSON as both the \code{numberOfMeasurements} and
#' \code{avgReadings}, and represents the number of measurements that were taken
#' in the original data per sample. Default is \code{1}.
#' @param file an optional character string with the path (including the filename)
#' where the JSON output should be written. If \code{NULL} (default), the JSON string
#' is returned. 
#'
#' @return If \code{file} is \code{NULL}, the JSON is returned visibly, otherwise,
#' the JSON is written to the path specified by \code{file} and the JSON is
#' returned invisibly.
#' @export
proxiscout_write_model_info <- function(object, n_measurements = 1L, file = NULL) {
  if (missing(object)) {
    stop("Parameter 'object' is required for generating the model info JSON")
  }
  if (!inherits(object, "spectral_model")) {
    stop("'object' must be of class 'spectral_model'.")
  }
  if (length(n_measurements) != 1L || is.na(n_measurements) || !is.numeric(n_measurements) ||
      is.infinite(n_measurements) || n_measurements != as.integer(n_measurements) || n_measurements < 1) {
    stop("'n_measurements' must be a single positive integer.")
  }
  if (!is.null(file)) {
    if (!is.character(file) || length(file) != 1)
      stop("'file' must be a single character string.")
  }
  final_ncomp <- object$final_ncomp
  cal_error <- object$final_model$model$cal_error
  cv_grid <- object$final_model$model_cv$grid
  Y <- object$final_model$calibration_statistics_all$Target
  n_samples <- length(Y)
  
  # Calibration error (RMSE) for the final number of components
  rmse_calib <- r2_calib <- 0.0
  if (!is.null(cal_error)) {
    rmse_calib <- cal_error[final_ncomp, "cal_set_error"]
    # R2 calibration from fitted values
    fitted_y <- object$final_model$model$fitted_y[, final_ncomp]
    sd_Y <- stats::sd(Y)
    sd_fitted <- stats::sd(fitted_y)
    if (valid_nonzero(sd_Y) && valid_nonzero(sd_fitted)) r2_calib <- drop(cor(Y, fitted_y))^2
  }
  
  # Cross-validation statistics
  rmse_cv <- r2_cv <- bias_cv <- rpd_cv <- 0.0
  if (!is.null(cv_grid)) {
    rmse_cv <- cv_grid[final_ncomp, "rmse"]
    r2_cv <- cv_grid[final_ncomp, "rsq"]
    # Bias and RPD from CV predictions
    sd_ref <- stats::sd(Y)
    rpd_cv <- if (valid_nonzero(rmse_cv) && valid_nonzero(sd_ref)) sd_ref / rmse_cv else 0.0
    cv_predictions <- object$final_model$model_cv$predicted
    if (!is.null(cv_predictions)) {
      bias_cv <- mean(Y - cv_predictions[, final_ncomp])
    }
  }
  
  info_list <- list(
    executionOrder = 0L,
    RMSECalib = zero_if_invalid(rmse_calib),
    R2Calib = zero_if_invalid(r2_calib),
    RMSECV = zero_if_invalid(rmse_cv),
    R2CV = zero_if_invalid(r2_cv),
    BiasCV = zero_if_invalid(bias_cv),
    RPDCV = zero_if_invalid(rpd_cv),
    RMSETest = 0.0,
    R2Test = 0.0,
    BiasTest = 0.0,
    RPDTest = 0.0,
    avgReadings = as.integer(n_measurements),
    avgPredictions = 1L,
    minValue = zero_if_invalid(min(Y, na.rm = TRUE)),
    maxValue = zero_if_invalid(max(Y, na.rm = TRUE)),
    numberOfSamples = as.integer(n_samples),
    numberOfMeasurements = as.integer(n_measurements)
  )
  
  json_string <- toJSON(info_list, auto_unbox = TRUE, pretty = TRUE, digits = 3)
  if (is.null(file)) {
    return(json_string)
  }
  writeLines(json_string, con = file)
  return(invisible(json_string))
}

#' @title Check that a numeric value is finite and non-zero
#' @keywords internal
valid_nonzero <- function(x) {
  isTRUE(length(x) == 1L) && is.finite(x) && abs(x) > 0
}

#' @title Returns 0 if `x` is not of length 1 or `is.finite(x)` returns `FALSE`
#' @keywords internal
zero_if_invalid <- function(x) {
  if (length(x) == 1L && is.finite(x)) return(x)
  return(0)
}
