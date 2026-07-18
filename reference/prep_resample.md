# Resampling constructor for spectral preprocessing

Creates a preprocessing constructor for resampling spectral data to a
new wavelength grid. The constructor is intended to be passed to
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed via
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

## Usage

``` r
prep_resample(grid)
```

## Arguments

- grid:

  Either a numeric vector of length 3 specifying the target wavelength
  grid as `c(min_wav, max_wav, resolution)`, or the character string
  `"proxiscout"` to resample to the standard NeoSpectra wavenumber grid
  (see Details).

  When `grid` is a numeric vector:

  - `grid[1]` (`min_wav`): minimum wavelength of the target grid.

  - `grid[2]` (`max_wav`): maximum wavelength; must be greater than
    `min_wav`.

  - `grid[3]` (`resolution`): spacing between wavelengths; must be
    positive.

  Extrapolation beyond the range of the input wavelengths is never
  allowed.

## Value

An object of class `preprocessing` to be used in
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed by
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

## Details

**User-defined grid** (`grid = c(min_wav, max_wav, resolution)`):
resamples spectra to the specified target grid using natural spline
interpolation via
[`resample`](https://l-ramirez-lopez.github.io/prospectr/reference/resample.html).
Column names of `X` must be coercible to numeric wavelength values. This
mode is compatible with the `"proximate"` device.

**NeoSpectra grid** (`grid = "proxiscout"`): resamples spectra to the
standard wavenumber grid of NeoSpectra NIR scanners (approx. 3921.569 to
7407.407 \\cm^{-1}\\, ~256 channels at ~13.617 \\cm^{-1}\\ steps). Only
wavenumbers overlapping with the input range are retained. This mode is
compatible with the `"proxiscout"` device.

## See also

[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md),
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md),
[`get_proxiscout_wavenumbers`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/get_proxiscout_wavenumbers.md)

## Author

Leonardo Ramirez-Lopez and Claudio Orellano

## Examples

``` r
data("NIRcannabis")
X <- NIRcannabis$spc

# User-defined grid (proximate)
rs <- prep_resample(grid = c(1001, 1700, 2))
recipe <- preprocess_recipe(rs, device = "proximate")
X_rs <- process(X, recipe)
```
