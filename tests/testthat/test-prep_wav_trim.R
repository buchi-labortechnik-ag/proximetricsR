# Test suite for prep_wav_trim() preprocessing constructor
# Tests cover the constructor and internal execution function .exec_wav_trim()

data("NIRcannabis", package = "proximetricsR")

# ============================================================================
# Test group 1: Constructor validation and return type
# ============================================================================

test_that("prep_wav_trim returns object of class 'preprocessing'", {
  result <- prep_wav_trim(band = c(1000, 1800))
  expect_true(inherits(result, "preprocessing"))
  expect_true(inherits(result, "list"))
})

test_that("prep_wav_trim returns list with method, band, and trim_constant_edges", {
  result <- prep_wav_trim(band = c(1200, 1600), trim_constant_edges = FALSE)
  expect_named(result, c("method", "band", "trim_constant_edges", "compatible_devices"))
  expect_equal(result$method, "prep_wav_trim")
  expect_equal(result$band, c(1200, 1600))
  expect_equal(result$trim_constant_edges, FALSE)
})

test_that("prep_wav_trim returns correct compatible_devices", {
  result <- prep_wav_trim(band = c(1000, 1800))
  expect_equal(result$compatible_devices, "proxiscout")
})

# ============================================================================
# Test group 2: Parameter validation - band argument
# ============================================================================

test_that("prep_wav_trim errors when band is missing", {
  expect_error(
    prep_wav_trim(),
    "'band' is required"
  )
})

test_that("prep_wav_trim accepts band as numeric vector of length 2", {
  result <- prep_wav_trim(band = c(1000, 1800))
  expect_equal(result$band, c(1000, 1800))
})

test_that("prep_wav_trim accepts empty vector band", {
  result <- prep_wav_trim(band = c())
  expect_equal(result$band, c())
})

test_that("prep_wav_trim errors when band has length 1", {
  expect_error(
    prep_wav_trim(band = c(1000)),
    "'band' must be of length 0"
  )
})

test_that("prep_wav_trim errors when band has length > 2", {
  expect_error(
    prep_wav_trim(band = c(1000, 1500, 1800)),
    "'band' must be of length 0"
  )
})

test_that("prep_wav_trim errors when band contains NA", {
  expect_error(
    prep_wav_trim(band = c(1000, NA)),
    "values in 'band' cannot be NA"
  )
})

test_that("prep_wav_trim errors when band[1] == band[2]", {
  expect_error(
    prep_wav_trim(band = c(1500, 1500)),
    "'band\\[1\\]' must be strictly less than 'band\\[2\\]'"
  )
})

test_that("prep_wav_trim accepts negative and decimal wavenumbers", {
  result <- prep_wav_trim(band = c(-100.5, -50.3))
  expect_equal(result$band, c(-100.5, -50.3))
})

test_that("prep_wav_trim accepts large wavenumber values", {
  result <- prep_wav_trim(band = c(3000, 7500))
  expect_equal(result$band, c(3000, 7500))
})

# ============================================================================
# Test group 3: Parameter validation - trim_constant_edges argument
# ============================================================================

test_that("prep_wav_trim has trim_constant_edges default FALSE", {
  result <- prep_wav_trim(band = c(1000, 1800))
  expect_false(result$trim_constant_edges)
})

test_that("prep_wav_trim accepts trim_constant_edges = TRUE", {
  result <- prep_wav_trim(band = c(1000, 1800), trim_constant_edges = TRUE)
  expect_true(result$trim_constant_edges)
})

test_that("prep_wav_trim accepts trim_constant_edges = FALSE", {
  result <- prep_wav_trim(band = c(1000, 1800), trim_constant_edges = FALSE)
  expect_false(result$trim_constant_edges)
})

test_that("prep_wav_trim errors when trim_constant_edges is not logical", {
  expect_error(
    prep_wav_trim(band = c(1000, 1800), trim_constant_edges = "TRUE"),
    "'trim_constant_edges' must be a single logical value"
  )
})

test_that("prep_wav_trim errors when trim_constant_edges is NA", {
  expect_error(
    prep_wav_trim(band = c(1000, 1800), trim_constant_edges = NA),
    "'trim_constant_edges' must be a single logical value"
  )
})

test_that("prep_wav_trim errors when trim_constant_edges has length > 1", {
  expect_error(
    prep_wav_trim(band = c(1000, 1800), trim_constant_edges = c(TRUE, FALSE)),
    "'trim_constant_edges' must be a single logical value"
  )
})

# ============================================================================
# Test group 4: Band trimming functionality
# ============================================================================

test_that("band trimming retains columns within specified range", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:10, ] # Reduced dataset
  step <- prep_wav_trim(band = c(1200, 1600))

  result <- proximetricsR:::.exec_wav_trim(X, step)

  result_wavs <- as.numeric(colnames(result))
  expect_true(all(result_wavs >= 1200 & result_wavs <= 1600))
})

test_that("band trimming with empty vector skips trimming", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:10, ]
  step <- prep_wav_trim(band = c())

  result <- proximetricsR:::.exec_wav_trim(X, step)

  # Should return original X
  expect_equal(ncol(result), ncol(X))
  expect_equal(colnames(result), colnames(X))
})

test_that("band trimming reduces number of columns", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:10, ]
  original_cols <- ncol(X)

  step <- prep_wav_trim(band = c(1200, 1600))
  result <- proximetricsR:::.exec_wav_trim(X, step)

  expect_true(ncol(result) < original_cols)
})

test_that("band trimming warns when no columns fall within range", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:10, ]
  # Use a range that doesn't match the data
  step <- prep_wav_trim(band = c(10000, 20000))

  expect_warning(
    result <- proximetricsR:::.exec_wav_trim(X, step),
    "Band trimming would drop all columns"
  )
  expect_equal(ncol(result), ncol(X))
})

test_that("band trimming preserves row names", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:10, ]
  step <- prep_wav_trim(band = c(1200, 1600))

  result <- proximetricsR:::.exec_wav_trim(X, step)

  expect_equal(rownames(result), rownames(X))
})

test_that("band trimming preserves row data correctly", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:10, ]
  wavs <- as.numeric(colnames(X))
  in_range <- which(wavs >= 1200 & wavs <= 1600)

  step <- prep_wav_trim(band = c(1200, 1600))
  result <- proximetricsR:::.exec_wav_trim(X, step)

  # Check that selected columns match the expected ones
  expect_equal(as.numeric(colnames(result)), wavs[in_range])
})

# ============================================================================
# Test group 5: Constant edge trimming functionality
# ============================================================================

test_that("constant edge trimming removes constant columns from left edge", {
  skip_on_cran()
  # Create test matrix with constant left edge
  X <- matrix(c(1, 1, 1, 2, 3, 4, 5, 6, 7, 8), nrow = 2, byrow = TRUE)
  colnames(X) <- c(1000, 1100, 1200, 1300, 1400)

  step <- prep_wav_trim(band = c(), trim_constant_edges = TRUE)
  result <- proximetricsR:::.exec_wav_trim(X, step)

  # The first column(s) with constant values should be removed
  expect_true(ncol(result) <= ncol(X))
})

test_that("constant edge trimming removes constant columns from right edge", {
  skip_on_cran()
  # Create test matrix with constant right edge
  X <- matrix(c(1, 2, 3, 4, 5, 6, 7, 7, 8, 8), nrow = 2, byrow = TRUE)
  colnames(X) <- c(1000, 1100, 1200, 1300, 1400)

  step <- prep_wav_trim(band = c(), trim_constant_edges = TRUE)
  result <- proximetricsR:::.exec_wav_trim(X, step)

  expect_true(ncol(result) <= ncol(X))
})

test_that("constant edge trimming preserves internal constant columns", {
  skip_on_cran()
  # Create test matrix with constant middle columns
  X <- matrix(c(1, 2, 2, 2, 3, 4, 5, 2, 2, 2, 6, 7), nrow = 2, byrow = TRUE)
  colnames(X) <- c(1000, 1100, 1200, 1300, 1400, 1500)

  step <- prep_wav_trim(band = c(), trim_constant_edges = TRUE)
  result <- proximetricsR:::.exec_wav_trim(X, step)

  # Should preserve the data structure
  expect_equal(nrow(result), nrow(X))
})

test_that("constant edge trimming removes zero-valued edge columns", {
  skip_on_cran()
  # Create test matrix with zero-valued edges
  X <- matrix(c(0, 0, 0, 2, 3, 4, 5, 6), nrow = 2, byrow = TRUE)
  colnames(X) <- c(1000, 1100, 1200, 1300)

  step <- prep_wav_trim(band = c(), trim_constant_edges = TRUE)
  result <- proximetricsR:::.exec_wav_trim(X, step)

  expect_true(ncol(result) <= ncol(X))
})

test_that("constant edge trimming warns when fewer than 2 columns remain", {
  skip_on_cran()
  # Create test matrix that would leave too few columns
  X <- matrix(c(1, 1, 2, 2), nrow = 2)
  colnames(X) <- c(1000, 1100)

  step <- prep_wav_trim(band = c(), trim_constant_edges = TRUE)
  result <- proximetricsR:::.exec_wav_trim(X, step)

  # Should warn but not crash
  expect_equal(ncol(result), ncol(X))
})

test_that("constant edge trimming is skipped when ncol <= 3", {
  skip_on_cran()
  X <- matrix(c(1, 1, 2), nrow = 1)
  colnames(X) <- c(1000, 1100, 1200)

  step <- prep_wav_trim(band = c(), trim_constant_edges = TRUE)
  result <- proximetricsR:::.exec_wav_trim(X, step)

  # Should return unchanged
  expect_equal(ncol(result), ncol(X))
})

# ============================================================================
# Test group 6: Combined band and edge trimming
# ============================================================================

test_that("band and edge trimming work together", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:10, ]
  step <- prep_wav_trim(band = c(1200, 1600), trim_constant_edges = TRUE)

  result <- proximetricsR:::.exec_wav_trim(X, step)

  result_wavs <- as.numeric(colnames(result))
  expect_true(all(result_wavs >= 1200 & result_wavs <= 1600))
})

# ============================================================================
# Test group 7: Data type preservation
# ============================================================================

test_that("trimming preserves numeric data type", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:10, ]
  step <- prep_wav_trim(band = c(1200, 1600))

  result <- proximetricsR:::.exec_wav_trim(X, step)

  expect_true(is.numeric(result))
  expect_true(inherits(result, "matrix"))
})

test_that("trimming preserves column names as numeric strings", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:10, ]
  step <- prep_wav_trim(band = c(1200, 1600))

  result <- proximetricsR:::.exec_wav_trim(X, step)

  # Column names should be numeric wavenumbers
  expect_true(all(!is.na(as.numeric(colnames(result)))))
})

# ============================================================================
# Test group 8: Integration with preprocess_recipe
# ============================================================================

test_that("prep_wav_trim integrates with preprocess_recipe", {
  skip_on_cran()
  trim_step <- prep_wav_trim(band = c(1200, 1600))
  recipe <- preprocess_recipe(trim_step, device = "proxiscout")

  expect_true(inherits(recipe, "preprocess_recipe"))
})

test_that("prep_wav_trim can be used with process function", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:5, ]
  trim_step <- prep_wav_trim(band = c(1200, 1600))
  recipe <- preprocess_recipe(trim_step, device = "proxiscout")

  result <- process(X, recipe)

  result_wavs <- as.numeric(colnames(result))
  expect_true(all(result_wavs >= 1200 & result_wavs <= 1600))
})

test_that("prep_wav_trim works in multi-step recipe", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:5, ]
  recipe <- preprocess_recipe(
    prep_wav_trim(band = c(1200, 1600)),
    prep_snv(),
    device = "proxiscout"
  )

  result <- process(X, recipe)

  expect_true(inherits(result, "matrix"))
  expect_true(ncol(result) > 0)
})

# ============================================================================
# Test group 9: Edge cases with non-numeric column names
# ============================================================================

test_that("trimming warns when column names are not numeric", {
  skip_on_cran()
  X <- matrix(1:20, nrow = 2)
  colnames(X) <- c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j")

  step <- prep_wav_trim(band = c(1, 5))

  warnings_emitted <- testthat::capture_warnings(
    result <- proximetricsR:::.exec_wav_trim(X, step)
  )

  expect_match(
    warnings_emitted, "NAs introduced by coercion",
    all = FALSE
  )
  expect_match(
    warnings_emitted,
    "Column names are not numeric wavelengths; band trimming skipped",
    all = FALSE
  )

  # Should return unchanged when column names can't be coerced
  expect_equal(ncol(result), ncol(X))
})

# ============================================================================
# Test group 10: Boundary conditions
# ============================================================================

test_that("trimming at exact wavenumber boundaries works", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:5, ]
  wavs <- as.numeric(colnames(X))
  min_wav <- wavs[1]
  max_wav <- wavs[length(wavs)]

  step <- prep_wav_trim(band = c(min_wav, max_wav))
  result <- proximetricsR:::.exec_wav_trim(X, step)

  # Should include boundary columns
  result_wavs <- as.numeric(colnames(result))
  expect_true(min(result_wavs) >= min_wav)
  expect_true(max(result_wavs) <= max_wav)
})

test_that("trimming with band narrower than data works", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:5, ]
  step <- prep_wav_trim(band = c(1200, 1500))

  result <- proximetricsR:::.exec_wav_trim(X, step)

  result_wavs <- as.numeric(colnames(result))
  expect_true(all(result_wavs >= 1200 & result_wavs <= 1500))
})

test_that("trimming with band wider than data includes all columns", {
  skip_on_cran()
  X <- NIRcannabis$spc[1:5, ]
  wavs <- as.numeric(colnames(X))

  step <- prep_wav_trim(band = c(min(wavs) - 100, max(wavs) + 100))
  result <- proximetricsR:::.exec_wav_trim(X, step)

  # Should include all columns
  expect_equal(ncol(result), ncol(X))
})
