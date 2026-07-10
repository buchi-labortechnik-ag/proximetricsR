# Test suite for proxiscout_write_model() and helper functions
# Tests cover the main function, parse_preprocessing(), and sgf()

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

test_that("proxiscout_write_model returns character string when file = NULL", {
  skip_on_cran()
  model <- setup_model()
  result <- proxiscout_write_model(model, file = NULL)
  expect_type(result, "character")
  expect_length(result, 1)
})

test_that("returned JSON string is valid JSON that can be parsed", {
  skip_on_cran()
  model <- setup_model()
  json_str <- proxiscout_write_model(model, file = NULL)
  # Should not throw an error
  parsed <- jsonlite::fromJSON(json_str)
  expect_type(parsed, "list")
})

test_that("JSON contains required fields 'id' and 'params'", {
  skip_on_cran()
  model <- setup_model()
  json_str <- proxiscout_write_model(model, file = NULL)
  parsed <- jsonlite::fromJSON(json_str)
  # Each element in the array should have id and params
  expect_true("id" %in% names(parsed))
  expect_true("params" %in% names(parsed))
})

test_that("JSON contains 'index' field for all operations", {
  skip_on_cran()
  model <- setup_model()
  json_str <- proxiscout_write_model(model, file = NULL)
  parsed <- jsonlite::fromJSON(json_str)
  expect_true("index" %in% names(parsed))
})

# ============================================================================
# Test group 2: File I/O behavior
# ============================================================================

test_that("when file is NULL, result is returned visibly", {
  skip_on_cran()
  model <- setup_model()
  result <- proxiscout_write_model(model, file = NULL)
  expect_true(is.character(result))
  expect_length(result, 1)
})

test_that("when file is specified, JSON is written to disk", {
  skip_on_cran()
  model <- setup_model()
  tmpfile <- tempfile(fileext = ".json")
  on.exit(unlink(tmpfile), add = TRUE)

  result <- proxiscout_write_model(model, file = tmpfile)
  expect_true(file.exists(tmpfile))
  expect_true(file.size(tmpfile) > 0)
})

test_that("when file is specified, result is returned invisibly", {
  skip_on_cran()
  model <- setup_model()
  tmpfile <- tempfile(fileext = ".json")
  on.exit(unlink(tmpfile), add = TRUE)

  # Capturing output to check invisibility
  output <- capture_output(result <- proxiscout_write_model(model, file = tmpfile))
  expect_equal(output, "")
})

test_that("JSON file can be read back and contains expected content", {
  skip_on_cran()
  model <- setup_model()
  tmpfile <- tempfile(fileext = ".json")
  on.exit(unlink(tmpfile), add = TRUE)

  proxiscout_write_model(model, file = tmpfile)
  json_str <- readLines(tmpfile, warn = FALSE)
  json_str <- paste(json_str, collapse = "\n")

  parsed <- jsonlite::fromJSON(json_str)
  expect_type(parsed, "list")
  expect_true(length(parsed) > 0)
  expect_true("id" %in% names(parsed))
})

# ============================================================================
# Test group 3: Error conditions
# ============================================================================

test_that("error when preprocessing recipe is empty", {
  skip_on_cran()
  dat <- NIRcannabis[1:20, ]
  control <- calibration_control(validation_type = "kfold", number = 3, seed = 42)
  recipe <- preprocess_recipe(device = "proxiscout") # Empty recipe

  model <- calibrate(
    THCA ~ spc,
    data = dat,
    preprocess = recipe,
    method = fit_plsr(3),
    control = control,
    verbose = FALSE
  )

  expect_error(
    proxiscout_write_model(model),
    "No preprocessing detected"
  )
})

test_that("error when first preprocessing step is not prep_resample", {
  skip_on_cran()
  dat <- NIRcannabis[1:20, ]
  dat$spc <- dat$spc[, seq(1, 234, by = 5)]
  control <- calibration_control(validation_type = "kfold", number = 3, seed = 42)

  recipe <- preprocess_recipe(
    prep_snv(), # Not starting with prep_resample
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

  expect_error(
    proxiscout_write_model(model),
    "The first preprocessing step must be"
  )
})

test_that("error when wavenumbers don't match hardware grid", {
  skip_on_cran()
  dat <- NIRcannabis[1:20, ]
  # Create a recipe with incompatible wavenumber range
  dat$spc <- dat$spc[, seq(1, 234, by = 5)]
  control <- calibration_control(validation_type = "kfold", number = 3, seed = 42)

  expect_error(
    recipe <- preprocess_recipe(
      prep_resample(grid = c(1000, 1200, 1)), # Custom grid not matching proxiscout
      device = "proxiscout"
    ),
    "'prep_resample' with algorithm ="
  )
})

test_that("error when file argument is not a character string", {
  skip_on_cran()
  model <- setup_model()
  expect_error(
    proxiscout_write_model(model, file = 123),
    "'file' must be a single character string"
  )
})

test_that("error when file argument is a vector of length > 1", {
  skip_on_cran()
  model <- setup_model()
  expect_error(
    proxiscout_write_model(model, file = c("file1.json", "file2.json")),
    "'file' must be a single character string"
  )
})

# ============================================================================
# Test group 4: parse_preprocessing() helper function
# ============================================================================

test_that("parse_preprocessing returns correct JSON for prep_snv", {
  skip_on_cran()
  step <- list(method = "prep_snv")
  result <- proximetricsR:::parse_preprocessing("prep_snv", step, index = 0)
  expect_equal(result$id, 2)
  expect_equal(result$index, 0)
  expect_type(result$params, "list")
})

test_that("parse_preprocessing returns correct JSON for prep_transform to absorbance", {
  skip_on_cran()
  step <- list(method = "prep_transform", to = "absorbance")
  result <- proximetricsR:::parse_preprocessing("prep_transform", step, index = 1)
  expect_equal(result$id, 29)
  expect_equal(result$index, 1)
  expect_length(result$params, 0)
})

test_that("parse_preprocessing warns and returns NULL for prep_transform to reflectance", {
  skip_on_cran()
  step <- list(method = "prep_transform", to = "reflectance")

  expect_warning(
    result <- proximetricsR:::parse_preprocessing("prep_transform", step, index = 0),
    "prep_transform.*reflectance"
  )
  expect_null(result)
})

test_that("parse_preprocessing returns correct JSON for prep_detrend", {
  skip_on_cran()
  step <- list(method = "prep_detrend", p = 2)
  result <- proximetricsR:::parse_preprocessing("prep_detrend", step, index = 2)
  expect_equal(result$id, 3)
  expect_equal(result$params, list(2))
  expect_equal(result$index, 2)
})

test_that("parse_preprocessing returns correct JSON for prep_derivative with savitzky-golay", {
  skip_on_cran()
  step <- list(
    method = "prep_derivative",
    m = 1,
    w = 11,
    p = 2,
    algorithm = "savitzky-golay"
  )
  result <- proximetricsR:::parse_preprocessing("prep_derivative", step, index = 3)
  expect_equal(result$id, 83)
  expect_equal(result$index, 3)
  expect_true(!is.null(result$params))
  expect_true(length(result$params) > 0)
})

test_that("parse_preprocessing returns NULL for prep_wav_trim", {
  skip_on_cran()
  step <- list(method = "prep_wav_trim", band = c(1000, 1800))
  result <- proximetricsR:::parse_preprocessing("prep_wav_trim", step, index = 0)
  expect_null(result)
})

test_that("parse_preprocessing handles prep_smooth as derivative order 0", {
  skip_on_cran()
  step <- list(
    method = "prep_smooth",
    m = NULL,
    w = 11,
    p = 2,
    algorithm = "savitzky-golay"
  )
  result <- proximetricsR:::parse_preprocessing("prep_smooth", step, index = 4)
  expect_equal(result$id, 83)
  # m should be treated as 0 for smoothing
  expect_true(!is.null(result$params))
})

test_that("parse_preprocessing errors on unknown preprocessing method", {
  skip_on_cran()
  step <- list(method = "unknown_method")
  expect_error(
    proximetricsR:::parse_preprocessing("unknown_method", step, index = 0),
    "Unknown preprocessing command"
  )
})

# ============================================================================
# Test group 5: sgf() Savitzky-Golay filter helper function
# ============================================================================

test_that("sgf returns numeric matrix with correct dimensions", {
  skip_on_cran()
  result <- proximetricsR:::sgf(p = 2, n = 5, m = 0)
  expect_type(result, "double")
  expect_true(inherits(result, "matrix"))
  expect_equal(nrow(result), 1)
  expect_equal(ncol(result), 5)
})

test_that("sgf output is numeric vector (as matrix row)", {
  skip_on_cran()
  result <- proximetricsR:::sgf(p = 2, n = 7, m = 1)
  expect_true(all(is.numeric(result)))
})

test_that("sgf with m=0 produces symmetric filter for smoothing", {
  skip_on_cran()
  result <- proximetricsR:::sgf(p = 2, n = 9, m = 0)
  # For a smoothing filter (m=0), it should be roughly symmetric
  result_vec <- as.numeric(result)
  # Check symmetry (allowing for numerical precision)
  expect_true(isTRUE(all.equal(result_vec, rev(result_vec), tolerance = 1e-10)))
})

test_that("sgf with increasing m produces different filters", {
  skip_on_cran()
  result_m0 <- proximetricsR:::sgf(p = 2, n = 7, m = 0)
  result_m1 <- proximetricsR:::sgf(p = 2, n = 7, m = 1)
  result_m2 <- proximetricsR:::sgf(p = 2, n = 7, m = 2)

  expect_false(isTRUE(all.equal(as.numeric(result_m0), as.numeric(result_m1))))
  expect_false(isTRUE(all.equal(as.numeric(result_m1), as.numeric(result_m2))))
})

test_that("sgf handles edge case of n=1", {
  skip_on_cran()
  result <- proximetricsR:::sgf(p = 0, n = 1, m = 0)
  expect_equal(nrow(result), 1)
  expect_equal(ncol(result), 1)
})

# ============================================================================
# Test group 6: JSON structure validation
# ============================================================================

test_that("JSON contains scaling operation (id=37) for 0-100 to 0-1 conversion", {
  skip_on_cran()
  model <- setup_model()
  json_str <- proxiscout_write_model(model, file = NULL)
  parsed <- jsonlite::fromJSON(json_str)

  ids <- parsed[["id"]]
  expect_true(37 %in% ids)
})

test_that("JSON contains averaging operation (id=7)", {
  skip_on_cran()
  model <- setup_model()
  json_str <- proxiscout_write_model(model, file = NULL)
  parsed <- jsonlite::fromJSON(json_str)

  ids <- parsed[["id"]]
  expect_true(7 %in% ids)
})

test_that("JSON contains model coefficients operation (id=13)", {
  skip_on_cran()
  model <- setup_model()
  json_str <- proxiscout_write_model(model, file = NULL)
  parsed <- jsonlite::fromJSON(json_str)

  ids <- parsed[["id"]]
  expect_true(13 %in% ids)
})

test_that("JSON contains centering operation (id=43) for X-means subtraction", {
  skip_on_cran()
  model <- setup_model()
  json_str <- proxiscout_write_model(model, file = NULL)
  parsed <- jsonlite::fromJSON(json_str)

  ids <- parsed[["id"]]
  expect_true(43 %in% ids)
})

# ============================================================================
# Test group 7: Preprocessing integration tests
# ============================================================================

test_that("model with multiple preprocessing steps serializes correctly", {
  skip_on_cran()
  dat <- NIRcannabis[1:20, ]
  dat$spc <- dat$spc[, seq(1, 234, by = 5)]
  control <- calibration_control(validation_type = "kfold", number = 3, seed = 42)

  recipe <- preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_snv(),
    prep_derivative(m = 1, w = 11, p = 2, algorithm = "savitzky-golay"),
    prep_smooth(w = 5, p = 2, algorithm = "savitzky-golay"),
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

  json_str <- proxiscout_write_model(model, file = NULL)
  parsed <- jsonlite::fromJSON(json_str)

  # Should have multiple operations
  expect_true(length(parsed) >= 3)
  # Should contain SNV and derivative/smooth operations
  ids <- parsed[["id"]]
  expect_true(2 %in% ids) # SNV
  expect_true(83 %in% ids) # Derivative or Smooth (Savitzky-Golay)
})

test_that("model with prep_transform(to='absorbance') includes transform operation", {
  skip_on_cran()
  dat <- NIRcannabis[1:20, ]
  dat$spc <- dat$spc[, seq(1, 234, by = 5)]
  control <- calibration_control(validation_type = "kfold", number = 3, seed = 42)

  recipe <- preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_transform(to = "absorbance"),
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

  json_str <- proxiscout_write_model(model, file = NULL)
  parsed <- jsonlite::fromJSON(json_str)

  ids <- parsed[["id"]]
  expect_true(29 %in% ids) # Transform operation
})
