# A function to create calibration and validation sample sets for leave-one-out cross-validation

for internal use only! If group is provided, the sampling is done based
on the groups.

## Usage

``` r
sample_loo(N, group = NULL)
```

## Arguments

- N:

  the total number of observations.

- group:

  the labels for each sample in `y` indicating the group each
  observation belongs to.

## Value

a list with two matrices (`hold_in` and `hold_out`) giving the indices
of the observations in each column. The number of columns represents the
number of sampling repetitions.
