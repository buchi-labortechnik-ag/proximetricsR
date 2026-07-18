# Test if a string can be coerced to a numeric

based on the code found at \#
https://stackoverflow.com/a/21154566/2292993

## Usage

``` r
is_numeric_like(
  x,
  na_strings = c("", ".", "NA", "na", "N/A", "n/a", "NaN", "nan")
)
```

## Value

A logical vector indicating whether each element can be coerced to
numeric.
