data("proximateCannabis", package = "proximetricsR")

dat <- proximateCannabis[41:80, ]
X <- dat$spc
rownames(X) <- NULL
Y <- matrix(dat$THC, dimnames = list(41:80, "THC"))

base_recipe <- preprocess_recipe(
  prep_wav_trim(band = c(1100, 1600)),
  prep_snv(),
  prep_derivative(m = 1, w = 11, p = 5, algorithm = "savitzky-golay"),
  device = "unspecified"
)

model <- calibrate(
  X, Y,
  data = dat, preprocess = base_recipe, method = fit_plsr(5, "standard"),
  control = calibration_control("none"), verbose = FALSE
)

test_that("export_sklearn_model requires a spectral_model object", {
  expect_error(export_sklearn_model(list()), "'object' must be of class 'spectral_model'")
})

test_that("export_sklearn_model accepts nwp-type models (identical coefficients to modified)", {
  recipe <- preprocess_recipe(prep_snv())
  nwp_model <- calibrate(
    X, Y,
    data = dat, preprocess = recipe,
    method = fit_plsr(5, "nwp"), control = calibration_control("none"), verbose = FALSE
  )
  modified_model <- calibrate(
    X, Y,
    data = dat, preprocess = recipe,
    method = fit_plsr(5, "modified"), control = calibration_control("none"), verbose = FALSE
  )

  json <- export_sklearn_model(nwp_model)
  doc <- jsonlite::fromJSON(json, simplifyVector = FALSE)
  model_step <- doc$params$steps[[length(doc$params$steps)]][[2]]

  expect_equal(model_step$params$type, "nwp")
  # coef_ absorbs the prep_snv() sample-vs-population SD factor, since
  # chemotools' StandardNormalVariate divides by the population SD.
  n_features <- length(nwp_model$final_model$model$x_means)
  snv_scale <- sqrt((n_features - 1) / n_features)
  expect_equal(
    unlist(model_step$attributes$coef_),
    unname(modified_model$final_model$model$coefficients[5, ]) * snv_scale,
    tolerance = 1e-8
  )
  expect_equal(
    model_step$attributes$intercept_,
    unname(modified_model$final_model$model$intercept)[1],
    tolerance = 1e-8
  )
})

test_that("export_sklearn_model rejects nwp preprocessing steps", {
  nwp_recipe <- preprocess_recipe(
    prep_derivative(m = 1, w = 5, p = 11, algorithm = "nwp"),
    device = "unspecified"
  )
  nwp_model <- calibrate(
    X, Y,
    data = dat, preprocess = nwp_recipe, method = fit_plsr(5, "standard"),
    control = calibration_control("none"), verbose = FALSE
  )
  expect_error(export_sklearn_model(nwp_model), 'algorithm = "nwp"')
})

test_that("export_sklearn_model rejects prep_derivative(algorithm = 'gap-segment')", {
  recipe <- preprocess_recipe(
    prep_derivative(m = 1, w = 3, p = 5, algorithm = "gap-segment"),
    device = "unspecified"
  )
  gap_model <- calibrate(
    X, Y,
    data = dat, preprocess = recipe, method = fit_plsr(5, "standard"),
    control = calibration_control("none"), verbose = FALSE
  )
  expect_error(export_sklearn_model(gap_model), "gap-segment")
})

test_that("export_sklearn_model rejects prep_transform(to = 'reflectance')", {
  recipe <- preprocess_recipe(
    prep_transform(to = "reflectance"),
    device = "proxiscout"
  )
  reflectance_model <- calibrate(
    X, Y,
    data = dat, preprocess = recipe, method = fit_plsr(5, "standard"),
    control = calibration_control("none"), verbose = FALSE
  )
  expect_error(export_sklearn_model(reflectance_model), 'to = "reflectance"')
})

test_that("export_sklearn_model rejects prep_wav_trim(trim_constant_edges = TRUE)", {
  recipe <- preprocess_recipe(
    prep_wav_trim(band = c(1100, 1600), trim_constant_edges = TRUE),
    device = "unspecified"
  )
  trim_model <- calibrate(
    X, Y,
    data = dat, preprocess = recipe, method = fit_plsr(5, "standard"),
    control = calibration_control("none"), verbose = FALSE
  )
  expect_error(export_sklearn_model(trim_model), "trim_constant_edges = TRUE")
})

test_that("export_sklearn_model rejects prep_resample", {
  recipe <- preprocess_recipe(
    prep_resample(grid = c(1100, 1600, 5)),
    device = "proximate"
  )
  resample_model <- calibrate(
    X, Y,
    data = dat, preprocess = recipe, method = fit_plsr(5, "standard"),
    control = calibration_control("none"), verbose = FALSE
  )
  expect_error(export_sklearn_model(resample_model), "prep_resample")
})

test_that("export_sklearn_model produces the expected Pipeline JSON shape", {
  json <- export_sklearn_model(model)
  doc <- jsonlite::fromJSON(json, simplifyVector = FALSE)

  expect_equal(doc$estimator_class, "Pipeline")
  steps <- doc$params$steps
  # one step per recipe step, plus the model, plus the extra RangeCut emitted to
  # reproduce the edge points prep_derivative() drops but SavitzkyGolay keeps.
  expect_length(steps, length(base_recipe$steps) + 2)

  step_classes <- sapply(steps, function(s) s[[2]]$estimator_class)
  expect_equal(
    unlist(step_classes),
    c(
      "RangeCut", "StandardNormalVariate", "SavitzkyGolay", "RangeCut",
      "NIRWiseLinearModel"
    )
  )

  model_step <- steps[[length(steps)]][[2]]
  expect_equal(model_step$params$fit_method, "plsr")
  expect_equal(model_step$params$type, "standard")
  expect_length(model_step$attributes$coef_, length(model$final_model$model$x_means))
  # the coefficient axis travels as wavenumbers_, never as scikit-learn's
  # feature_names_in_ (which the model step can never satisfy -- see
  # export_sklearn_model.R)
  expect_length(
    model_step$attributes$wavenumbers_, length(model$final_model$model$x_means)
  )
  expect_null(model_step$attributes$feature_names_in_)

  expect_equal(doc$metadata$domain, "sklearn")
  expect_equal(doc$metadata$producer_name, "proximetricsR")
})

test_that("export_sklearn_model can write to a file", {
  file <- tempfile(fileext = ".json")
  result <- export_sklearn_model(model, file = file)
  expect_true(file.exists(file))
  expect_equal(as.character(result), paste(readLines(file), collapse = "\n"))
})

test_that("export_sklearn_model matches openmodels' documented dict shape", {
  # https://github.com/Gnpd/openmodels/blob/main/docs/format.md
  json <- export_sklearn_model(model)
  doc <- jsonlite::fromJSON(json, simplifyVector = FALSE)

  # metadata is root-only and never duplicated on nested sub-estimators.
  expect_true("metadata" %in% names(doc))

  for (step in doc$params$steps) {
    est <- step[[2]]
    expect_false("metadata" %in% names(est))
    # every param carries a type, so values JSON cannot represent natively
    # survive the round trip
    # as.character() so a block that is absent or empty reads as character(0)
    expect_setequal(
      as.character(names(est$param_types)), as.character(names(est$params))
    )
    # openmodels indexes data["attribute_types"] directly once "attributes" is
    # present, so the two must always be emitted together
    if (!is.null(est$attributes)) expect_false(is.null(est$attribute_types))
  }

  meta <- doc$metadata
  expect_equal(meta$openmodels_format_version, 3)
  # producer_* is the tool that wrote the file (ONNX convention), not the root
  # estimator's package.
  expect_equal(meta$producer_name, "proximetricsR")
  expect_equal(
    meta$producer_version, as.character(utils::packageVersion("proximetricsR"))
  )
  # packages lists exactly the packages contributing a class to this tree, at
  # the versions whose attribute layouts the export targets.
  expect_equal(
    names(meta$packages),
    c("chemotools", "proximetricsr_estimators", "sklearn")
  )
  expect_equal(
    unlist(meta$packages),
    proximetricsR:::.sklearn_export_targets[names(meta$packages)]
  )
  expect_equal(meta$domain_version, meta$packages$sklearn)
  # dependency_versions is this R session's own runtime.
  expect_equal(meta$dependency_versions$R, as.character(getRversion()))
  # pre-v3 ad-hoc/placeholder fields are gone
  for (field in c(
    "source", "proximetricsR_version", "r_version", "producers", "openmodels_version"
  )) {
    expect_null(meta[[field]])
  }
})
