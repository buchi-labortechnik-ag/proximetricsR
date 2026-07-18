# A function to assign values to sample distribution strata

for internal use only! This function takes a continuous variable,
creates n strata based on its distribution and assigns the corresponding
starta to every value.

## Usage

``` r
get_sample_strata(y, n = NULL, probs = NULL)
```

## Arguments

- y:

  a matrix of one column with the response variable.

- n:

  the number of strata.

## Value

a data table with the input `y` and the corresponding strata to every
value.
