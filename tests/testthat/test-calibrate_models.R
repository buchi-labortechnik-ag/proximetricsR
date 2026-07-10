# Tests for calibrate_models() and predict.spectral_multimodel()
#
# Shared setup: run calibrate_models() ONCE before all test_that blocks so
# tests don't each pay the calibration cost.

data("NIRcannabis", package = "proximetricsR")

recipe1 <- preprocess_recipe(
  prep_resample(grid = c(1001, 1700, 2)),
  prep_snv(),
  device = "proximate"
)
recipe2 <- preprocess_recipe(
  prep_resample(grid = c(1001, 1700, 2)),
  prep_derivative(m = 1, w = 9, p = 7, algorithm = "nwp"),
  device = "proximate"
)

ctrl <- calibration_control(validation_type = "kfold", number = 3, seed = 42)

multi <- calibrate_models(
  formulas = list(THC ~ spc, CBD ~ spc),
  data = NIRcannabis,
  preprocess_recipes = list(recipe1, recipe2),
  methods = list(fit_plsr(3)),
  control = ctrl,
  verbose = FALSE
)

# -----------------------------------------------------------------------
# 1. Return class
# -----------------------------------------------------------------------

test_that("calibrate_models returns class c('spectral_multimodel', 'list')", {
  skip_on_cran()
  expect_true(inherits(multi, "spectral_multimodel"))
  expect_true(inherits(multi, "list"))
  expect_identical(class(multi), c("spectral_multimodel", "list"))
})

# -----------------------------------------------------------------------
# 2. Top-level element names
# -----------------------------------------------------------------------

test_that("result has elements results_grid, preprocess_recipes, all_models, final_models", {
  skip_on_cran()
  expect_named(multi, c("results_grid", "preprocess_recipes", "all_models", "final_models"))
})

# -----------------------------------------------------------------------
# 3. results_grid is a data.frame
# -----------------------------------------------------------------------

test_that("results_grid is a data.frame", {
  skip_on_cran()
  expect_true(is.data.frame(multi$results_grid))
})

# -----------------------------------------------------------------------
# 4. results_grid has required columns
# -----------------------------------------------------------------------

test_that("results_grid has columns formula, recipe, and selection", {
  skip_on_cran()
  expect_true(all(c("formula", "recipe", "selection") %in% colnames(multi$results_grid)))
})

# -----------------------------------------------------------------------
# 5. results_grid row count: length(formulas) * length(recipes) = 2 * 2 = 4
# -----------------------------------------------------------------------

test_that("results_grid has length(formulas) * length(recipes) rows (4)", {
  skip_on_cran()
  expect_equal(nrow(multi$results_grid), 4L)
})

# -----------------------------------------------------------------------
# 6. final_models is a named list with length equal to number of formulas
# -----------------------------------------------------------------------

test_that("final_models is a named list with length equal to number of formulas", {
  skip_on_cran()
  expect_type(multi$final_models, "list")
  expect_length(multi$final_models, 2L)
})

# -----------------------------------------------------------------------
# 7. Names of final_models match the formula character strings
# -----------------------------------------------------------------------

test_that("names of final_models match formula strings", {
  skip_on_cran()
  expect_identical(sort(names(multi$final_models)), sort(c("THC ~ spc", "CBD ~ spc")))
})

# -----------------------------------------------------------------------
# 8. Each element of final_models inherits 'spectral_model'
# -----------------------------------------------------------------------

test_that("each element of final_models inherits 'spectral_model'", {
  skip_on_cran()
  for (m in multi$final_models) {
    expect_true(inherits(m, "spectral_model"))
  }
})

# -----------------------------------------------------------------------
# 9. all_models is NULL when save_all = FALSE (default)
# -----------------------------------------------------------------------

test_that("all_models is NULL when save_all = FALSE", {
  skip_on_cran()
  expect_null(multi$all_models)
})

# -----------------------------------------------------------------------
# 10. all_models is populated when save_all = TRUE
# -----------------------------------------------------------------------

test_that("all_models is populated when save_all = TRUE", {
  skip_on_cran()
  multi_all <- calibrate_models(
    formulas = list(THC ~ spc),
    data = NIRcannabis,
    preprocess_recipes = list(recipe1),
    methods = list(fit_plsr(3)),
    control = ctrl,
    verbose = FALSE,
    save_all = TRUE
  )
  expect_false(is.null(multi_all$all_models))
  expect_type(multi_all$all_models, "list")
  expect_gt(length(multi_all$all_models), 0L)
})

# -----------------------------------------------------------------------
# 11. selection column has exactly one TRUE per formula group
# -----------------------------------------------------------------------

test_that("selection column has exactly one TRUE per formula group", {
  skip_on_cran()
  rg <- multi$results_grid
  for (fml in levels(rg$formula)) {
    n_selected <- sum(rg$selection[rg$formula == fml])
    expect_equal(n_selected, 1L)
  }
})

# -----------------------------------------------------------------------
# 12. predict.spectral_multimodel returns list with predictions and model_information
# -----------------------------------------------------------------------

preds <- predict(multi, NIRcannabis, verbose = FALSE)

test_that("predict.spectral_multimodel returns list with predictions and model_information", {
  skip_on_cran()
  expect_type(preds, "list")
  expect_true(all(c("predictions", "model_information") %in% names(preds)))
})

# -----------------------------------------------------------------------
# 13. predictions is a matrix with nrow = nrow(data) and ncol = n formulas
# -----------------------------------------------------------------------

test_that("predictions is a matrix with correct dimensions", {
  skip_on_cran()
  expect_true(is.matrix(preds$predictions))
  expect_equal(nrow(preds$predictions), nrow(NIRcannabis))
  expect_equal(ncol(preds$predictions), length(multi$final_models))
})

# -----------------------------------------------------------------------
# 14. model_information is a list named by target variable
# -----------------------------------------------------------------------

test_that("model_information is a list named by target variable", {
  skip_on_cran()
  expect_type(preds$model_information, "list")
  target_vars <- sapply(multi$final_models, function(m) m$target_variable)
  expect_identical(sort(names(preds$model_information)), sort(unname(target_vars)))
})

# -----------------------------------------------------------------------
# 15. Error when preprocess_recipes is missing
# -----------------------------------------------------------------------

test_that("calibrate_models errors when preprocess_recipes is missing", {
  expect_error(
    calibrate_models(
      formulas = list(THC ~ spc),
      data = NIRcannabis,
      methods = list(fit_plsr(3)),
      control = ctrl,
      verbose = FALSE
    ),
    "'preprocess_recipes' is missing"
  )
})

# -----------------------------------------------------------------------
# 16. Error when formula variable is missing from data
# -----------------------------------------------------------------------

test_that("calibrate_models errors when formula variable is missing from data", {
  expect_error(
    calibrate_models(
      formulas = list(NONEXISTENT ~ spc),
      data = NIRcannabis,
      preprocess_recipes = list(recipe1),
      methods = list(fit_plsr(3)),
      control = ctrl,
      verbose = FALSE
    )
  )
})

# -----------------------------------------------------------------------
# 17. Error when control$tuning_parameter == "none"
# -----------------------------------------------------------------------

test_that("calibrate_models errors when tuning_parameter is 'none'", {
  ctrl_none <- suppressWarnings(
    calibration_control(validation_type = "kfold", number = 3, tuning_parameter = "none", seed = 42)
  )
  expect_error(
    calibrate_models(
      formulas = list(THC ~ spc),
      data = NIRcannabis,
      preprocess_recipes = list(recipe1),
      methods = list(fit_plsr(3)),
      control = ctrl_none,
      verbose = FALSE
    ),
    "none.*tuning parameter|tuning parameter.*none|Value 'none'",
    perl = TRUE
  )
})

# -----------------------------------------------------------------------
# 18. Warning for duplicated formulas
# -----------------------------------------------------------------------

test_that("calibrate_models warns for duplicated formulas", {
  skip_on_cran()
  expect_warning(
    calibrate_models(
      formulas = list(THC ~ spc, THC ~ spc),
      data = NIRcannabis,
      preprocess_recipes = list(recipe1),
      methods = list(fit_plsr(3)),
      control = ctrl,
      verbose = FALSE
    ),
    "duplicated"
  )
})

# -----------------------------------------------------------------------
# 19. Warning for duplicated preprocess_recipes
# -----------------------------------------------------------------------

test_that("calibrate_models warns for duplicated preprocess_recipes", {
  skip_on_cran()
  expect_warning(
    calibrate_models(
      formulas = list(THC ~ spc),
      data = NIRcannabis,
      preprocess_recipes = list(recipe1, recipe1),
      methods = list(fit_plsr(3)),
      control = ctrl,
      verbose = FALSE
    ),
    "duplicated"
  )
})
