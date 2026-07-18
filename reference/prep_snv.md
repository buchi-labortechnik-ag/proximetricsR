# Standard Normal Variate constructor for spectral preprocessing

Creates a preprocessing constructor for applying Standard Normal Variate
(SNV) normalisation to spectral data. The constructor is intended to be
passed to
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed via
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

## Usage

``` r
prep_snv()
```

## Value

An object of class `preprocessing` to be used in
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed by
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

## Details

SNV normalises each spectrum row-wise by subtracting its mean and
dividing by its standard deviation:

\\SNV_i = \frac{x_i - \bar{x}\_i}{s_i}\\

where \\x_i\\ is the signal of the \\i\\th observation, \\\bar{x}\_i\\
is its mean and \\s_i\\ its standard deviation. Implemented via
[`standardNormalVariate`](https://l-ramirez-lopez.github.io/prospectr/reference/standardNormalVariate.html).

## References

Barnes RJ, Dhanoa MS, Lister SJ. 1989. Standard normal variate
transformation and de-trending of near-infrared diffuse reflectance
spectra. Applied spectroscopy, 43(5): 772-777.

## See also

[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md),
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)

## Author

Leonardo Ramirez-Lopez with code from Antoine Stevens

## Examples

``` r
data("NIRcannabis")
X <- NIRcannabis$spc

snv <- prep_snv()
recipe <- preprocess_recipe(snv)
X_snv <- process(X, recipe)
```
