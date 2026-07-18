# A function for stratified calibration/validation sampling

for internal use only! This function selects samples based on provided
strata.

## Usage

``` r
get_samples_from_strata(
  y,
  original_order,
  strata,
  samples_per_strata,
  sampling_for = c("calibration", "validation"),
  replacement = FALSE
)
```

## Arguments

- y:

  the vector of reference values

- original_order:

  a matrix of one column with the response variable.

- strata:

  the number of strata.

- sampling_for:

  sampling to select the calibration samples ("calibration") or sampling
  to select the validation samples ("validation").

- replacement:

  logical indicating if sampling with replacement must be done.

## Value

a list with the indices of the calibration and validation samples.
