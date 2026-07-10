data("NIRcannabis", package = "proximetricsR")
X <- NIRcannabis$spc[1:2, 100:150] # reduce to save memory
derivative_noX <- prep_derivative(m = 1, w = 3, p = 7, algorithm = "nwp")

# Round numeric results to 6 decimal places for platform-independent snapshots
round_result <- function(x, digits = 6) {
  round(x, digits)
}

test_that("Function returns named list if no spectrum given", {
  expect_named(derivative_noX, c("method", "m", "w", "p", "algorithm", "half_w", "half_s", "compatible_devices"))
  expect_true(inherits(derivative_noX, c("preprocessing", "list")))
})

test_that("Instructions to compute derivative are correctly saved if no spectrum given", {
  expect_true(derivative_noX$method == "prep_derivative")
  expect_identical(derivative_noX$m, 1L)
  expect_identical(derivative_noX$w, 3L)
  expect_identical(derivative_noX$p, 7L)
  expect_identical(derivative_noX$algorithm, "nwp")
  expect_identical(derivative_noX$half_w, 2L)
  expect_identical(derivative_noX$half_s, 3L)
  expect_identical(derivative_noX$compatible_devices, "proximate")
})

test_that("derivatives without smoothing returns correct result", {
  expect_snapshot(round_result(process(X, prep_derivative(m = 1, w = 9, p = 1, algorithm = "nwp"))))
  expect_snapshot(round_result(process(X, prep_derivative(m = 2, w = 39, p = 1, algorithm = "nwp"))))
})

test_that("first derivative with smoothing works", {
  expect_snapshot(round_result(process(X, prep_derivative(m = 1, w = 5, p = 23, algorithm = "nwp"))))
})

test_that("second derivative with smoothing works", {
  expect_snapshot(round_result(process(X, prep_derivative(m = 1, w = 13, p = 31, algorithm = "nwp"))))
})

test_that("Order and windows are automatically coerced to integer", {
  expect_identical(prep_derivative(m = "1.5", w = "3.1", p = as.character(pi * 2.5), algorithm = "nwp"), derivative_noX)
})

#################
# SANITY CHECKS #
#################

test_that("Window parameters must be numerics", {
  expect_error(prep_derivative(half_w = "", half_s = 1))
  expect_error(prep_derivative(half_w = 1, half_s = ""))
})

test_that("Only first and second order derivatives are supported", {
  expect_error(prep_derivative(m = 3, half_w = 3, half_s = 3))
})

test_that("Derivative must be convertable to numeric", {
  expect_error(prep_derivative(m = "1s", half_w = 3, half_s = 3))
})

test_that("Windows cannot be larger than the number of columns", {
  expect_error(prep_derivative(X, m = 1, half_w = 150, half_s = 1))
  expect_error(prep_derivative(X, m = 1, half_w = 1, half_s = 150))
})
