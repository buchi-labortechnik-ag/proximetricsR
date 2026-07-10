data("NIRcannabis", package = "proximetricsR")
X <- NIRcannabis$spc[c(5, 28), 100:150] # reduce to save memory

# Round numeric results to 6 decimal places for platform-independent snapshots
round_result <- function(x, digits = 6) {
  round(x, digits)
}

test_that("Function returns named list if no spectrum given", {
  expect_named(prep_smooth(w = 5, p = 3), c("method", "w", "p", "algorithm", "half_w", "compatible_devices"))
  expect_true(inherits(prep_smooth(w = 15, algorithm = "moving-average"), c("preprocessing", "list")))
})

test_that("Instructions to compute smoothing are correctly saved if no spectrum given", {
  p_smooth <- prep_smooth(w = 5, algorithm = "moving-average")
  expect_identical(p_smooth$method, "prep_smooth")
  expect_identical(p_smooth$w, 5L)
  expect_null(p_smooth$p)
  expect_identical(p_smooth$algorithm, "moving-average")
  expect_identical(p_smooth$half_w, 2L)
  expect_identical(p_smooth$compatible_devices, "proximate")
})

test_that("Moving average with 0 sized window returns the matrix", {
  no_smooth <- process(X, prep_smooth(w = 1, algorithm = "moving-average"))
  attr(no_smooth, "processed_wavs") <- attr(no_smooth, "preprocess_recipe") <- NULL
  expect_identical(no_smooth, X)
})

test_that("Savitzky-Golay smoothing returns correct result", {
  expect_snapshot(round_result(process(X, prep_smooth(w = 3, p = 2, algorithm = "savitzky-golay"))))
})

test_that("Moving average returns correct result", {
  expect_snapshot(round_result(process(X, prep_smooth(w = 3, algorithm = "moving-average"))))
})

test_that("Window is automatically coerced to integer", {
  expect_identical(
    prep_smooth(w = as.character(pi), p = "2.5", algorithm = "savitzky-golay"),
    prep_smooth(w = 3, p = 2, algorithm = "savitzky-golay")
  )
})

#################
# SANITY CHECKS #
#################

test_that("Windows cannot be larger than the number of columns", {
  expect_error(process(X, prep_smooth(w = 150, algorithm = "moving-average")))
})

test_that("Window parameter must be numerical", {
  expect_error(prep_smooth(w = "", algorithm = "moving-average"), "'w' must be numeric.")
})

test_that("The window must be larger than 0", {
  expect_error(prep_smooth(w = -1, algorithm = "moving-average"), "'w' must be a positive odd integer")
})
