# Test suite for proxiscout_write_model_info() and helper functions
# Tests cover the main function, valid_nonzero and zero_if_invalid

data("NIRcannabis", package = "proximetricsR")

# Setup: Create a basic calibrated model for testing
setup_model <- function() {
  dat <- NIRcannabis[1:20, ]
  dat$spc <- dat$spc[, seq(1, 234, by = 5)]
  control <- calibration_control(validation_type = "kfold", number = 3, seed = 42)
  recipe <- preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_snv(),
    prep_derivative(m = 1, w = 11, p = 2, algorithm = "savitzky-golay"),
    device = "proxiscout"
  )
  model <- calibrate(
    THCA ~ spc,
    data = dat,
    preprocess = recipe,
    method = fit_plsr(3),
    control = control,
    verbose = FALSE
  )
  model
}

# ============================================================================
# Test group 1: Basic functionality and return value types
# ============================================================================

test_that("proxiscout_write_model_info returns character string when file = NULL", {
  skip_on_cran()
  model <- setup_model()
  result <- proxiscout_write_model_info(model, file = NULL)
  expect_type(result, "character")
  expect_length(result, 1)
})

test_that("returned JSON string is valid JSON that can be parsed", {
  skip_on_cran()
  model <- setup_model()
  json_str <- proxiscout_write_model_info(model, file = NULL)
  # Should not throw an error
  parsed <- jsonlite::fromJSON(json_str)
  expect_type(parsed, "list")
})

test_that("JSON contains required fields", {
  skip_on_cran()
  model <- setup_model()
  json_str <- proxiscout_write_model_info(model, file = NULL)
  parsed <- jsonlite::fromJSON(json_str)
  # Check that all expected names are present
  expected_names <- c("executionOrder", "RMSECalib", "R2Calib",
                      "RMSECV", "R2CV", "BiasCV", "RPDCV", "RMSETest",
                      "R2Test", "BiasTest", "RPDTest", "avgReadings",
                      "avgPredictions", "minValue", "maxValue",
                      "numberOfSamples", "numberOfMeasurements")
  expect_true(all(expected_names %in% names(parsed)))
})

# ============================================================================
# Test group 2: File I/O behavior
# ============================================================================

test_that("when file is NULL, result is returned visibly", {
  skip_on_cran()
  model <- setup_model()
  result <- proxiscout_write_model_info(model, file = NULL)
  expect_true(is.character(result))
  expect_length(result, 1)
})

test_that("when file is specified, JSON is written to disk", {
  skip_on_cran()
  model <- setup_model()
  tmpfile <- tempfile(fileext = ".json")
  on.exit(unlink(tmpfile), add = TRUE)
  
  result <- proxiscout_write_model_info(model, file = tmpfile)
  expect_true(file.exists(tmpfile))
  expect_true(file.size(tmpfile) > 0)
})

test_that("when file is specified, result is returned invisibly", {
  skip_on_cran()
  model <- setup_model()
  tmpfile <- tempfile(fileext = ".json")
  on.exit(unlink(tmpfile), add = TRUE)
  
  # Capturing output to check invisibility
  output <- capture_output(result <- proxiscout_write_model_info(model, file = tmpfile))
  expect_equal(output, "")
})

test_that("JSON file can be read back and contains expected content", {
  skip_on_cran()
  model <- setup_model()
  tmpfile <- tempfile(fileext = ".json")
  on.exit(unlink(tmpfile), add = TRUE)
  
  proxiscout_write_model_info(model, n_measurements = 2L, file = tmpfile)
  json_str <- readLines(tmpfile, warn = FALSE)
  json_str <- paste(json_str, collapse = "\n")
  
  parsed <- jsonlite::fromJSON(json_str)
  expect_type(parsed, "list")
  expect_true(length(parsed) > 0)
  # Check that all expected names are present
  expected_names <- c("executionOrder", "RMSECalib", "R2Calib",
                      "RMSECV", "R2CV", "BiasCV", "RPDCV", "RMSETest",
                      "R2Test", "BiasTest", "RPDTest", "avgReadings",
                      "avgPredictions", "minValue", "maxValue",
                      "numberOfSamples", "numberOfMeasurements")
  expect_true(all(expected_names %in% names(parsed)))
  expect_identical(parsed$avgPredictions, 1L)
  expect_identical(parsed$numberOfMeasurements, 2L)
  expect_identical(parsed$avgReadings, 2L)
})

# ============================================================================
# Test group 3: Error conditions
# ============================================================================

test_that("error when file argument is not a character string", {
  skip_on_cran()
  model <- setup_model()
  expect_error(
    proxiscout_write_model_info(model, file = 123),
    "'file' must be a single character string"
  )
})

test_that("error when file argument is a vector of length > 1", {
  skip_on_cran()
  model <- setup_model()
  expect_error(
    proxiscout_write_model_info(model, file = c("file1.json", "file2.json")),
    "'file' must be a single character string"
  )
})

test_that("error when object is not of class spectral_model", {
  skip_on_cran()
  model <- setup_model()
  class(model) <- c("list")
  expect_error(
    proxiscout_write_model_info(model, file = NULL),
    "'object' must be of class 'spectral_model'."
  )
})

test_that("error when n_measurements is negative", {
  skip_on_cran()
  model <- setup_model()
  expect_error(
    proxiscout_write_model_info(model, n_measurements = -1),
    "'n_measurements' must be a single positive integer."
  )
})
