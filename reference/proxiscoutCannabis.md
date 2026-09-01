# proxiscoutCannabis

Selected samples of cannabis NIR measurements for demo purposes. Note
these samples are different from the ones in
[`proximateCannabis`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximateCannabis.md).
The dataset contains absorbance spectra of 192 cannabis samples measured
with three ProxiScout devices at the 257 standard ProxiScout
wavenumbers, ranging from 3921.569 \\cm^{-1}\\ to 7407.407 \\cm^{-1}\\
in steps of around 13.61655 \\cm^{-1}\\ (equivalent to a spectral range
of 1350 nm to 2550 nm), see
[`get_proxiscout_wavenumbers`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/get_proxiscout_wavenumbers.md).
A total number of eleven reference vectors is included: `"CBDA"`
(Cannabidiolic acid), `"CBG"` (Cannabigerol), `"CBD"` (Cannabidiol),
`"CBN"` (Cannabinol), `"THC"` (Tetrahydrocannabinol), `"THCA"`
(Tetrahydrocannabinolic acid), `"CBC"` (Cannabichromene), `"CBGA"`
(Cannabigerolic acid), `"CBD_total"` (total Cannabidiol), `"THC_total"`
(total Tetrahydrocannabinol) and `"CBGt"` (total Cannabigerol).

## Usage

``` r
data("proxiscoutCannabis")
```

## Format

A `data.frame` of class `"proxiscout_data"` containing 192 observations
of eleven response variables, with their corresponding spectral data.

## Source

BUCHI Labortechnik AG.

## Details

This dataset is an example for a typical data file for ProxiScout
applications, with a total of 192 cannabis samples, selected as a subset
of a larger database. It was obtained by reading a spectra file together
with its corresponding property file using
[`proxiscout_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proxiscout_read_data.md).
As the data contains 257 spectral columns, the object is of class
`"proxiscout_data"`.

Since the samples were measured with three different devices, the
dataset is also suitable for illustrating the grouped validation plots
of
[`calibrate_models`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate_models.md)
and
[`plot.spectral_model`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/plot.spectral_model.md),
using `deviceId` as the grouping variable.

The dataset contains one clear outlier, a single sample whose absorbance
is markedly higher than that of the rest of the set across the whole
spectral range. This is a legitimate measurement and has been retained
intentionally, as it is useful for demonstrating the detection of
outliers, for example with the leverage and spectral residual
diagnostics returned by
[`validate_prediction`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/validate_prediction.md).

It contains the following rows for each observation:

- **`sampleName`:** Characters for the name of the sample. Repeated
  scans of the same sample are indicated by a numerical suffix, see
  [`proxiscout_repetition_pattern`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proxiscout_repetition_pattern.md).

- **`deviceId`:** Characters of the identifier of the involved
  ProxiScout device.

- **`train`:** Logicals, indicating whether the particular observation
  belongs to the training set used for the construction of the model.

- **`type`:** Characters for the type of the sample.

- **`CBDA`:** Numerics for the reference values of Cannabidiolic acid.

- **`CBG`:** Numerics for the reference values of Cannabigerol.

- **`CBD`:** Numerics for the reference values of Cannabidiol.

- **`CBN`:** Numerics for the reference values of Cannabinol.

- **`THC`:** Numerics for the reference values of Tetrahydrocannabinol.

- **`THCA`:** Numerics for the reference values of
  Tetrahydrocannabinolic acid.

- **`CBC`:** Numerics for the reference values of Cannabichromene.

- **`CBGA`:** Numerics for the reference values of Cannabigerolic acid.

- **`CBD_total`:** Numerics for the reference values of total
  Cannabidiol.

- **`THC_total`:** Numerics for the reference values of total
  Tetrahydrocannabinol.

- **`CBGt`:** Numerics for the reference values of total Cannabigerol.

- **`.repetition_group`:** Integers identifying the rows that correspond
  to repeated scans of the same sample, added by
  [`proxiscout_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proxiscout_read_data.md).

- **`spc`:** A numerical matrix of the absorbance spectra, corresponding
  to each individual observation.

## See also

[`proximateCannabis`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximateCannabis.md)

## Author

Marçal Plans
