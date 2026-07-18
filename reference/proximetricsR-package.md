# Overview of the proximetricsR package

NIR calibration and application tools for BUCHI ProxiMate and ProxiScout
devices.

## Details

This is package version 0.6.5 (Matterhorn2).

This package provides `R` functions for spectral pre-processing, NIR
model calibration, and reading/writing files for BUCHI ProxiMate and
ProxiScout devices. The calibration algorithms
([`fit_plsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md),
[`fit_xlsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md))
and the pre-treatment constructors
([`prep_smooth`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_smooth.md),
[`prep_snv`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_snv.md),
[`prep_resample`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_resample.md),
[`prep_derivative`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_derivative.md))
reproduce the corresponding algorithms in BUCHI NIRWise PLUS (version
1.1.3000.0), guaranteeing numerical compatibility between models built
with this package and those built in NIRWise PLUS.

The ProxiScout functions for preprocessing are also numerically
equivalent to the ones of the "BUCHI Modeller" software. The regression
method in te Modeller is teh classical PLS regression, however, the
other PLS algorithms implemented in proximetricsR (modified PLS,
standard PLS, and XLS) can also be used to generate models for
ProxiScout devices.

The functions available for ProxiMate spectral data are:

- [`proximate_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_read_data.md)

- [`proximate_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_data.md)

- [`proximate_merge`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_merge.md)

The functions available for reading generic spectral data files are:

- [`read_spc`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/read_spc.md)

The functions available for spectral pre-processing are:

- [`prep_resample`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_resample.md)

- [`prep_smooth`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_smooth.md)

- [`prep_snv`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_snv.md)

- [`prep_derivative`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_derivative.md)

- [`prep_detrend`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_detrend.md)

- [`prep_transform`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_transform.md)

- [`prep_wav_trim`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_wav_trim.md)

- [`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)

- [`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)

The functions available for calibrating NIR regression models are:

- [`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)

- [`calibrate_models`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate_models.md)

- [`calibration_control`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibration_control.md)

- [`fit_plsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md)

- [`fit_xlsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md)

- [`add_model_metadata`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/add_model_metadata.md)

- [`validate_prediction`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/validate_prediction.md)

The functions available for writing ProxiMate files are:

- [`proximate_write_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_data.md)

- [`proximate_write_model`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_model.md)

- [`add_application_metadata`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/add_application_metadata.md)

- [`proximate_write_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_nax.md)

The functions available for reading and editing ProxiMate application
files are:

- [`proximate_read_cal`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_read_cal.md)

- [`proximate_read_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_read_nax.md)

- [`proximate_recalibrate_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_recalibrate_nax.md)

- [`proximate_add2nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_add2nax.md)

The functions available for ProxiScout devices are:

- [`proxiscout_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proxiscout_read_data.md)

- [`proxiscout_write_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proxiscout_write_data.md)

- [`proxiscout_write_model`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proxiscout_write_model.md)

- [`get_proxiscout_wavenumbers`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/get_proxiscout_wavenumbers.md)

- [`proxiscout_repetition_pattern`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proxiscout_repetition_pattern.md)

The functions available for creating plots are:

- [`plot.spectral_model`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/plot.spectral_model.md)

Other functions:

- [`extract_property_names`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/extract_property_names.md)

A typical example dataset for a ProxiMate device can be found in:

- [`NIRcannabis`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/NIRcannabis.md)

## See also

Useful links:

- <https://buchi-labortechnik-ag.github.io/proximetricsR/https://github.com/l-ramirez-lopez/proximetricsr>

- Report bugs at
  <https://github.com/buchi-labortechnik-ag/proximetricsr/issues>

## Author

Leonardo Ramirez-Lopez, Claudio Orellano, Nicolae Cudlenco, Mai Said,
Mohamed Abushosha, Marcal Plans
