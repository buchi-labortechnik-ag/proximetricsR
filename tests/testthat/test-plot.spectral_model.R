data("NIRcannabis", package = "proximetricsR")

gen_plot_from_model <- function(object, validations) {
  temporary_dir <- tempdir()
  my_wd <- getwd()
  suppressWarnings(
    plot(
      object,
      validations = validations,
      output_file = "example_plot",
      output_dir = temporary_dir,
      spectral = "all",
      cv = "all",
      regression = "all",
      validation = "all",
      marker = list(color = "red", symbol = 300, opacity = 0.9),
      line = list(color = "green", width = 1, simplify = TRUE),
      hoverinfo = list(bgcolor = "gray", bordercolor = "red"),
      verbose = FALSE,
      open_file = FALSE
    )
  )
  expect_identical(my_wd, getwd())
  paste0(temporary_dir, "/example_plot.html")
}

# Note: Cannot test snapshot, because it would be too big (even for small plots.)
# Approach of converting it to a svg (as being done in plotly) does not work
# because we are also using a flexdashboard. Hence, we only check if it can actually
# be compiled, which is not really the best test.
test_that("Plots can be made from a spectral_model", {
  skip_on_cran()
  dat <- NIRcannabis[seq(2, 80, by = 10), ]
  dat <- dat[, !colnames(NIRcannabis) %in% c("CBDA", "CBD", "THCA")]
  dat$spc <- dat$spc[, seq(2, 234, by = 10)]
  dat$SRN <- dat$SNR
  dat$SNR <- NULL
  method <- fit_plsr(2)
  control <- calibration_control(
    validation_type = "kfold", number = 2, folds = "random", remove_outliers = 1,
    seed = 25
  )
  pretreats <- preprocess_recipe(
    prep_resample(c(1035, 1600, 35)),
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
  # Make predictions
  preds <- predict(test_model, NIRcannabis[seq(1, 80, by = 3), ], verbose = FALSE)
  #' # Validate predictions
  validations <- validate_prediction(preds, NIRcannabis$THC[seq(1, 80, by = 3)])
  expect_true(file.exists(gen_plot_from_model(test_model, validations)))
})

#################
# SANITY CHECKS #
#################

test_that("Plots require a model", {
  expect_error(plot.spectral_model(), "Please specify the model")
})

test_that("Validations for plot must be of class 'spectral_validation'", {
  expect_error(plot.spectral_model(list(), list()))
})

test_that("Verbose must be a logical", {
  empty_val <- list()
  class(empty_val) <- "spectral_validation"
  expect_error(
    plot.spectral_model(list(), empty_val, verbose = "1"),
    "'verbose' must be a logical."
  )
})
