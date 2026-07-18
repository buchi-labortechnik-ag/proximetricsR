# A function to construct an optimal strata for the samples, based on the distribution of the given y.

for internal use only! This function computes the optimal strata from
the distribution of the given y

## Usage

``` r
optim_sample_strata(y, n)
```

## Arguments

- y:

  a matrix of one column with the response variable.

- n:

  number of samples that must be sampled.

## Value

a list with two data frames: `sample_strata` contains the optimal
strata, whereas `samples_to_get` contains information on how many
samples per stratum are supposed to be drawn.
