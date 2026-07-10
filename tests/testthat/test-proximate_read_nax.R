nax_file <- test_path("testdata", "11A601BYDPU00N0101.nax")

# ─── 1. Return class is c("nax", "list") ──────────────────────────────────────

test_that("proximate_read_nax returns an object of class c('nax', 'list')", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_identical(class(result), c("nax", "list"))
})

# ─── 2. Has all required top-level elements ───────────────────────────────────

test_that("proximate_read_nax result has all required top-level elements", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expected <- c("nax_summary", "nad_info", "cal_info", "rtf_info", "data")
  expect_true(all(expected %in% names(result)))
})

# ─── 3. nax_summary structure ─────────────────────────────────────────────────

test_that("nax_summary has content, size, and raw elements", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_true(all(c("content", "size", "raw") %in% names(result$nax_summary)))
})

test_that("nax_summary content is a character vector", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_type(result$nax_summary$content, "character")
  expect_gt(length(result$nax_summary$content), 0L)
})

test_that("nax_summary size is a character string", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_type(result$nax_summary$size, "character")
  expect_equal(length(result$nax_summary$size), 1L)
})

# ─── 4. nad_info structure ────────────────────────────────────────────────────

test_that("nad_info has summary and data elements", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_true(all(c("summary", "data") %in% names(result$nad_info)))
})

test_that("nad_info summary has app_name, properties, geometry, mode, and created", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expected_fields <- c("app_name", "properties", "geometry", "mode", "created")
  expect_true(all(expected_fields %in% names(result$nad_info$summary)))
})

test_that("nad_info summary app_name is a character", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_type(result$nad_info$summary$app_name, "character")
})

test_that("nad_info summary properties has names element", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_true("names" %in% names(result$nad_info$summary$properties))
})

# ─── 5. cal_info is a read_cal object ─────────────────────────────────────────

test_that("cal_info is of class c('read_cal', 'list')", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_identical(class(result$cal_info), c("read_cal", "list"))
})

test_that("cal_info has required read_cal elements", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_true(all(c("summary", "meta_param", "file_info", "models") %in%
    names(result$cal_info)))
})

# ─── 6. data has summary and data elements ────────────────────────────────────

test_that("data element has summary and data sub-elements", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_true(all(c("summary", "data") %in% names(result$data)))
})

test_that("data summary is a data.frame", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_s3_class(result$data$summary, "data.frame")
})

test_that("data data is a list", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_type(result$data$data, "list")
})

# ─── 7. Error for nonexistent file ────────────────────────────────────────────

test_that("proximate_read_nax errors when the file does not exist", {
  expect_error(
    proximate_read_nax("/nonexistent/path/to/file.nax"),
    "File does not exists!"
  )
})

test_that("proximate_read_nax errors for a random non-existent path", {
  expect_error(
    proximate_read_nax(tempfile(fileext = ".nax")),
    "File does not exists!"
  )
})

# ─── 8. nax_summary raw is raw type ──────────────────────────────────────────

test_that("nax_summary raw is of type raw", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_type(result$nax_summary$raw, "raw")
})

test_that("nax_summary raw has length greater than zero", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_nax(nax_file, ignore_version = TRUE))
  expect_gt(length(result$nax_summary$raw), 0L)
})
