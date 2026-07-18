# ProxiScout standard wavenumbers

Returns the standard wavenumbers used by ProxiScout NIR scanners.

## Usage

``` r
get_proxiscout_wavenumbers()
```

## Value

A numeric vector containing the standard wavenumbers of ProxiScout NIR
scanners.

## Details

The standard wavenumbers of ProxiScout (see <https://www.si-ware.com/>)
NIR scanners range from approximately 3921.569 \\cm^{-1}\\ to 7407.407
\\cm^{-1}\\ in steps (resolution) of around 13.61655 \\cm^{-1}\\. This
is equivalent to a spectral range of 1350 to 2550 nm, with a varying
resolution that starts from 2.486189 nm at 1350 nm and ends with a
resolution of 8.823525 nm at 2550 nm.

## Examples

``` r
# Get the complete set of ProxiScout wavenumbers
wavs <- get_proxiscout_wavenumbers()

# Get the corresponding wavelengths (nm)
wavelengths_nm <- 10000000 / wavs

# Display the range of wavenumbers
range(wavs)
#> [1] 3921.569 7407.407
```
