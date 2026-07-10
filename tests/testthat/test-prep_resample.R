data("NIRcannabis", package = "proximetricsR")
X <- NIRcannabis$spc[c(11, 56), seq(1, 230, by = 5)] # reduce to save memory

test_that("Function returns named list if no spectrum given", {
  spline_recipe <- prep_resample(c(5, 10, 100))
  expect_named(spline_recipe, c("method", "min_wav", "max_wav", "resolution", "compatible_devices"))
  expect_true(inherits(spline_recipe, c("preprocessing", "list")))
})

test_that("Instructions to compute splines are correctly saved if no spectrum given", {
  spline_recipe <- prep_resample(c(100, 200, 5))
  expect_true(spline_recipe$method == "prep_resample")
  expect_identical(spline_recipe$min_w, 100)
  expect_identical(spline_recipe$max_w, 200)
  expect_identical(spline_recipe$resolution, 5)
})

test_that("Splines returns correct result", {
  expect_snapshot(process(X, preprocess_recipe(prep_resample(c(1001, 1601, 100)), device = "unspecified")))
  expect_snapshot(process(X, preprocess_recipe(prep_resample(c(1001, 1676, 10)), device = "unspecified")))
})

test_that("Using the same wavelengths does not change X", {
  X_rand <- matrix(rnorm(500), 5, 100, dimnames = list(NULL, seq(1000, 1699, by = 7)))
  X_pp <- process(X_rand, preprocess_recipe(prep_resample(c(1000, 1699, 7)), device = "unspecified"))
  attr(X_pp, "processed_wavs") <- attr(X_pp, "preprocess_recipe") <- NULL
  expect_equal(X_rand, X_pp)
})

test_that("Wavelength and resolution parameters must be numerical", {
  expect_error(prep_resample(c(list(), 5, 2)))
})
