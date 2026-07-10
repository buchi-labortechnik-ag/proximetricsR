nax_file <- test_path("testdata", "11A601BYDPU00N0101.nax")

# ─── helper: load the nax object once ─────────────────────────────────────────

get_nax <- function() {
  skip_on_cran()
  suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
}

# ─── overall description section ──────────────────────────────────────────────

test_that("print.nax outputs 'Overall description' header", {
  skip_on_cran()
  nax <- get_nax()
  output <- capture.output(print(nax))
  expect_true(any(grepl("Overall description", output)))
})

test_that("print.nax outputs 'Size:' line", {
  skip_on_cran()
  nax <- get_nax()
  output <- capture.output(print(nax))
  expect_true(any(grepl("Size:", output)))
})

test_that("print.nax outputs file names from nax_summary$content", {
  skip_on_cran()
  nax <- get_nax()
  output <- capture.output(print(nax))
  expect_true(any(grepl("Files:", output)))
  expect_true(length(output) > 5)
})

# ─── measurement geometry section ─────────────────────────────────────────────

test_that("print.nax outputs 'Measurement geometry'", {
  skip_on_cran()
  nax <- get_nax()
  output <- capture.output(print(nax))
  expect_true(any(grepl("Measurement geometry", output)))
})

# ─── properties section ───────────────────────────────────────────────────────

test_that("print.nax outputs 'Properties' header", {
  skip_on_cran()
  nax <- get_nax()
  output <- capture.output(print(nax))
  expect_true(any(grepl("Properties", output)))
})

# ─── model summary section ────────────────────────────────────────────────────

test_that("print.nax outputs 'Model's summary'", {
  skip_on_cran()
  nax <- get_nax()
  output <- capture.output(print(nax))
  expect_true(any(grepl("Model", output)))
})

# ─── calibration data section ─────────────────────────────────────────────────

test_that("print.nax outputs 'Calibration data' section", {
  skip_on_cran()
  nax <- get_nax()
  output <- capture.output(print(nax))
  expect_true(any(grepl("Calibration data", output)))
})

# ─── no rtf_info branch ───────────────────────────────────────────────────────

test_that("print.nax outputs 'no rtf reports' when rtf_info is NULL", {
  skip_on_cran()
  nax <- get_nax()
  nax$rtf_info <- NULL
  output <- capture.output(print(nax))
  expect_true(any(grepl("no rtf reports", output)))
})

# ─── cal_info$summary is not a data.frame ─────────────────────────────────────

test_that("print.nax handles non-data.frame cal_info$summary", {
  skip_on_cran()
  nax <- get_nax()
  nax$rtf_info <- NULL
  nax$cal_info$summary <- "No calibration info available"
  expect_no_error(capture.output(print(nax)))
})
