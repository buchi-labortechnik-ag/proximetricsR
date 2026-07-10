#' @title Smoothing constructor for spectral preprocessing
#'
#' @description
#'
#' \loadmathjax
#'
#' Creates a preprocessing constructor for smoothing spectral data. The
#' constructor is intended to be passed to \code{\link{preprocess_recipe}} and
#' executed via \code{\link{process}}.
#'
#' Two algorithms are supported: Savitzky-Golay (\code{"savitzky-golay"}) and
#' moving average (\code{"moving-average"}).
#'
#' @usage
#' prep_smooth(w, p = NULL, algorithm = c("savitzky-golay", "moving-average"))
#'
#' @param w A positive odd integer specifying the filter window size.
#' @param p An integer specifying the polynomial order. Required when
#' \code{algorithm = "savitzky-golay"}. Must satisfy \code{p < w} and
#' \code{p >= 0}. Ignored for \code{"moving-average"}.
#' @param algorithm A character string specifying the smoothing algorithm. One
#' of \code{"savitzky-golay"} (default) or \code{"moving-average"}. See
#' Details.
#'
#' @return An object of class \code{preprocessing} to be used in
#' \code{\link{preprocess_recipe}} and executed by \code{\link{process}}.
#' The object is a list containing the method name and all parameters. For
#' \code{algorithm = "moving-average"}, the NIRWise PLUS half-window value
#' (\code{half_w}) is also stored for device file serialization.
#'
#' @details
#' \strong{Savitzky-Golay} (\code{"savitzky-golay"}): fits a polynomial of
#' order \code{p} within a moving window of size \code{w} and returns the
#' zero-order coefficient (i.e. the smoothed value). Implemented via
#' \code{\link[prospectr]{savitzkyGolay}} with \code{m = 0}.
#'
#' \strong{Moving average} (\code{"moving-average"}): computes a simple moving
#' average of window size \code{w} using \code{\link[prospectr]{movav}}.
#' Edge values are handled using progressively narrower windows so the output
#' has the same number of columns as the input. This reproduces the "Smooth"
#' pre-treatment from BUCHI NIRWise PLUS.
#'
#' For \code{"moving-average"}, the NIRWise PLUS half-window convention is:
#' \mjdeqn{half_w = (w - 1) / 2}{half_w = (w - 1) / 2}
#' stored internally for device file serialization and not user-facing.
#'
#' @author Leonardo Ramirez-Lopez and Claudio Orellano
#'
#' @examples
#' data("NIRcannabis")
#' X <- NIRcannabis$spc
#'
#' # Savitzky-Golay smoothing, window 11, polynomial order 3
#' sg <- prep_smooth(w = 11, p = 3, algorithm = "savitzky-golay")
#'
#' # Moving average smoothing, window 7
#' ma <- prep_smooth(w = 7, algorithm = "moving-average")
#'
#' # Apply via preprocess_recipe
#' recipe <- preprocess_recipe(sg, device = "proxiscout")
#' X_smooth <- process(X, recipe)
#'
#' @seealso \code{\link{preprocess_recipe}}, \code{\link{process}}
#' @export
prep_smooth <- function(w, p = NULL, algorithm = c("savitzky-golay", "moving-average")) {
  algorithm <- match.arg(algorithm)

  if (!is_numeric_like(w)) {
    stop("'w' must be numeric.")
  }
  w <- as.integer(w)
  if (w < 1 || w %% 2 != 1) {
    stop("'w' must be a positive odd integer.")
  }

  if (algorithm == "savitzky-golay") {
    if (is.null(p)) {
      stop("'p' is required for 'savitzky-golay'.")
    }
    if (!is_numeric_like(p)) {
      stop("'p' must be numeric.")
    }
    p <- as.integer(p)
    if (p < 0) {
      stop("'p' must be >= 0.")
    }
    if (p >= w) {
      stop("'w' must be greater than 'p'.")
    }
  }

  half_w <- if (algorithm == "moving-average") as.integer((w - 1L) / 2L) else NULL

  compatible_devices <- switch(algorithm,
    "savitzky-golay" = "proxiscout",
    "moving-average" = "proximate"
  )

  structure(
    list(
      method = "prep_smooth",
      w = w,
      p = p,
      algorithm = algorithm,
      half_w = half_w,
      compatible_devices = compatible_devices
    ),
    class = c("preprocessing", "list")
  )
}

#' @keywords internal
.exec_smooth <- function(X, step) {
  as_legacy <- FALSE # kept for future use; not exposed in the public API

  if (step$algorithm == "savitzky-golay") {
    return(savitzkyGolay(X, m = 0, p = step$p, w = step$w))
  }

  if (step$algorithm == "moving-average") {
    w <- step$w
    half_w <- step$half_w

    if (w == 1L) {
      return(X)
    }

    moving_a <- movav(X, w = w)

    if (as_legacy) {
      edge_left <- lapply(
        seq_len(half_w),
        FUN = function(spectra, half_w, i) rowMeans(spectra[, 1:(half_w + i), drop = FALSE]),
        spectra = X[, 2:w, drop = FALSE], half_w = half_w
      )
      edge_left <- cbind(
        rowMeans(X[, 1:(half_w + 1L), drop = FALSE]),
        do.call("cbind", edge_left)
      )
      edge_right <- lapply(
        half_w:1,
        FUN = function(spectra, half_w, i) rowMeans(spectra[, (half_w - i + 1L):ncol(spectra), drop = FALSE]),
        spectra = X[, (ncol(X) - w + 1L):(ncol(X) - 1L), drop = FALSE], half_w = half_w
      )
      edge_right <- cbind(
        do.call("cbind", edge_right),
        rowMeans(X[, (ncol(X) - half_w):ncol(X), drop = FALSE])
      )
      moving_a <- moving_a[, -c(1L, ncol(moving_a)), drop = FALSE]
    } else {
      edge_left <- sapply(
        1:half_w,
        FUN = function(spectra, half_w, i) rowMeans(spectra[, 1:(half_w + i), drop = FALSE]),
        spectra = X[, 1:w, drop = FALSE], half_w = half_w
      )
      edge_right <- sapply(
        half_w:1,
        FUN = function(spectra, half_w, i) rowMeans(spectra[, (ncol(spectra) - i - half_w + 1L):ncol(spectra), drop = FALSE]),
        spectra = X[, (ncol(X) - w + 2L):ncol(X), drop = FALSE], half_w = half_w
      )
    }

    moving_a <- cbind(edge_left, moving_a, edge_right)
    colnames(moving_a) <- colnames(X)
    return(moving_a)
  }
}
