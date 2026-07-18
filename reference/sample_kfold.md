# A function to create calibration and validation sample sets for k-fold cross-validation

for internal use only! This function implements k-fold sampling. based
on either a random or sequential selection of observations. If group is
provided, the sampling is done based on the groups. This function is
used to create groups for k-fold cross-validations.

## Usage

``` r
sample_kfold(
  N,
  number,
  group = NULL,
  sampling = c("random", "sequential"),
  seed = NULL
)
```

## Arguments

- N:

  the total number of observations.

- number:

  the number of folds.

- group:

  the labels for each sample in indicating the group each observation
  belongs to.

- sampling:

  a character vector indicating hw to sample. Options are: `"random"`
  (default) or `"sequential"` (the one used in NIRWise PLUS).

- seed:

  an integer for random number generator (default `NULL`).

## Value

a list with two matrices (`hold_in` and `hold_out`) giving the indices
of the observations in each column. The number of columns represents the
number of sampling repetitions.
