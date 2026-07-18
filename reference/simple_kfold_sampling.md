# Simple k-fold sampling

For internal use only

## Usage

``` r
simple_kfold_sampling(
  N,
  number,
  sampling = c("random", "sequential"),
  seed = NULL
)
```

## Value

A list with two matrices (`hold_in` and `hold_out`) giving the indices
of the observations in each column for each fold.
