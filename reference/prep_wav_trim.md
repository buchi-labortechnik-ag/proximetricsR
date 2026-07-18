# Wavelength trimming constructor for spectral preprocessing

Creates a preprocessing constructor for trimming spectral data to a
specified wavelength band. The constructor is intended to be passed to
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed via
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

## Usage

``` r
prep_wav_trim(
  band,
  trim_constant_edges = FALSE
)
```

## Arguments

- band:

  A numeric vector of length 2 giving the minimum and maximum
  wavenumber/wavelength to retain. Columns of `X` outside this range are
  dropped. Pass [`c()`](https://rdrr.io/r/base/c.html) (empty vector) to
  skip band trimming and only apply `trim_constant_edges`.

- trim_constant_edges:

  A logical. If `TRUE`, constant or zero-valued columns at the left and
  right edges are removed after band trimming. Default is `FALSE`.

## Value

An object of class `preprocessing` to be used in
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed by
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

## Details

Band trimming retains only those columns whose names (coerced to
numeric) fall within `[min(band), max(band)]`. If no columns fall within
the band the original matrix is returned with a warning.

Constant edge trimming scans inward from each edge and drops columns
that are identical to their immediate neighbour or are all zero. If
trimming would leave fewer than two columns the step is skipped with a
warning.

## See also

[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md),
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)

## Author

Claudio Orellano and Leonardo Ramirez-Lopez

## Examples

``` r
data("NIRcannabis")
X <- NIRcannabis$spc

tr <- prep_wav_trim(band = c(1000, 1800))
recipe <- preprocess_recipe(tr, device = "proxiscout")
X_trim <- process(X, recipe)
```
