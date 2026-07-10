data("NIRcannabis", package = "proximetricsR")

# Setup for checking if model predictions are as expected.
dat <- NIRcannabis[41:80, ] # reduce number of samples
X <- dat$spc # reduced number of samples
rownames(X) <- NULL
Y <- matrix(dat$THC, dimnames = list(41:80, "THC"))
method <- fit_plsr(10, "standard")
control <- calibration_control(validation_type = "kfold", number = 3, folds = "random", tuning_parameter = "rsq", seed = 42)
pretreats <- preprocess_recipe(
  prep_resample(c(1100, 1600, 5)),
  prep_derivative(m = 1, w = 5, p = 11, algorithm = "nwp"),
  prep_snv(),
  prep_smooth(w = 3, algorithm = "moving-average"),
  device = "unspecified"
)
# Index 50 cannot be skipped, will give a warning.
skiped_ind <- c(6, 14, 27, 31, 33, 50)

# model with formula; to check the predictions in detail
expect_warning(
  model_form <- calibrate(
    THC ~ spc,
    data = dat, preprocess = pretreats, method = method, control = control,
    skip_indices = skiped_ind, verbose = FALSE, metadata = add_model_metadata(unit = "%")
  ),
  "Unable to skip index 50, as it lies outside the considered indices."
)

# model with X, Y; to check the predictions in detail
expect_warning(
  model_xy <- calibrate(
    X, Y,
    data = dat, preprocess = pretreats, method = method, control = control,
    skip_indices = skiped_ind, verbose = FALSE, metadata = add_model_metadata()
  ),
  "Unable to skip index 50, as it lies outside the considered indices."
)

##################################
# CHECK PREDICTIONS ON SAME DATA #
##################################

test_that("Predictions on same dataset should be the same as the fitted values in the model", {
  # For model_form, data.frame as newdat
  expect_equal(
    model_form$final_model$model$fitted_y,
    predict(model_form, dat[-skiped_ind, ], ncomp = 1:10, verbose = FALSE)$predictions,
    tolerance = 1e-07
  )
  # For model_form, matrix as newdat
  expect_equal(
    unname(model_form$final_model$model$fitted_y),
    unname(predict(model_form, X[-skiped_ind, ], ncomp = 1:10, verbose = FALSE)$predictions),
    tolerance = 1e-07
  )
  # For model_xy, data.frame as newdat
  expect_equal(
    unname(model_xy$final_model$model$fitted_y),
    unname(predict(model_form, dat[-skiped_ind, ], ncomp = 1:10, verbose = FALSE)$predictions),
    tolerance = 1e-07
  )
  # For model_form, data.frame as newdat
  expect_equal(
    model_xy$final_model$model$fitted_y,
    predict(model_form, X[-skiped_ind, ], ncomp = 1:10, verbose = FALSE)$predictions,
    tolerance = 1e-07
  )
})

####################################################
# GENERATE PREDICTIONS USING DIFFERENT DATAFORMATS #
####################################################

# Predictions for model with formula, done with newdat being a data.frame, 6 components
predictions_df_form <- predict(
  model_form,
  dat[skiped_ind[1:(length(skiped_ind) - 1)], , drop = FALSE],
  ncomp = 1:6,
  verbose = FALSE
)

# Predictions for model with formula, done with newdat being a matrix, one component only
predictions_mat_form <- predict(
  model_form,
  X[skiped_ind[1:(length(skiped_ind) - 1)], , drop = FALSE],
  ncomp = 6,
  verbose = FALSE
)

# Predictions for model with X, Y, done with newdat being a data.frame, 1 component
predictions_df_mat <- predict(
  model_xy,
  dat[skiped_ind[1:(length(skiped_ind) - 1)], , drop = FALSE],
  ncomp = 4,
  verbose = FALSE
)

# Predictions for model with X, Y, done with newdat being a matrix, 7 components
predictions_mat_mat <- predict(
  model_xy,
  X[skiped_ind[1:(length(skiped_ind) - 1)], , drop = FALSE],
  ncomp = 4:10,
  verbose = FALSE
)

############################################
# CHECKING PREDICTIONS predictions_df_form #
############################################

test_that("Predictions with formula from a data.frame are correct", {
  withr::local_options(digits = 8)
  expect_snapshot(predictions_df_form$predictions)
})

test_that("Predictions with formula from a data.frame is of class 'spectral_prediction", {
  expect_true(inherits(predictions_df_form, "spectral_prediction"))
})

test_that("Predictions with formula from a data.frame is named correctly", {
  expect_named(predictions_df_form, c("predictions", "scores", "model_information"))
})

test_that("Model information of predictions with formula from a data.frame is correct", {
  expect_identical(predictions_df_form$model_information$target_var, "THC")
  expect_identical(predictions_df_form$model_information$preprocess_recipe, model_form$preprocess)
  expect_identical(predictions_df_form$model_information$unit, "%")
  expect_identical(predictions_df_form$model_information$opt_comp, 10L)
  withr::local_options(digits = 8)
  expect_snapshot(predictions_df_form$model_information$model_grid)
})

test_that("Predictions for dataframes from a formula are correctly printed", {
  withr::local_options(digits = 8)
  expect_snapshot(print(predictions_df_form))
})

#########################################################################
# PREDICTIONS OF predictions_mat_form CORRESPOND TO predictions_df_form #
#########################################################################

test_that("Predictions are the same for matrix/data.frame as newdata", {
  expect_identical(
    predictions_mat_form$model_information$model_grid,
    predictions_df_form$model_information$model_grid[6, , drop = FALSE]
  )
  expect_equal(
    unname(predictions_mat_form$predictions),
    unname(predictions_df_form$predictions[, 6, drop = FALSE]),
    tolerance = 1e-14
  )
})

#######################################################################
# PREDICTIONS OF predictions_df_mat CORRESPOND TO predictions_df_form #
#######################################################################

test_that("Predictions are the same for model with matrices/model with formula", {
  expect_identical(
    predictions_df_mat$model_information$model_grid,
    predictions_df_form$model_information$model_grid[4, , drop = FALSE]
  )
  expect_equal(
    predictions_df_mat$predictions,
    predictions_df_form$predictions[, 4, drop = FALSE],
    tolerance = 1e-14
  )
})

############################################
# CHECKING PREDICTIONS predictions_mat_mat #
############################################

test_that("Predictions with matrices from a matrix are correct", {
  withr::local_options(digits = 8)
  expect_snapshot(predictions_mat_mat$predictions)
})

test_that("Predictions with matrices from a matrix is of class 'spectral_prediction", {
  expect_true(inherits(predictions_mat_mat, "spectral_prediction"))
})

test_that("Predictions with matrices from a matrix is named correctly", {
  expect_named(predictions_mat_mat, c("predictions", "scores", "model_information"))
})

test_that("Model information of predictions with matrices from a matrix is correct", {
  expect_identical(predictions_mat_mat$model_information$target_var, "THC")
  expect_identical(predictions_mat_mat$model_information$preprocess_recipe, model_form$preprocess)
  expect_identical(predictions_mat_mat$model_information$unit, "")
  expect_identical(predictions_mat_mat$model_information$opt_comp, 10L)
  withr::local_options(digits = 8)
  expect_snapshot(predictions_mat_mat$model_information$model_grid)
})

test_that("Predictions of a dataframe from a matrix are correctly printed", {
  withr::local_options(digits = 8)
  expect_snapshot(print(predictions_df_mat))
})

#################
# SANITY CHECKS #
#################

test_that("For predictions, newdata must be given", {
  expect_error(predict(model_form, verbose = FALSE))
})

test_that("For predictions, the model given must be of class 'spectral_model'", {
  expect_error(
    predict.spectral_model(list(), newdata = NIRcannabis),
    "'object' must be of class 'spectral_model."
  )
})

test_that("For predictions, the number of components must be in the computed components of the model", {
  expect_error(
    predict(model_form, newdata = NIRcannabis, ncomp = c(20, 21), verbose = FALSE),
    "The maximum of 'ncomp' is larger than the number of components in the model"
  )
  expect_error(
    predict(model_form, newdata = NIRcannabis, ncomp = 20, verbose = FALSE),
    "'ncomp' is larger than the number of components in the model"
  )
})

test_that("For predictions, newdata must be a data.frame or matrix", {
  expect_error(predict(model_form, newdata = c(NIRcannabis), verbose = FALSE))
})

test_that("For predictions with formula, the predictor variables must be contained in newdata", {
  expect_error(
    predict(model_form, newdata = unname(NIRcannabis), verbose = FALSE),
    "The following predictor variables are missing: spc"
  )
})

test_that("Verbose must be a logical", {
  expect_error(
    predict(model_form, newdata = NIRcannabis, verbose = "1"),
    "'verbose' must a logical."
  )
})

test_that("ncomp must be a vector of numerics", {
  expect_error(
    predict(model_form, newdata = NIRcannabis, ncomp = "1")
  )
})

test_that("Predictor variables (newdata) must have the same wavelengths as the model", {
  dt <- dat
  s_model <- calibrate(
    THC ~ spc,
    data = dt, preprocess = preprocess_recipe(), method = method, control = control, verbose = FALSE, metadata = add_model_metadata()
  )
  colnames(dt$spc) <- 1:ncol(dt$spc)
  expect_error(
    predict(s_model, newdata = dt$spc, verbose = FALSE),
    "Missing predictor variables"
  )
})
