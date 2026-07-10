data("NIRcannabis", package = "proximetricsR")
dat <- NIRcannabis[25:40, ]
X <- dat$spc[, seq(1, 230, by = 5)] # reduce to save memory
Y <- matrix(dat$THCA, dimnames = list(1:16, "THCA"))
control <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential")
pretreats <- preprocess_recipe(
  prep_resample(c(1004, 1650, 4)),
  prep_derivative(m = 1, w = 5, p = 9, algorithm = "nwp"),
  prep_snv(),
  prep_smooth(w = 7, algorithm = "moving-average"),
  device = "unspecified"
)
model1 <- calibrate(
  X, Y,
  data = dat, preprocess = pretreats, method = fit_plsr(4), control = control,
  verbose = FALSE
)
pred1 <- predict(model1, NIRcannabis[1:10, ], verbose = FALSE, ncomp = 1:4)
val <- validate_prediction(pred1, NIRcannabis$THCA[1:10])

test_that("Validation contains the correct model information", {
  expect_identical(val$model_information, pred1$model_information)
})

test_that("The correct target values are saved", {
  expect_identical(val$reference, matrix(NIRcannabis$THCA[1:10], dimnames = list(1:10, "y")))
})

test_that("The validation results are correct", {
  expect_snapshot(val$validation)
})

test_that("Not available target values are correctly ignored", {
  Y_new <- matrix(c(NIRcannabis$THCA[1:5], rep(NA, 5)))
  colnames(Y_new) <- "THCA"
  val2 <- validate_prediction(pred1, Y_new)

  expect_identical(val2$model_information, val$model_information)
  expect_identical(val2$reference, matrix(c(NIRcannabis$THCA[1:5], rep(NA, 5)), dimnames = list(1:10, "y")))
  expect_snapshot(val2$validation)
})

test_that("Validations are correctly printed if original model grid given", {
  val_copy <- val
  val_copy$model_information$unit <- "%"
  val_copy$reference[1] <- NA
  expect_snapshot(print(val_copy))
})

test_that("Validations are correctly printed if original model grid missing", {
  val_copy <- val
  val_copy$model_information$model_grid <- NULL
  expect_snapshot(print(val_copy))
})

#################
# SANITY CHECKS #
#################

test_that("Provided prediction must be of class 'spectral_prediction'", {
  expect_error(validate_prediction(pred1$predictions, NIRcannabisTHCA[1:10]), "Parameter 'prediction' must be of class 'spectral_prediction'.")
})

test_that("Entries in reference must be numerical", {
  expect_error(validate_prediction(pred1, "test"), "Non-numerical values found in 'reference'")
})

test_that("Prediction and references must have the same number of rows", {
  expect_error(validate_prediction(pred1, c(1, 2)), "Predictions and reference values contain differing number of rows.")
})

test_that("Only a single column for the reference values is allowed", {
  expect_error(validate_prediction(pred1, matrix(1:20, ncol = 2)), "Only one column of reference values is allowed.")
})

test_that("Reference values cannot all be not available", {
  expect_error(validate_prediction(pred1, rep(NA, 10)), "'reference' only contains 'NA' values.")
})


test_that("validations work", {
  # Check issues
  expect_error(validate_prediction(preds, cbind(rep(NIRcannabis$CBDA[skips], 2))))
  expect_error(validate_prediction(preds, rbind(rep(NIRcannabis$CBDA[skips], 2))))
  expect_error(validate_prediction(preds, rep(NA, 5)))
})
