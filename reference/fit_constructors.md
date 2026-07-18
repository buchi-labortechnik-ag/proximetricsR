# Fitting method constructors

These functions create configuration objects that specify the regression
method to be used within
[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md).

## Usage

``` r
fit_plsr(ncomp, type = c("nwp", "standard", "modified"))

fit_xlsr(ncomp, type = c("nwp", "standard", "modified"), min_w = 3, max_w = 15)
```

## Arguments

- ncomp:

  a positive integer indicating the maximum number of PLS components to
  use.

- type:

  a character string indicating the algorithm variant. One of `"nwp"`
  (default), `"standard"`, or `"modified"`.

  - `"nwp"`: replicates the NIRWise PLUS method, which uses
    correlation-based weights with an additional slope correction
    applied to the weights and scores.

  - `"standard"`: standard PLS using standardised covariances between
    spectra and reference values as weights.

  - `"modified"`: modified PLS using correlations between spectra and
    reference values as weights.

- min_w:

  a positive integer indicating the minimum window size for the XLS
  algorithm. Default is `3`.

- max_w:

  a positive integer indicating the maximum window size for the XLS
  algorithm. Must be greater than `min_w`. Default is `15`.

## Value

An object of class `c("fit_plsr", "fit_constructor")` or
`c("fit_xlsr", "fit_constructor")` containing the specified parameters,
to be passed to
[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md).

## Details

There are two regression methods available:

### Partial least squares (`fit_plsr`)

Uses PLS regression. The only parameter optimised is the number of
components (`ncomp`). Three algorithm variants are available via `type`:
`"nwp"`, `"standard"`, and `"modified"`.

### Extended partial least squares (`fit_xlsr`)

Uses the XLS algorithm. In addition to `ncomp` and `type`, the window
range (`min_w`, `max_w`) controls the local smoothing applied within the
algorithm.

## See also

[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md),
[`calibrate_models`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate_models.md)

## Author

Leonardo Ramirez-Lopez and Claudio Orellano

## Examples

``` r
# PLS as in NIRWise PLUS
fit_plsr(ncomp = 15)
#> Fitting method: fit_plsr
#>   ncomp: 15 
#>   type : nwp 

# Standard PLS with 15 components
fit_plsr(ncomp = 15, type = "standard")
#> Fitting method: fit_plsr
#>   ncomp: 15 
#>   type : standard 

# Modified PLS with 15 components
fit_plsr(ncomp = 15, type = "modified")
#> Fitting method: fit_plsr
#>   ncomp: 15 
#>   type : modified 

# XLS as in NIRWise PLUS
fit_xlsr(ncomp = 10)
#> Fitting method: fit_xlsr
#>   ncomp: 10 
#>   type : nwp 
#>   min_w: 3 
#>   max_w: 15 

# Standard XLS with custom window range
fit_xlsr(ncomp = 10, type = "standard", min_w = 5, max_w = 20)
#> Fitting method: fit_xlsr
#>   ncomp: 10 
#>   type : standard 
#>   min_w: 5 
#>   max_w: 20 
```
