test_that("Leave-one-out CV is correct without groups", {
  loo_sample <- sample_loo(5)
  expect_identical(loo_sample$hold_out, matrix(1:5, ncol = 5, dimnames = list("index_1")))
  expect_snapshot(loo_sample$hold_in)
})

test_that("Leave-one-out CV assigns only one index per fold per hold-out", {
  loo_sample <- sample_loo(10)
  expect_identical(nrow(loo_sample$hold_out), 1L)
})

test_that("Leave-one-out CV assigns each index to a fold", {
  loo_sample <- sample_loo(8)
  combined_folds <- apply(rbind(loo_sample$hold_in, loo_sample$hold_out), 2, sort)
  expect_identical(combined_folds, matrix(rep(1:8, 8), 8, 8))
})

test_that("Leave-one-out CV is correct with groups", {
  grp <- withr::with_seed(15, sample(1:3, 12, replace = TRUE))
  loo_sample <- sample_loo(12, group = grp)
  expect_snapshot(loo_sample)
})

test_that("Leave-one-out CV with groups assigns each index to a fold", {
  grp <- withr::with_seed(10, sample(1:3, 10, replace = TRUE))
  loo_sample <- sample_loo(10, group = grp)
  combined_folds <- apply(rbind(loo_sample$hold_in, loo_sample$hold_out), 2, sort)
  expect_identical(combined_folds, matrix(rep(1:10, 3), 10, 3))
})

#################
# SANITY CHECKS #
#################

test_that("The length of group must be equal to the number of indices", {
  expect_error(sample_loo(5, rep(1:2, 2)), "The length of 'group' must be equal to 'N = 5'")
})
