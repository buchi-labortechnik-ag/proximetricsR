#############################
# SEQUENTIAL KFOLD SAMPLING #
#############################

test_that("Sequential kfold sampling is as expected", {
  seq_sample <- sample_kfold(10, 5, sampling = "sequential")
  # Held out matrix
  hold_out_exp <- matrix(1:10, 2, 5, byrow = TRUE, dimnames = list(
    c("index_1", "index_2"),
    c("Fold_1", "Fold_2", "Fold_3", "Fold_4", "Fold_5")
  ))
  expect_identical(seq_sample$hold_out, hold_out_exp)

  # Held in matrix
  expect_snapshot(seq_sample$hold_in)
})

test_that("Sequential kfold sampling assigns each index to hold-in or hold-out set", {
  seq_sample <- sample_kfold(15, 3, sampling = "sequential")
  combined_folds <- apply(rbind(seq_sample$hold_in, seq_sample$hold_out), 2, sort)
  expect_identical(combined_folds, matrix(rep(1:15, 3), 15, 3, dimnames = list(NULL, c("Fold_1", "Fold_2", "Fold_3"))))
})

test_that("Each index is only once selected in the sequential kfold hold-out set", {
  seq_sample <- sample_kfold(20, 3, sampling = "sequential")
  expect_identical(sort(na.omit(c(seq_sample$hold_out))), 1:20)
})

test_that("Leftover indices are correctly assigned to a sequential fold", {
  seq_sample <- sample_kfold(9, 4, sampling = "sequential")
  hold_out_exp <- matrix(c(1:9, rep(NA, 3)), 3, 4, byrow = TRUE, dimnames = list(
    c("index_1", "index_2", "index_3"),
    c("Fold_1", "Fold_2", "Fold_3", "Fold_4")
  ))
  expect_identical(seq_sample$hold_out, hold_out_exp)

  # Held in matrix
  expect_snapshot(seq_sample$hold_in)
})

test_that("Grouped sequential kfold sampling computes the correct indices", {
  seq_group_sample <- sample_kfold(15, 2, group = rep(1:5, 3), sampling = "sequential")
  expect_snapshot(seq_group_sample)
})

test_that("Each index is only once selected in the grouped sequential kfold hold-out set", {
  withr::with_seed(45, {
    grp <- sample(1:4, 20, replace = TRUE)
  })
  seq_sample <- sample_kfold(20, 2, group = grp, sampling = "sequential")
  expect_identical(sort(na.omit(c(seq_sample$hold_out))), 1:20)
})

#########################
# RANDOM KFOLD SAMPLING #
#########################

test_that("Random kfold sampling is as expected", {
  rand_sample <- sample_kfold(15, 5, sampling = "random", seed = 25)
  expect_snapshot(rand_sample)
})

test_that("Sequential kfold sampling assigns each index to hold-in or hold-out set", {
  seq_sample <- sample_kfold(16, 3, sampling = "random")
  combined_folds <- apply(rbind(seq_sample$hold_in, seq_sample$hold_out), 2, sort)
  expect_identical(combined_folds, matrix(rep(1:16, 3), 16, 3, dimnames = list(NULL, c("Fold_1", "Fold_2", "Fold_3"))))
})

test_that("Each index is only once selected in the random kfold hold-out set", {
  seq_sample <- sample_kfold(13, 3, sampling = "random")
  expect_identical(sort(na.omit(c(seq_sample$hold_out))), 1:13)
})

test_that("Leftover indices are correctly assigned to a random fold", {
  rand_sample <- sample_kfold(15, 6, sampling = "random", seed = 47)
  expect_snapshot(rand_sample)
})

test_that("Grouped random kfold sampling computes the correct indices", {
  rand_group_sample <- sample_kfold(15, 2, group = rep(1:5, 3), sampling = "random", seed = 123)
  expect_snapshot(rand_group_sample)
})

test_that("Each index is only once selected in the grouped random kfold hold-out set", {
  withr::with_seed(123, {
    grp <- sample(1:4, 20, replace = TRUE)
  })
  seq_sample <- sample_kfold(20, 2, group = grp, sampling = "random")
  expect_identical(sort(na.omit(c(seq_sample$hold_out))), 1:20)
})

#################
# SANITY CHECKS #
#################

test_that("The length of group must be equal to N", {
  expect_error(sample_kfold(5, 2, group = 1:4), "The length of 'group' must be equal to 'N = 5'")
})

test_that("The number of groups must be larger than twice the number of folds", {
  expect_error(sample_kfold(10, 5, group = rep(1:2, 5)), "Argument 'number' cannot be larger than the half of the number of groups")
})

test_that("The number of folds must be smaller than half the number of indices", {
  expect_error(sample_kfold(10, 10), "Argument 'number' cannot be larger than N/2")
})
