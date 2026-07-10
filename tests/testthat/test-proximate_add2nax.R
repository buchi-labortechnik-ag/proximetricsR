data("NIRcannabis")

# ─── helper: minimal proximate_data object ────────────────────────────────────

make_pd <- function() {
  spc <- NIRcannabis$spc[1:10, ]
  id <- paste0("S", 1:10)
  proximate_data(spc = spc, id = id)
}

# ─── error: data not proximate_data ───────────────────────────────────────────

test_that("proximate_add2nax errors when data is not proximate_data", {
  df <- data.frame(a = 1:3)
  expect_error(proximate_add2nax(data = df), "proximate_data")
})

# ─── valid call: formulas = NULL ──────────────────────────────────────────────

test_that("proximate_add2nax works with formulas = NULL", {
  pd <- make_pd()
  result <- proximate_add2nax(data = pd)
  expect_true(inherits(result, "list"))
  expect_null(result$formulas)
})

# ─── return class ─────────────────────────────────────────────────────────────

test_that("proximate_add2nax returns class c('list', 'nax_augment')", {
  pd <- make_pd()
  result <- proximate_add2nax(data = pd)
  expect_identical(class(result), c("list", "nax_augment"))
})

# ─── return structure ─────────────────────────────────────────────────────────

test_that("proximate_add2nax result has expected names", {
  pd <- make_pd()
  result <- proximate_add2nax(data = pd)
  expect_identical(names(result), c("formulas", "data", "metadata_list", "skip_indices_list"))
})

# ─── error: formula variable not in data ──────────────────────────────────────

test_that("proximate_add2nax errors when formula variable is absent from data", {
  pd <- make_pd()
  f <- list(nonexistent ~ spc)
  expect_error(proximate_add2nax(formulas = f, data = pd), "response variables")
})

# ─── error: metadata_list length mismatch ─────────────────────────────────────

test_that("proximate_add2nax errors on metadata_list length mismatch", {
  pd <- make_pd()
  f <- list(THCA ~ spc, CBD ~ spc)
  pd2 <- proximate_data(
    spc = NIRcannabis$spc[1:10, ],
    id = paste0("S", 1:10),
    properties = as.matrix(NIRcannabis[1:10, c("THCA", "CBD")])
  )
  expect_error(
    proximate_add2nax(formulas = f, data = pd2, metadata_list = list(NULL)),
    "metadata_list"
  )
})

# ─── error: skip_indices_list length mismatch ─────────────────────────────────

test_that("proximate_add2nax errors on skip_indices_list length mismatch", {
  pd2 <- proximate_data(
    spc = NIRcannabis$spc[1:10, ],
    id = paste0("S", 1:10),
    properties = as.matrix(NIRcannabis[1:10, c("THCA", "CBD")])
  )
  f <- list(THCA ~ spc, CBD ~ spc)
  expect_error(
    proximate_add2nax(formulas = f, data = pd2, skip_indices_list = list(numeric())),
    "skip_indices_list"
  )
})

# ─── valid call with formulas ──────────────────────────────────────────────────

test_that("proximate_add2nax accepts valid formulas and data", {
  pd2 <- proximate_data(
    spc = NIRcannabis$spc[1:10, ],
    id = paste0("S", 1:10),
    properties = as.matrix(NIRcannabis[1:10, c("THCA", "CBD")])
  )
  f <- list(THCA ~ spc)
  result <- proximate_add2nax(formulas = f, data = pd2)
  expect_identical(result$formulas, f)
  expect_identical(result$data, pd2)
})

# ─── valid call with all arguments ────────────────────────────────────────────

test_that("proximate_add2nax stores all arguments correctly", {
  pd2 <- proximate_data(
    spc = NIRcannabis$spc[1:10, ],
    id = paste0("S", 1:10),
    properties = as.matrix(NIRcannabis[1:10, c("THCA"), drop = FALSE])
  )
  f <- list(THCA ~ spc)
  meta <- list(NULL)
  skip <- list(numeric())
  result <- proximate_add2nax(
    formulas = f, data = pd2,
    metadata_list = meta, skip_indices_list = skip
  )
  expect_identical(result$metadata_list, meta)
  expect_identical(result$skip_indices_list, skip)
})
