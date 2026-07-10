data("NIRcannabis", package = "proximetricsR")

test_that("Calibration statistics without CV is as expected", {
  X <- NIRcannabis$spc[20:40, ] # reduced number of samples
  Y <- matrix(NIRcannabis$CBD[20:40], dimnames = list(1:21, "CBDA"))
  model_basic <- .estimate_model(X, Y, fit_plsr(5))
  cal_stats <- .calibration_statistics(
    Y, model_basic$fitted_y,
    scaled_scores = model_basic$scaled_scores, ncomp = 5
  )

  expect_named(cal_stats, c(
    "Sample_index", "Target", "fitted_y", "residual", "predicted_y_in_cv",
    "cv_residual", "Mahalanobis", "Q_value"
  ))
  expect_identical(cal_stats$Sample_index, 1:21)
  expect_null(cal_stats$predicted_y_in_cv)
  expect_null(cal_stats$cv_residual)
  expect_null(cal_stats$Q_value)

  expect_identical(cal_stats$Target, Y)
  expect_identical(cal_stats$fitted_y, model_basic$fitted_y[, 5, drop = FALSE])
  expect_identical(unname(cal_stats$residual), unname(cal_stats$Target - cal_stats$fitted_y))

  expect_snapshot(cal_stats$Mahalanobis)
})

test_that("Calibration statistics with CV is as expected", {
  dat <- NIRcannabis[15:34, ]
  control <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential")
  X <- dat$spc
  Y <- matrix(dat$THC, dimnames = list(1:20, "THC"))
  model_basic <- calibrate(
    X, Y,
    data = dat, method = fit_xlsr(5), control = control, verbose = FALSE
  )
  cal_stats <- .calibration_statistics(
    Y, model_basic$final_model$model$fitted_y, model_basic$final_model$model_cv$predicted,
    model_basic$final_model$model$scaled_scores, 5
  )

  expect_named(cal_stats, c(
    "Sample_index", "Target", "fitted_y", "residual", "predicted_y_in_cv",
    "cv_residual", "Mahalanobis", "Q_value"
  ))
  expect_identical(cal_stats$Sample_index, 1:20)
  expect_identical(cal_stats$Target, Y)
  expect_identical(cal_stats$fitted_y, model_basic$final_model$model$fitted_y[, 5, drop = FALSE])

  exp_residual <- cal_stats$Target - cal_stats$fitted_y
  colnames(exp_residual) <- "ncomp_5"
  expect_identical(cal_stats$residual, exp_residual)

  expect_identical(cal_stats$cv_residual, unname(Y - model_basic$final_model$model_cv$predicted[, 5]))
  expect_identical(cal_stats$predicted_y_in_cv, model_basic$final_model$model_cv$predicted[, 5, drop = FALSE])

  expect_snapshot(cal_stats$Mahalanobis)
  expect_snapshot(cal_stats$Q_value)
})
