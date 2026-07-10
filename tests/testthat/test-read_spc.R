data("NIRcannabis", package = "proximetricsR")

# Build a simple flat data.frame from NIRcannabis for round-trip testing.
# Non-spectral columns: ID and THC.
# Spectral columns prefixed with "X" so we can test both prefix and numeric-only paths.
spc_mat <- NIRcannabis$spc
colnames(spc_mat) <- paste0("X", colnames(spc_mat))

base_df <- data.frame(
  ID = NIRcannabis$ID,
  THC = NIRcannabis$THC,
  spc_mat,
  check.names = FALSE
)

tmp_tab <- tempfile(fileext = ".txt")
write.table(base_df, file = tmp_tab, sep = "\t", row.names = FALSE)

# A second version without the "X" prefix so we can test numeric-column detection.
base_df_noprefix <- data.frame(
  ID = NIRcannabis$ID,
  THC = NIRcannabis$THC,
  NIRcannabis$spc,
  check.names = FALSE
)

tmp_noprefix <- tempfile(fileext = ".txt")
write.table(base_df_noprefix, file = tmp_noprefix, sep = "\t", row.names = FALSE)

# A third version for spectra_starts / spectra_ends testing (columns 3 onward).
tmp_starts <- tmp_tab # reuse the prefixed file; starts/ends refer to column positions

# ─── 1. Class of output is correct ────────────────────────────────────────────

test_that("read_spc returns object of class c('proximate_data', 'data.frame')", {
  result <- read_spc(tmp_tab, spectra_prefix = "X")
  expect_s3_class(result, "proximate_data")
  expect_s3_class(result, "data.frame")
  expect_identical(class(result), c("proximate_data", "data.frame"))
})

# ─── 2. spectra_prefix correctly selects spectral columns ─────────────────────

test_that("spectra_prefix selects only columns matching the prefix pattern", {
  result <- read_spc(tmp_tab, spectra_prefix = "X")
  # The spc matrix should have as many columns as the original spectral columns.
  expect_equal(ncol(result$spc), ncol(spc_mat))
})

test_that("spectra_prefix leaves non-spectral columns in the data.frame", {
  result <- read_spc(tmp_tab, spectra_prefix = "X")
  expect_true("ID" %in% colnames(result))
  expect_true("THC" %in% colnames(result))
})

# ─── 3. spectra_starts / spectra_ends correctly selects columns ───────────────

test_that("spectra_starts selects columns starting at the given index", {
  # Spectral columns start at column 3 in base_df (after ID and THC).
  result <- read_spc(tmp_tab, spectra_starts = 3)
  expect_equal(ncol(result$spc), ncol(spc_mat))
})

test_that("spectra_starts with spectra_ends selects a column sub-range", {
  # Select only the first 10 spectral columns (columns 3:12 in the file).
  result <- read_spc(tmp_tab, spectra_starts = 3, spectra_ends = 12)
  expect_equal(ncol(result$spc), 10)
})

test_that("spectra_ends defaults to the last column when not supplied", {
  n_cols <- ncol(base_df)
  # Reading from column 3 to last should yield all spectral columns.
  result_default <- read_spc(tmp_tab, spectra_starts = 3)
  result_explicit <- read_spc(tmp_tab, spectra_starts = 3, spectra_ends = n_cols)
  expect_equal(ncol(result_default$spc), ncol(result_explicit$spc))
})

# ─── 4. spc column is a matrix ────────────────────────────────────────────────

test_that("spc column is a matrix", {
  result <- read_spc(tmp_tab, spectra_prefix = "X")
  expect_true(is.matrix(result$spc))
})

# ─── 5. Number of rows and spectral columns match the input ───────────────────

test_that("number of rows in result matches the input file", {
  result <- read_spc(tmp_tab, spectra_prefix = "X")
  expect_equal(nrow(result), nrow(base_df))
})

test_that("number of spectral columns in spc matches the number of X columns", {
  result <- read_spc(tmp_tab, spectra_prefix = "X")
  expect_equal(ncol(result$spc), sum(grepl("^X", colnames(base_df))))
})

# ─── 6. Non-spectral columns are preserved ────────────────────────────────────

test_that("non-spectral columns are preserved in the returned data.frame", {
  result <- read_spc(tmp_tab, spectra_prefix = "X")
  expect_true(all(c("ID", "THC") %in% colnames(result)))
  expect_equal(result$ID, base_df$ID)
  expect_equal(result$THC, base_df$THC)
})

# ─── 7. spectra_prefix strips leading letters from column names ───────────────

test_that("spc column names have leading letters stripped when using spectra_prefix", {
  result <- read_spc(tmp_tab, spectra_prefix = "X")
  # The original column names are "X<wavelength>"; after stripping the leading
  # letters the names should equal the original wavelength numbers.
  expected_wavs <- gsub("^[A-Za-z ]{0,}", "", colnames(spc_mat))
  expect_equal(colnames(result$spc), expected_wavs)
})

test_that("spc column names without a prefix are unchanged (no letters to strip)", {
  result <- read_spc(tmp_noprefix)
  # When column names are already numeric strings, stripping letters is a no-op.
  expect_equal(colnames(result$spc), colnames(NIRcannabis$spc))
})

# ─── 8. Error when spectra_prefix is not character ────────────────────────────

test_that("read_spc errors when spectra_prefix is not a character", {
  expect_error(
    read_spc(tmp_tab, spectra_prefix = 42),
    "'spectra_prefix' must be a character"
  )
})

test_that("read_spc errors when spectra_prefix is a logical", {
  expect_error(
    read_spc(tmp_tab, spectra_prefix = TRUE),
    "'spectra_prefix' must be a character"
  )
})

# ─── 9. Works with comma separator and different dec ──────────────────────────

test_that("read_spc works with comma separator and comma decimal separator", {
  # Build a small data.frame with European-style decimals.
  small_df <- data.frame(
    ID = c("s1", "s2"),
    X1001.0 = c(0.1, 0.2),
    X1004.0 = c(0.3, 0.4),
    check.names = FALSE
  )
  tmp_csv <- tempfile(fileext = ".csv")
  write.table(small_df, file = tmp_csv, sep = ",", dec = ".", row.names = FALSE)

  result <- read_spc(tmp_csv, sep = ",", dec = ".", spectra_prefix = "X")
  expect_s3_class(result, "proximate_data")
  expect_true(is.matrix(result$spc))
  expect_equal(nrow(result), 2L)
  expect_equal(ncol(result$spc), 2L)
})

test_that("read_spc works with semicolon separator and European decimal", {
  small_df2 <- data.frame(
    ID = c("a", "b"),
    X1001 = c(1.5, 2.5),
    X1004 = c(3.5, 4.5),
    check.names = FALSE
  )
  # Write with semicolon and comma decimal (European CSV style).
  tmp_eu <- tempfile(fileext = ".csv")
  write.table(small_df2, file = tmp_eu, sep = ";", dec = ",", row.names = FALSE)

  result <- read_spc(tmp_eu, sep = ";", dec = ",", spectra_prefix = "X")
  expect_s3_class(result, "proximate_data")
  expect_true(is.matrix(result$spc))
  expect_equal(nrow(result), 2L)
})

on.exit(
  {
    if (file.exists(tmp_tab)) file.remove(tmp_tab)
    if (file.exists(tmp_noprefix)) file.remove(tmp_noprefix)
  },
  add = TRUE
)
