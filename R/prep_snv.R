#' @title Standard Normal Variate constructor for spectral preprocessing
#'
#' @description
#'
#' \loadmathjax
#'
#' Creates a preprocessing constructor for applying Standard Normal Variate
#' (SNV) normalisation to spectral data. The constructor is intended to be
#' passed to \code{\link{preprocess_recipe}} and executed via \code{\link{process}}.
#'
#' @usage
#' prep_snv()
#'
#' @return An object of class \code{preprocessing} to be used in
#' \code{\link{preprocess_recipe}} and executed by \code{\link{process}}.
#'
#' @details
#' SNV normalises each spectrum row-wise by subtracting its mean and dividing
#' by its standard deviation:
#'
#' \mjdeqn{SNV_i = \frac{x_i - \bar{x}_i}{s_i}}{SNV_i = (x_i - mean(x_i)) / sd(x_i)}
#'
#' where \mjeqn{x_i}{x_i} is the signal of the \mjeqn{i}{i}th observation,
#' \mjeqn{\bar{x}_i}{\bar{x}_i} is its mean and \mjeqn{s_i}{s_i} its standard
#' deviation. Implemented via \code{\link[prospectr]{standardNormalVariate}}.
#'
#' @author Leonardo Ramirez-Lopez with code from Antoine Stevens
#'
#' @references Barnes RJ, Dhanoa MS, Lister SJ. 1989. Standard normal variate
#' transformation and de-trending of near-infrared diffuse reflectance spectra.
#' Applied spectroscopy, 43(5): 772-777.
#'
#' @examples
#' data("NIRcannabis")
#' X <- NIRcannabis$spc
#'
#' snv <- prep_snv()
#' recipe <- preprocess_recipe(snv)
#' X_snv <- process(X, recipe)
#'
#' @seealso \code{\link{preprocess_recipe}}, \code{\link{process}}
#' @export
prep_snv <- function() {
  structure(
    list(method = "prep_snv"),
    class = c("preprocessing", "list")
  )
}

#' @keywords internal
.exec_snv <- function(X, step) {
  standardNormalVariate(X)
}
