#' @title Print method for an object of class \code{spectral_fit}
#' @description Prints the content of an object of class \code{spectral_fit}
#' @aliases print.nwp_pls
#' @usage \method{print}{spectral_fit}(x, ...)
#' @param x an object of class \code{spectral_fit} (as returned by the
#' \code{\link{.estimate_model}} function).
#' @param ... arguments to be passed to methods (not functional).
#' @return Returns \code{x} invisibly.
#' @author Leonardo Ramirez-Lopez
#' @keywords internal
#' @export

print.spectral_fit <- function(x, ...) {
  sys_width <- getOption("width")
  bar_width <- 55

  if (bar_width > sys_width) {
    bar_width <- sys_width
  }

  div <- paste(rep("_", bar_width), collapse = "")
  method_used <- strsplit(x$method$type, "_")[[1]]

  if (length(method_used) > 1) {
    cat("Method:", toupper(method_used[1]), paste0("(", method_used[2], ")"), "\n")
  } else {
    cat("Method:", method_used, "\n")
  }
  cat("PLS factors:", x$method$ncomp, "\n")

  if (!is.null(x$n_observations)) {
    cat("Total number of observations:", x$n_observations, "\n")

    cat(div, "\n\n")

    cat("Quantiles of reference values:", "\n\n")
    print(signif(x$y_quantiles, 4))
    cat(div, "\n\n")

    cat("X variance (explained)\n\n")
    print(signif(x$explained_variance$x_variance, 4))
    cat(div, "\n\n")

    cat("Y variance (explained)\n\n")
    print(signif(x$explained_variance$y_variance, 4))
    cat(div, "\n")
  } else {
    cat("\n", "Basic fit", "\n")
  }
  invisible(x)
}
