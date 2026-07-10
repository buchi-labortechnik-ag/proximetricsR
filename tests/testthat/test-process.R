# Use a random matrix for testing process
# Only check if process recipe is correctly applied, not the actual contents of the
# matrices. These are checked for each process function individually.

X <- withr::with_seed(56, {
  matrix(rnorm(100), 10, 50, dimnames = list(NULL, seq(1000, 1700, length.out = 50)))
})

###########################
# TESTING IF RECIPE WORKS #
###########################

test_that("The recipe is of class 'preprocess_recipe", {
  expect_true(inherits(preprocess_recipe(), "preprocess_recipe"))
})

test_that("Elements passed to process recipe must be of class 'process", {
  expect_error(preprocess_recipe(1, device = "unspecified"))
  expect_error(process(X, recipe = "1"), "'recipe' must be of class 'preprocess_recipe' or 'preprocessing'")
})

################
# TESTING on X #
################

test_that("Empty recipe does not change X", {
  X_no_preprocess <- process(X, preprocess_recipe())
  attr(X_no_preprocess, "processed_wavs") <- attr(X_no_preprocess, "preprocess_recipe") <- NULL
  expect_identical(X_no_preprocess, X)
})

test_that("Derivative is correctly applied", {
  as_recipe <- process(X, preprocess_recipe(prep_derivative(m = 1, w = 5, p = 3), device = "unspecified"))
  expect_identical(as_recipe, process(X, prep_derivative(m = 1, w = 5, p = 3)))
})

test_that("Smoothing is applied the correct way", {
  as_recipe <- process(X, preprocess_recipe(prep_smooth(w = 3, p = 2, algorithm = "savitzky-golay"), device = "unspecified"))
  expect_identical(as_recipe, process(X, prep_smooth(w = 3, p = 2)))
})

test_that("Standard normal variate is correctly applied", {
  as_recipe <- process(X, preprocess_recipe(prep_snv(), device = "unspecified"))
  expect_identical(as_recipe, process(X, prep_snv()))
})

test_that("Splines are correctly interpolated", {
  as_recipe <- process(X, preprocess_recipe(prep_resample(c(1000, 1700, 90)), device = "unspecified"))
  expect_identical(as_recipe, process(X, prep_resample(c(1000, 1700, 90))))
})

####################
# TEST FULL RECIPE #
####################

full_recipe <- process(X, preprocess_recipe(
  prep_resample(c(1100, 1500, 20)),
  prep_snv(),
  prep_derivative(m = 2, w = 5, p = 2, algorithm = "savitzky-golay"),
  prep_smooth(w = 5, p = 3, algorithm = "savitzky-golay"),
  device = "unspecified"
))

full_recipe_rev <- process(X, preprocess_recipe(
  prep_smooth(w = 5, p = 3, algorithm = "savitzky-golay"),
  prep_derivative(m = 2, w = 5, p = 2, algorithm = "savitzky-golay"),
  prep_snv(),
  prep_resample(c(1100, 1500, 20)),
  device = "unspecified"
))

test_that("A full recipe is correctly applied", {
  with_recipe <- full_recipe
  attr(with_recipe, "processed_wavs") <- attr(with_recipe, "preprocess_recipe") <- NULL

  one_by_one <- X |>
    process(prep_resample(c(1100, 1500, 20))) |>
    process(prep_snv()) |>
    process(prep_derivative(m = 2, w = 5, p = 2, algorithm = "savitzky-golay")) |>
    process(prep_smooth(w = 5, p = 3, algorithm = "savitzky-golay"))
  attr(one_by_one, "processed_wavs") <- attr(one_by_one, "preprocess_recipe") <- NULL
  expect_identical(with_recipe, one_by_one)
})

test_that("The order of the recipe matters", {
  expect_true(any(dim(full_recipe) != dim(full_recipe_rev)))
})

test_that("The recipe is correctly printed", {
  recipe <- preprocess_recipe(
    prep_smooth(w = 5, p = 3, algorithm = "savitzky-golay"),
    prep_resample(c(1, 1000, 2)),
    prep_derivative(m = 1, w = 5, p = 3, algorithm = "savitzky-golay"),
    prep_snv(),
    device = "unspecified"
  )
  recipe_print <- capture.output(print(recipe))
  expect_length(recipe_print, 8L)
  expect_snapshot(recipe_print)
})

#################
# SANITY CHECKS #
#################

test_that("Elements in a recipe must be of class 'preprocessing'", {
  expect_error(preprocess_recipe(mean, sd))
})
