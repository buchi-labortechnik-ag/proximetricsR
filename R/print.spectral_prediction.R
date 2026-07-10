#' @title Print method for an object of class \code{spectral_prediction}
#' @description Prints the content of an object of class \code{spectral_prediction}
#' @aliases print.spectral_prediction
#' @usage \method{print}{spectral_prediction}(x, ...)
#' @param x an object of class \code{spectral_prediction} (as returned by the
#' \code{\link[=predict.spectral_model]{predict}} function).
#' @param ... arguments to be passed to methods (not functional).
#' @return No return value, called for side effects.
#' @author Claudio Orellano
#' @keywords internal
#' @export
print.spectral_prediction <- function(x, ...) {
  sys_width <- getOption("width")
  bar_width <- 55

  if (bar_width > sys_width) {
    bar_width <- sys_width
  }
  div <- paste(rep("_", bar_width), collapse = "")

  final_predictions <- x$predictions

  target_var <- x$model_information$target_var
  n_preds <- nrow(final_predictions)
  final_ncomp <- as.numeric(gsub("ncomp_", "", colnames(final_predictions)))

  cat("Predicted response:", target_var, "\n")
  if (!is.null(x$model_information$preprocess_recipe)) {
    print(x$model_information$preprocess_recipe)
  }
  cat("Number of predictions:", n_preds, "\n")
  if (length(final_ncomp) == 1) {
    cat("Final number of pls factors:", final_ncomp, "\n")
    if (final_ncomp != x$model_information$opt_comp) {
      cat("Proposed number of pls factors by the model: ", x$model_information$opt_comp, "\n")
    }
  } else {
    cat("Considered pls factors:", paste0(final_ncomp, collapse = ", "), "\n")
    cat("Proposed number of pls factors by the model: ", x$model_information$opt_comp, "\n")
  }
  if (!is.null(x$model_information$unit)) {
    if (x$model_information$unit != "") {
      cat("Units of the predicted response: ", x$model_information$unit, "\n")
    }
  }

  cat(div, "\n")
  if (nrow(final_predictions) > 20) {
    cat("\n", "First 20 Predictions obtained from the model with 'newdata'", "\n\n")
    print(final_predictions, digits = 3, max = 20 * length(final_ncomp))
  } else {
    cat("\n", "Predictions obtained from the model with 'newdata'", "\n\n")
    print(final_predictions, digits = 3)
  }
  cat(div, "\n")
  invisible(x)
}
