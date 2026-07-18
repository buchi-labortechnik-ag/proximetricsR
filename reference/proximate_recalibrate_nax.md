# Recalibrate a nax file

This function updates a nax file

## Usage

``` r
proximate_recalibrate_nax(x,
                          preprocess_recipes = NULL,
                          methods = NULL,
                          control = calibration_control(seed = 1),
                          name,
                          add = NULL)
```

## Arguments

- x:

  an object of class `nax` as returned by the
  [`proximate_read_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_read_nax.md)
  function.

- preprocess_recipes:

  an optional list with one or more objects of class
  [`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
  that are to be tested for finding the optimal one for each model in
  the list passed to `formulas`.

- methods:

  an optional list containing one ore more objects of class
  `fit_constructor` which are as returned by one of the
  [`fit_constructors`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md)
  functions, indicating what type of regression method to use along with
  its parameters.

- control:

  a `calibration_control` object as returned by the
  [`calibration_control`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibration_control.md)
  function, indicating how some aspects of the calibration process must
  be conducted (e.g. cross-validation and outlier detection). Default is
  `calibration_control(seed = 1)`. See details.

- name:

  a vector length at most 2, consisting of characters for the name and
  alias of the application. Defaults to "Untitled".

- add:

  an optional object of class `nax_augment` as returned by the
  [`proximate_add2nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_add2nax.md)
  function.

## Value

A list of class `"spectral_multimodel"`. See
[`calibrate_models`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate_models.md)
function.

## See also

[`proximate_add2nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_add2nax.md)

[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md),

[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md),

[`fit_plsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md),

[`fit_xlsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md),

[`calibration_control`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibration_control.md),

[`calibrate_models`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate_models.md)

## Author

Leonardo Ramirez-Lopez and Claudio Orellano
