#' @title Reflectance/absorbance conversion constructor for spectral preprocessing
#'
#' @description
#'
#' \loadmathjax
#'
#' Creates a preprocessing constructor for converting spectral data between
#' reflectance and absorbance. The constructor is intended to be passed to
#' \code{\link{preprocess_recipe}} and executed via \code{\link{process}}.
#'
#' @usage
#' prep_transform(to = c("absorbance", "reflectance"))
#'
#' @param to A character string specifying the target unit. Either
#' \code{"absorbance"} (default) or \code{"reflectance"}.
#'
#' @return An object of class \code{preprocessing} to be used in
#' \code{\link{preprocess_recipe}} and executed by \code{\link{process}}.
#'
#' @details
#' Conversion follows Beer's Law:
#'
#' \mjdeqn{A = -\log_{10}(R)}{A = -log10(R)}
#'
#' where \mjeqn{A}{A} is absorbance and \mjeqn{R}{R} is reflectance.
#'
#' When converting to absorbance, all values in \code{X} must be strictly
#' positive. A warning is issued if the resulting absorbance contains small
#' negative values, which may indicate precision or scaling issues in the
#' input.
#'
#' Note that no check is performed on whether the input is actually in the
#' expected unit (the transformation is applied as specified).
#'
#' @author Leonardo Ramirez-Lopez
#'
#' @examples
#' data("NIRcannabis")
#' X <- NIRcannabis$spc # absorbance
#'
#' tr <- prep_transform(to = "reflectance")
#' recipe <- preprocess_recipe(tr, device = "proxiscout")
#' X_ref <- process(X, recipe)
#'
#' @seealso \code{\link{preprocess_recipe}}, \code{\link{process}}
#' @export
prep_transform <- function(to = c("absorbance", "reflectance")) {
  to <- match.arg(to)

  structure(
    list(
      method = "prep_transform",
      to = to,
      compatible_devices = "proxiscout"
    ),
    class = c("preprocessing", "list")
  )
}

#' @noRd
.exec_transform <- function(X, step) {
  if (step$to == "absorbance") {
    if (any(X <= 0, na.rm = TRUE)) {
      stop("Reflectance contains values <= 0; cannot compute -log10.")
    }
    out <- -log10(X)
    if (any(out < -1e-12, na.rm = TRUE)) {
      warning("Absorbance contains small negatives; check inputs/precision.")
    }
    return(out)
  } else {
    out <- 10^(-X)
    if (any(out <= 0 | out > 1, na.rm = TRUE)) {
      warning("Reflectance outside (0, 1]; check absorbance scale/units.")
    }
    return(out)
  }
}
