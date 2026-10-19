# Test suite for proximate_recalibrate_nax()
# Tests cover recalibration of ProxiMate nax application files

data("proximateCannabis", package = "proximetricsR")

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

test_that("proximate_recalibrate_nax works without units and with special property names", {
  skip_on_cran()
  dat <- proximateCannabis[seq(1, 80, by = 2), ]
  colnames(dat)[colnames(dat) == "CBD"] <- "CBD (%)?"
  # The default metadata has an empty unit
  model <- calibrate(
    `CBD (%)?` ~ spc,
    data = dat, method = fit_plsr(5), verbose = FALSE, return_inputs = TRUE,
    metadata = add_model_metadata(key = "", created = "T", changed = "T")
  )
  nax_dir <- file.path(tempdir(), "recalibrate_nax")
  app_meta <- add_application_metadata(name = "recalibrate", key = "", created = "T", changed = "T")
  suppressMessages(proximate_write_nax(list(model), path = nax_dir, metadata = app_meta, verbose = FALSE))
  nax <- proximate_read_nax(file.path(nax_dir, "recalibrate.nax"))

  result <- suppressWarnings(proximate_recalibrate_nax(
    nax,
    methods = list(fit_plsr(5)),
    control = calibration_control(validation_type = "kfold", number = 3)
  ))
  expect_equal(result[[1]]$target_variable, "CBD_(%)")
  expect_equal(result[[1]]$metadata$Unit, "")
  unlink(nax_dir, recursive = TRUE)
})
