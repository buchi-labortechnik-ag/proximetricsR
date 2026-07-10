#' @title Fitting method constructors
#' @name fit_constructors
#' @aliases fit_plsr
#' @aliases fit_xlsr
#' @description
#'
#' \loadmathjax
#'
#' These functions create configuration objects that specify the regression
#' method to be used within \code{\link{calibrate}}.
#'
#' @usage
#' fit_plsr(ncomp, type = c("nwp", "standard", "modified"))
#'
#' fit_xlsr(ncomp, type = c("nwp", "standard", "modified"), min_w = 3, max_w = 15)
#'
#' @param ncomp a positive integer indicating the maximum number of PLS
#' components to use.
#' @param type a character string indicating the algorithm variant. One of
#' \code{"nwp"} (default), \code{"standard"}, or \code{"modified"}.
#' \itemize{
#'   \item{\code{"nwp"}: replicates the NIRWise PLUS method, which uses
#'     correlation-based weights with an additional slope correction applied
#'     to the weights and scores.}
#'   \item{\code{"standard"}: standard PLS using standardised covariances
#'     between spectra and reference values as weights.}
#'   \item{\code{"modified"}: modified PLS using correlations between spectra
#'     and reference values as weights.}
#' }
#' @param min_w a positive integer indicating the minimum window size for the
#' XLS algorithm. Default is \code{3}.
#' @param max_w a positive integer indicating the maximum window size for the
#' XLS algorithm. Must be greater than \code{min_w}. Default is \code{15}.
#'
#' @details
#' There are two regression methods available:
#'
#' \subsection{Partial least squares (\code{fit_plsr})}{
#' Uses PLS regression. The only parameter optimised is the number of
#' components (\code{ncomp}). Three algorithm variants are available via
#' \code{type}: \code{"nwp"}, \code{"standard"}, and \code{"modified"}.
#' }
#'
#' \subsection{Extended partial least squares (\code{fit_xlsr})}{
#' Uses the XLS algorithm. In addition to \code{ncomp} and \code{type},
#' the window range (\code{min_w}, \code{max_w}) controls the local
#' smoothing applied within the algorithm.
#' }
#'
#' @return An object of class \code{c("fit_plsr", "fit_constructor")} or
#' \code{c("fit_xlsr", "fit_constructor")} containing the specified parameters,
#' to be passed to \code{\link{calibrate}}.
#'
#' @author Leonardo Ramirez-Lopez and Claudio Orellano
#'
#' @seealso \code{\link{calibrate}}, \code{\link{calibrate_models}}
#'
#' @examples
#' # PLS as in NIRWise PLUS
#' fit_plsr(ncomp = 15)
#'
#' # Standard PLS with 15 components
#' fit_plsr(ncomp = 15, type = "standard")
#'
#' # Modified PLS with 15 components
#' fit_plsr(ncomp = 15, type = "modified")
#'
#' # XLS as in NIRWise PLUS
#' fit_xlsr(ncomp = 10)
#'
#' # Standard XLS with custom window range
#' fit_xlsr(ncomp = 10, type = "standard", min_w = 5, max_w = 20)
#'
NULL

# Internal shared constructor
.new_fit_method <- function(fit_method, ...) {
  structure(
    list(fit_method = fit_method, ...),
    class = c(paste0("fit_", fit_method), "fit_constructor")
  )
}


# fit_plsr
#' @export
fit_plsr <- function(ncomp, type = c("nwp", "standard", "modified")) {
  if (missing(ncomp)) {
    stop("'ncomp' must be specified.")
  }
  if (length(ncomp) != 1L || !is.numeric(ncomp) || ncomp < 1L) {
    stop("'ncomp' must be a single positive integer.")
  }

  type <- match.arg(type)

  .new_fit_method(
    "plsr",
    ncomp = as.integer(ncomp),
    type = type
  )
}

#' @noRd
#' @export
print.fit_plsr <- function(x, ...) {
  cat("Fitting method: fit_plsr\n")
  cat("  ncomp:", x$ncomp, "\n")
  cat("  type :", x$type, "\n")
  invisible(x)
}


# fit_xlsr
#' @export
fit_xlsr <- function(
  ncomp,
  type = c("nwp", "standard", "modified"),
  min_w = 3,
  max_w = 15
) {
  if (missing(ncomp)) {
    stop("'ncomp' must be specified.")
  }
  if (length(ncomp) != 1L || !is.numeric(ncomp) || ncomp < 1L) {
    stop("'ncomp' must be a single positive integer.")
  }
  if (length(min_w) != 1L || !is.numeric(min_w) || min_w < 1L) {
    stop("'min_w' must be a single positive integer.")
  }
  if (length(max_w) != 1L || !is.numeric(max_w) || max_w < 1L) {
    stop("'max_w' must be a single positive integer.")
  }
  if (min_w >= max_w) {
    stop("'min_w' must be less than 'max_w'.")
  }

  type <- match.arg(type)

  .new_fit_method(
    "xlsr",
    ncomp = as.integer(ncomp),
    type = type,
    min_w = as.integer(min_w),
    max_w = as.integer(max_w)
  )
}

#' @noRd
#' @export
print.fit_xlsr <- function(x, ...) {
  cat("Fitting method: fit_xlsr\n")
  cat("  ncomp:", x$ncomp, "\n")
  cat("  type :", x$type, "\n")
  cat("  min_w:", x$min_w, "\n")
  cat("  max_w:", x$max_w, "\n")
  invisible(x)
}


# Fallback print for fit_constructor
#' @noRd
#' @export
print.fit_constructor <- function(x, ...) {
  cat("Fitting method:", x$fit_method, "\n")
  for (nm in setdiff(names(x), "fit_method")) {
    cat(" ", nm, ":", x[[nm]], "\n")
  }
  invisible(x)
}
