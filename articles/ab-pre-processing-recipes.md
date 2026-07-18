# Spectral pre-processing recipes

## 1 Overview

Spectral preprocessing is a critical step in near-infrared (NIR)
calibration workflows. Raw spectral data often contains systematic
variations, noise, and artifacts that can obscure the true relationship
between spectra and reference properties. The `proximetricsR` package
provides a flexible, composable system for building and applying
preprocessing pipelines.

### 1.1 Key concepts

- **Preprocessing constructors** (`prep_*()` functions): Create
  specifications for individual preprocessing steps
- **Preprocessing recipes**
  ([`preprocess_recipe()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)):
  Assemble multiple constructors into an ordered sequence
- **Recipe execution**
  ([`process()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)):
  Apply the recipe to spectral data matrices
- **Device compatibility**: Different devices (ProxiMate, ProxiScout)
  support different preprocessing algorithms

This separation of specification and execution enables reproducible,
device-aware preprocessing pipelines that can be stored, shared, and
applied consistently.

## 2 Setup

``` r

library("proximetricsR")
```

``` r

data("NIRcannabis")
X <- NIRcannabis$spc
```

## 3 Preprocessing constructors

The `prep_*()` functions create preprocessing step objects. Each
constructor validates its parameters and encodes algorithm-specific
information. The order in which constructors are passed to
[`preprocess_recipe()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
defines the execution order.

### 3.1 Resampling: `prep_resample()`

Resampling interpolates spectra to a new wavelength or wavenumber grid.

**ProxiMate mode** (user-defined grid):

``` r

prep_resample(grid = c(1001, 1700, 2))
```

    - prep_resample
        min_wav: 1001; max_wav: 1700; resolution: 2

**ProxiScout mode** (NeoSpectra standard grid):

``` r

prep_resample(grid = "proxiscout")
```

    - prep_resample 

Resampling is often the first step to standardize wavelength grids
across different instruments.

### 3.2 Smoothing: `prep_smooth()`

Smoothing reduces high-frequency noise while preserving spectral
features.

**Savitzky-Golay** (ProxiScout compatible):

``` r

prep_smooth(w = 11, p = 3, algorithm = "savitzky-golay")
```

    - prep_smooth
        w: 11; p: 3; algorithm: 'savitzky-golay'

**Moving average** (ProxiMate compatible):

``` r

prep_smooth(w = 7, algorithm = "moving-average")
```

    - prep_smooth
        w: 7; algorithm: 'moving-average'

- `w`: window size (must be a positive odd integer)
- `p`: polynomial order for Savitzky-Golay (must be \< w)

### 3.3 Standard Normal Variate: `prep_snv()`

SNV (Standard Normal Variate) normalizes each spectrum independently by
centering and scaling:

``` math
SNV_i = \frac{x_i - \bar{x}_i}{s_i}
```

where $`\bar{x}_i`$ and $`s_i`$ are the mean and standard deviation of
the $`i`$-th spectrum.

``` r

prep_snv()
```

    - prep_snv 

SNV corrects for multiplicative effects (e.g., baseline offsets, path
length variations) and is device-agnostic.

### 3.4 Derivatives: `prep_derivative()`

Derivatives enhance spectral differences and reduce baseline effects.

**Savitzky-Golay** (ProxiScout):

``` r

prep_derivative(m = 1, w = 11, p = 3, algorithm = "savitzky-golay")
```

    - prep_derivative
        m: 1; w: 11; p: 3; algorithm: 'savitzky-golay'

**Gap-Segment** (ProxiScout):

``` r

prep_derivative(m = 2, w = 9, p = 3, algorithm = "gap-segment")
```

    - prep_derivative
        m: 2; w: 9; p: 3; algorithm: 'gap-segment'

**NIRWise PLUS compatible** (ProxiMate):

``` r

prep_derivative(m = 1, w = 5, p = 11, algorithm = "nwp")
```

    - prep_derivative
        m: 1; w: 5; p: 11; algorithm: 'nwp'

Parameters: - `m`: derivative order (1 or 2) - `w`: window/gap size
(positive odd integer) - `p`: polynomial order (Savitzky-Golay) or
smoothing window (gap-segment, nwp) - `algorithm`: choice of method

### 3.5 Detrending: `prep_detrend()`

Detrending removes wavelength-dependent baseline effects by fitting and
removing a polynomial trend (ProxiScout only):

``` r

prep_detrend(p = 2)
```

    - prep_detrend
        p: 2

- `p`: polynomial order (default 2)

For the full Barnes et al. (1989) procedure (SNV + detrending), chain
[`prep_snv()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_snv.md)
before
[`prep_detrend()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_detrend.md).

### 3.6 Reflectance/Absorbance conversion: `prep_transform()`

Convert between reflectance and absorbance using Beer’s Law (ProxiScout
only):

``` math
A = -\log_{10}(R)
```

``` r

prep_transform(to = "absorbance")
```

    - prep_transform
        to: 'absorbance'

- `to`: target unit (`"absorbance"` or `"reflectance"`)

### 3.7 Wavelength trimming: `prep_wav_trim()`

Retain only a specified wavelength band and/or remove constant-valued
edge columns (ProxiScout only):

``` r

prep_wav_trim(band = c(1000, 1800), trim_constant_edges = TRUE)
```

    - prep_wav_trim
        band: 1000, 1800; trim_constant_edges: TRUE

- `band`: wavelength range to retain (or
  [`c()`](https://rdrr.io/r/base/c.html) to skip)
- `trim_constant_edges`: remove zero or constant-valued columns at edges

## 4 Building preprocessing recipes

The
[`preprocess_recipe()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
function combines constructors into an ordered pipeline. Order matters:
preprocessing steps are applied in the order specified.

### 4.1 Device compatibility

Different BUCHI devices support different preprocessing steps:

**ProxiMate** supports: -
[`prep_resample()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_resample.md)
with user-defined grids -
[`prep_smooth()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_smooth.md)
with moving-average algorithm -
[`prep_snv()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_snv.md) -
[`prep_derivative()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_derivative.md)
with nwp algorithm

**ProxiScout** supports: -
[`prep_resample()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_resample.md)
with “proxiscout” grid -
[`prep_smooth()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_smooth.md)
with savitzky-golay algorithm -
[`prep_snv()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_snv.md) -
[`prep_derivative()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_derivative.md)
with savitzky-golay or gap-segment algorithms -
[`prep_detrend()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_detrend.md) -
[`prep_transform()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_transform.md) -
[`prep_wav_trim()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_wav_trim.md)

### 4.2 Building recipes

**Single preprocessing step (SNV only):**

SNV is device-agnostic, so `device` is optional:

``` r

recipe_snv <- preprocess_recipe(prep_snv())
recipe_snv
```

    Spectral preprocessing recipe (device: "unspecified"):
     - Step 1: prep_snv

**Multiple steps (requires device):**

``` r

recipe_ps <- preprocess_recipe(
  prep_smooth(w = 7, p = 1, algorithm = "savitzky-golay"),
  prep_snv(),
  prep_derivative(m = 1, w = 5, p = 2, algorithm = "savitzky-golay"),
  device = "proxiscout"
)
recipe_ps
```

    Spectral preprocessing recipe (device: "proxiscout"):
     - Step 1: prep_smooth
        w: 7; p: 1; algorithm: 'savitzky-golay'
     - Step 2: prep_snv
     - Step 3: prep_derivative
        m: 1; w: 5; p: 2; algorithm: 'savitzky-golay'

**ProxiMate-specific recipe:**

``` r

recipe_pm <- preprocess_recipe(
  prep_smooth(w = 7, algorithm = "moving-average"),
  prep_snv(),
  prep_derivative(m = 1, w = 5, p = 11, algorithm = "nwp"),
  device = "proximate"
)
recipe_pm
```

    Spectral preprocessing recipe (device: "proximate"):
     - Step 1: prep_smooth
        w: 7; algorithm: 'moving-average'
     - Step 2: prep_snv
     - Step 3: prep_derivative
        m: 1; w: 5; p: 11; algorithm: 'nwp'

Recipes validate that all steps are compatible with the specified device
and raise informative errors if not.

## 5 Applying recipes with `process()`

The
[`process()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
function executes a recipe on spectral data:

``` r

X_snv <- process(X, recipe_snv)
dim(X_snv)
```

    [1]  80 234

``` r

X_ps <- process(X, recipe_ps)
dim(X_ps)
```

    [1]  80 224

The applied recipe is stored as an attribute and can be retrieved:

``` r

applied_recipe <- attr(X_ps, "preprocess_recipe")
applied_recipe
```

    Spectral preprocessing recipe (device: "proxiscout"):
     - Step 1: prep_smooth
        w: 7; p: 1; algorithm: 'savitzky-golay'
     - Step 2: prep_snv
     - Step 3: prep_derivative
        m: 1; w: 5; p: 2; algorithm: 'savitzky-golay'

## 6 Practical examples

### 6.1 Example 1: ProxiMate workflow

A typical ProxiMate workflow for fat/protein prediction:

``` r

recipe_pm_fat <- preprocess_recipe(
  prep_smooth(w = 7, algorithm = "moving-average"),
  prep_snv(),
  prep_derivative(m = 1, w = 5, p = 11, algorithm = "nwp"),
  device = "proximate"
)

X_fat_prep <- process(X, recipe_pm_fat)
head(X_fat_prep[, 1:5])
```

            1025    1028    1031    1034    1037
    [1,] -0.0137 -0.0138 -0.0138 -0.0135 -0.0131
    [2,] -0.0208 -0.0213 -0.0215 -0.0215 -0.0212
    [3,] -0.0184 -0.0186 -0.0187 -0.0185 -0.0181
    [4,] -0.0122 -0.0124 -0.0124 -0.0122 -0.0119
    [5,] -0.0170 -0.0171 -0.0170 -0.0167 -0.0161
    [6,] -0.0134 -0.0135 -0.0135 -0.0132 -0.0128

### 6.2 Example 2: ProxiScout workflow with detrending

ProxiScout instruments benefit from additional preprocessing steps:

``` r

recipe_ps_full <- preprocess_recipe(
  prep_resample(grid = "proxiscout"),
  prep_smooth(w = 7, p = 1, algorithm = "savitzky-golay"),
  prep_snv(),
  prep_detrend(p = 2),
  prep_derivative(m = 1, w = 5, p = 2, algorithm = "savitzky-golay"),
  device = "proxiscout"
)

X_ps_full <- process(X, recipe_ps_full)
dim(X_ps_full)
```

    [1]  80 102

### 6.3 Example 3: Minimal preprocessing

Sometimes less is more. A minimal recipe with only SNV:

``` r

recipe_minimal <- preprocess_recipe(prep_snv())
X_minimal <- process(X, recipe_minimal)
```

### 6.4 Example 4: Wavelength band selection

Select a specific wavelength range for ProxiScout:

``` r

recipe_band <- preprocess_recipe(
  prep_wav_trim(band = c(1100, 1600)),
  prep_smooth(w = 5, p = 1, algorithm = "savitzky-golay"),
  prep_snv(),
  device = "proxiscout"
)

X_band <- process(X, recipe_band)
colnames(X_band)[c(1, ncol(X_band))]
```

    [1] "1106" "1592"

## 7 Best practices

### 7.1 Order matters

Preprocessing steps affect each other. Common orderings:

1.  **Smoothing → SNV → Derivative** (standard for noise reduction +
    normalization + enhancement)
2.  **Resampling → Smoothing → Derivative → SNV** (device-specific
    resampling first)
3.  **SNV → Detrend** (full de-trending procedure)

### 7.2 Device-aware development

Always specify `device = "proximate"` or `device = "proxiscout"` when
building recipes (except for SNV-only recipes). This ensures recipes are
portable and the preprocessing is compatible with the target device.

### 7.3 Reproducibility

Store recipes alongside calibration models to ensure preprocessing is
applied identically during prediction. The
[`process()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
function attaches the recipe as an attribute for downstream tracking.

### 7.4 Parameter tuning

Preprocessing parameters are typically tuned during model development:

- Window sizes should be small relative to spectral features of interest
- Derivative orders depend on spectral complexity (first-order for
  baseline removal, second-order for sharper features)
- SNV is almost universally beneficial for multiplicative interference

## 8 Summary

The preprocessing recipe system in `proximetricsR` provides a
structured, reproducible approach to spectral preprocessing:

- **Constructors** define individual steps with validation
- **Recipes** compose steps into device-aware pipelines
- **Process** applies recipes consistently
- **Attributes** preserve recipe information for downstream use

This design enables seamless integration with calibration workflows and
ensures preprocessing is applied consistently from model development
through deployment on BUCHI devices.
