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

test_that("single-file input: duplicated sample ids without suffix are grouped", {
  x_dup <- data.frame(
    SampleID = c("A", "A", "B", "C", "C", "C"),
    "3921" = c(50.1, 48.3, 47.0, 46.1, 45.2, 44.3),
    check.names = FALSE
  )
  result <- proxiscout_read_data(write_spec_csv(x_dup))
  expect_equal(result$.repetition_group, c(1L, 1L, 2L, 3L, 3L, 3L))
})

test_that("single-file input: suffixed and duplicated sample ids share a group", {
  x_mix <- data.frame(
    SampleID = c("A_1", "A_1", "A_2", "A", "B_1"),
    "3921" = c(50.1, 48.3, 47.0, 46.1, 45.2),
    check.names = FALSE
  )
  result <- proxiscout_read_data(write_spec_csv(x_mix))
  expect_equal(result$.repetition_group, c(1L, 1L, 1L, 1L, 2L))
})

test_that("single-file input: same sample id on different scanners is not grouped", {
  x_dev <- data.frame(
    SampleID = c("A", "A", "A_1", "A_2"),
    deviceId = c("S1", "S1", "S2", "S2"),
    "3921" = c(50.1, 48.3, 47.0, 46.1),
    check.names = FALSE
  )
  result <- proxiscout_read_data(write_spec_csv(x_dev))
  expect_equal(result$.repetition_group, c(1L, 1L, 2L, 2L))
})

test_that("single-file input: unique sample ids get one group each", {
  x_uniq <- data.frame(
    SampleID = c("A", "B", "C"),
    "3921" = c(50.1, 48.3, 47.0),
    check.names = FALSE
  )
  result <- proxiscout_read_data(write_spec_csv(x_uniq))
  expect_equal(result$.repetition_group, 1:3)
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

test_that("two-file merge: prefers independently-named id-like columns over an incidental shared non-id column", {
  x3b <- data.frame(
    SampleName = c("A", "B", "C"),
    Date = c("2024-01-01", "2024-01-02", "2024-01-03"),
    "3921" = c(50.1, 48.3, 47.0),
    "3942" = c(51.2, 49.1, 48.5),
    check.names = FALSE
  )
  refs3b <- data.frame(
    SampleID = c("A", "B", "C"),
    Date = c("2024-02-01", "2024-02-02", "2024-02-03"),
    moisture = c(1, 2, 3)
  )
  result <- proxiscout_read_data(write_spec_csv(x3b), write_spec_csv(refs3b))

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

# -----------------------------------------------------------------------
# xlsx NA-marker handling — read_excel(file, na = c("", "-", "NA"))
# The fixture proxiscout-na-markers.xlsx stores numeric columns that contain
# "-" / "NA" / blank placeholder cells. With the na argument these markers are
# turned into NA so the columns are read as numeric instead of character.
# -----------------------------------------------------------------------

test_that("xlsx read converts '-', 'NA' and blank markers to numeric NA", {
  skip_on_cran()
  na_xlsx <- test_path("testdata", "proxiscout-na-markers.xlsx")
  result_na <- proxiscout_read_data(na_xlsx)

  # moisture has a "-" marker, protein an "NA" marker, fat a blank cell
  expect_true(is.numeric(result_na$moisture))
  expect_equal(result_na$moisture, c(10, NA, 30))

  expect_true(is.numeric(result_na$protein))
  expect_equal(result_na$protein, c(5, 6, NA))

  expect_true(is.numeric(result_na$fat))
  expect_equal(result_na$fat, c(1.5, NA, 2.5))
})

test_that("csv read converts '-', 'NA' and blank markers to numeric NA", {
  # CSV counterpart of the xlsx test: read.csv(na.strings = c("", "-", "NA"))
  # turns the placeholder markers into NA so the columns read as numeric.
  # A temp CSV is enough here — no committed fixture needed.
  tmp <- tempfile(fileext = ".csv")
  writeLines(
    c(
      "SampleName,moisture,protein,fat,3921,3942",
      "S1,10,5,1.5,50.1,51.2",
      "S2,-,6,,48.3,49.1",
      "S3,30,NA,2.5,47.0,48.5"
    ),
    tmp
  )
  result_csv_na <- proxiscout_read_data(tmp)

  # moisture has a "-" marker, protein an "NA" marker, fat a blank field
  expect_true(is.numeric(result_csv_na$moisture))
  expect_equal(as.numeric(result_csv_na$moisture), c(10, NA, 30))

  expect_true(is.numeric(result_csv_na$protein))
  expect_equal(as.numeric(result_csv_na$protein), c(5, 6, NA))

  expect_true(is.numeric(result_csv_na$fat))
  expect_equal(as.numeric(result_csv_na$fat), c(1.5, NA, 2.5))
})

test_that("two-file merge: repeats of the same sample on different scanners are not grouped", {
  x8 <- data.frame(
    sampleName = c("A_1", "A_2", "A_1", "A_2", "B_1", "B_1"),
    deviceId = c("S1", "S1", "S2", "S2", "S1", "S2"),
    "3921" = c(50, 51, 60, 61, 40, 45),
    check.names = FALSE
  )
  refs8 <- data.frame(sampleName = c("A", "B"), moisture = c(10, 20))
  result <- proxiscout_read_data(write_spec_csv(x8), write_spec_csv(refs8))

  expect_equal(result$.repetition_group, c(1L, 1L, 2L, 2L, 3L, 4L))
  expect_equal(result$moisture, c(10, 10, 10, 10, 20, 20))
})

test_that("two-file merge: scanner grouping uses the spectra file when refs share the scanner column", {
  x9 <- data.frame(
    sampleName = c("A_1", "A_2", "A_1"),
    deviceId = c("S1", "S1", "S2"),
    "3921" = c(50, 51, 60),
    check.names = FALSE
  )
  refs9 <- data.frame(sampleName = "A", deviceId = "S1", moisture = 10)
  result <- proxiscout_read_data(write_spec_csv(x9), write_spec_csv(refs9))

  expect_equal(result$.repetition_group, c(1L, 1L, 2L))
})

test_that("two-file merge: '-' / 'NA' markers in the references file are read as numeric NA", {
  x_spec <- data.frame(
    SampleID = c("A", "B", "C"),
    "3921" = c(50.1, 48.3, 47.0),
    "3942" = c(51.2, 49.1, 48.5),
    check.names = FALSE
  )
  refs_path <- tempfile(fileext = ".csv")
  writeLines(
    c(
      "SampleID,moisture,protein",
      "A,10,5",
      "B,-,6",
      "C,30,NA"
    ),
    refs_path
  )
  result <- proxiscout_read_data(write_spec_csv(x_spec), refs_path)

  expect_true(is.numeric(result$moisture))
  expect_equal(as.numeric(result$moisture), c(10, NA, 30))
  expect_true(is.numeric(result$protein))
  expect_equal(as.numeric(result$protein), c(5, 6, NA))
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
