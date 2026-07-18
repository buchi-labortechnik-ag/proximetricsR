# Build and execute spectral preprocessing recipes

The `preprocess_recipe` function assembles an ordered sequence of
preprocessing steps into a recipe, while `process` executes the recipe
on a spectral data matrix.

## Usage

``` r
preprocess_recipe(..., device)

process(X, recipe, device)
```

## Arguments

- ...:

  one or more objects of class `preprocessing` as returned by any of the
  following constructor functions:

  - [`prep_resample`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_resample.md)

  - [`prep_smooth`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_smooth.md)

  - [`prep_snv`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_snv.md)

  - [`prep_derivative`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_derivative.md)

  - [`prep_detrend`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_detrend.md)

  - [`prep_transform`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_transform.md)

  - [`prep_wav_trim`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_wav_trim.md)

  The order in which the objects are provided defines the order of
  execution. If no arguments are provided, an empty recipe is returned
  and `process` will return the input data unchanged.

- device:

  a character string specifying the target device: `"unspecified"` (no
  validation), `"proximate"`, or `"proxiscout"`. When `"proximate"` or
  `"proxiscout"` is specified, `preprocess_recipe` validates that all
  steps are compatible with that device and raises an informative error
  if not. Pass `"unspecified"` to skip validation explicitly.

  `device` is required whenever the recipe contains any preprocessing
  step, with one exception: a recipe containing only a single
  [`prep_snv`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_snv.md)
  step does not require `device`, because SNV is device-agnostic
  (identical behaviour for both `"proximate"` and `"proxiscout"`). In
  that case `device` defaults to `"unspecified"`.

- X:

  a numeric matrix of spectral data to be preprocessed (samples in rows,
  wavelengths in columns).

- recipe:

  an object of class `preprocess_recipe` as returned by
  `preprocess_recipe`. A single object of class `preprocessing` is also
  accepted and treated as a one-step recipe.

## Value

For `preprocess_recipe`, an object of class `preprocess_recipe` with
three components: `steps` (the ordered list of preprocessing step
objects), `device` (the target device string), and `preprocessing_order`
(a simplified string summarising the sequence of applied
transformations).

For `process`, a numeric matrix of preprocessed spectral data. The
applied recipe is stored as the attribute `"preprocess_recipe"` on the
returned matrix and can be retrieved with
`attr(result, "preprocess_recipe")`.

## See also

[`prep_smooth`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_smooth.md),
[`prep_snv`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_snv.md),
[`prep_derivative`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_derivative.md),
[`prep_resample`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_resample.md),
[`prep_detrend`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_detrend.md),
[`prep_transform`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_transform.md),
[`prep_wav_trim`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_wav_trim.md)

## Author

Leonardo Ramirez-Lopez

## Examples

``` r
data("NIRcannabis")
X <- NIRcannabis$spc

# SNV alone — no device needed (SNV is device-agnostic)
recipe_snv <- preprocess_recipe(prep_snv())
X_snv <- process(X, recipe_snv)

# Any other combination requires device
recipe <- preprocess_recipe(
  prep_smooth(w = 7, p = 1, algorithm = "savitzky-golay"),
  prep_snv(),
  prep_derivative(m = 1, w = 5, p = 2, algorithm = "savitzky-golay"),
  device = "proxiscout"
)

X_proc <- process(X, recipe)
attr(X_proc, "preprocess_recipe")
#> Spectral preprocessing recipe (device: "proxiscout"): 
#>  - Step 1: prep_smooth
#>     w: 7; p: 1; algorithm: 'savitzky-golay'
#>  - Step 2: prep_snv
#>  - Step 3: prep_derivative
#>     m: 1; w: 5; p: 2; algorithm: 'savitzky-golay'
```
