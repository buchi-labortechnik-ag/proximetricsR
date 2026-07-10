data("NIRcannabis", package = "proximetricsR")
X <- NIRcannabis$spc[1:40, 1:15] # reduced number of wavelengths to save memory
Y <- matrix(NIRcannabis$THC[1:40], dimnames = list(NULL, "thc"))
method <- fit_plsr(10)
group <- rep(1:10, times = 4)

# Helper function to round numeric values for tolerance in snapshots
round_numeric_tol <- function(x, digits = 5) {
  if (is.numeric(x)) {
    return(round(x, digits))
  } else if (is.list(x)) {
    return(lapply(x, round_numeric_tol, digits = digits))
  } else if (is.matrix(x) || is.data.frame(x)) {
    return(round(x, digits))
  }
  return(x)
}

control_loo <- calibration_control(validation_type = "loo")

##################################
# LEAVE-ONE-OUT CROSS-VALIDATION #
##################################

test_that("Standard leave-one-out cross-validation computes correctly", {
  model_loo <- proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_loo, verbose = FALSE)
  withr::with_options(list(digits = 6), expect_snapshot(model_loo))
  expect_length(model_loo, 2)
  expect_named(model_loo, c("grid", "predicted"))
  expect_true(all(colnames(model_loo$grid) == c("ncomp", "rsq", "rmse", "largest_residual")))
  expect_identical(dim(model_loo$grid), c(as.integer(method$ncomp), 4L))
  expect_identical(dim(model_loo$predicted), c(nrow(X), as.integer(method$ncomp)))
})

test_that("Grouped leave-one-out cross-validation computes correctly", {
  model_loo_grp <- proximetricsR:::.calibrate_cv(X, Y, group = group, method = method, control = control_loo, verbose = FALSE)
  withr::with_options(list(digits = 6), expect_snapshot(model_loo_grp))
  expect_length(model_loo_grp, 2)
  expect_named(model_loo_grp, c("grid", "predicted"))
  expect_true(all(colnames(model_loo_grp$grid) == c("ncomp", "rsq", "rmse", "largest_residual")))
  expect_identical(dim(model_loo_grp$grid), c(as.integer(method$ncomp), 4L))
  expect_identical(dim(model_loo_grp$predicted), c(nrow(X), as.integer(method$ncomp)))
})

###########################
# k-fold Cross-Validation #
###########################

test_that("kfold validation with sequential folds computes as expected", {
  control_seq <- calibration_control(validation_type = "kfold", number = 5, folds = "sequential")
  model_kfold_seq <- proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_seq, verbose = FALSE)
  withr::with_options(list(digits = 6), expect_snapshot(model_kfold_seq))
  expect_length(model_kfold_seq, 2)
  expect_named(model_kfold_seq, c("grid", "predicted"))
  expect_true(all(colnames(model_kfold_seq$grid) == c("ncomp", "rsq", "rmse", "largest_residual")))
  expect_identical(dim(model_kfold_seq$grid), c(as.integer(method$ncomp), 4L))
  expect_identical(dim(model_kfold_seq$predicted), c(nrow(X), as.integer(method$ncomp)))
})

test_that("kfold validation with sequential folds with groups computes as expected", {
  control_seq <- calibration_control(validation_type = "kfold", number = 5, folds = "sequential")
  model_kfold_seq <- proximetricsR:::.calibrate_cv(X, Y, group = group, method = method, control = control_seq, verbose = FALSE)
  withr::with_options(list(digits = 6), expect_snapshot(model_kfold_seq))
  expect_length(model_kfold_seq, 2)
  expect_named(model_kfold_seq, c("grid", "predicted"))
  expect_true(all(colnames(model_kfold_seq$grid) == c("ncomp", "rsq", "rmse", "largest_residual")))
  expect_identical(dim(model_kfold_seq$grid), c(as.integer(method$ncomp), 4L))
  expect_identical(dim(model_kfold_seq$predicted), c(nrow(X), as.integer(method$ncomp)))
})

test_that("kfold validation with random folds are correct", {
  control_rand <- calibration_control(validation_type = "kfold", number = 5, folds = "random", seed = 123)
  model_kfold_rand <- proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_rand, verbose = FALSE)
  withr::with_options(list(digits = 6), expect_snapshot(round_numeric_tol(model_kfold_rand)))
  expect_length(model_kfold_rand, 2)
  expect_named(model_kfold_rand, c("grid", "predicted"))
  expect_true(all(colnames(model_kfold_rand$grid) == c("ncomp", "rsq", "rmse", "largest_residual")))
  expect_identical(dim(model_kfold_rand$grid), c(as.integer(method$ncomp), 4L))
  expect_identical(dim(model_kfold_rand$predicted), c(nrow(X), as.integer(method$ncomp)))
})

test_that("kfold validation with random folds and groups are correct", {
  control_rand <- calibration_control(validation_type = "kfold", number = 5, folds = "random", seed = 321)
  model_kfold_rand <- proximetricsR:::.calibrate_cv(X, Y, group = group, method = method, control = control_rand, verbose = FALSE)
  withr::with_options(list(digits = 6), expect_snapshot(model_kfold_rand))
  expect_length(model_kfold_rand, 2)
  expect_named(model_kfold_rand, c("grid", "predicted"))
  expect_true(all(colnames(model_kfold_rand$grid) == c("ncomp", "rsq", "rmse", "largest_residual")))
  expect_identical(dim(model_kfold_rand$grid), c(as.integer(method$ncomp), 4L))
  expect_identical(dim(model_kfold_rand$predicted), c(nrow(X), as.integer(method$ncomp)))
})

test_that("leave-group-out CV with replacements, sampling for validation  samples", {
  control_lgo_val <- calibration_control(validation_type = "lgo", number = 10, p = 0.75, seed = 42)
  model_lgo_val <- proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_lgo_val, verbose = F)
  withr::with_options(list(digits = 6), expect_snapshot(model_lgo_val))
  expect_length(model_lgo_val, 1)
  expect_named(model_lgo_val, c("grid"))
  lgo_grid_names <- c("ncomp", "rsq", "rmse", "largest_residual", "rsq_sd", "rmse_sd", "largest_residual_sd")
  expect_true(all(colnames(model_lgo_val$grid) == lgo_grid_names))
  expect_identical(dim(model_lgo_val$grid), c(as.integer(method$ncomp), 7L))
})

test_that("leave-group-out CV with replacements, sampling for validation groups", {
  control_lgo_val <- calibration_control(validation_type = "lgo", number = 10, p = 0.75, seed = 24)
  model_lgo_val_grp <- proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_lgo_val, verbose = F)
  withr::with_options(list(digits = 6), expect_snapshot(model_lgo_val_grp))
  expect_length(model_lgo_val_grp, 1)
  expect_named(model_lgo_val_grp, c("grid"))
  lgo_grid_names <- c("ncomp", "rsq", "rmse", "largest_residual", "rsq_sd", "rmse_sd", "largest_residual_sd")
  expect_true(all(colnames(model_lgo_val_grp$grid) == lgo_grid_names))
  expect_identical(dim(model_lgo_val_grp$grid), c(as.integer(method$ncomp), 7L))
})

test_that("leave-group-out CV with replacements, sampling for calibration  samples", {
  control_lgo_cal <- calibration_control(validation_type = "lgo", number = 10, p = 0.30, seed = 23)
  model_lgo_cal <- proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_lgo_cal, verbose = F)
  withr::with_options(list(digits = 6), expect_snapshot(model_lgo_cal))
  expect_length(model_lgo_cal, 1)
  expect_named(model_lgo_cal, c("grid"))
  lgo_grid_names <- c("ncomp", "rsq", "rmse", "largest_residual", "rsq_sd", "rmse_sd", "largest_residual_sd")
  expect_true(all(colnames(model_lgo_cal$grid) == lgo_grid_names))
  expect_identical(dim(model_lgo_cal$grid), c(as.integer(method$ncomp), 7L))
})

test_that("leave-group-out CV with replacements, sampling for calibration groups", {
  control_lgo_cal <- calibration_control(validation_type = "lgo", number = 10, p = 0.30, seed = 32)
  model_lgo_cal_grp <- proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_lgo_cal, verbose = F)
  withr::with_options(list(digits = 6), expect_snapshot(model_lgo_cal_grp))
  expect_length(model_lgo_cal_grp, 1)
  expect_named(model_lgo_cal_grp, c("grid"))
  lgo_grid_names <- c("ncomp", "rsq", "rmse", "largest_residual", "rsq_sd", "rmse_sd", "largest_residual_sd")
  expect_true(all(colnames(model_lgo_cal_grp$grid) == lgo_grid_names))
  expect_identical(dim(model_lgo_cal_grp$grid), c(as.integer(method$ncomp), 7L))
})


test_that("leave-group-out CV without replacements, sampling for validation  samples", {
  control_lgo_val <- calibration_control(validation_type = "lgo", number = 10, p = 0.75, replacements = FALSE, seed = 54)
  model_lgo_val <- proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_lgo_val, verbose = F)
  withr::with_options(list(digits = 6), expect_snapshot(model_lgo_val))
  expect_length(model_lgo_val, 1)
  expect_named(model_lgo_val, c("grid"))
  lgo_grid_names <- c("ncomp", "rsq", "rmse", "largest_residual", "rsq_sd", "rmse_sd", "largest_residual_sd")
  expect_true(all(colnames(model_lgo_val$grid) == lgo_grid_names))
  expect_identical(dim(model_lgo_val$grid), c(as.integer(method$ncomp), 7L))
})

test_that("leave-group-out CV without replacements, sampling for validation groups", {
  control_lgo_val <- calibration_control(validation_type = "lgo", number = 10, p = 0.75, replacements = FALSE, seed = 45)
  model_lgo_val_grp <- proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_lgo_val, verbose = F)
  withr::with_options(list(digits = 6), expect_snapshot(model_lgo_val_grp))
  expect_length(model_lgo_val_grp, 1)
  expect_named(model_lgo_val_grp, c("grid"))
  lgo_grid_names <- c("ncomp", "rsq", "rmse", "largest_residual", "rsq_sd", "rmse_sd", "largest_residual_sd")
  expect_true(all(colnames(model_lgo_val_grp$grid) == lgo_grid_names))
  expect_identical(dim(model_lgo_val_grp$grid), c(as.integer(method$ncomp), 7L))
})

test_that("leave-group-out CV without replacements, sampling for calibration  samples", {
  control_lgo_cal <- calibration_control(validation_type = "lgo", number = 10, p = 0.30, replacements = FALSE, seed = 90)
  model_lgo_cal <- proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_lgo_cal, verbose = F)
  withr::with_options(list(digits = 6), expect_snapshot(model_lgo_cal))
  expect_length(model_lgo_cal, 1)
  expect_named(model_lgo_cal, c("grid"))
  lgo_grid_names <- c("ncomp", "rsq", "rmse", "largest_residual", "rsq_sd", "rmse_sd", "largest_residual_sd")
  expect_true(all(colnames(model_lgo_cal$grid) == lgo_grid_names))
  expect_identical(dim(model_lgo_cal$grid), c(as.integer(method$ncomp), 7L))
})

test_that("leave-group-out CV without replacements, sampling for calibration groups", {
  control_lgo_cal <- calibration_control(validation_type = "lgo", number = 10, p = 0.30, replacements = FALSE, seed = 9)
  model_lgo_cal_grp <- proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_lgo_cal, verbose = F)
  withr::with_options(list(digits = 6), expect_snapshot(model_lgo_cal_grp))
  expect_length(model_lgo_cal_grp, 1)
  expect_named(model_lgo_cal_grp, c("grid"))
  lgo_grid_names <- c("ncomp", "rsq", "rmse", "largest_residual", "rsq_sd", "rmse_sd", "largest_residual_sd")
  expect_true(all(colnames(model_lgo_cal_grp$grid) == lgo_grid_names))
  expect_identical(dim(model_lgo_cal_grp$grid), c(as.integer(method$ncomp), 7L))
})

#################
# SANITY CHECKS #
#################

test_that("Missing values in X or Y are not allowed", {
  expect_error(proximetricsR:::.calibrate_cv(matrix(NA), matrix(1), control = control_loo, method = method), "Missing values in X are not allowed")
  expect_error(proximetricsR:::.calibrate_cv(matrix(1), matrix(NA), control = control_loo, method = method), "Missing values in Y are not allowed")
})

test_that("No validation requested throws an error", {
  expect_warning(control_none <- calibration_control(validation_type = "none"))
  expect_error(
    proximetricsR:::.calibrate_cv(X, Y, method = method, control = control_none, verbose = F),
    "This function requires a 'validation_type' in 'control' that is not 'none'."
  )
})

test_that("The spectra must be given as a matrix", {
  expect_error(proximetricsR:::.calibrate_cv(c(1), matrix(1), control = control_loo, method = method), "'X' must be a matrix.")
})

test_that("The reference values have to be a matrix", {
  expect_error(proximetricsR:::.calibrate_cv(matrix(1), c(1), control = control_loo, method = method), "'Y' must be a matrix.")
})

test_that("The regression fitting method must be of class 'fit_constructor'", {
  expect_error(
    proximetricsR:::.calibrate_cv(matrix(1), matrix(1), control = control_loo, method = list(1)),
    "'method' must be of class 'fit_constructor'"
  )
})

test_that("The control argument must be of class 'calibration_control'", {
  expect_error(
    proximetricsR:::.calibrate_cv(matrix(1), matrix(1), control = list(), method = method),
    "'control' must be of class 'calibration_control'"
  )
})

test_that("The verbose argument must be logical", {
  expect_error(
    proximetricsR:::.calibrate_cv(matrix(1), matrix(1), control = control_loo, method = method, verbose = "1"),
    "'verbose' must be a logical"
  )
})
