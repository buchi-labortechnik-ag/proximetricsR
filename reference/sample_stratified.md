# A function to create calibration and validation sample sets for leave-group-out cross-validation

for internal use only! This is stratified sampling based on the values
of a continuous response variable (y). If group is provided, the
sampling is done based on the groups and the average of y per group.
This function is used to create calibration and validation groups for
leave-group-out cross-validations (or leave-group-of-groups-out
cross-validation if group argument is provided).

## Usage

``` r
sample_stratified(y, p, number, group = NULL, replacement = FALSE, seed = NULL)
```

## Arguments

- y:

  a matrix of one column with the response variable.

- p:

  the percentage of samples (or groups if group argument is used) to
  retain in the validation_indices set

- number:

  the number of sample groups to be crated

- group:

  the labels for each sample in `y` indicating the group each
  observation belongs to.

- replacement:

  A logical indicating sample replacements for the calibration set are
  required.

- seed:

  an integer for random number generator (default `NULL`).

## Value

a list with two matrices (`hold_in` and `hold_out`) giving the indices
of the observations in each column. The number of columns represents the
number of sampling repetitions.
