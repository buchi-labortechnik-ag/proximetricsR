############################################
# STRATIFIED SAMPLING WITHOUT REPLACEMENTS #
############################################

test_that("Stratified sampling without replacements for validation is correct", {
  y_rand <- withr::with_seed(23, matrix(rnorm(20, 5, 2)))
  strat_sample <- sample_stratified(y_rand, 0.8, 5, replacement = FALSE, seed = 54)
  expect_snapshot(strat_sample)
})

test_that("Stratified sampling without replacements for validation uses all indices", {
  y_rand <- matrix(rnorm(50, 50, 5))
  strat_sample <- sample_stratified(y_rand, 0.7, 5, replacement = FALSE)
  combined_folds <- apply(rbind(strat_sample$hold_in, strat_sample$hold_out), 2, sort)
  expect_identical(combined_folds, matrix(rep(1:50, 5), 50, 5, dimnames = list(NULL, c(
    "Resample_1", "Resample_2", "Resample_3", "Resample_4", "Resample_5"
  ))))
})

test_that("Stratified sampling without replacements for calibration is correct", {
  y_rand <- withr::with_seed(23, matrix(rnorm(30, 10, 1)))
  strat_sample <- sample_stratified(y_rand, 0.3, 5, replacement = FALSE, seed = 23)
  expect_snapshot(strat_sample)
})

test_that("Stratified sampling without replacements for calibration uses all indices", {
  strat_sample <- sample_stratified(matrix(rnorm(50, 2, 5)), 0.2, 5, replacement = FALSE)
  combined_folds <- apply(rbind(strat_sample$hold_in, strat_sample$hold_out), 2, sort)
  expect_identical(combined_folds, matrix(rep(1:50, 5), 50, 5, dimnames = list(NULL, c(
    "Resample_1", "Resample_2", "Resample_3", "Resample_4", "Resample_5"
  ))))
})

#########################################
# STRATIFIED SAMPLING WITH REPLACEMENTS #
#########################################

test_that("Stratified sampling with replacements for validation is correct", {
  y_rand <- withr::with_seed(99, matrix(rnorm(20, 10, 5)))
  strat_sample <- sample_stratified(y_rand, 0.8, 5, replacement = TRUE, seed = 45)
  expect_snapshot(strat_sample)
})

test_that("Stratified sampling with replacements for validation uses all indices", {
  y_rand <- matrix(rnorm(50, 15, 5))
  strat_sample <- sample_stratified(y_rand, 0.7, 5, replacement = TRUE)
  combined_folds <- apply(rbind(strat_sample$hold_in, strat_sample$hold_out), 2, sort)
  combined_folds <- apply(combined_folds, 2, unique)
  expect_identical(combined_folds, matrix(rep(1:50, 5), 50, 5, dimnames = list(NULL, c(
    "Resample_1", "Resample_2", "Resample_3", "Resample_4", "Resample_5"
  ))))
})

test_that("Stratified sampling with replacements for calibration is correct", {
  y_rand <- withr::with_seed(23, matrix(rnorm(20, 10, 5)))
  strat_sample <- sample_stratified(y_rand, 0.3, 5, replacement = TRUE, seed = 32)
  expect_snapshot(strat_sample)
})

test_that("Stratified sampling with replacements for calibration uses all indices", {
  strat_sample <- sample_stratified(matrix(rnorm(50)), 0.2, 5, replacement = TRUE)
  combined_folds <- apply(rbind(strat_sample$hold_in, strat_sample$hold_out), 2, sort)
  combined_folds <- apply(combined_folds, 2, unique)
  expect_identical(combined_folds, matrix(rep(1:50, 5), 50, 5, dimnames = list(NULL, c(
    "Resample_1", "Resample_2", "Resample_3", "Resample_4", "Resample_5"
  ))))
})

###############
# WITH GROUPS #
###############

test_that("Stratified group sampling without replacement for validation is correct", {
  y_rand <- withr::with_seed(12, matrix(rnorm(28)))
  grp <- withr::with_seed(28, sample(1:4, 28, replace = TRUE))
  strat_sample <- sample_stratified(y_rand, 0.9, 5, group = grp, replacement = FALSE, seed = 45)
  expect_snapshot(strat_sample)
})

test_that("Stratified group sampling without replacement for calibration is correct", {
  y_rand <- withr::with_seed(8, matrix(rnorm(12)))
  grp <- withr::with_seed(12, sample(1:4, 12, replace = TRUE))
  strat_sample <- sample_stratified(y_rand, 0.4, 5, group = grp, replacement = FALSE, seed = 14)
  expect_snapshot(strat_sample)
})

test_that("Stratified group sampling with replacement for validation is correct", {
  y_rand <- withr::with_seed(18, matrix(rnorm(12)))
  grp <- withr::with_seed(10, sample(1:3, 12, replace = TRUE))
  strat_sample <- sample_stratified(y_rand, 0.6, 5, group = grp, replacement = TRUE, seed = 6)
  expect_snapshot(strat_sample)
})

test_that("Stratified group sampling with replacement for calibration is correct", {
  y_rand <- withr::with_seed(81, matrix(rnorm(18)))
  grp <- withr::with_seed(18, sample(1:6, 18, replace = TRUE))
  strat_sample <- sample_stratified(y_rand, 0.4, 5, group = grp, replacement = TRUE, seed = 4)
  expect_snapshot(strat_sample)
})
