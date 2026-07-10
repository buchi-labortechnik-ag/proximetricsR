#' @title Derivative constructor for spectral preprocessing
#'
#' @description
#'
#' \loadmathjax
#'
#' Creates a preprocessing constructor for computing first or second order
#' derivatives of spectral data. The constructor is intended to be passed to
#' \code{\link{preprocess_recipe}} and executed via \code{\link{process}}.
#'
#' Three algorithms are supported: Savitzky-Golay (\code{"savitzky-golay"}),
#' Norris-Gap/Gap-Segment (\code{"gap-segment"}), and the derivative
#' pre-treatment from BUCHI NIRWise PLUS software (\code{"nwp"}).
#'
#' @usage
#' prep_derivative(m, w, p, algorithm = c("savitzky-golay", "gap-segment", "nwp"))
#'
#' @param m An integer indicating the derivative order. Must be \code{1}
#' (first derivative) or \code{2} (second derivative).
#' @param w A positive odd integer indicating the filter window size.
#' For \code{"gap-segment"}, \code{w} indicates the gap size (spacing between
#' points over which the derivative is computed).
#' @param p An integer. For \code{"savitzky-golay"}, indicates the polynomial order
#' and must satisfy \code{p < w} and \code{p >= m}. For \code{"gap-segment"} and
#' \code{"nwp"}, indicates the segment or smoothing window size and must be a
#' positive odd integer.
#' @param algorithm A character string specifying the algorithm. One of
#' \code{"savitzky-golay"} (default), \code{"gap-segment"}, or \code{"nwp"}.
#' See Details.
#'
#' @return An object of class \code{preprocessing} to be used in
#' \code{\link{preprocess_recipe}} and executed by \code{\link{process}}.
#' The object is a list containing the method name, all parameters, and
#' (for \code{algorithm = "nwp"}) the NIRWise PLUS half-window values
#' (\code{half_w}, \code{half_s}) required for device file serialization.
#'
#' @details
#' \strong{Savitzky-Golay} (\code{"savitzky-golay"}): fits a polynomial of
#' order \code{p} within a moving window of size \code{w} and differentiates
#' analytically. Implemented via \code{\link[prospectr]{savitzkyGolay}}.
#'
#' \strong{Gap-Segment} (\code{"gap-segment"}): computes the derivative over a
#' gap of \code{w} points, with optional averaging over a segment of \code{p}
#' points. When \code{p = 1} this reduces to the standard Norris-Gap
#' derivative. Implemented via \code{\link[prospectr]{gapDer}}.
#'
#' \strong{NWP} (\code{"nwp"}): reproduces the "DG" derivative pre-treatment
#' from BUCHI NIRWise PLUS calibration software. A moving average of window
#' \code{p} is applied first (pre-smoothing), followed by differentiation.
#' For first order, a gap derivative with gap \code{w} is used. For second
#' order, a centered second difference with spacing \code{half_w} is computed:
#'
#' \mjdeqn{d^2x_i = \frac{2x_i - (x_{i+h} + x_{i-h})}{2h}}{d2x_i = (2*x_i - (x_{i+h} + x_{i-h})) / (2h)}
#'
#' where \mjeqn{h = half_w}{h = half_w}. Edge columns affected by the
#' window are removed from the output.
#'
#' For the \code{"nwp"} algorithm, the NIRWise PLUS half-window conventions are:
#' \mjdeqn{half_w = (w + 1) / 2}{half_w = (w + 1) / 2}
#' \mjdeqn{half_s = (p - 1) / 2}{half_s = (p - 1) / 2}
#' These are stored internally for device file serialization and are not
#' user-facing parameters.
#'
#' @author Leonardo Ramirez-Lopez and Claudio Orellano
#'
#' @examples
#' data("NIRcannabis")
#' X <- NIRcannabis$spc
#'
#' # Savitzky-Golay first derivative, window 11, polynomial order 3
#' sg <- prep_derivative(m = 1, w = 11, p = 3, algorithm = "savitzky-golay")
#'
#' # Gap-Segment second derivative, gap 9, segment 3
#' gs <- prep_derivative(m = 2, w = 9, p = 3, algorithm = "gap-segment")
#'
#' # NWP first derivative, window 5, pre-smoothing 11
#' nwp <- prep_derivative(m = 1, w = 5, p = 11, algorithm = "nwp")
#'
#' # Apply via preprocess_recipe
#' recipe <- preprocess_recipe(sg, device = "unspecified")
#' X_der <- process(X, recipe)
#'
#' @seealso \code{\link{preprocess_recipe}}, \code{\link{process}}
#' @export
prep_derivative <- function(m, w, p, algorithm = c("savitzky-golay", "gap-segment", "nwp")) {
  algorithm <- match.arg(algorithm)

  # validate m
  if (!is_numeric_like(m)) {
    stop("'m' must be numeric.")
  }
  m <- as.integer(m)
  if (!m %in% 1:2) {
    stop("'m' must be 1 or 2.")
  }

  # validate w
  if (!is_numeric_like(w)) {
    stop("'w' must be numeric.")
  }
  w <- as.integer(w)
  if (w < 1 || w %% 2 != 1) {
    stop("'w' must be a positive odd integer.")
  }

  # validate p
  if (!is_numeric_like(p)) {
    stop("'p' must be numeric.")
  }
  p <- as.integer(p)

  # algorithm-specific validation
  if (algorithm == "savitzky-golay") {
    if (p >= w) {
      stop("'w' must be greater than 'p' for 'savitzky-golay'")
    }
    if (p < m) {
      stop("'p' must be >= 'm' for 'savitzky-golay'")
    }
  }

  if (algorithm == "gap-segment" || algorithm == "nwp") {
    if (p < 1 || p %% 2 == 0) {
      stop(sprintf("'p' must be a positive odd integer for '%s'", algorithm))
    }
  }

  # NWP half-window values stored for device file serialization
  half_w <- if (algorithm == "nwp") as.integer((w + 1L) / 2L) else NULL
  half_s <- if (algorithm == "nwp") as.integer((p - 1L) / 2L) else NULL

  compatible_devices <- switch(algorithm,
    "nwp" = "proximate",
    "savitzky-golay" = "proxiscout",
    "gap-segment" = "proxiscout"
  )

  structure(
    list(
      method = "prep_derivative",
      m = m,
      w = w,
      p = p,
      algorithm = algorithm,
      half_w = half_w,
      half_s = half_s,
      compatible_devices = compatible_devices
    ),
    class = c("preprocessing", "list")
  )
}

#' @keywords internal
.exec_derivative <- function(X, step) {
  m <- step$m
  w <- step$w
  algorithm <- step$algorithm

  if (algorithm == "savitzky-golay") {
    return(savitzkyGolay(X, m = m, p = step$p, w = w))
  }

  if (algorithm == "gap-segment") {
    return(gapDer(X, m = m, w = w, s = step$p))
  }

  if (algorithm == "nwp") {
    as_legacy <- FALSE
    p <- step$p
    half_w <- step$half_w
    half_s <- step$half_s

    if (w >= ncol(X)) {
      stop("'w' is too large for the number of columns in X.")
    }
    if (p >= ncol(X)) {
      stop("'p' is too large for the number of columns in X.")
    }

    if (half_s > 0L) {
      X <- movav(X, p)
    }

    if (m == 2L) {
      left <- cbind(X[, -c(1:half_w), drop = FALSE], matrix(NA, nrow(X), half_w))
      right <- cbind(matrix(NA, nrow(X), half_w), X[, -c((ncol(X) - half_w + 1L):ncol(X)), drop = FALSE])
      der <- (2 * X - (left + right)) / (2 * half_w)
      to_rm <- c(1:half_w, (ncol(der) - half_w + 1L):ncol(der))
      return(der[, -to_rm, drop = FALSE])
    }
    return(gapDer(X, m = 1L, w = w, s = 1L))
  }
}
