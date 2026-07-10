data("NIRcannabis", package = "proximetricsR")

gen_rtf_file_from_model <- function(object, application_name, property_name) {
  temporary_dir <- tempdir()

  wh_models <- "final_model"
  if (!is.null(object$initial_fit)) {
    wh_models <- c(wh_models, "initial_fit")
  }
  for (wh_model in wh_models) {
    # Reduce precision to try and avoid checking for machine precision
    # ... for the model
    object[[wh_model]]$model$intercept <- round(object[[wh_model]]$model$intercept, digits = 5)
    object[[wh_model]]$model$x_means <- round(object[[wh_model]]$model$x_means, digits = 5)
    object[[wh_model]]$model$projection_m <- round(object[[wh_model]]$model$projection_m, digits = 5)
    object[[wh_model]]$model$coefficients <- round(object[[wh_model]]$model$coefficients, digits = 5)
    object[[wh_model]]$model$x_residuals <- round(object[[wh_model]]$model$x_residuals, digits = 5)
    object[[wh_model]]$model$weights <- round(object[[wh_model]]$model$weights, digits = 5)
    object[[wh_model]]$model$scores <- round(object[[wh_model]]$model$scores, digits = 5)
    object[[wh_model]]$model$sd_scores <- round(object[[wh_model]]$model$sd_scores, digits = 5)
    object[[wh_model]]$model$scaled_scores <- round(object[[wh_model]]$model$scaled_scores, digits = 5)
    object[[wh_model]]$model$y_loadings <- round(object[[wh_model]]$model$y_loadings, digits = 5)
    object[[wh_model]]$model$x_loadings <- round(object[[wh_model]]$model$x_loadings, digits = 5)
    object[[wh_model]]$model$fitted_y <- round(object[[wh_model]]$model$fitted_y, digits = 5)
    object[[wh_model]]$model$cal_error <- round(object[[wh_model]]$model$cal_error, digits = 5)
    object[[wh_model]]$model$y_quantiles <- round(object[[wh_model]]$model$y_quantiles, digits = 5)
    object[[wh_model]]$model$explained_variance$x_variance <- round(object[[wh_model]]$model$explained_variance$x_variance, digits = 5)
    object[[wh_model]]$model$explained_variance$y_variance <- round(object[[wh_model]]$model$explained_variance$y_variance, digits = 5)

    # ... for model_cv
    if (!is.null(object[[wh_model]]$model_cv$grid)) {
      object[[wh_model]]$model_cv$grid <- round(object[[wh_model]]$model_cv$grid, digits = 5)
    }
    if (!is.null(object[[wh_model]]$model_cv$predicted)) {
      object[[wh_model]]$model_cv$predicted <- round(object[[wh_model]]$model_cv$predicted, digits = 5)
    }

    # ... for calibration_statistics_all
    object[[wh_model]]$calibration_statistics_all$fitted_y <- round(object[[wh_model]]$calibration_statistics_all$fitted_y, digits = 5)
    object[[wh_model]]$calibration_statistics_all$residual <- round(object[[wh_model]]$calibration_statistics_all$residual, digits = 5)
    object[[wh_model]]$calibration_statistics_all$Mahalanobis <- round(object[[wh_model]]$calibration_statistics_all$Mahalanobis, digits = 5)
    if (!is.null(object[[wh_model]]$calibration_statistics_all$predicted_y_in_cv)) {
      object[[wh_model]]$calibration_statistics_all$predicted_y_in_cv <-
        round(object[[wh_model]]$calibration_statistics_all$predicted_y_in_cv, digits = 5)
      object[[wh_model]]$calibration_statistics_all$cv_residual <-
        round(object[[wh_model]]$calibration_statistics_all$cv_residual, digits = 5)
      object[[wh_model]]$calibration_statistics_all$Q_value <-
        round(object[[wh_model]]$calibration_statistics_all$Q_value, digits = 5)
    }

    # ... and the preprocessed X
    object$preprocessed_X <- round(object$preprocessed_X, digits = 5)
  }

  proximetricsR:::write_rtf(
    list(object),
    tsv_path = "", application_name = application_name,
    path = temporary_dir, verbose = FALSE
  )
  paste0(temporary_dir, "/", application_name, ".", property_name, ".rtf")
}

test_that("Writing report files works on refitted models without validation", {
  skip_on_cran()
  dat <- NIRcannabis[1:40, ]
  dat <- dat[, !colnames(NIRcannabis) %in% c("CBDA", "CBD", "THCA")]
  dat$spc <- dat$spc[, seq(1, 234, by = 15)]
  dat$SRN <- dat$SNR
  dat$SNR <- NULL
  method <- fit_plsr(3)
  expect_warning(
    control <- calibration_control(
      validation_type = "none", remove_outliers = 0, mahalanobis_limit = 3.0
    )
  )
  pretreats <- preprocess_recipe(
    prep_snv(),
    device = "unspecified"
  )
  test_model <- calibrate(
    THC ~ spc,
    data = dat, preprocess = pretreats, method = method,
    control = control, verbose = FALSE, return_inputs = TRUE
  )

  gen_rtf_file <- gen_rtf_file_from_model(test_model, "test_rtf1", property_name = "THC")

  announce_snapshot_file(gen_rtf_file, name = "test_rtf1.THC.rtf")
  expect_snapshot_file(gen_rtf_file, compare = compare_file_text)
})

#################
# SANITY CHECKS #
#################

# Simulates an spectral_model for Sanity checks.
empty_model <- list()
class(empty_model) <- "spectral_model"
empty_object <- list(empty_model)

test_that("An object must be given for write_cal", {
  expect_error(write_rtf(), "object is required for generating the .prj and .cal files")
})

test_that("The object must be a list", {
  expect_error(write_rtf(""), "Parameter 'object' has to be a list.")
})

test_that("The object for writing calibration files must be of class 'spectral_model'", {
  expect_error(write_rtf(list("")), "All entries in 'object' must be of class 'spectral_model'.")
})

test_that("The verbose argument must be a logical", {
  expect_error(write_rtf(empty_object, verbose = 1), "Parameter 'verbose' has to be a logical")
})

test_that("The name of the application must be a character", {
  expect_error(write_rtf(empty_object, path = tempdir(), application_name = 1), "'application_name' has to be a character.")
})

test_that("The path to .tsv file must be given as a character", {
  expect_error(write_rtf(empty_object, tsv_path = 1, path = tempdir()), "Please provide the path to the .tsv file as a character")
})

test_that("Data must be available through the model for creating calibration files", {
  expect_error(write_rtf(empty_object, tsv_path = "", path = tempdir()), "No data found in any model of 'object'. Data is required to be present when generating report files.")
})
