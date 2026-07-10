# Tests for proxiscout_read_data() and proxiscout_repetition_pattern()

# -----------------------------------------------------------------------
# Shared setup for xlsx-based tests
# -----------------------------------------------------------------------

xlsx_file <- test_path("testdata", "proxiscout-samples.xlsx")
result <- proxiscout_read_data(xlsx_file)

# -----------------------------------------------------------------------
# 1. Result is a data.frame
# -----------------------------------------------------------------------

test_that("proxiscout_read_data result is a data.frame", {
  skip_on_cran()
  expect_true(is.data.frame(result))
})

# -----------------------------------------------------------------------
# 2. Result has a spc column that is a matrix
# -----------------------------------------------------------------------

test_that("result has spc column that is a matrix", {
  skip_on_cran()
  expect_true("spc" %in% colnames(result))
  expect_true(is.matrix(result$spc))
})

# -----------------------------------------------------------------------
# 3. spc is numeric
# -----------------------------------------------------------------------

test_that("spc matrix is numeric", {
  skip_on_cran()
  expect_true(is.numeric(result$spc))
})

# -----------------------------------------------------------------------
# 4. If 257 spectral columns: class includes "proxiscout_data" and
#    spc values are between 0 and 1 (divided by 100)
# -----------------------------------------------------------------------

test_that("if 257 spectral columns, class is proxiscout_data and spc in [0, 1]", {
  skip_on_cran()
  if (ncol(result$spc) == 257L) {
    expect_true(inherits(result, "proxiscout_data"))
    expect_true(all(result$spc >= 0, na.rm = TRUE))
    expect_true(all(result$spc <= 1, na.rm = TRUE))
  } else {
    expect_false(inherits(result, "proxiscout_data"))
  }
})

# -----------------------------------------------------------------------
# 5. Column names of spc are numeric-coercible characters
# -----------------------------------------------------------------------

test_that("spc column names are numeric-coercible", {
  skip_on_cran()
  wav_names <- colnames(result$spc)
  expect_true(is.character(wav_names))
  expect_true(all(!is.na(suppressWarnings(as.numeric(wav_names)))))
})

# -----------------------------------------------------------------------
# 6. nrow(result) > 0
# -----------------------------------------------------------------------

test_that("result has at least one row", {
  skip_on_cran()
  expect_gt(nrow(result), 0L)
})

# -----------------------------------------------------------------------
# 7. Error on unsupported file extension
# -----------------------------------------------------------------------

test_that("proxiscout_read_data errors on unsupported file extension", {
  expect_error(
    proxiscout_read_data(tempfile(fileext = ".txt")),
    "Unsupported file format"
  )
})

# -----------------------------------------------------------------------
# 8. proxiscout_repetition_pattern() returns a character string
# -----------------------------------------------------------------------

test_that("proxiscout_repetition_pattern returns a character string", {
  pat <- proxiscout_repetition_pattern()
  expect_type(pat, "character")
  expect_length(pat, 1L)
})

# -----------------------------------------------------------------------
# 9. Repetition pattern matches "Sample_001" and "Sample_12"
# -----------------------------------------------------------------------

test_that("repetition pattern matches strings with trailing underscore-digits", {
  pat <- proxiscout_repetition_pattern()
  expect_true(grepl(pat, "Sample_001"))
  expect_true(grepl(pat, "Sample_12"))
  expect_true(grepl(pat, "ABC_5"))
})

# -----------------------------------------------------------------------
# 10. Repetition pattern does NOT match bare "Sample"
# -----------------------------------------------------------------------

test_that("repetition pattern does not match string without trailing digits", {
  pat <- proxiscout_repetition_pattern()
  expect_false(grepl(pat, "Sample"))
})

# -----------------------------------------------------------------------
# CSV tests — generate a small temp CSV with numeric column names
# -----------------------------------------------------------------------

tmp_csv <- tempfile(fileext = ".csv")
df_test <- data.frame(
  SampleName = c("A_1", "B_2"),
  "3921" = c(50.1, 48.3),
  "3942" = c(51.2, 49.1),
  check.names = FALSE
)
write.csv(df_test, tmp_csv, row.names = FALSE)
result_csv <- proxiscout_read_data(tmp_csv)

test_that("proxiscout_read_data reads CSV files", {
  expect_true(is.data.frame(result_csv))
})

test_that("spc from CSV has 2 columns named '3921' and '3942'", {
  expect_true(is.matrix(result_csv$spc))
  expect_equal(ncol(result_csv$spc), 2L)
  expect_identical(colnames(result_csv$spc), c("3921", "3942"))
})

test_that("non-spectral column SampleName remains in the data.frame", {
  expect_true("SampleName" %in% colnames(result_csv))
})

test_that("CSV result with 2 spectral columns does not get proxiscout_data class", {
  expect_false(inherits(result_csv, "proxiscout_data"))
})
