#' @title Print method for an object of class \code{spectral_model}
#' @description Prints the content of an object of class \code{spectral_model}
#' @aliases print.spectral_model
#' @usage \method{print}{spectral_model}(x, ...)
#' @param x an object of class \code{spectral_model} (as returned by the
#' \code{\link{calibrate}} function).
#' @param ... arguments to be passed to methods (not functional).
#' @return No return value, called for side effects.
#' @author Leonardo Ramirez-Lopez
#' @keywords internal
#' @export
print.spectral_model <- function(x, ...) {
  sys_width <- getOption("width")
  bar_width <- 55

  if (bar_width > sys_width) {
    bar_width <- sys_width
  }

  div <- paste(rep("_", bar_width), collapse = "")

  smr <- get_model_summary(x)

  xp <- smr$preprocessing$xp

  cat("Modeling response:", smr$target_var, "\n")
  cat("Range:", paste(smr$y_range, collapse = " - "), "\n")
  cat("Final number of observations:", smr$n_observations, "\n")
  cat("Number of predictors:", smr$d_predictors, "\n")

  cat("Pre-processing:\n ")
  print(x$preprocess, separator = " >\n ")
  if (!is.null(x$formula)) {
    cat("Formula:", Reduce(paste, deparse(x$formula)), "\n")
  }
  if (length(smr$method_used) > 1) {
    cat("Method:", toupper(smr$method_used[1]), paste0("(", smr$method_used[2], ")"), "\n")
  } else {
    cat("Method:", toupper(smr$method_used), "\n")
  }
  cat("Total number of factors considered:", smr$ncomp, "\n")
  cat("Final number of pls factors:", smr$final_ncomp, "\n")
  cat("Tuning parameter:", smr$tuning_param, "\n")

  if (!is.null(smr$train_stats)) {
    cat(div, "\n")
    cat("\n", "Statistics for (cross-) validation of final training set", "\n\n")
    print(smr$train_stats, digits = 3)
    cat(div, "\n")
  } else {
    cat("Validation: None\n")
  }
  invisible(x)
}
