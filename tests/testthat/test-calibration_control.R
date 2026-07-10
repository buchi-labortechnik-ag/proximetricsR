#############################################
# Check the defaults of calibration_control:#
#############################################

default_cal_control <- calibration_control()

expected_names <- c(
  "validation_type", "number", "p", "folds", "tuning_parameter", "learning_rates",
  "remove_outliers", "cal_residual_limit", "mahalanobis_limit", "val_residual_limit",
  "allow_parallel", "fix_pls_factors", "fixed_components", "replacements", "seed"
)

test_that("calibration_control default is list", {
  expect_type(default_cal_control, "list")
})

test_that("calibration_control default is of class calibration_control", {
  expect_true(inherits(default_cal_control, "calibration_control"))
})

test_that("calibration_control defaults have correct names", {
  expect_named(default_cal_control, expected_names)
})

test_that("calibration_control default has length 15", {
  expect_length(default_cal_control, 15)
})

test_that("calibration_control default 'validation_type' is 'lgo'", {
  expect_identical(default_cal_control$validation_type, "lgo")
})

test_that("calibration_control default 'number' is 100", {
  expect_identical(default_cal_control$number, 100)
})

test_that("calibration_control default 'p' is 75%", {
  expect_identical(default_cal_control$p, 0.75)
})

test_that("calibration_control default 'folds' is 'random'", {
  expect_identical(default_cal_control$folds, "random")
})

test_that("calibration_control default 'tuning_parameter' is 'rmse'", {
  expect_identical(default_cal_control$tuning_parameter, "rmse")
})

test_that("calibration_control default 'learning_rates' is c(1.1, 1.05)", {
  expect_identical(default_cal_control$learning_rates, c(maximum = 1.1, sequential = 1.05))
})

test_that("calibration_control default 'remove_outliers' is 0", {
  expect_identical(default_cal_control$remove_outliers, 0)
})

test_that("calibration_control default 'cal_residual_limit' is 2.5", {
  expect_identical(default_cal_control$cal_residual_limit, 2.5)
})

test_that("calibration_control default 'mahalanobis_limit' is 5", {
  expect_identical(default_cal_control$mahalanobis_limit, 5)
})

test_that("calibration_control default 'val_residual_limit' is 3.5", {
  expect_identical(default_cal_control$val_residual_limit, 3.5)
})

test_that("calibration_control default 'allow_parallel' is TRUE", {
  expect_true(default_cal_control$allow_parallel)
})

test_that("calibration_control default 'fix_pls_factors' is TRUE", {
  expect_true(default_cal_control$fix_pls_factors)
})

test_that("calibration_control default 'fix_pls_factors' is TRUE", {
  expect_true(default_cal_control$fix_pls_factors)
})

test_that("calibration_control default 'fixed_components' is 0", {
  expect_true(default_cal_control$replacements)
})

test_that("calibration_control default 'seed' is NULL", {
  expect_null(default_cal_control$seed)
})

test_that("calibration_control default 'number' when 'validation_type' is not 'lgo' is 10", {
  default_non_lgo <- calibration_control("kfold")
  expect_identical(default_non_lgo$number, 10)
})

test_that("calibration_control 'remove_outliers' can be Inf", {
  expect_identical(calibration_control(remove_outliers = Inf)$remove_outliers, Inf)
})


##########################
# Sanity checks testing: #
##########################

test_that("calibration_control 'validation_type' must be one of 'lgo', 'loo', 'kfold' or 'none'", {
  expect_error(calibration_control(validation_type = ""))
})

test_that("calibration_control if 'validation_type' is 'none' gives a warning", {
  expect_warning(calibration_control(validation_type = "none"), "Cross-validation is required for model tuning, parameter tuning will not be conducted")
})

test_that("calibration_control 'number' must be numeric", {
  expect_error(calibration_control(number = ""), "'number' must be numeric")
})

test_that("calibration_control 'p' must be a numeric between 0 and 1", {
  msg <- "p must be a single numeric value larger than 0 and below than 1"
  expect_error(calibration_control(p = ""), msg)
  expect_error(calibration_control(p = 2), msg)
})

test_that("calibration_control 'folds' must be either 'random' or 'sequential'", {
  expect_error(calibration_control(folds = ""))
})

test_that("calibration_control 'tuning_parameter' must be one of 'rmse', 'rsq, or 'none'", {
  expect_error(calibration_control(tuning_parameter = ""))
})

test_that("calibration_control 'learning_rates' must be a vector of numerics with length 2", {
  expect_error(calibration_control(learning_rates = 1), "'learning_rates' must be of length 2.")
  expect_error(calibration_control(learning_rates = c("", "")), "'learning_rates' must a vector of numericals.")
})

test_that("calibration_control 'remove_outliers' must be an integer or Inf", {
  expect_error(calibration_control(remove_outliers = TRUE), "'remove_outliers' must be an integer or 'Inf'.")
})

test_that("calibration_control 'cal_residual_limit' must be a numeric", {
  expect_error(calibration_control(cal_residual_limit = "", "'cal_residual_limit' must be numerical."))
})

test_that("calibration_control 'mahalanobis_limit' must be a numeric", {
  expect_error(calibration_control(mahalanobis_limit = "", "'mahalanobis_limit' must be numerical."))
})

test_that("calibration_control 'val_residual_limit' must be a numeric", {
  expect_error(calibration_control(val_residual_limit = "", "'val_residual_limit' must be numerical."))
})

test_that("calibration_control 'allow_parallel' must be a logical", {
  expect_error(calibration_control(allow_parallel = ""), "allow_parallel must be a logical value")
})

test_that("calibration_control 'fix_pls_factors' must be a logical", {
  expect_error(calibration_control(fix_pls_factors = ""), "'fix_pls_factors' must be a logical.")
})

test_that("calibration_control 'replacements' must be a logical", {
  expect_error(calibration_control(replacements = ""), "'replacements' must be a logical.")
})

test_that("calibration_control 'seed' must be a numerical or NULL", {
  expect_error(calibration_control(seed = ""), "'seed' must be either NULL or an integer.")
})

test_that("calibration_control 'mahalanobis_limit' must be numerical", {
  expect_error(calibration_control(mahalanobis_limit = ""), "'mahalanobis_limit' must be numerical.")
})

test_that("calibration_control 'cal_residual_limit' must be numerical", {
  expect_error(calibration_control(cal_residual_limit = ""), "'cal_residual_limit' must be numerical.")
})

test_that("calibration_control 'val_residual_limit' must be numerical", {
  expect_error(calibration_control(val_residual_limit = ""), "'val_residual_limit' must be numerical.")
})
