# Smoothing constructor for spectral preprocessing

Creates a preprocessing constructor for smoothing spectral data. The
constructor is intended to be passed to
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed via
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

Two algorithms are supported: Savitzky-Golay (`"savitzky-golay"`) and
moving average (`"moving-average"`).

## Usage

``` r
prep_smooth(w, p = NULL, algorithm = c("savitzky-golay", "moving-average"))
```

## Arguments

- w:

  A positive odd integer specifying the filter window size.

- p:

  An integer specifying the polynomial order. Required when
  `algorithm = "savitzky-golay"`. Must satisfy `p < w` and `p >= 0`.
  Ignored for `"moving-average"`.

- algorithm:

  A character string specifying the smoothing algorithm. One of
  `"savitzky-golay"` (default) or `"moving-average"`. See Details.

## Value

An object of class `preprocessing` to be used in
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed by
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).
The object is a list containing the method name and all parameters. For
`algorithm = "moving-average"`, the NIRWise PLUS half-window value
(`half_w`) is also stored for device file serialization.

## Details

**Savitzky-Golay** (`"savitzky-golay"`): fits a polynomial of order `p`
within a moving window of size `w` and returns the zero-order
coefficient (i.e. the smoothed value). Implemented via
[`savitzkyGolay`](https://l-ramirez-lopez.github.io/prospectr/reference/savitzkyGolay.html)
with `m = 0`.

**Moving average** (`"moving-average"`): computes a simple moving
average of window size `w` using
[`movav`](https://l-ramirez-lopez.github.io/prospectr/reference/movav.html).
Edge values are handled using progressively narrower windows so the
output has the same number of columns as the input. This reproduces the
"Smooth" pre-treatment from BUCHI NIRWise PLUS.

For `"moving-average"`, the NIRWise PLUS half-window convention is:
\\half_w = (w - 1) / 2\\ stored internally for device file serialization
and not user-facing.

## See also

[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md),
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)

## Author

Leonardo Ramirez-Lopez and Claudio Orellano

## Examples

``` r
data("NIRcannabis")
X <- NIRcannabis$spc

# Savitzky-Golay smoothing, window 11, polynomial order 3
sg <- prep_smooth(w = 11, p = 3, algorithm = "savitzky-golay")

# Moving average smoothing, window 7
ma <- prep_smooth(w = 7, algorithm = "moving-average")

# Apply via preprocess_recipe
recipe <- preprocess_recipe(sg, device = "proxiscout")
X_smooth <- process(X, recipe)
```
