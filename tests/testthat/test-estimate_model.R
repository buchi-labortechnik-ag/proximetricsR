# Use only a small subset of NIRcannabis
data("NIRcannabis", package = "proximetricsR")

# Helper function to round numeric values to 6 decimal places (5 for tolerant tests)
round_numeric <- function(x, digits = 6) {
  if (is.numeric(x)) {
    return(round(x, digits))
  } else if (is.list(x)) {
    return(lapply(x, round_numeric, digits = digits))
  } else if (is.matrix(x) || is.data.frame(x)) {
    return(round(x, digits))
  }
  return(x)
}

round_numeric_tol <- function(x, digits = 5) {
  if (is.numeric(x)) {
    return(round(x, digits))
  } else if (is.list(x)) {
    return(lapply(x, round_numeric_tol, digits = digits))
  } else if (is.matrix(x) || is.data.frame(x)) {
    return(round(x, digits))
  }
  return(x)
}


test_that("Modified partial least squares computes the correct results", {
  X <- NIRcannabis$spc[seq(1, 80, by = 15), seq(1, ncol(NIRcannabis$spc), by = 20)]
  Y <- NIRcannabis$CBD[seq(1, 80, by = 15)]
  model_result <- .estimate_model(X, Y, fit_plsr(5, "modified"))
  expect_true(inherits(model_result, "spectral_fit"))
  class(model_result) <- "list"
  expect_snapshot(round_numeric(model_result))
})

test_that("Standard partial least squares computes the correct results", {
  X <- NIRcannabis$spc[seq(2, 80, by = 15), seq(2, ncol(NIRcannabis$spc), by = 20)]
  Y <- NIRcannabis$CBDA[seq(2, 80, by = 15)]
  model_result <- .estimate_model(X, Y, fit_plsr(4, "standard"))
  expect_true(inherits(model_result, "spectral_fit"))
  class(model_result) <- "list"
  expect_snapshot(round_numeric(model_result))
})

test_that("NIRWise PLUS partial least squares computes the correct results", {
  X <- NIRcannabis$spc[seq(3, 80, by = 15), seq(3, ncol(NIRcannabis$spc), by = 20)]
  Y <- NIRcannabis$CBD[seq(3, 80, by = 15)]
  model_result <- .estimate_model(X, Y, fit_plsr(5, "nwp"))
  expect_true(inherits(model_result, "spectral_fit"))
  class(model_result) <- "list"
  expect_snapshot(round_numeric(model_result))
})

test_that("Modified extended partial least squares computes the correct results", {
  X <- NIRcannabis$spc[seq(4, 80, by = 15), seq(4, ncol(NIRcannabis$spc), by = 20)]
  Y <- NIRcannabis$THC[seq(4, 80, by = 15)]
  model_result <- .estimate_model(X, Y, fit_xlsr(3, "modified", min_w = 5, max_w = 10))
  expect_true(inherits(model_result, "spectral_fit"))
  class(model_result) <- "list"
  expect_snapshot(round_numeric(model_result))
})

test_that("Standard extended partial least squares computes the correct results", {
  X <- NIRcannabis$spc[seq(5, 80, by = 15), seq(5, ncol(NIRcannabis$spc), by = 20)]
  Y <- NIRcannabis$CBD[seq(5, 80, by = 15)]
  model_result <- .estimate_model(X, Y, fit_xlsr(4, "standard"))
  expect_true(inherits(model_result, "spectral_fit"))
  class(model_result) <- "list"
  expect_snapshot(round_numeric(model_result))
})

test_that("NIRWise PLUS extended partial least squares computes the correct results", {
  X <- NIRcannabis$spc[seq(5, 80, by = 15), seq(6, ncol(NIRcannabis$spc), by = 20)]
  Y <- NIRcannabis$THCA[seq(5, 80, by = 15)]
  model_result <- .estimate_model(X, Y, fit_xlsr(5, "nwp", min_w = 2, max_w = 4))
  expect_true(inherits(model_result, "spectral_fit"))
  class(model_result) <- "list"
  expect_snapshot(round_numeric(model_result))
})

test_that("The regression method is printed correctly", {
  X <- NIRcannabis$spc[seq(6, 80, by = 15), seq(6, ncol(NIRcannabis$spc), by = 20)]
  Y <- NIRcannabis$THCA[seq(6, 80, by = 15)]
  model_result <- .estimate_model(X, Y, fit_xlsr(3, "nwp", min_w = 1, max_w = 3))
  model_result$method$method <- "xls"
  expect_snapshot(print(round_numeric_tol(model_result)))
})

test_that("Basic regression is printed correctly", {
  X <- NIRcannabis$spc[seq(6, 80, by = 15), seq(6, ncol(NIRcannabis$spc), by = 20)]
  Y <- NIRcannabis$THCA[seq(6, 80, by = 15)]
  model_result <- .estimate_model(X, Y, fit_plsr(4, "modified"))
  model_result$n_observations <- NULL
  expect_snapshot(print(round_numeric(model_result)))
})

#################
# SANITY CHECKS #
#################

test_that("Method for regression models must be of class 'fit_constructor'", {
  expect_error(.estimate_model(X, Y, list(5)), "'method' must be of class 'fit_constructor'.")
})

test_that("The reference values must be a matrix of a single column", {
  X <- Y <- matrix(5)
  expect_error(.estimate_model(X, cbind(Y, Y)), "'Y' must be a matrix with one single column.")
})

test_that("The number of observations must match the number of reference values", {
  X <- Y <- matrix(5)
  expect_error(.estimate_model(X, c(Y, Y)), "The number of observations in 'X' does not match with the number of observations in 'Y'.")
})

test_that("Predicting from spectral_fit requires newdata", {
  s_model <- .estimate_model(matrix(5), matrix(5))
  expect_error(predict(s_model), "newdata is missing")
})

test_that("Predicting from spectral_fit requires newdata as a matrix", {
  s_model <- .estimate_model(matrix(5), matrix(5))
  expect_error(predict(s_model, c(5)), "Argument 'newdata' must be a 'matrix'")
})
