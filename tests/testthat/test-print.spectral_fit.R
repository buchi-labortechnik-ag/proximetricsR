make_spectral_fit <- function(method_type = "plsr", ncomp = 3,
                              n_observations = 50) {
  obj <- list(
    method = list(type = method_type, ncomp = ncomp),
    n_observations = n_observations,
    y_quantiles = c(`0%` = 1.1, `25%` = 2.2, `50%` = 3.3, `75%` = 4.4, `100%` = 5.5),
    explained_variance = list(
      x_variance = setNames(c(0.5, 0.3, 0.1), paste0("Comp.", 1:3)),
      y_variance = setNames(c(0.6, 0.2, 0.1), paste0("Comp.", 1:3))
    )
  )
  class(obj) <- "spectral_fit"
  obj
}

# ─── return value ─────────────────────────────────────────────────────────────

test_that("print.spectral_fit returns x invisibly", {
  obj <- make_spectral_fit()
  capture.output(out <- print(obj))
  expect_identical(
    names(out),
    c("method", "n_observations", "y_quantiles", "explained_variance")
  )
})

# ─── single-word method (no underscore) ───────────────────────────────────────

test_that("print.spectral_fit prints single-word method name", {
  obj <- make_spectral_fit(method_type = "plsr")
  output <- capture.output(print(obj))
  expect_true(any(grepl("Method:", output)))
  expect_true(any(grepl("pls", output)))
})

# ─── multi-word method (underscore splits into name + suffix) ─────────────────

test_that("print.spectral_fit prints multi-word method with parentheses", {
  obj <- make_spectral_fit(method_type = "plsr_pls")
  output <- capture.output(print(obj))
  expect_true(any(grepl("\\(pls\\)", output)))
})

# ─── n_observations not NULL: full output ─────────────────────────────────────

test_that("print.spectral_fit shows full output when n_observations present", {
  obj <- make_spectral_fit()
  output <- capture.output(print(obj))
  expect_true(any(grepl("Total number of observations:", output)))
  expect_true(any(grepl("Quantiles", output)))
  expect_true(any(grepl("X variance", output)))
  expect_true(any(grepl("Y variance", output)))
})

# ─── n_observations NULL: basic fit branch ────────────────────────────────────

test_that("print.spectral_fit shows 'Basic fit' when n_observations is NULL", {
  obj <- make_spectral_fit()
  obj$n_observations <- NULL
  output <- capture.output(print(obj))
  expect_true(any(grepl("Basic fit", output)))
  expect_false(any(grepl("Quantiles", output)))
})

# ─── bar_width clamp when terminal is narrow ──────────────────────────────────

test_that("print.spectral_fit clamps bar_width to terminal width", {
  obj <- make_spectral_fit()
  old <- options(width = 20)
  on.exit(options(old))
  expect_silent(capture.output(print(obj)))
})

# ─── PLS factors line ─────────────────────────────────────────────────────────

test_that("print.spectral_fit prints PLS factors", {
  obj <- make_spectral_fit(ncomp = 7)
  output <- capture.output(print(obj))
  expect_true(any(grepl("PLS factors: 7", output)))
})
