# Prepare data for augmenting a nax application

This function collects all the necessary data that is required prior
updating a nax application.

## Usage

``` r
proximate_add2nax(formulas = NULL, data, metadata_list = NULL, skip_indices_list = NULL)
```

## Arguments

- formulas:

  a list containing one or more objects of class
  [`formula`](https://rdrr.io/r/stats/formula.html) where each of them
  represents the model to be calibrated.

- data:

  a data.frame containing the data of the variables in the model (as in
  the
  [`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
  function).

- metadata_list:

  a list of containing the specifications for the metadata of each model
  in `formulas` given in the same order. Each element in the list should
  be defined as in the `metadata` argument of
  [`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
  using the
  [`add_model_metadata`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/add_model_metadata.md)
  function. Defaults to `NULL`.

- skip_indices_list:

  a list of vectors of integers for the indices in the input data to be
  skipped for the computation of each of the models in `formulas`. The
  vectors in this list must be provided in the same order as their
  corresponding counterparts in `formulas`. Defaults to `NULL`. In case
  a list is passed, the list components must be filled with
  [`numeric()`](https://rdrr.io/r/base/numeric.html) for those
  `formulas` where there is no indices to be skipped.

## Value

A list mirroing the objects passed to the function.

## See also

[`proximate_recalibrate_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_recalibrate_nax.md)

[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md),

[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md),

[`fit_plsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md),

[`fit_xlsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md),

[`calibration_control`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibration_control.md),

[`calibrate_models`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate_models.md)

## Author

Leonardo Ramirez-Lopez and Claudio Orellano
