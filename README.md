

# `proximetricsR` Spectral preprocessing and chemometric calibration of near-infrared (NIR) sensors

[![R-CMD-check](https://github.com/buchi-labortechnik-ag/proximetricsR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/buchi-labortechnik-ag/proximetricsR/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/buchi-labortechnik-ag/proximetricsR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/buchi-labortechnik-ag/proximetricsR)
[![CRAN
status](https://www.r-pkg.org/badges/version/proximetricsR?v=2.png)](https://CRAN.R-project.org/package=proximetricsR)

<img align="right" src="./man/figures/logo.png" alt="proximetricsR logo" width="15%">

*Last update: 2026-07-19*

Version: 0.6.5 – Matterhorn2

## About

The `proximetricsR` package provides tools for developing, validating,
and deploying quantitative chemometric models for near-infrared (NIR)
spectroscopy, with dedicated support for BUCHI NIR sensors and
workflows.

The package implements partial least squares (PLS) regression and
related methods together with spectral preprocessing, model validation,
visualisation, and native support for BUCHI calibration and application
formats.

### Key features

- Spectral preprocessing and preprocessing pipelines

- Quantitative calibration using PLS-based methods

- Model validation, diagnostics, and uncertainty assessment

- Native support for BUCHI file formats and applications

- Publication-ready visualisation tools

## Installation

Install the development version from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("l-ramirez-lopez/proximetricsr")
```

Requires R ≥ 4.2.0 and compilation tools (C++ via Rcpp and
RcppArmadillo).

## A couple of examples

``` r
library(proximetricsR)

data("NIRcannabis")
# the list of formulas for the models to be built
app_formulas <- list(THC ~ spc, THCA ~ spc, CBD ~ spc, CBDA ~ spc)

# the list of pre-processing recipes to be tested
precipes <- list(
  recipe_1 = preprocess_recipe(
    prep_resample(grid = c(1001, 1700, 2)),
    prep_snv(),
    prep_derivative(m = 1, w = 9, p = 7, algorithm = "nwp"),
    device = "proximate"
  ),
  recipe_2 = preprocess_recipe(
    prep_resample(grid = c(1001, 1700, 2)),
    prep_snv(),
    prep_derivative(m = 2, w = 11, p = 9, algorithm = "nwp"),
    device = "proximate"
  )
)

optimized_app <- calibrate_models(
  formulas = app_formulas,
  data = NIRcannabis,
  preprocess_recipes = precipes,
  methods = list(fit_plsr(15, type = "nwp")),
  return_inputs = TRUE,
  save_all = FALSE
)
```

``` r
optimized_app
```

    Grid search results: 
           formula recipe min property max property ncomp   rsq  rmse
    1   THC ~ spc       1       0.0136         5.44     2 0.532 0.679
    2 * THC ~ spc       2       0.0136         5.44     3 0.690 0.578
    3   THCA ~ spc      1       0.0200        12.13     7 0.780 1.539
    4 * THCA ~ spc      2       0.0200        12.13     6 0.820 1.407
    5   CBD ~ spc       1       0.0262         5.89     1 0.148 0.675
    6 * CBD ~ spc       2       0.0262         5.89     1 0.175 0.668
    7   CBDA ~ spc      1       0.0100        24.64     4 0.684 3.454
    8 * CBDA ~ spc      2       0.0100        24.64     2 0.682 3.431
      largest_residual rsq_sd rmse_sd largest_residual_sd outliers    method
    1             1.87 0.1112   0.171               0.978        0 PLS (nwp)
    2             1.67 0.1025   0.191               1.047        0 PLS (nwp)
    3             4.27 0.1033   0.366               1.323        0 PLS (nwp)
    4             3.63 0.0726   0.265               0.944        0 PLS (nwp)
    5             2.17 0.0849   0.301               1.599        0 PLS (nwp)
    6             2.18 0.0734   0.300               1.573        0 PLS (nwp)
    7            11.37 0.2049   1.312               6.147        0 PLS (nwp)
    8            11.66 0.2310   1.477               6.749        0 PLS (nwp)
     
    *best model 
    ---
    Suggested models: 
    Model:  THC ~ spc 
    Spectral preprocessing recipe (device: "proximate"): 
     - Step 1: prep_resample
        min_wav: 1001; max_wav: 1700; resolution: 2
     - Step 2: prep_snv
     - Step 3: prep_derivative
        m: 2; w: 11; p: 9; algorithm: 'nwp'
    Method:  PLS (nwp) 

    Model:  THCA ~ spc 
    Spectral preprocessing recipe (device: "proximate"): 
     - Step 1: prep_resample
        min_wav: 1001; max_wav: 1700; resolution: 2
     - Step 2: prep_snv
     - Step 3: prep_derivative
        m: 2; w: 11; p: 9; algorithm: 'nwp'
    Method:  PLS (nwp) 

    Model:  CBD ~ spc 
    Spectral preprocessing recipe (device: "proximate"): 
     - Step 1: prep_resample
        min_wav: 1001; max_wav: 1700; resolution: 2
     - Step 2: prep_snv
     - Step 3: prep_derivative
        m: 2; w: 11; p: 9; algorithm: 'nwp'
    Method:  PLS (nwp) 

    Model:  CBDA ~ spc 
    Spectral preprocessing recipe (device: "proximate"): 
     - Step 1: prep_resample
        min_wav: 1001; max_wav: 1700; resolution: 2
     - Step 2: prep_snv
     - Step 3: prep_derivative
        m: 2; w: 11; p: 9; algorithm: 'nwp'
    Method:  PLS (nwp) 

## Core functionality

### Spectral preprocessing

A collection of preprocessing methods is available through functions
with the `prep_*` prefix. The `preprocess_recipe()` framework enables
the construction of reproducible preprocessing pipelines that can be
applied consistently during calibration and prediction.

Supported operations include:

- Spectral resampling
- Savitzky-Golay smoothing and derivatives
- Standard normal variate (SNV)
- Detrending
- Gap-segment derivatives
- Transformations and scaling

### Model calibration

The package supports multiple regression approaches, including:

- Partial least squares (PLS)
- Modified PLS (MPLS)
- NIRWise PLUS-compatible workflows
- XLS variants

The `calibrate_models()` function enables automated calibration,
parameter optimisation, and model comparison using a range of
cross-validation strategies.

### Model validation and visualisation

Built-in tools support:

- Model performance assessment

- Outlier detection

- Uncertainty estimation

- Model interpretation

Publication-ready diagnostic plots can be generated using
`plot.spectral_model()`.

### BUCHI ProxiMate & ProxiScout integration

`proximetricsR` implements algorithms that are numerically consistent
with BUCHI NIRWise PLUS software, enabling reproducible workflows
between R and production BUCHI devices.

Key capabilities include:

- **Native file I/O:** Read and write ProxiMate and ProxiScout formats
  (`.cal`, `.prj`, `.nax`, `.rtf`, `.nad`, `.tsv`)

- **Application bundles:** Create deployable `.nax` applications
  containing calibration models, preprocessing metadata, and
  device-specific parameters

- **Sensor-aware workflows:** Support preprocessing and calibration
  workflows tailored to BUCHI sensor characteristics

- **Cross-software reproducibility:** Develop and validate models in R
  and deploy them directly to BUCHI instruments without
  re-parameterisation

## Documentation

For a complete overview of available vignettes:

``` r
browseVignettes("proximetricsR")
```

Additional documentation can be accessed through:

``` r
help(package = "proximetricsR")
```

## References

- Wold, S. (1975). Pattern recognition by means of disjoint principal
  components models. *Pattern Recognition*, 8(3), 127–139.
  [doi:10.1016/B978-0-12-103950-9.50017-4](https://doi.org/10.1016/B978-0-12-103950-9.50017-4)

- Shenk, J. S., & Westerhaus, M. O. (1991). The application of near
  infrared reflectance spectroscopy (NIRS) to compositional analysis of
  agricultural products. *Crop Science*, 31(2), 409–413.
  [doi:10.2135/cropsci1991.0011183X003100020049x](https://doi.org/10.2135/cropsci1991.0011183X003100020049x)

- Westerhaus, M. O. (2014). Eastern Analytical Symposium Award for
  outstanding innovations in near infrared spectroscopy. *NIR News*,
  25(7), 7–10.
  [doi:10.1255/nirn.1492](https://doi.org/10.1255/nirn.1492)

## Support

For bug reports, feature requests, and discussions, please create an
issue on GitHub:

https://github.com/buchi-labortechnik-ag/proximetricsR/issues

For questions, contact:

<ramirez-lopez.l@buchi.com>
