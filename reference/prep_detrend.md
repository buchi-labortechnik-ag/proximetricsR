# Detrending constructor for spectral preprocessing

Creates a preprocessing constructor for detrending spectral data. The
constructor is intended to be passed to
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed via
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

## Usage

``` r
prep_detrend(p = 2)
```

## Arguments

- p:

  A positive integer specifying the polynomial order used for fitting.
  Must be \>= 1. Default is `2`.

## Value

An object of class `preprocessing` to be used in
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed by
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

## Details

For each spectrum, a polynomial of order `p` is fitted using the column
wavelengths as the explanatory variable (or integer indices if column
names are not numeric). The residuals from this fit are returned as the
detrended spectrum, removing wavelength-dependent baseline effects.

This constructor always performs pure polynomial detrending without a
prior SNV transformation. Users who want the full Barnes et al. (1989)
procedure (SNV followed by detrending) should chain
[`prep_snv`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_snv.md)
before `prep_detrend` in their recipe.

The computation is delegated to
[`detrend`](https://l-ramirez-lopez.github.io/prospectr/reference/detrend.html)
with `snv = FALSE`.

## References

Barnes RJ, Dhanoa MS, Lister SJ. 1989. Standard normal variate
transformation and de-trending of near-infrared diffuse reflectance
spectra. Applied Spectroscopy, 43(5): 772-777.

## See also

[`prep_snv`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_snv.md),
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md),
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)

## Author

Leonardo Ramirez-Lopez

## Examples

``` r
data("NIRcannabis")
X <- NIRcannabis$spc

# Pure polynomial detrend
dt <- prep_detrend(p = 2)
recipe <- preprocess_recipe(dt, device = "unspecified")
X_dt <- process(X, recipe)

# Barnes et al. (1989): SNV followed by detrend
recipe_barnes <- preprocess_recipe(
  prep_snv(), prep_detrend(p = 2),
  device = "unspecified"
)
X_barnes <- process(X, recipe_barnes)
```
