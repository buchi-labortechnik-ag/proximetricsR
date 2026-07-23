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

# -----------------------------------------------------------------------
# Two-file merge tests (file + references_file)
# -----------------------------------------------------------------------

write_spec_csv <- function(df) {
  path <- tempfile(fileext = ".csv")
  write.csv(df, path, row.names = FALSE)
  path
}

test_that("single-file input: .repetition_group groups repeated sample ids", {
  x_single <- data.frame(
    SampleID = c("A_1", "A_2", "B"),
    "3921" = c(50.1, 48.3, 47.0),
    check.names = FALSE
  )
  result <- proxiscout_read_data(write_spec_csv(x_single))
  expect_equal(result$.repetition_group[1], result$.repetition_group[2])
  expect_false(result$.repetition_group[1] %in% result$.repetition_group[3])
})

test_that("two-file merge: happy path with shared id column", {
  x1 <- data.frame(
    SampleID = c("A", "B", "C"),
    "3921" = c(50.1, 48.3, 47.0),
    "3942" = c(51.2, 49.1, 48.5),
    check.names = FALSE
  )
  refs1 <- data.frame(SampleID = c("A", "B", "C"), moisture = c(10, 20, 30))
  result <- proxiscout_read_data(write_spec_csv(x1), write_spec_csv(refs1))

  expect_equal(nrow(result), 3L)
  expect_equal(result$moisture, c(10, 20, 30))
  expect_true(".repetition_group" %in% colnames(result))
  expect_equal(result$.repetition_group, c(1L, 2L, 3L))
})

test_that("two-file merge: shared columns in different order use the id-like column", {
  x2 <- data.frame(
    Date = c("2024-01-01", "2024-01-02", "2024-01-03"),
    SampleID = c("A", "B", "C"),
    "3921" = c(50.1, 48.3, 47.0),
    "3942" = c(51.2, 49.1, 48.5),
    check.names = FALSE
  )
  refs2 <- data.frame(
    SampleID = c("A", "B", "C"),
    Date = c("2024-01-01", "2024-01-02", "2024-01-03"),
    moisture = c(11, 22, 33)
  )
  result <- proxiscout_read_data(write_spec_csv(x2), write_spec_csv(refs2))

  expect_equal(nrow(result), 3L)
  expect_equal(result$moisture, c(11, 22, 33))
})

test_that("two-file merge: falls back to id-regex detection when no common column names", {
  x3 <- data.frame(
    SampleName = c("A", "B", "C"),
    "3921" = c(50.1, 48.3, 47.0),
    "3942" = c(51.2, 49.1, 48.5),
    check.names = FALSE
  )
  refs3 <- data.frame(SampleID = c("A", "B", "C"), moisture = c(1, 2, 3))
  result <- proxiscout_read_data(write_spec_csv(x3), write_spec_csv(refs3))

  expect_equal(nrow(result), 3L)
  expect_equal(result$moisture, c(1, 2, 3))
})

test_that("two-file merge: supports a mixture of repeated and non-repeated sample ids", {
  x4 <- data.frame(
    SampleID = c("A_1", "B", "C_2"),
    "3921" = c(50.1, 48.3, 47.0),
    "3942" = c(51.2, 49.1, 48.5),
    check.names = FALSE
  )
  refs4 <- data.frame(SampleID = c("A", "B", "C"), moisture = c(100, 200, 300))
  result <- proxiscout_read_data(write_spec_csv(x4), write_spec_csv(refs4))

  expect_equal(nrow(result), 3L)
  expect_false(anyNA(result$moisture))
  expect_equal(result$moisture, c(100, 200, 300))
})

test_that("two-file merge: duplicated reference rows are deduplicated (first occurrence kept)", {
  x5 <- data.frame(
    SampleID = c("A", "B"),
    "3921" = c(50.1, 48.3),
    "3942" = c(51.2, 49.1),
    check.names = FALSE
  )
  refs5 <- data.frame(SampleID = c("A", "A", "B"), moisture = c(10, 999, 20))
  result <- proxiscout_read_data(write_spec_csv(x5), write_spec_csv(refs5))

  expect_equal(nrow(result), 2L)
  expect_equal(result$moisture, c(10, 20))
})

test_that("two-file merge: unmatched samples get NA references but a valid, grouped .repetition_group", {
  x7 <- data.frame(
    SampleID = c("A", "B", "Z_1", "Z_2"),
    "3921" = c(50.1, 48.3, 47.0, 46.5),
    "3942" = c(51.2, 49.1, 48.5, 48.0),
    check.names = FALSE
  )
  refs7 <- data.frame(SampleID = c("A", "B"), moisture = c(10, 20))
  result <- proxiscout_read_data(write_spec_csv(x7), write_spec_csv(refs7))

  expect_equal(nrow(result), 4L)
  expect_equal(result$moisture, c(10, 20, NA, NA))
  expect_false(anyNA(result$.repetition_group))
  # The two unmatched repeats of "Z" (Z_1, Z_2) share the same fallback group
  expect_equal(result$.repetition_group[3], result$.repetition_group[4])
  # The fallback group must not collide with any reference-matched group
  expect_false(result$.repetition_group[3] %in% result$.repetition_group[1:2])
})

test_that("two-file merge: errors when no common or id-like column can be found", {
  x6 <- data.frame(
    Foo = c("x", "y"),
    "3921" = c(50.1, 48.3),
    "3942" = c(51.2, 49.1),
    check.names = FALSE
  )
  refs6 <- data.frame(Bar = c("x", "y"), moisture = c(1, 2))

  expect_error(
    proxiscout_read_data(write_spec_csv(x6), write_spec_csv(refs6)),
    "No common column names or sample ID columns detected"
  )
})
