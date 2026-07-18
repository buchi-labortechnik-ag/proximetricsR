# Reflectance/absorbance conversion constructor for spectral preprocessing

Creates a preprocessing constructor for converting spectral data between
reflectance and absorbance. The constructor is intended to be passed to
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed via
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

## Usage

``` r
prep_transform(to = c("absorbance", "reflectance"))
```

## Arguments

- to:

  A character string specifying the target unit. Either `"absorbance"`
  (default) or `"reflectance"`.

## Value

An object of class `preprocessing` to be used in
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed by
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

## Details

Conversion follows Beer's Law:

\\A = -\log\_{10}(R)\\

where \\A\\ is absorbance and \\R\\ is reflectance.

When converting to absorbance, all values in `X` must be strictly
positive. A warning is issued if the resulting absorbance contains small
negative values, which may indicate precision or scaling issues in the
input.

Note that no check is performed on whether the input is actually in the
expected unit (the transformation is applied as specified).

## See also

[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md),
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)

## Author

Leonardo Ramirez-Lopez

## Examples

``` r
data("NIRcannabis")
X <- NIRcannabis$spc # absorbance

tr <- prep_transform(to = "reflectance")
recipe <- preprocess_recipe(tr, device = "proxiscout")
X_ref <- process(X, recipe)
```
