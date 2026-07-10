data("NIRcannabis", package = "proximetricsR")

# Setup for checking if model is as expected.
dat <- NIRcannabis[1:40, ] # reduce number of samples
dat$spc <- dat$spc[, seq(1, 234, by = 5)]
X <- dat$spc # reduced number of samples
rownames(X) <- 1:40
Y <- matrix(dat$CBDA, dimnames = list(1:40, "CBDA"))
method <- fit_plsr(5, "standard")
control <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential")
pretreats <- preprocess_recipe(
  prep_resample(c(1005, 1600, 5)),
  prep_derivative(m = 2, w = 9, p = 5, algorithm = "nwp"),
  prep_snv(),
  prep_smooth(w = 5, algorithm = "moving-average"),
  device = "unspecified"
)
skiped_ind <- c(5, 13, 21)


# model1 is to check in detail if the the results are as expected
model1 <- calibrate(
  CBDA ~ spc,
  data = dat, preprocess = pretreats,
  method = method, control = control, skip_indices = skiped_ind, verbose = FALSE, metadata = add_model_metadata()
)

# model_xy is similar to model1, but using default calibrate method instead of formula.
# Additionally, it also performs one refit.
control_refit <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential", remove_outliers = 1)
model_xy <- calibrate(
  X = X, Y = Y, data = dat, preprocess = pretreats, method = method,
  control = control_refit, skip_indices = skiped_ind, verbose = FALSE, metadata = add_model_metadata()
)

# model_refit is the refitted model that should result in the model_xy. In particular,
# we use the outliers detected in model_xy as additional skiped_ind
model_refit <- calibrate(
  X = X, Y = Y, data = dat, preprocess = pretreats, method = method, metadata = add_model_metadata(),
  control = control, skip_indices = sort(c(skiped_ind, model_xy$detected_outliers$removed)), verbose = FALSE
)


#################################
# EXHAUSTIVE CHECKING OF model1 #
#################################

test_that("Model using formulas is a list of class spectral_model", {
  expect_type(model1, "list")
  expect_true(inherits(model1, c("spectral_model")))
})

test_that("Model list contains 15 elements", {
  expect_length(model1, 15)
})

test_that("Model list has correct names", {
  expect_named(model1, c(
    "formula", "dataclasses", "target_variable", "predictor_variables", "final_model",
    "detected_outliers", "final_ncomp", "preprocess", "processed_wavs", "method", "control",
    "metadata", "preprocessed_X", "skipped_indices", "input_data"
  ))
})

test_that("Formula is correctly saved in the model", {
  expect_type(model1$formula, "language")
  expect_true(inherits(model1$formula, "formula"))
})

test_that("Dataclasses for inputs are correctly stored in the model", {
  expect_length(model1$dataclasses, 2)
  expect_identical(c("CBDA" = "numeric", "spc" = "nmatrix.47"), model1$dataclasses)
})

test_that("The correct target variable is found", {
  expect_identical(model1$target_variable, "CBDA")
})

test_that("Predictor variables are correctly read from spectral matrix", {
  expect_identical(model1$predictor_variables, as.character(seq(1040, 1565, by = 5)))
})

test_that("Detected outliers are stored in a named list", {
  expect_type(model1$detected_outliers, "list")
  expect_named(model1$detected_outliers, c("all", "removed", "model_1"))
})

test_that("The expected outliers in 'all' are found", {
  expect_identical(model1$detected_outliers$all$calibration, integer())
  expect_identical(model1$detected_outliers$all$Mahalanobis, integer())
  expect_identical(model1$detected_outliers$all$validation, 30L)
})

test_that("No outliers are removed", {
  expect_identical(model1$detected_outliers$removed, integer())
})

test_that("The outliers in 'all' must be the same as in 'model_1'", {
  expect_identical(model1$detected_outliers$all, model1$detected_outliers$model_1)
})

test_that("The final number of components is correct", {
  expect_identical(model1$final_ncomp, 5L)
})

test_that("The preprocess recipe is correctly mirrored", {
  expect_identical(model1$preprocess, pretreats)
  expect_identical(model1$preprocess$preprocessing_order, "resample > derivative (2nd) > snv > smooth")
  expect_true(inherits(model1$preprocess, c("preprocess_recipe", "list")))
})

test_that("The method is correctly mirrored", {
  expect_identical(model1$method, method)
})

test_that("The control argument is correctly mirrored", {
  expect_identical(model1$control, control)
})

test_that("The metadata is correctly added", {
  expect_identical(model1$metadata, add_model_metadata(
    key = model1$metadata$Key, name = "CBDA", created = model1$metadata$Created,
    changed = model1$metadata$Changed
  ))
  expect_true(inherits(model1$metadata, "model_metadata"))
})

test_that("The spectrum is correctly preprocessed", {
  prepro_X <- unname(process(X[-skiped_ind, ], pretreats))
  attr(prepro_X, "preprocess_recipe") <- NULL
  attr(prepro_X, "processed_wavs") <- NULL
  expect_identical(unname(model1$preprocessed_X), prepro_X)
})

test_that("The skipped indices are correctly mirrored, and no additional indices are skipped", {
  expect_named(model1$skipped_indices, c("missing_response", "manually_skipped"))
  expect_identical(model1$skipped_indices$manually_skipped, skiped_ind)
  expect_identical(model1$skipped_indices$missing_response, integer())
})

test_that("The input data is correctly mirrored", {
  expect_identical(model1$input_data$data, dat)
})

test_that("The fitted model is a named list", {
  expect_type(model1$final_model, "list")
  expect_named(model1$final_model, c(
    "model_cv", "ncomp", "model", "calibration_statistics", "calibration_statistics_all",
    "detected_outliers_all"
  ))
  expect_length(model1$final_model, 6)
})

test_that("The cross-validation is performed correctly", {
  expect_length(model1$final_model$model_cv, 2)
  expect_named(model1$final_model$model_cv, c("grid", "predicted"))
  expect_true(all(colnames(model1$final_model$model_cv$grid) == c("ncomp", "rsq", "rmse", "largest_residual")))
  expect_identical(dim(model1$final_model$model_cv$grid), c(as.integer(method$ncomp), 4L))
  expect_identical(dim(model1$final_model$model_cv$predicted), c(nrow(X) - length(skiped_ind), as.integer(method$ncomp)))
  withr::local_options(digits = 8)
  expect_snapshot(model1$final_model$model_cv)
})

test_that("The number of optimal components is correct", {
  expect_identical(model1$final_model$ncomp, 5L)
})

test_that("The fitted model is a list of class 'spectral_fit'", {
  expect_type(model1$final_model$model, "list")
  expect_true(inherits(model1$final_model$model, "spectral_fit"))
})

test_that("The resulting fitted model is correct", {
  fit_model <- model1$final_model$model
  class(fit_model) <- "list"
  expect_named(fit_model, c(
    "method", "intercept", "x_means", "projection_m", "coefficients", "n_observations",
    "x_residuals", "weights", "scores", "sd_scores", "scaled_scores", "y_loadings",
    "x_loadings", "fitted_y", "cal_error", "y_quantiles", "explained_variance"
  ))
  expect_length(fit_model, 17L)
  expect_true(inherits(model1$final_model$model, "spectral_fit"))
  withr::local_options(digits = 8)
  expect_snapshot(fit_model)
})

test_that("The full calibration statistics is a named list", {
  expect_type(model1$final_model$calibration_statistics_all, "list")
  expect_named(model1$final_model$calibration_statistics_all, c(
    "Sample_index", "Target", "fitted_y", "residual", "predicted_y_in_cv",
    "cv_residual", "Mahalanobis", "Q_value"
  ))
  expect_identical(Y[-skiped_ind, , drop = FALSE], model1$final_model$calibration_statistics_all$Target)
})

test_that("The full calibration statistics is correctly computed", {
  withr::local_options(digits = 8)
  expect_snapshot(model1$final_model$calibration_statistics_all)
})

test_that("The calibration statistcs for the optimal components is correct", {
  cal_stats <- model1$final_model$calibration_statistics
  cal_stats_full <- model1$final_model$calibration_statistics_all
  opt_comp <- model1$final_ncomp
  subset_cal_stats <- matrix(NA, nrow(cal_stats), ncol(cal_stats), dimnames = list(rownames(cal_stats), colnames(cal_stats)))
  subset_cal_stats[, "Sample_index"] <- cal_stats_full$Sample_index
  subset_cal_stats[, "Target"] <- cal_stats_full$Target
  subset_cal_stats[, "fitted_y"] <- cal_stats_full$fitted_y[, opt_comp]
  subset_cal_stats[, "residual"] <- cal_stats_full$residual[, opt_comp]
  subset_cal_stats[, "predicted_y_in_cv"] <- cal_stats_full$predicted_y_in_cv[, opt_comp]
  subset_cal_stats[, "cv_residual"] <- cal_stats_full$cv_residual[, opt_comp]
  subset_cal_stats[, "Mahalanobis"] <- cal_stats_full$Mahalanobis[, opt_comp]
  subset_cal_stats[, "Q_value"] <- cal_stats_full$Q_value[, opt_comp]
  expect_identical(cal_stats, subset_cal_stats)
})

test_that("All detected outliers in every iteration is correct", {
  det_outl <- model1$final_model$detected_outliers_all
  expect_named(det_outl, paste("ncomp", 1:method$ncomp, sep = "_"))
  expect_true(all(unname(unlist(lapply(X = det_outl, FUN = names))) %in% c("calibration", "Mahalanobis", "validation")))
  expect_snapshot(det_outl)
})

test_that("The model can be printed and the print is correct", {
  printout <- capture.output(print(model1))
  expect_type(printout, "character")
  expect_length(printout, 29L)
  expect_snapshot(printout)
})

test_that("The hash of the data is correct", {
  expect_identical(attr(model1, "data_hash"), "248c2716f1f5d9781355a8beef3949eb")
})

######################################################################
# CHECK if model_xy is truly a combination of model1 and model_refit #
######################################################################

test_that("Refitting models does not interfer with original fitted model", {
  expect_identical(model_xy$initial_fit, model1$final_model)
})

test_that("Refitted model must be the same as the model with manual skiped_ind", {
  # Remove things from copy which are not expected to be in model_refit or expected
  # to be different.
  model_xy_copy <- model_xy
  model_xy_copy$initial_fit <- NULL
  # skiped_ind should be different
  model_xy_copy$skipped_indices$manually_skipped <- sort(c(skiped_ind, model_xy$detected_outliers$removed))
  # Outliers are also different
  model_xy_copy$detected_outliers$model_1 <- model_xy$detected_outliers$model_2
  model_xy_copy$detected_outliers$model_2 <- NULL
  model_xy_copy$detected_outliers$removed <- integer()
  model_xy_copy$detected_outliers$all <- model_refit$detected_outliers$all
  # The mirrored control is also slightly different
  model_xy_copy$control$remove_outliers <- 0
  # The metadata key, created and changed are different
  model_xy_copy$metadata$Key <- model_refit$metadata$Key
  model_xy_copy$metadata$Created <- model_refit$metadata$Created
  model_xy_copy$metadata$Changed <- model_refit$metadata$Changed

  expect_identical(model_xy_copy, model_refit)
})

test_that("Model provided with X and Y must be similar to formula", {
  model1_copy <- model1
  model_xy_copy2 <- model_xy
  model1_copy$formula <- NULL
  model1_copy$dataclasses <- NULL
  # Remove outliers of model_xy from preprocessed spectra of model1
  rem_outlier <- model_xy_copy2$detected_outliers$removed
  rem_outlier <- rem_outlier - sum(skiped_ind < rem_outlier)
  model1_copy$preprocessed_X <- model1_copy$preprocessed_X[-rem_outlier, , drop = FALSE]

  # Remove expected differences from model_xy
  # Refitted model does not exist in model1, so replace final_model with initial_fit
  model_xy_copy2$final_model <- model_xy_copy2$initial_fit
  model_xy_copy2$initial_fit <- NULL
  # Detected outliers are different
  model_xy_copy2$detected_outliers$all <- model1$detected_outliers$all
  model_xy_copy2$detected_outliers$removed <- integer()
  model_xy_copy2$detected_outliers$model_2 <- NULL
  # Control: remove_outliers is different
  model_xy_copy2$control$remove_outliers <- 0
  # The final number of components is different
  model_xy_copy2$final_ncomp <- 5L
  # The metadata key, created and changed are different
  model_xy_copy2$metadata$Key <- model1$metadata$Key
  model_xy_copy2$metadata$Created <- model1$metadata$Created
  model_xy_copy2$metadata$Changed <- model1$metadata$Changed


  expect_identical(model_xy_copy2, model1_copy)
})

########################
# TESTING THE model_xy #
########################

test_that("The refitted model is correct", {
  refit_model <- model_xy$final_model$model
  class(refit_model) <- "list"
  withr::local_options(digits = 8)
  expect_snapshot(refit_model)
})

test_that("The removed outliers are as expected", {
  expect_identical(model_xy$detected_outliers$removed, c(30L))
})

test_that("The refitted model is printed correctly", {
  model_xy_copy <- model_xy
  model_xy_copy$control$tuning_parameter <- "rsq"
  model_xy_copy$method$method <- "pls"
  model_xy_copy$final_model$model_cv <- NULL
  expect_snapshot(print(model_xy_copy))
})

test_that("The data hash of the model remains the same", {
  expect_identical(attr(model1, "data_hash"), attr(model_xy, "data_hash"))
})

#################
# SANITY CHECKS #
#################

test_that("Only one reference value can be provided", {
  expect_error(calibrate(X = X, Y = matrix(c(Y, Y), ncol = 2)), "Y must be a matrix of one column")
})

test_that("X must be a matrix", {
  expect_error(calibrate(X = 1, Y = Y), "X must be a matrix")
})

test_that("Y must be a matrix", {
  expect_error(calibrate(X = X, Y = c(Y)), "Y must be a matrix of one column")
})

test_that("Columns of Y must be named", {
  expect_error(calibrate(X = X, Y = unname(Y)), "Missing variable/column name in Y")
})

test_that("Columns of X must be named", {
  expect_error(calibrate(X = unname(X), Y), "Missing variable/column names in X")
})

test_that("The number of computed components must be less than than the number of observations", {
  expect_error(calibrate(X = X[1:5, , drop = F], Y = Y[1:5, , drop = F]))
})

test_that("The number of observations in each CV segment must be large enough", {
  expect_error(calibrate(X, Y, control = calibration_control("kfold", number = 100), verbose = FALSE))
})

test_that("Predictor variables must be contained in the data", {
  expect_error(calibrate(X ~ Y, data = NIRcannabis, method = method), "Predictor variables not found in data.")
})

test_that("A method must be given", {
  expect_error(calibrate(X ~ Y, data = NIRcannabis), "'method' is missing")
})

test_that("Data should be of class 'proximate_data' or 'proxiscout_data', column names of X must be convertible to numerics", {
  X_copy <- X
  colnames(X_copy) <- rep("one", ncol(X))
  suppressWarnings(
    expect_warning(
      expect_error(
        calibrate(X_copy, Y, data = data.frame(dat), method = method, control = control),
        "Column names in X must be formed only by numbers"
      ),
      "Object 'data' is not of class 'proximate_data' or 'proxiscout_data'"
    )
  )
})

test_that("Data of class 'proxiscout_data' does not trigger warning", {
  proxiscout_data <- data.frame(dat)
  class(proxiscout_data) <- c("proxiscout_data", class(proxiscout_data))
  expect_no_warning(
    calibrate(X, Y, data = proxiscout_data, method = method, control = control, verbose = FALSE)
  )
})

test_that("Metadata must be of class 'model_metadata' if given", {
  expect_error(calibrate(X, Y, dat, method = method, metadata = list()), "'metadata' must be of class 'model_metadata' if provided.")
})

test_that("Preprocess must be of class 'preprocess_recipe", {
  expect_error(calibrate(X, Y, dat, method = method, preprocess = NULL), "Parameter 'preprocess' must be of class 'preprocess_recipe'.")
})

test_that("Control must be of class 'calibration_control'", {
  expect_error(calibrate(X, Y, dat, method = method, control = NULL), "Parameter 'control' must be of class 'calibration_control'.")
})

test_that("Method must be of class 'fit_method'", {
  expect_error(calibrate(X, Y, dat, method = NULL), "Parameter 'method' must be of class 'fit_constructor'.")
})

test_that("Skipped indices must be numerical", {
  expect_error(calibrate(X, Y, dat, method = method, skip_indices = "1"), "'skip_indices' must be a numeric vector.")
})

test_that("Return inputs must be a logical", {
  expect_error(calibrate(X, Y, dat, method = method, return_inputs = "1"), "'return_inputs' must be a logical.")
})

test_that("Verbose must be a logical", {
  expect_error(calibrate(X, Y, dat, method = method, verbose = "1"), "'verbose' must be a logical.")
})
