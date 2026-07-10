#' @title The spectral_fit class
#' @name spectral_fit
#'
#' @description
#' An object of class \code{spectral_fit} represents a fitted PLS or XLS
#' regression model for a single component sequence. It is produced internally
#' by \code{\link{calibrate}} and is accessible via
#' \code{object$final_model$model}.
#'
#' A \code{spectral_fit} object is a list with the following elements:
#' \itemize{
#'   \item \strong{\code{method}:} The \code{fit_constructor} object passed to the
#'   fitting call. See \code{\link{fit_plsr}} and \code{\link{fit_xlsr}}.
#'   \item \strong{\code{explained_variance}:} A list with two matrices:
#'   \code{x_variance} (three rows: \code{pls_var}, \code{x_expl_var},
#'   \code{x_expl_var_cum} - absolute, relative, and cumulative relative
#'   explained variance of X per component) and \code{y_variance} (relative
#'   explained variance of the response per component).
#'   \item \strong{\code{x_means}:} Named numeric vector of column means of the input
#'   spectral matrix \code{X}.
#'   \item \strong{\code{weights}:} Matrix of PLS weights (one row per component).
#'   \item \strong{\code{scores}:} Matrix of scores (one column per component).
#'   \item \strong{\code{sd_scores}:} Named numeric vector of standard deviations for
#'   each score column.
#'   \item \strong{\code{scaled_scores}:} Matrix of scores scaled by their standard
#'   deviations.
#'   \item \strong{\code{x_loadings}:} Matrix of X loadings (one row per component).
#'   \item \strong{\code{projection_m}:} Projection matrix that maps new spectra onto
#'   the score space.
#'   \item \strong{\code{intercept}:} Named numeric scalar; the intercept of the
#'   regression model (equal to the mean of \code{Y}).
#'   \item \strong{\code{coefficients}:} Matrix of regression coefficients (one row per
#'   component, one column per wavelength).
#'   \item \strong{\code{fitted_y}:} Matrix of fitted response values (one column per
#'   component).
#'   \item \strong{\code{cal_error}:} Matrix with three columns: number of components,
#'   root mean squared error of calibration, and largest residual.
#'   \item \strong{\code{x_residuals}:} Matrix of spectral residuals (one column per
#'   component).
#'   \item \strong{\code{n_observations}:} Integer; number of observations used for
#'   fitting.
#'   \item \strong{\code{y_quantiles}:} Named numeric vector of the 0th, 25th, 50th,
#'   75th, and 100th percentiles of the response \code{Y}.
#' }
#'
#' @seealso \code{\link{calibrate}}, \code{\link{fit_plsr}},
#' \code{\link{fit_xlsr}}
#'
#' @author Leonardo Ramirez-Lopez and Claudio Orellano
NULL
