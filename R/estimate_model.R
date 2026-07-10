#' @title A method for estimating the model
#' @aliases .estimate_model
#' @aliases predict.spectral_fit
#'
#' @description
#'
#' \loadmathjax
#' Compute partial least squares (PLS) or extended partial least squares (XLS)
#' regression models for a response variable and its associated set of predictors
#' based on the methods available in the BUCHI NIRWise PLUS calibration software.
#' @usage
#'
#' .estimate_model(X, Y, method = fit_plsr(ncomp = min(15, dim(X))))
#' \method{predict}{spectral_fit}(object, newdata, ...)
#'
#' @param X a numeric matrix of spectral data.
#' @param Y a matrix of one column with the response variable.
#' @param method an object of class \code{fit_constructor} specifying the regression
#' method, as returned by \code{\link{fit_plsr}} or \code{\link{fit_xlsr}}.
#'
#' @param object an object of class \code{spectral_fit}.
#' @param newdata a matrix containing new spectral data.
#' @param ... not currently used.
#'
#' @author Leonardo Ramirez-Lopez and Claudio Orellano
#' @return For \code{.estimate_model}, an object of class \code{spectral_fit},
#' which is a list with the following elements:
#' \itemize{
#'          \item \strong{\code{method}:}  A character specifying the method used to
#'          obtain the regression model.
#'          \item \strong{\code{explained_variance}:} A list containing two matrices:
#'          \itemize{
#'              \item \strong{\code{x_variance}:} A numerical matrix containing the
#'              variance explained by each component with respect to X. Contains
#'              the following rows:\cr
#'              \code{"pls_var"}, the absolute explained variance of X for each
#'              included component;\cr
#'              \code{x_expl_var}, the relative explained variance of X for each
#'              included component;\cr
#'              and \code{x_expl_var_cum}, the cumulated relative explained
#'              variance of X for each component.
#'              \item \strong{\code{y_variance}:}A numerical matrix of one row,
#'              containing the relative explained variance of the reference
#'              values \code{Y}.
#'              }
#'          \item \strong{\code{x_means}:} A numerical matrix of one row, containing
#'          the means of the columns of input \code{X}.
#'          \item \strong{\code{weights}:} A numerical matrix containing the weights.
#'          \item \strong{\code{scores}:} A numerical matrix with the scores.
#'          \item \strong{\code{sd_scores}:} A vector of standard deviations for each
#'          column in the matrix of scores.
#'          \item \strong{\code{scaled_scores}:} A numerical matrix containing the
#'          scores scaled by their standard deviations.
#'          \item \strong{\code{x_loadings}:} A numerical matrix of loadings.
#'          \item \strong{\code{projection_m}:} A numerical matrix of projections.
#'          It can be used to project new spectral data onto the score space.
#'          \item \strong{\code{intercept}:} A numeric for the intercept of the model.
#'          It is defined by the mean of the reference values \code{Y}.
#'          \item \strong{\code{coefficients}:} A numerical matrix of regression
#'          coefficients.
#'          \item \strong{\code{fitted_y}:} A numerical matrix containing the fitted
#'          values corresponding to the reference values \code{Y} for each
#'          component.
#'          \item \strong{\code{cal_error}:} A numerical matrix, containing the
#'          estimated error statistics for each component. Contains 3 columns:
#'          the number of included components, the root mean squared error of
#'          calibration for each components, and the largest obtained residuals.
#'          \item \strong{\code{x_residuals}:} A numerical matrix containing the
#'          spectral residuals obtained for each component.
#'          \item \strong{\code{n_observations}:} A single numerical, indicating the
#'          number of observations used for regression.
#'          \item \strong{\code{y_quantiles}:} A numerical vector containing the
#'          quantiles of the reference values \code{Y}.
#'          }
#' For \code{predict}, a list with one element:
#' \itemize{
#'          \item \strong{\code{predictions}:} A numerical matrix of the predicted
#'          values of the response variable.
#'          }
#' @details
#' The regression method (PLS or XLS) and its parameters are controlled entirely
#' through the \code{method} argument. See \code{\link{fit_plsr}} and
#' \code{\link{fit_xlsr}} for the available methods and their options.
#'
#' @seealso \code{\link{fit_plsr}}, \code{\link{fit_xlsr}}, \code{\link{calibrate}}
#' @keywords internal

.estimate_model <- function(X, Y, method = fit_plsr(ncomp = min(15, dim(X)))) {
  if (!"fit_constructor" %in% class(method)) {
    stop("'method' must be of class 'fit_constructor'.")
  }

  Y <- as.matrix(Y)

  if (ncol(Y) > 1) {
    stop("'Y' must be a matrix with one single column.")
  }

  if (nrow(X) != length(Y)) {
    stop("The number of observations in 'X' does not match with the number of observations in 'Y'.")
  }

  pls_objects <- estimate_all_pls(X, Y, method = method)

  pls_objects$y_quantiles <- c(pls_objects$y_quantiles)
  pls_objects$x_means <- c(pls_objects$x_means)
  pls_objects$sd_scores <- c(pls_objects$sd_scores)
  pls_objects$y_loadings <- c(pls_objects$y_loadings)

  row_nms <- paste0("ncomp_", 1:method$ncomp)
  colnames(pls_objects$projection_m) <-
    colnames(pls_objects$weights) <-
    colnames(pls_objects$x_loadings) <-
    names(pls_objects$x_means) <-
    colnames(pls_objects$coefficients) <- colnames(X)

  rownames(pls_objects$projection_m) <-
    rownames(pls_objects$weights) <-
    rownames(pls_objects$x_loadings) <-
    colnames(pls_objects$scores) <-
    names(pls_objects$sd_scores) <-
    colnames(pls_objects$scaled_scores) <-
    colnames(pls_objects$x_residuals) <-
    colnames(pls_objects$fitted_y) <-
    rownames(pls_objects$coefficients) <-
    names(pls_objects$y_loadings) <-
    rownames(pls_objects$cal_error) <- row_nms

  names(pls_objects$intercept) <- colnames(Y)
  colnames(pls_objects$cal_error) <- c("ncomp", "cal_set_error", "max_residuals")
  names(pls_objects$y_quantiles) <- c("0%", "25%", "50%", "75%", "100%")

  colnames(pls_objects$explained_variance$x_variance) <-
    colnames(pls_objects$explained_variance$y_variance) <- row_nms
  rownames(pls_objects$explained_variance$x_variance) <- c("pls_var", "x_expl_var", "x_expl_var_cum")
  rownames(pls_objects$explained_variance$y_variance) <- "y_explained_variance"

  if (!is.null(rownames(X))) {
    rownames(pls_objects$x_residuals) <-
      rownames(pls_objects$fitted_y) <-
      rownames(pls_objects$scores) <-
      rownames(pls_objects$scaled_scores) <- rownames(X)
  } else {
    rownames(pls_objects$x_residuals) <-
      rownames(pls_objects$fitted_y) <-
      rownames(pls_objects$scores) <-
      rownames(pls_objects$scaled_scores) <- 1:nrow(X)
  }

  model_obj <- c(
    list(
      method = method
    ),
    pls_objects
  )
  class(model_obj) <- c("spectral_fit", "list")
  model_obj
}

#' @aliases spectral_fit
#' @export
#' @keywords internal
predict.spectral_fit <- function(object, newdata, ...) {
  if (missing(newdata)) {
    stop("newdata is missing")
  }

  if (!"matrix" %in% class(newdata)) {
    stop("Argument 'newdata' must be a 'matrix'")
  }

  predictions <- scale(newdata, center = object$x_means, FALSE) %*% t(object$coefficients) + object$intercept

  colnames(predictions) <- rownames(object$coefficients)
  if (!is.null(rownames(newdata))) {
    rownames(predictions) <- rownames(newdata)
  } else {
    rownames(predictions) <- 1:nrow(newdata)
  }

  list(
    predictions = predictions
  )
}
