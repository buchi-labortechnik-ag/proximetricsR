cal_file <- test_path("testdata", "DEMO_Soybean_Meal_Upview.Fat.cal")

# ─── 1. Return class is c("read_cal", "list") ─────────────────────────────────

test_that("proximate_read_cal returns an object of class c('read_cal', 'list')", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  expect_identical(class(result), c("read_cal", "list"))
})

# ─── 2. Has required top-level elements ───────────────────────────────────────

test_that("proximate_read_cal result has summary, meta_param, file_info, and models", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  expect_true(all(c("summary", "meta_param", "file_info", "models") %in% names(result)))
})

# ─── 3. summary is a data.frame with correct columns ──────────────────────────

test_that("proximate_read_cal summary is a data.frame", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  expect_s3_class(result$summary, "data.frame")
})

test_that("proximate_read_cal summary has the expected columns", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  expected_cols <- c(
    "Property", "Preprocessing", "Method", "Factors",
    "Cross-validation", "Auto-skip"
  )
  expect_true(all(expected_cols %in% colnames(result$summary)))
})

test_that("proximate_read_cal summary has at least one row", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  expect_gt(nrow(result$summary), 0L)
})

# ─── 4. models is a named list ────────────────────────────────────────────────

test_that("proximate_read_cal models element is a named list", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  expect_type(result$models, "list")
  expect_false(is.null(names(result$models)))
  expect_true(all(nchar(names(result$models)) > 0))
})

test_that("models names match Property column in summary", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  expect_identical(names(result$models), result$summary$Property)
})

# ─── 5. meta_param has expected structure ────────────────────────────────────

test_that("meta_param is a list named by property", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  expect_type(result$meta_param, "list")
  expect_identical(names(result$meta_param), result$summary$Property)
})

test_that("each meta_param entry has precipe, auto_skip, and aggregate", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  for (mp in result$meta_param) {
    expect_true(all(c("precipe", "auto_skip", "aggregate") %in% names(mp)))
  }
})

test_that("meta_param aggregate is logical", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  for (mp in result$meta_param) {
    expect_type(mp$aggregate, "logical")
  }
})

# ─── 6. Invalid file extension errors ─────────────────────────────────────────

test_that("proximate_read_cal errors on a non-.cal extension", {
  expect_error(proximate_read_cal("model.txt"), "Ivalid input file format")
})

test_that("proximate_read_cal errors when given a .nax file", {
  expect_error(
    proximate_read_cal(test_path("testdata", "11A601BYDPU00N0101.nax")),
    "Ivalid input file format"
  )
})

test_that("proximate_read_cal errors when given mixed extensions", {
  skip_on_cran()
  expect_error(
    proximate_read_cal(c(cal_file, "other.txt")),
    "Ivalid input file format"
  )
})

# ─── 7. predict.read_cal returns predictions and distances ────────────────────

test_that("predict.read_cal returns a list with predictions and distances", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  # Use the wavelengths from the first model to build minimal newdata.
  wavs <- result$models[[1]]$Wavelengths
  newdat <- matrix(
    rnorm(length(wavs)),
    nrow = 1,
    dimnames = list(NULL, as.character(wavs))
  )
  preds <- predict(result, newdata = newdat)
  expect_true(all(c("predictions", "distances") %in% names(preds)))
})

test_that("predict.read_cal predictions is a named list", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  wavs <- result$models[[1]]$Wavelengths
  newdat <- matrix(
    rnorm(2 * length(wavs)),
    nrow = 2,
    dimnames = list(NULL, as.character(wavs))
  )
  preds <- predict(result, newdata = newdat)
  expect_type(preds$predictions, "list")
  expect_identical(names(preds$predictions), names(result$models))
})

test_that("predict.read_cal distances has the same names as predictions", {
  skip_on_cran()
  result <- suppressWarnings(proximate_read_cal(cal_file, ignore_version = TRUE))
  wavs <- result$models[[1]]$Wavelengths
  newdat <- matrix(
    rnorm(3 * length(wavs)),
    nrow = 3,
    dimnames = list(NULL, as.character(wavs))
  )
  preds <- predict(result, newdata = newdat)
  expect_identical(names(preds$distances), names(preds$predictions))
})
