data("NIRcannabis")
X <- NIRcannabis$spc

# ─── constructor: class and structure ─────────────────────────────────────────

test_that("prep_detrend returns class c('preprocessing', 'list')", {
  dt <- prep_detrend()
  expect_identical(class(dt), c("preprocessing", "list"))
})

test_that("prep_detrend stores method name", {
  dt <- prep_detrend()
  expect_identical(dt$method, "prep_detrend")
})

test_that("prep_detrend default p is 2L", {
  dt <- prep_detrend()
  expect_identical(dt$p, 2L)
})

test_that("prep_detrend stores custom p as integer", {
  dt <- prep_detrend(p = 3)
  expect_identical(dt$p, 3L)
})

test_that("prep_detrend compatible_devices is 'proxiscout'", {
  dt <- prep_detrend()
  expect_identical(dt$compatible_devices, "proxiscout")
})

# ─── constructor: validation errors ───────────────────────────────────────────

test_that("prep_detrend errors on non-numeric p", {
  expect_error(prep_detrend(p = "a"), "'p' must be numeric")
})

test_that("prep_detrend errors when p < 1", {
  expect_error(prep_detrend(p = 0), "'p' must be an integer >= 1")
})

test_that("prep_detrend errors when p is negative", {
  expect_error(prep_detrend(p = -1), "'p' must be an integer >= 1")
})

# ─── execution via process() ──────────────────────────────────────────────────

test_that("process with prep_detrend returns matrix of same dimensions", {
  recipe <- preprocess_recipe(prep_detrend(p = 2), device = "unspecified")
  result <- process(X, recipe)
  expect_equal(dim(result), dim(X))
})

test_that("process with prep_detrend returns numeric matrix", {
  recipe <- preprocess_recipe(prep_detrend(p = 2), device = "unspecified")
  result <- process(X, recipe)
  expect_true(is.matrix(result))
  expect_true(is.numeric(result))
})

test_that("process with prep_detrend changes spectral values", {
  recipe <- preprocess_recipe(prep_detrend(p = 2), device = "unspecified")
  result <- process(X, recipe)
  expect_false(isTRUE(all.equal(as.numeric(result[1, ]), as.numeric(X[1, ]))))
})

test_that("process with prep_detrend p=1 works", {
  recipe <- preprocess_recipe(prep_detrend(p = 1), device = "unspecified")
  result <- process(X, recipe)
  expect_equal(dim(result), dim(X))
})

test_that("SNV followed by detrend (Barnes) works end-to-end", {
  recipe <- preprocess_recipe(prep_snv(), prep_detrend(p = 2), device = "unspecified")
  result <- process(X, recipe)
  expect_equal(dim(result), dim(X))
  expect_true(is.numeric(result))
})

test_that("prep_detrend in proxiscout recipe is accepted", {
  recipe <- preprocess_recipe(
    prep_resample(grid = "proxiscout"),
    prep_detrend(p = 2),
    device = "proxiscout"
  )
  expect_identical(recipe$device, "proxiscout")
})
