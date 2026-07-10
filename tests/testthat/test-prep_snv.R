data("NIRcannabis", package = "proximetricsR")
X <- NIRcannabis$spc[5:15, seq(1, 200, by = 5)] # reduce to save memory

test_that("Standard normal variate returns correct values", {
  expect_snapshot(process(X, prep_snv()))
})

test_that("Row means are 0 after SNV", {
  X_rand <- matrix(rnorm(100), 10, 10)
  X_snv <- process(X_rand, prep_snv())
  expect_equal(apply(X_snv, 1, mean), rep(0, 10))
})

test_that("Row standard deviations are 1 after SNV", {
  X_rand <- matrix(rnorm(100), 10, 10)
  X_snv <- process(X_rand, prep_snv())
  expect_equal(apply(X_snv, 1, sd), rep(1, 10))
})

test_that("SNV without a matrix is of class 'preprocessing", {
  expect_true(inherits(prep_snv(), "preprocessing"))
})
