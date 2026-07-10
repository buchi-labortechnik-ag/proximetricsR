data("NIRcannabis", package = "proximetricsR")

gen_cal_file_from_model <- function(object, application_name, property_name) {
  temporary_dir <- tempdir()

  # Reduce precision to try and avoid checking for machine precision
  # ... for the model
  object$final_model$model$intercept <- round(object$final_model$model$intercept, digits = 5)
  object$final_model$model$x_means <- round(object$final_model$model$x_means, digits = 5)
  object$final_model$model$projection_m <- round(object$final_model$model$projection_m, digits = 5)
  object$final_model$model$coefficients <- round(object$final_model$model$coefficients, digits = 5)
  object$final_model$model$x_residuals <- round(object$final_model$model$x_residuals, digits = 5)
  object$final_model$model$weights <- round(object$final_model$model$weights, digits = 5)
  object$final_model$model$scores <- round(object$final_model$model$scores, digits = 5)
  object$final_model$model$sd_scores <- round(object$final_model$model$sd_scores, digits = 5)
  object$final_model$model$scaled_scores <- round(object$final_model$model$scaled_scores, digits = 5)
  object$final_model$model$y_loadings <- round(object$final_model$model$y_loadings, digits = 5)
  object$final_model$model$x_loadings <- round(object$final_model$model$x_loadings, digits = 5)
  object$final_model$model$fitted_y <- round(object$final_model$model$fitted_y, digits = 5)
  object$final_model$model$cal_error <- round(object$final_model$model$cal_error, digits = 5)
  object$final_model$model$y_quantiles <- round(object$final_model$model$y_quantiles, digits = 5)
  object$final_model$model$explained_variance$x_variance <- round(object$final_model$model$explained_variance$x_variance, digits = 5)
  object$final_model$model$explained_variance$y_variance <- round(object$final_model$model$explained_variance$y_variance, digits = 5)

  # ... for model_cv
  object$final_model$model_cv$grid <- round(object$final_model$model_cv$grid, digits = 5)
  if (!is.null(object$final_model$model_cv$predicted)) {
    object$final_model$model_cv$predicted <- round(object$final_model$model_cv$predicted, digits = 5)
  }

  # ... for calibration_statistics_all
  object$final_model$calibration_statistics_all$fitted_y <- round(object$final_model$calibration_statistics_all$fitted_y, digits = 5)
  object$final_model$calibration_statistics_all$residual <- round(object$final_model$calibration_statistics_all$residual, digits = 5)
  object$final_model$calibration_statistics_all$Mahalanobis <- round(object$final_model$calibration_statistics_all$Mahalanobis, digits = 5)
  if (!is.null(object$final_model$calibration_statistics_all$predicted_y_in_cv)) {
    object$final_model$calibration_statistics_all$predicted_y_in_cv <-
      round(object$final_model$calibration_statistics_all$predicted_y_in_cv, digits = 5)
    object$final_model$calibration_statistics_all$cv_residual <-
      round(object$final_model$calibration_statistics_all$cv_residual, digits = 5)
    object$final_model$calibration_statistics_all$Q_value <-
      round(object$final_model$calibration_statistics_all$Q_value, digits = 5)
  }

  # ... and the preprocessed X
  object$preprocessed_X <- round(object$preprocessed_X, digits = 5)

  write_cal(list(object),
    tsv_paths = "", application_name = application_name,
    path = temporary_dir, verbose = FALSE
  )
  paste0(temporary_dir, "/", application_name, ".", property_name, ".cal")
}

test_that("Writing calibration files works on refitted models with kfold sampling", {
  dat <- NIRcannabis[seq(2, 80, by = 3), ]
  dat <- dat[, !colnames(NIRcannabis) %in% c("CBDA", "CBD", "THCA")]
  dat$spc <- dat$spc[, seq(2, 234, by = 10)]
  dat$SRN <- dat$SNR
  dat$SNR <- NULL
  method <- fit_plsr(5, "modified")
  control <- calibration_control(
    validation_type = "kfold", number = 3, folds = "random", remove_outliers = 0,
    seed = 23
  )
  pretreats <- preprocess_recipe(
    prep_resample(c(1035, 1690, 35)),
    prep_derivative(m = 2, w = 5, p = 7, algorithm = "nwp"),
    prep_snv(),
    prep_smooth(w = 3, algorithm = "moving-average"),
    device = "unspecified"
  )
  test_model <- calibrate(
    THC ~ spc,
    data = dat, preprocess = pretreats, method = method,
    control = control, verbose = FALSE, return_inputs = TRUE, skip_indices = 1
  )
  gen_cal_file <- gen_cal_file_from_model(test_model, "test_cal1", property_name = "THC")
  announce_snapshot_file(gen_cal_file, name = "test_cal1.THC.cal")
  expect_snapshot_file(gen_cal_file, compare = compare_file_numeric)
})

test_that("Writing calibration files works on fitted models with stratified sampling", {
  dat <- NIRcannabis[seq(1, 80, by = 3), ]
  dat <- dat[, !colnames(NIRcannabis) %in% c("CBDA", "THC", "THCA")]
  dat$spc <- dat$spc[, seq(1, 234, by = 10)]
  method <- fit_plsr(5, "modified")
  control <- calibration_control(
    validation_type = "lgo", number = 5, remove_outliers = 0, seed = 23, p = 0.9
  )
  pretreats <- preprocess_recipe(
    prep_derivative(m = 1, w = 5, p = 7, algorithm = "nwp"),
    prep_snv(),
    prep_smooth(w = 3, algorithm = "moving-average"),
    device = "unspecified"
  )
  test_model <- calibrate(
    CBD ~ spc,
    data = dat, preprocess = pretreats, method = method,
    control = control, verbose = FALSE, return_inputs = TRUE
  )

  announce_snapshot_file(name = "test_cal2.CBD.cal")
  expect_snapshot_file(gen_cal_file_from_model(test_model, "test_cal2", "CBD"), compare = compare_file_numeric)
})

#################
# SANITY CHECKS #
#################

# Simulates an spectral_model for Sanity checks.
empty_model <- list()
class(empty_model) <- "spectral_model"
empty_object <- list(empty_model)

test_that("An object must be given for write_cal", {
  expect_error(write_cal(), "Parameter 'object' is required for generating the .prj and .cal files")
})

test_that("The object must be a list", {
  expect_error(write_cal(""), "Parameter 'object' has to be a list.")
})

test_that("The object for writing calibration files must be of class 'spectral_model'", {
  expect_error(write_cal(list("")), "All entries in 'object' must be of class 'spectral_model'.")
})

test_that("The verbose argument must be a logical", {
  expect_error(write_cal(empty_object, verbose = 1), "Parameter 'verbose' has to be a logical")
})

test_that("The name of the application must be a character", {
  expect_error(write_cal(empty_object, application_name = 1), "'application_name' has to be a character.")
})

test_that("The path to .tsv files must be given as a character", {
  skip_on_cran()
  expect_error(write_cal(empty_object, path = tempdir(), tsv_paths = 1), "Please provide the paths to the .tsv files as a vector of character strings.")
})

test_that("Data must be available through the model for creating calibration files", {
  skip_on_cran()
  expect_error(write_cal(empty_object, path = tempdir()), "No data found in any model of 'object'. Data is required to be present when generating calibration files.")
})

# For proximate_write_model
test_that("Write model requires an object", {
  expect_error(proximate_write_model(), "'object' is required for generating the .prj and .cal files")
})

test_that("Writing model requires a tsv path", {
  expect_error(proximate_write_model(list()), "Please provide a path to the .tsv file")
})

test_that("Verbose must be a logical", {
  skip_on_cran()
  expect_error(proximate_write_model(list(), path = tempdir(), tsv_paths = "", verbose = ""), "'verbose' must be a logical")
})

test_that("'path' must be provided", {
  skip_on_cran()
  expect_error(
    write_cal(empty_object, path = tempdir(), tsv_paths = 1),
    "Please provide the paths to the .tsv files as a vector of character strings."
  )
})

test_that("cal must be a logical", {
  skip_on_cran()
  expect_error(proximate_write_model(list(), path = tempdir(), tsv_paths = "", cal = ""), "'cal' must be a logical")
})

test_that("prj must be a logical", {
  skip_on_cran()
  expect_error(proximate_write_model(list(), path = tempdir(), tsv_paths = "", prj = ""), "'prj' must be a logical")
})

test_that("rtf must be a logical", {
  skip_on_cran()
  expect_error(proximate_write_model(list(), path = tempdir(), tsv_paths = "", rtf = ""), "'rtf' must be a logical")
})

test_that("Application name for creating files must be a character", {
  skip_on_cran()
  expect_error(proximate_write_model(list(), path = tempdir(), tsv_paths = "", application_name = 1), "'application_name' must be a character.")
})
