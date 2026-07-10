data("NIRcannabis", package = "proximetricsR")

# Generates a nax file, returns the path to the file
gen_nax_file_from_model <- function(object, temporary_dir, application_name, ext_props, app_meta) {
  for (i in seq_along(object)) {
    # Reduce precision to try and avoid checking for machine precision
    # ... for the models
    object[[i]]$final_model$model$intercept <- round(object[[i]]$final_model$model$intercept, digits = 5)
    object[[i]]$final_model$model$x_means <- round(object[[i]]$final_model$model$x_means, digits = 5)
    object[[i]]$final_model$model$projection_m <- round(object[[i]]$final_model$model$projection_m, digits = 5)
    object[[i]]$final_model$model$coefficients <- round(object[[i]]$final_model$model$coefficients, digits = 5)
    object[[i]]$final_model$model$x_residuals <- round(object[[i]]$final_model$model$x_residuals, digits = 5)
    object[[i]]$final_model$model$weights <- round(object[[i]]$final_model$model$weights, digits = 5)
    object[[i]]$final_model$model$scores <- round(object[[i]]$final_model$model$scores, digits = 5)
    object[[i]]$final_model$model$sd_scores <- round(object[[i]]$final_model$model$sd_scores, digits = 5)
    object[[i]]$final_model$model$scaled_scores <- round(object[[i]]$final_model$model$scaled_scores, digits = 5)
    object[[i]]$final_model$model$y_loadings <- round(object[[i]]$final_model$model$y_loadings, digits = 5)
    object[[i]]$final_model$model$x_loadings <- round(object[[i]]$final_model$model$x_loadings, digits = 5)
    object[[i]]$final_model$model$fitted_y <- round(object[[i]]$final_model$model$fitted_y, digits = 5)
    object[[i]]$final_model$model$cal_error <- round(object[[i]]$final_model$model$cal_error, digits = 5)
    object[[i]]$final_model$model$y_quantiles <- round(object[[i]]$final_model$model$y_quantiles, digits = 5)
    object[[i]]$final_model$model$explained_variance$x_variance <- round(object[[i]]$final_model$model$explained_variance$x_variance, digits = 5)
    object[[i]]$final_model$model$explained_variance$y_variance <- round(object[[i]]$final_model$model$explained_variance$y_variance, digits = 5)

    # ... for model_cv
    object[[i]]$final_model$model_cv$grid <- round(object[[i]]$final_model$model_cv$grid, digits = 5)
    if (!is.null(object[[i]]$final_model$model_cv$predicted)) {
      object[[i]]$final_model$model_cv$predicted <- round(object[[i]]$final_model$model_cv$predicted, digits = 5)
    }

    # ... for calibration_statistics_all
    object[[i]]$final_model$calibration_statistics_all$fitted_y <- round(object[[i]]$final_model$calibration_statistics_all$fitted_y, digits = 5)
    object[[i]]$final_model$calibration_statistics_all$residual <- round(object[[i]]$final_model$calibration_statistics_all$residual, digits = 5)
    object[[i]]$final_model$calibration_statistics_all$Mahalanobis <- round(object[[i]]$final_model$calibration_statistics_all$Mahalanobis, digits = 5)
    if (!is.null(object[[i]]$final_model$calibration_statistics_all$predicted_y_in_cv)) {
      object[[i]]$final_model$calibration_statistics_all$predicted_y_in_cv <-
        round(object[[i]]$final_model$calibration_statistics_all$predicted_y_in_cv, digits = 5)
      object[[i]]$final_model$calibration_statistics_all$cv_residual <-
        round(object[[i]]$final_model$calibration_statistics_all$cv_residual, digits = 5)
      object[[i]]$final_model$calibration_statistics_all$Q_value <-
        round(object[[i]]$final_model$calibration_statistics_all$Q_value, digits = 5)
    }

    # ... and the preprocessed X
    object[[i]]$preprocessed_X <- round(object[[i]]$preprocessed_X, digits = 5)
  }

  my_wd <- getwd()
  proximate_write_nax(
    object,
    path = temporary_dir, metadata = app_meta,
    tsv_name = application_name, empty_tsv_name = paste0(application_name, "_empty"),
    external_properties = ext_props, verbose = FALSE, internal_prj_path = ""
  )
  expect_identical(my_wd, getwd())
  c(paste0(temporary_dir, "/", application_name, ".nax"), temporary_dir)
}

# Since zip files cannot reliably snapshotted, define our own snapshot function
# that uses expect_snapshot_file to compare the different files

expect_nax_file <- function(file_loc, exp_filenames) {
  expect_true(file.exists(file_loc[1]))

  ext_files <- unzip(file_loc[1], exdir = file_loc[2])

  for (file_n in ext_files) {
    file_name <- exp_filenames[which(mapply(grepl, exp_filenames, file_n))]

    announce_snapshot_file(file_n, name = file_name)
    expect_snapshot_file(file_n, name = file_name, compare = compare_file_numeric)
  }
}

test_that("Creating an application files for several model at once works", {
  dat <- NIRcannabis[seq(1, 80, by = 5), ]
  dat <- dat[, !colnames(NIRcannabis) %in% c("THC", "THCA")]
  dat$spc <- dat$spc[, seq(1, 234, by = 10)]

  control_1 <- calibration_control(
    validation_type = "kfold", number = 2, folds = "random", remove_outliers = 0,
    seed = 95
  )
  control_2 <- calibration_control(
    validation_type = "lgo", number = 10, p = 0.7, tuning_parameter = "rsq", learning_rates = c(1, 1),
    seed = 91, remove_outliers = 0, cal_residual_limit = 1
  )
  pretreats <- preprocess_recipe(
    prep_derivative(m = 1, w = 5, p = 7, algorithm = "nwp"),
    prep_snv(),
    prep_smooth(w = 3, algorithm = "moving-average"),
    device = "unspecified"
  )

  # First model
  model_1 <- calibrate(
    CBD ~ spc,
    data = dat, preprocess = pretreats, method = fit_plsr(5, "modified"),
    control = control_1, verbose = FALSE, return_inputs = TRUE,
    metadata = add_model_metadata(key = "", created = "T", changed = "T")
  )
  # Second model
  model_2 <- calibrate(
    CBDA ~ spc,
    data = dat, preprocess = pretreats, method = fit_xlsr(5, "modified"),
    control = control_2, verbose = FALSE, return_inputs = TRUE,
    metadata = add_model_metadata(key = "", created = "T", changed = "T")
  )

  temporary_dir <- tempdir()
  app_meta <- add_application_metadata(name = "test_nax", key = "", created = "T", changed = "T")
  gen_nax_file <- gen_nax_file_from_model(list(model_1, model_2), temporary_dir, "test_nax", NULL, app_meta)

  exp_filenames <- c(
    "test_nax.tsv", "test_nax_empty.tsv", "test_nax.CBD.cal", "test_nax.CBDA.cal",
    "test_nax.CBD.prj", "test_nax.CBDA.prj", "test_nax.CBD.rtf", "test_nax.CBDA.rtf",
    "test_nax.nad"
  )
  expect_nax_file(gen_nax_file, exp_filenames)
})

test_that("Creating an application with external files works", {
  dat <- NIRcannabis[seq(2, 80, by = 5), ]
  dat <- dat[, !colnames(NIRcannabis) %in% c("CBD", "CBDA", "THCA")]
  dat$spc <- dat$spc[, seq(2, 234, by = 10)]

  control <- calibration_control(
    validation_type = "lgo", number = 10, folds = "random", remove_outliers = 0,
    replacements = FALSE, seed = 64
  )
  pretreats <- preprocess_recipe(
    prep_derivative(m = 2, w = 1, p = 7, algorithm = "nwp"),
    prep_snv(),
    device = "unspecified"
  )

  model <- calibrate(
    THC ~ spc,
    data = dat, preprocess = pretreats, method = fit_plsr(5, "standard"),
    control = control, verbose = FALSE, return_inputs = TRUE,
    metadata = add_model_metadata(key = "", created = "T", changed = "T")
  )
  ext_props <- list(add_model_metadata(
    key = "", created = "T", changed = "T", name = "empty"
  ))
  app_meta <- add_application_metadata(name = "test_nax1", key = "", created = "T", changed = "T", rotate_sample = FALSE)
  temporary_dir <- tempdir()
  expect_true(file.create(paste0(temporary_dir, "/test_nax1.empty.cal")))
  expect_true(file.create(paste0(temporary_dir, "/test_nax1.empty.prj")))
  expect_true(file.create(paste0(temporary_dir, "/test_nax1.empty.rtf")))

  gen_nax_file <- gen_nax_file_from_model(list(model), temporary_dir, "test_nax1", ext_props, app_meta)
  exp_filenames <- c(
    "test_nax1.empty.rtf", "test_nax1.empty.cal", "test_nax1.empty.prj",
    "test_nax1.tsv", "test_nax1_empty.tsv", "test_nax1.THC.cal",
    "test_nax1.THC.prj", "test_nax1.THC.rtf", "test_nax1.nad"
  )
  expect_nax_file(gen_nax_file, exp_filenames)
})

#################
# SANITY CHECKS #
#################

empty_model <- list()
class(empty_model) <- "spectral_model"
empty_model <- list(empty_model)

test_that("Creating an application file requires parameter 'object'", {
  skip_on_cran()
  expect_error(proximate_write_nax(path = tempdir()), "Parameter 'object' has to be provided")
})

test_that("The parameter 'object' must be given as a list", {
  expect_error(proximate_write_nax("", path = tempdir()), "Parameter 'object' has to be a list.")
})

test_that("The list must only contain elements of class 'spectral_model'", {
  expect_error(proximate_write_nax(list(""), path = tempdir(), metadata = add_application_metadata()), "All entries in 'object' must be of class 'spectral_model'.")
})

test_that("Verbose must be given as a logical", {
  expect_error(proximate_write_nax(verbose = "", path = tempdir()), "Parameter 'verbose' has to be a logical")
})

test_that("Writing an application requires application metadata", {
  expect_error(
    proximate_write_nax(empty_model, path = tempdir()),
    "No application metadata found in either 'object' or 'metadata', but must be provided via function 'add_application_metadata'."
  )
})

test_that("Creating an application requires data saved in any of models", {
  expect_error(
    expect_warning(
      proximate_write_nax(empty_model, path = tempdir(), metadata = add_application_metadata()),
      "No metadata found in the model for: NULL. Using defaults instead, which might be incorrect.
 Consider using function 'add_model_metadata'."
    ),
    "No data found in any model of 'object', which is required for creating an application."
  )
})

test_that("Model metadata should be of class 'model_metadata'", {
  empty_model_copy <- add_model_metadata(empty_model[[1]])
  class(empty_model_copy$metadata) <- "list"
  expect_error(expect_warning(
    proximate_write_nax(list(empty_model_copy), metadata = add_application_metadata(), report = ""),
    "No metadata found in the model for: NULL. Using defaults instead, which might be incorrect.
 Consider using function 'add_model_metadata'."
  ))
})

test_that("Application metadata should be of class 'application_metadata", {
  app_meta <- add_application_metadata()
  empty_model_copy <- add_model_metadata(empty_model[[1]])
  class(app_meta) <- "list"
  expect_error(expect_warning(
    proximate_write_nax(list(empty_model_copy), metadata = app_meta, report = ""),
    "'metadata' is not of class 'application_metadata', which may result in errors. Consider using function 'add_application_metadata'."
  ))
})

test_that("Report must be a logical", {
  empty_model_copy <- add_model_metadata(empty_model[[1]])
  expect_error(
    proximate_write_nax(list(empty_model_copy), path = tempdir(), report = "", metadata = add_application_metadata()),
    "'Report' has to be a logical."
  )
})

test_that("Duplicated property names are not allowed", {
  skip_on_cran()
  single_empty_model <- list(target_variable = "")
  class(single_empty_model) <- "spectral_model"
  single_empty_model <- add_model_metadata(single_empty_model)
  expect_error(
    proximate_write_nax(list(single_empty_model, single_empty_model), path = tempdir(), metadata = add_application_metadata()),
    "The provided list of models contains more than one model for the following: .
Duplicates of properties are not supported."
  )
})

test_that("Data hashes must all be the same for every model", {
  empty_model_copy <- empty_model_copy_2 <- add_model_metadata(empty_model[[1]])
  empty_model_copy$target_variable <- "test"
  empty_model_copy$input_data <- "1"
  attr(empty_model_copy, "data_hash") <- "1"
  attr(empty_model_copy_2, "data_hash") <- "2"

  app_meta <- add_application_metadata()
  class(app_meta) <- "list"
  expect_error(
    expect_warning(
      proximate_write_nax(list(empty_model_copy, empty_model_copy_2), path = tempdir(), metadata = app_meta),
      "'metadata' is not of class 'application_metadata', which may result in errors. Consider using function 'add_application_metadata'."
    ),
    "Differences found in data used to create the models in 'object'. The data for all models included must be from one single 'data.frame'."
  )
})

test_that("External properties that cannot be found throw a warning", {
  skip_on_cran()
  dat <- NIRcannabis[seq(2, 80, by = 5), ]
  dat <- dat[, !colnames(NIRcannabis) %in% c("CBD", "CBDA", "THCA")]
  dat$spc <- dat$spc[, seq(2, 234, by = 10)]

  control <- calibration_control(
    validation_type = "lgo", number = 10, folds = "random", remove_outliers = 0,
    replacements = FALSE, seed = 64
  )

  model <- calibrate(
    THC ~ spc,
    data = dat, preprocess = preprocess_recipe(), method = fit_plsr(5, "modified"),
    control = control, verbose = FALSE, return_inputs = TRUE,
    metadata = add_model_metadata(key = "", created = "T", changed = "T")
  )
  ext_props <- list(add_model_metadata(
    key = "", created = "T", changed = "T", name = "non_existent"
  ))
  app_meta <- add_application_metadata(name = "warn", key = "", created = "T", changed = "T", rotate_sample = FALSE)
  temporary_dir <- tempdir()

  expect_warning(
    proximate_write_nax(
      list(model),
      path = temporary_dir, metadata = app_meta,
      external_properties = ext_props, verbose = FALSE
    ),
    "File 'warn.non_existent.cal' not found. Ignoring property in application file computation."
  )
})

test_that("Writing the metadata file requires objects of class 'spectral_model'", {
  expect_error(write_nad(list(list()), "", ""), "All entries in 'object' must be of class 'spectral_model'.")
})

test_that("Writing the metadata file must have a character as path", {
  expect_error(write_nad(empty_model, 5, ""), "'path' must be a character")
})
