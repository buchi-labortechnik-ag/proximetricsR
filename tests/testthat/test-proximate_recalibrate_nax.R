# Test suite for proximate_recalibrate_nax()
# Tests cover recalibration of ProxiMate nax application files

data("NIRcannabis", package = "proximetricsR")

# ============================================================================
# Test group 1: Basic input validation
# ============================================================================

test_that("proximate_recalibrate_nax errors when x is not a nax object", {
  skip_on_cran()
  expect_error(
    warnings_emitted <- testthat::capture_warnings(
      proximate_recalibrate_nax(
        x = list(), # Not a nax object
        name = "test"
      )
    ),
    "argument of length 0"
  )
})

test_that("proximate_recalibrate_nax returns early with warning for protected models", {
  skip_on_cran()
  # Create a mock nax-like object with protected calibration models
  mock_nax <- list(
    data = list(summary = data.frame()),
    cal_info = list(summary = "Protected"),
    nad_info = list(summary = list())
  )

  class(mock_nax) <- "nax"

  expect_warning(
    result <- proximate_recalibrate_nax(mock_nax, name = "test"),
    "Protected"
  )
  expect_null(result)
})
