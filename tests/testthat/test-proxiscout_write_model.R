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

















































train_path <- test_path("testdata", "ProxiScout_SoyaCake_Train.xlsx")

test_data_path <- test_path("testdata", "SoyaCake_Test.xlsx")

# ---- helpers --------------------------------------------------------

read_train <- function() {
  proximetricsR:::proxiscout_read_data(train_path)
}

read_test <- function() {
  proximetricsR:::proxiscout_read_data(test_data_path)
}

fit_hum_model <- function(recipe, data, ncomp = 7, type = "modified") {
  calibrate(
    HUM ~ spc,
    data = data,
    preprocess = recipe,
    method = fit_plsr(ncomp = ncomp, type = type),
    control = calibration_control(
      validation_type = "kfold", number = 5, seed = 42
    ),
    verbose = FALSE
  )
}

# structural sanity checks that hold for *any* valid ProxiScout JSON,
# independent of the specific recipe -- catches gross breakage (wrong ids,
# duplicate/negative indices, missing model coefficients) even before a
# snapshot is available to compare against.
expect_valid_proxiscout_json <- function(json_string) {
  parsed <- jsonlite::fromJSON(json_string, simplifyVector = FALSE)
  expect_type(parsed, "list")
  expect_true(length(parsed) >= 5)
  
  ids <- vapply(parsed, function(x) x$id, numeric(1))
  indices <- vapply(parsed, function(x) x$index, numeric(1))
  
  # hardware-mandatory steps that must always be present regardless of recipe
  expect_true(31 %in% ids) # wavelength -> wavenumber conversion
  expect_true(37 %in% ids) # 0-100 -> 0-1 reflectance scaling
  expect_true(7  %in% ids) # averaging repeated scans
  expect_true(43 %in% ids) # X-mean centering
  expect_true(13 %in% ids) # model coefficients
  
  expect_equal(anyDuplicated(indices), 0)
  expect_true(all(indices >= 0))
  
  # the model step (id 13) must carry the highest index -- it's always
  # written last
  model_step <- parsed[[which(ids == 13)]]
  expect_equal(model_step$index, max(indices))
  
  invisible(parsed)
}

# structural sanity check for predict() output -- independent of the
# specific recipe/model, catches gross breakage (wrong row count, NAs,
# non-numeric output) even before a snapshot is available to compare
# against.
expect_valid_predictions <- function(preds, expected_n) {
  expect_true(is.list(preds))
  expect_true("predictions" %in% names(preds))
  expect_true(is.numeric(preds$predictions))
  expect_equal(NROW(preds$predictions), expected_n)
  expect_false(anyNA(preds$predictions))
  invisible(preds$predictions)
}

# ---- pure-function unit tests (no model fitting required) -----------
# These exercise parse_preprocessing() and sgf() directly and run in
# milliseconds -- keep them even if you switch the integration tests
# below to literal fixtures, since they catch id/param-mapping bugs
# without needing a fitted model at all.

test_that("parse_preprocessing dispatches prep_snv to id 2", {
  step <- proximetricsR:::parse_preprocessing("prep_snv", list(), index = 5)
  expect_equal(step, list(id = 2, params = list(), index = 5))
})

test_that("parse_preprocessing dispatches prep_detrend to id 3 with p", {
  step <- proximetricsR:::parse_preprocessing("prep_detrend", list(p = 2), index = 3)
  expect_equal(step, list(id = 3, params = list(2), index = 3))
})

test_that("parse_preprocessing returns NULL for prep_resample and prep_wav_trim", {
  expect_null(proximetricsR:::parse_preprocessing("prep_resample", list(), index = 0))
  expect_null(proximetricsR:::parse_preprocessing("prep_wav_trim", list(), index = 0))
})

test_that("parse_preprocessing maps prep_transform(to='absorbance') to id 29", {
  step <- proximetricsR:::parse_preprocessing(
    "prep_transform", list(to = "absorbance"), index = 1
  )
  expect_equal(step, list(id = 29, params = list(), index = 1))
})

test_that("parse_preprocessing warns and drops prep_transform(to='reflectance')", {
  expect_warning(
    step <- proximetricsR:::parse_preprocessing(
      "prep_transform", list(to = "reflectance"), index = 1
    ),
    "not supported by ProxiScout"
  )
  expect_null(step)
})

test_that("parse_preprocessing errors on non-Savitzky-Golay derivative/smooth", {
  expect_error(
    proximetricsR:::parse_preprocessing(
      "prep_derivative",
      list(m = 1, w = 5, p = 2, algorithm = "norris-williams"),
      index = 0
    ),
    "Only 'savitzky-golay' is supported"
  )
})

test_that("parse_preprocessing errors on an unknown preprocessing method", {
  expect_error(
    proximetricsR:::parse_preprocessing("prep_made_up", list(), index = 0),
    "Unknown preprocessing command"
  )
})

test_that("parse_preprocessing treats prep_smooth as a 0th-order derivative", {
  # prep_smooth has no 'm' -- parse_preprocessing must default it to 0L
  # rather than erroring or passing NULL through to sgf()
  step <- proximetricsR:::parse_preprocessing(
    "prep_smooth",
    list(m = NULL, w = 5, p = 2, algorithm = "savitzky-golay"),
    index = 2
  )
  expect_equal(step$id, 83)
  expect_equal(step$index, 2)
  expect_equal(step$params[[3]], 0L) # params = [w, p, m, mode, 1.0, 0.0, ...]
})

test_that("sgf returns a 1 x n coefficient matrix", {
  f <- proximetricsR:::sgf(p = 2, n = 9, m = 0)
  expect_equal(dim(f), c(1, 9))
})

test_that("sgf smoothing coefficients (m = 0) sum to 1", {
  # a Savitzky-Golay smoothing filter is a weighted average of the window,
  # so applying it to a constant signal must return that same constant
  f <- proximetricsR:::sgf(p = 2, n = 9, m = 0)
  expect_equal(sum(f), 1, tolerance = 1e-8)
})

test_that("sgf derivative coefficients (m > 0) sum to ~0", {
  # a derivative filter applied to a constant signal must return 0
  f <- proximetricsR:::sgf(p = 2, n = 9, m = 1)
  expect_equal(sum(f), 0, tolerance = 1e-8)
})

# ---- error paths of proxiscout_write_model() -------------------------
# These use minimal stub objects rather than a fitted model, since both
# checks fire before the function touches anything else.

test_that("proxiscout_write_model errors when there is no preprocessing", {
  stub <- list(preprocess = list(steps = list()))
  expect_error(proxiscout_write_model(stub), "No preprocessing detected")
})

test_that("proxiscout_write_model errors when the first step isn't prep_resample", {
  stub <- list(preprocess = list(steps = list(list(method = "prep_snv"))))
  expect_error(
    proxiscout_write_model(stub),
    "first preprocessing step must be 'prep_resample"
  )
})

test_that("proxiscout_write_model rejects a non-scalar-character file argument", {
  stub_recipe <- preprocess_recipe(
    prep_resample(grid = "proxiscout"), device = "proxiscout"
  )
  model <- fit_hum_model(stub_recipe, data = read_train())
  expect_error(
    proxiscout_write_model(model, file = c("a.json", "b.json")),
    "'file' must be a single character string"
  )
})

# ---- integration / snapshot tests: recipes 00-14 ---------------------

mdata_full <- read_train()
to_pred_full <- read_test()

recipes <- list(
  "00" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_derivative(m = 2, w = 9, p = 2, algorithm = "savitzky-golay"),
    prep_snv(),
    prep_smooth(w = 3, p = 2, algorithm = "savitzky-golay"),
    device = "proxiscout"
  ),
  "01" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_derivative(m = 2, w = 9, p = 2, algorithm = "savitzky-golay"),
    prep_snv(),
    device = "proxiscout"
  ),
  "02" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_snv(),
    prep_derivative(m = 2, w = 9, p = 2, algorithm = "savitzky-golay"),
    device = "proxiscout"
  ),
  "03" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_derivative(m = 2, w = 9, p = 2, algorithm = "savitzky-golay"),
    prep_detrend(p = 2),
    device = "proxiscout"
  ),
  "04" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_transform(to = "absorbance"),
    prep_derivative(m = 1, w = 5, p = 1, algorithm = "savitzky-golay"),
    prep_snv(),
    device = "proxiscout"
  ),
  "05" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_detrend(p = 2),
    prep_derivative(m = 1, w = 5, p = 1, algorithm = "savitzky-golay"),
    prep_snv(),
    device = "proxiscout"
  ),
  "06" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_transform(to = "absorbance"),
    prep_snv(),
    device = "proxiscout"
  ),
  "09" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_derivative(m = 1, w = 3, p = 2, algorithm = "savitzky-golay"),
    prep_snv(),
    device = "proxiscout"
  ),
  "10" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_snv(),
    prep_detrend(p = 2),
    prep_derivative(m = 1, w = 5, p = 1, algorithm = "savitzky-golay"),
    device = "proxiscout"
  ),
  "11" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_smooth(w = 11, p = 1, algorithm = "savitzky-golay"),
    prep_detrend(p = 2),
    prep_derivative(m = 1, w = 5, p = 1, algorithm = "savitzky-golay"),
    device = "proxiscout"
  ),
  "12" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_derivative(m = 1, w = 7, p = 1, algorithm = "savitzky-golay"),
    device = "proxiscout"
  ),
  "13" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_derivative(m = 1, w = 5, p = 1, algorithm = "savitzky-golay"),
    prep_snv(),
    device = "proxiscout"
  ),
  "14" = preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_derivative(m = 1, w = 7, p = 1, algorithm = "savitzky-golay"),
    prep_snv(),
    device = "proxiscout"
  )
)

# recipe_06 alone uses fit_plsr(type = "standard") in my-tests.R; every
# other recipe uses "modified"
recipe_methods <- setNames(rep("modified", length(recipes)), names(recipes))
recipe_methods[["06"]] <- "standard"

for (rid in names(recipes)) {
  local({
    rid <- rid # force per-iteration binding inside the loop
    test_that(paste0("my_serialised_model_", rid), {
      model <- fit_hum_model(
        recipes[[rid]], data = mdata_full, type = recipe_methods[[rid]]
      )
      json_out <- proxiscout_write_model(model, file = NULL)
      expect_valid_proxiscout_json(json_out)
      expect_snapshot_value(json_out, style = "json2")
      
      preds <- predict(model, newdata = to_pred_full, verbose = FALSE)
      expect_valid_predictions(preds, nrow(to_pred_full))
      expect_snapshot_value(preds$predictions, style = "json2")
    })
  })
}

# ---- recipes 07 and 08: cropped-spectra variable-selection branch ----
# These crop the training spectra (columns 1:11 and 244:246 removed, per
# my-tests.R) before fitting, which forces proxiscout_write_model() down
# the id=17 variable-selection branch that matches the trimmed predictor
# wavenumbers back onto the full ProxiScout hardware grid. This is the
# branch most likely to silently break on a hardware-grid change, since
# nothing else in the recipe signals that cropping happened.

test_that("my_serialised_model_07", {
  mdata_cropped <- mdata_full
  mdata_cropped$spc <- mdata_cropped$spc[, -c(1:11)]
  mdata_cropped$spc <- mdata_cropped$spc[, -c(244:246)]
  
  recipe_07 <- preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_transform(to = "absorbance"),
    device = "proxiscout"
  )
  model_07 <- fit_hum_model(recipe_07, data = mdata_cropped, type = "standard")
  json_out <- proxiscout_write_model(model_07, file = NULL)
  parsed <- expect_valid_proxiscout_json(json_out)
  
  ids <- vapply(parsed, function(x) x$id, numeric(1))
  expect_true(17 %in% ids) # crop must produce an explicit variable-selection step
  
  expect_snapshot_value(json_out, style = "json2")
  
  # to_pred is NEVER cropped in my-tests.R, even for models fit on cropped
  # training spectra -- predict() is expected to realign wavenumbers
  # internally via the model's stored recipe/predictor_variables
  preds <- predict(model_07, newdata = to_pred_full, verbose = FALSE)
  expect_valid_predictions(preds, nrow(to_pred_full))
  expect_snapshot_value(preds$predictions, style = "json2")
})

test_that("my_serialised_model_08", {
  mdata_cropped <- mdata_full
  mdata_cropped$spc <- mdata_cropped$spc[, -c(1:11)]
  mdata_cropped$spc <- mdata_cropped$spc[, -c(244:246)]
  
  recipe_08 <- preprocess_recipe(
    prep_resample(grid = "proxiscout"), device = "proxiscout"
  )
  model_08 <- fit_hum_model(recipe_08, data = mdata_cropped, type = "standard")
  json_out <- proxiscout_write_model(model_08, file = NULL)
  parsed <- expect_valid_proxiscout_json(json_out)
  
  ids <- vapply(parsed, function(x) x$id, numeric(1))
  expect_true(17 %in% ids)
  
  expect_snapshot_value(json_out, style = "json2")
  
  preds <- predict(model_08, newdata = to_pred_full, verbose = FALSE)
  expect_valid_predictions(preds, nrow(to_pred_full))
  expect_snapshot_value(preds$predictions, style = "json2")
})

# ---- file = NULL vs file = <path> consistency -------------------------

test_that("proxiscout_write_model writes identical JSON to file and to console", {
  model <- fit_hum_model(recipes[["12"]], data = mdata_full)
  json_console <- proxiscout_write_model(model, file = NULL)
  
  tmp <- tempfile(fileext = ".json")
  on.exit(unlink(tmp), add = TRUE)
  ret <- proxiscout_write_model(model, file = tmp)
  
  expect_true(file.exists(tmp))
  json_file <- paste(readLines(tmp), collapse = "\n")
  # jsonlite's toJSON() tags its return value with class "json" (a character
  # subclass used for pretty-printing); readLines() on the written file has
  # no such class, so compare content only via as.character()
  expect_equal(as.character(json_file), as.character(json_console))
  expect_equal(as.character(ret), as.character(json_console)) # returned invisibly when file is given
})
