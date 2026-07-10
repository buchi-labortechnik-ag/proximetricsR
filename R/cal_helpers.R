#' @title Computes the NIRWise QVAL statistic
#' @description
#' QVAL indicates how different the predicted response variable (y) in
#' cross-validation deviates from the fitted version of y (i.e. the fitted y
#' values obtained when all calibration observations are used to fit the model).
#' @param y a matrix of one column with the response variable.
#' @param fitted_y a matrix with the estimated response variable for each
#' component.
#' @param predicted_y_in_cv the cross-validation estimates of the response
#' variable for every component.
#' @param scaled_scores a matrix of the scaled scores of the model.
#' @param ncomp a vector for each included component.
#' @seealso
#' \code{\link{calibrate}}
#' @return A list containing calibration statistics including residuals, predicted values, Mahalanobis distance, and Q-values.
#' @keywords internal
.calibration_statistics <- function(y, fitted_y, predicted_y_in_cv = NULL,
                                    scaled_scores, ncomp) {
  residual <- sweep(-fitted_y[, ncomp, drop = FALSE], MARGIN = 1, STATS = y, FUN = "+")

  if (!is.null(predicted_y_in_cv)) {
    cv_residual <- sweep(-predicted_y_in_cv[, ncomp, drop = FALSE], MARGIN = 1, STATS = y, FUN = "+")
    sd_res <- apply(
      residual,
      MARGIN = 2,
      FUN = function(x) {
        sqrt(sd(x)^2 * (length(x) - 1) / length(x))
      }
    )
    q_value <- abs(sweep(residual - cv_residual, MARGIN = 2, STATS = sd_res, FUN = "/"))
  } else {
    cv_residual <- q_value <- NULL
  }

  ## convert from Euclidean space to the Mahalanobis space
  scaled_scores <- eval(parse(text = "prospectr:::e2m(scaled_scores)"))
  center_scores <- matrix(0, 1, ncol(scaled_scores))

  get_diss <- function(x, center, factors) {
    t(eval(parse(text = 'prospectr:::fastDist(
      x[, 1:factors, drop = FALSE],
      center[, 1:factors, drop = FALSE],
      "euclid")')))
  }

  gh <- sweep(sapply(ncomp, FUN = get_diss, x = scaled_scores, center = center_scores),
    MARGIN = 2,
    STATS = ncomp,
    FUN = "/"
  )

  # rownames(gh) <- rownames(scaled_scores)
  calibration_results <- list(
    Sample_index = seq_along(y),
    Target = y,
    fitted_y = fitted_y[, ncomp, drop = FALSE],
    residual = residual,
    predicted_y_in_cv = predicted_y_in_cv[, ncomp, drop = FALSE],
    cv_residual = cv_residual,
    Mahalanobis = gh,
    Q_value = q_value
  )
  calibration_results
}

#' @title Test if a string can be coerced to a numeric
#' @description
#' based on the code found at # https://stackoverflow.com/a/21154566/2292993
#' @return A logical vector indicating whether each element can be coerced to numeric.
#' @keywords internal
is_numeric_like <- function(x, na_strings = c("", ".", "NA", "na", "N/A", "n/a", "NaN", "nan")) {
  x <- trimws(x, "both")
  x[x %in% na_strings] <- NA_character_
  # https://stackoverflow.com/a/21154566/2292993
  result <- grepl("^[\\-\\+]?[0-9]+[\\.,]?[0-9]*$|^[\\-\\+]?[0-9]+[L]?$|^[\\-\\+]?[0-9]+[\\.,]?[0-9]*[eE][0-9]+$", x, perl = TRUE)
  result
}
