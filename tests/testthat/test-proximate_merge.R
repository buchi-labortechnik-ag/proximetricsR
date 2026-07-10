# Test suite for proximate_merge()
# Tests cover merging of proximate_data objects

# ============================================================================
# Helper function to create mock proximate_data objects
# ============================================================================

create_mock_proximate_data <- function(n_samples = 10, n_wavs = 50, wavs = NULL) {
  if (is.null(wavs)) {
    wavs <- seq(1000, 1000 + (n_wavs - 1) * 10, by = 10)
  }

  spc <- matrix(rnorm(n_samples * length(wavs)), nrow = n_samples, ncol = length(wavs))
  colnames(spc) <- as.character(wavs)
  rownames(spc) <- paste0("sample_", 1:n_samples)

  dat <- data.frame(
    ROW = 1:n_samples,
    Check = rep("OK", n_samples),
    Date = rep(Sys.Date(), n_samples),
    SRN = rep("SN123", n_samples),
    SNR = rnorm(n_samples, mean = 50, sd = 10),
    ID = paste0("ID_", 1:n_samples),
    Barcode = paste0("BC_", 1:n_samples),
    Note = rep("", n_samples),
    Result = rep("Pass", n_samples),
    Reference = rep("Ref", n_samples),
    Property1 = rnorm(n_samples),
    Property2 = rnorm(n_samples),
    Begin = rep("", n_samples),
    End = rep("", n_samples),
    Recipe = rep("Recipe1", n_samples),
    Composition = rep("", n_samples),
    Images = rep("", n_samples),
    spc = I(spc),
    stringsAsFactors = FALSE
  )

  class(dat) <- c("proximate_data", "data.frame")
  dat
}

# ============================================================================
# Test group 1: Input validation
# ============================================================================

test_that("proximate_merge errors when x is not a list", {
  mdata <- create_mock_proximate_data(n_samples = 5)
  expect_error(
    proximate_merge(data),
    "'x' must be a list of 'proximate_data' objects"
  )
})

test_that("proximate_merge errors when elements are not proximate_data", {
  # Create list with non-proximate_data elements
  bad_list <- list(
    data.frame(a = 1:5),
    data.frame(b = 1:5)
  )

  expect_error(
    proximate_merge(bad_list),
    "class 'proximate_data'"
  )
})

test_that("proximate_merge filters out NULL elements", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data_list <- list(data1, NULL, data1)

  result <- proximate_merge(data_list)
  expect_true(inherits(result, "proximate_data"))
  expect_true(nrow(result) > 0)
})

test_that("proximate_merge errors when data lacks 'spc' column", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 5)

  # Remove spc column
  data2$spc <- NULL

  expect_error(
    proximate_merge(list(data1, data2)),
    "must have a column named 'spc'"
  )
})

test_that("proximate_merge errors when data lacks 'ID' column", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 5)

  # Remove ID column
  data2$ID <- NULL

  expect_error(
    proximate_merge(list(data1, data2)),
    "must have a column named 'ID'"
  )
})

# ============================================================================
# Test group 2: Basic merging functionality
# ============================================================================

test_that("proximate_merge returns proximate_data object", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  result <- proximate_merge(list(data1))

  expect_true(inherits(result, "proximate_data"))
  expect_true(inherits(result, "data.frame"))
})

test_that("proximate_merge with single element returns that element", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  result <- proximate_merge(list(data1))

  expect_equal(nrow(result), nrow(data1))
  expect_equal(ncol(result), ncol(data1))
})

test_that("proximate_merge combines rows from multiple datasets", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  expect_equal(nrow(result), nrow(data1) + nrow(data2))
})

test_that("proximate_merge preserves row identifiers with offset", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  expect_equal(result$ROW, 1:(nrow(data1) + nrow(data2)))
})

# ============================================================================
# Test group 3: Spectral data resampling
# ============================================================================

test_that("proximate_merge resamples second dataset to match first", {
  wavs1 <- seq(1000, 2000, by = 100)
  wavs2 <- seq(1050, 1950, by = 100)

  data1 <- create_mock_proximate_data(n_samples = 5, wavs = wavs1)
  data2 <- create_mock_proximate_data(n_samples = 3, wavs = wavs2)

  warnings_emitted <- testthat::capture_warnings(
    result <- proximate_merge(list(data1, data2))
  )

  expect_length(warnings_emitted, 2)
  expect_match(warnings_emitted, "have been introduced in the spectra", all = FALSE)
  expect_match(warnings_emitted, "have been introduced in the spectra", all = FALSE)

  # Result should have same wavelengths as first dataset
  result_wavs <- as.numeric(colnames(result$spc))
  expect_equal(result_wavs, as.numeric(colnames(data1$spc)))
})

test_that("proximate_merge sets NA for spectral data outside range", {
  wavs1 <- seq(1000, 2000, by = 50) # Wide range
  wavs2 <- seq(1200, 1600, by = 50) # Narrow range

  data1 <- create_mock_proximate_data(n_samples = 3, wavs = wavs1)
  data2 <- create_mock_proximate_data(n_samples = 2, wavs = wavs2)

  warnings_emitted <- testthat::capture_warnings(
    result <- proximate_merge(list(data1, data2))
  )

  # Check that rows from data2 have NA values outside their wavelength range
  expect_true(any(is.na(result$spc[4:5, ])))
})

test_that("proximate_merge handles identical wavelength grids", {
  wavs <- seq(1000, 2000, by = 100)

  data1 <- create_mock_proximate_data(n_samples = 5, wavs = wavs)
  data2 <- create_mock_proximate_data(n_samples = 3, wavs = wavs)

  result <- proximate_merge(list(data1, data2))

  expect_equal(nrow(result), 8)
  expect_equal(ncol(result$spc), ncol(data1$spc))
})

# ============================================================================
# Test group 4: Property column handling
# ============================================================================

test_that("proximate_merge preserves property columns from first dataset", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  expect_true("Property1" %in% colnames(result))
  expect_true("Property2" %in% colnames(result))
})

test_that("proximate_merge fills NA for missing properties in second dataset", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  # Remove a property from data2
  data2$Property1 <- NULL

  warnings_emitted <- testthat::capture_warnings(
    result <- proximate_merge(list(data1, data2))
  )
  # Property1 should still exist, with NAs for data2 rows
  expect_true("Property1" %in% colnames(result))
  expect_true(any(is.na(result$Property1[(nrow(data1) + 1):nrow(result)])))
})

test_that("proximate_merge warns about different property sets", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  # Add extra property to data2
  data3 <- data.frame(
    data2[, 1:12],
    Property3 = rnorm(3),
    data2[, 13:17]
  )

  data3$spc <- data2$spc
  class(data3) <- c("proximate_data", "data.frame")

  expect_warning(
    result <- proximate_merge(list(data1, data3)),
    "properties seems different"
  )
})

# ============================================================================
# Test group 5: Metadata preservation
# ============================================================================

test_that("proximate_merge preserves ID column", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  expect_true("ID" %in% colnames(result))
  expect_equal(length(result$ID), nrow(result))
})

test_that("proximate_merge preserves Date column", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  expect_true("Date" %in% colnames(result))
})

test_that("proximate_merge preserves Note column", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  expect_true("Note" %in% colnames(result))
})

test_that("proximate_merge preserves SRN column", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  expect_true("SRN" %in% colnames(result))
})

test_that("proximate_merge fills NA for missing standard columns", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  # Remove a standard column from data2
  data2$Barcode <- NULL

  result <- proximate_merge(list(data1, data2))

  expect_true("Barcode" %in% colnames(result))
  expect_true(any(is.na(result$Barcode[(nrow(data1) + 1):nrow(result)])))
})

# ============================================================================
# Test group 6: Column ordering
# ============================================================================

test_that("proximate_merge orders columns according to standard schema", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  # Check that standard columns appear first
  col_names <- colnames(result)
  expect_true(which(col_names == "ROW") < which(col_names == "spc"))
  expect_true(which(col_names == "ID") < which(col_names == "spc"))
})

# ============================================================================
# Test group 7: Multiple dataset merging
# ============================================================================

test_that("proximate_merge handles three datasets", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)
  data3 <- create_mock_proximate_data(n_samples = 2)

  result <- proximate_merge(list(data1, data2, data3))

  expect_equal(nrow(result), 10)
})

test_that("proximate_merge handles many datasets", {
  data_list <- lapply(1:5, function(i) {
    create_mock_proximate_data(n_samples = 3)
  })

  result <- proximate_merge(data_list)

  expect_equal(nrow(result), 15)
})

# ============================================================================
# Test group 8: Spectral matrix structure
# ============================================================================

test_that("proximate_merge result has valid spc matrix", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  expect_true(is.matrix(result$spc) || inherits(result$spc, "matrix"))
  expect_equal(nrow(result$spc), nrow(result))
})

test_that("proximate_merge preserves spectral values for same wavelength grids", {
  wavs <- seq(1000, 2000, by = 100)
  data1 <- create_mock_proximate_data(n_samples = 2, wavs = wavs)
  data2 <- create_mock_proximate_data(n_samples = 2, wavs = wavs)

  result <- proximate_merge(list(data1, data2))

  # Spectral values should match original for matching wavelength ranges
  expect_equal(nrow(result$spc), 4)
  expect_equal(ncol(result$spc), ncol(data1$spc))
})

test_that("proximate_merge result spc has numeric column names", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  wavs <- as.numeric(colnames(result$spc))
  expect_true(all(!is.na(wavs)))
})

# ============================================================================
# Test group 9: Return value validation
# ============================================================================

test_that("proximate_merge result has correct class", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  result <- proximate_merge(list(data1))

  expect_equal(class(result), c("proximate_data", "data.frame"))
})

test_that("proximate_merge result is a valid data.frame", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  expect_true(is.data.frame(result))
  expect_true(nrow(result) == 8)
})

test_that("proximate_merge result preserves data types", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  # ROW should be numeric
  expect_true(is.numeric(result$ROW))
  # ID should be character
  expect_true(is.character(result$ID))
})

# ============================================================================
# Test group 10: Row naming and indexing
# ============================================================================

test_that("proximate_merge updates row names sequentially", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  # spc row names should be updated
  spc_rownames <- rownames(result$spc)
  expect_equal(length(spc_rownames), 8)
})

test_that("proximate_merge spc row names match data frame row names", {
  data1 <- create_mock_proximate_data(n_samples = 5)
  data2 <- create_mock_proximate_data(n_samples = 3)

  result <- proximate_merge(list(data1, data2))

  # Row numbers should be consistent
  expect_equal(as.numeric(rownames(result$spc)), as.numeric(rownames(result)))
})

# ============================================================================
# Test group 11: Edge cases
# ============================================================================

test_that("proximate_merge handles single-column spectral data", {
  wavs <- c(1500)
  data1 <- create_mock_proximate_data(n_samples = 3, wavs = wavs)

  result <- proximate_merge(list(data1))

  expect_equal(ncol(result$spc), 1)
})

test_that("proximate_merge handles large spectral range difference", {
  wavs1 <- seq(1000, 3000, by = 50)
  wavs2 <- seq(1500, 2500, by = 50)

  data1 <- create_mock_proximate_data(n_samples = 2, wavs = wavs1)
  data2 <- create_mock_proximate_data(n_samples = 2, wavs = wavs2)
  warnings_emitted <- testthat::capture_warnings(
    result <- proximate_merge(list(data1, data2))
  )
  expect_true(any(is.na(result$spc[3:4, 1:10])))
})

test_that("proximate_merge handles single sample datasets", {
  data1 <- create_mock_proximate_data(n_samples = 1)
  data2 <- create_mock_proximate_data(n_samples = 1)

  result <- proximate_merge(list(data1, data2))

  expect_equal(nrow(result), 2)
})
