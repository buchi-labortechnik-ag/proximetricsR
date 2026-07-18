# ProxiScout: Building applications

## 1 Introduction

ProxiScout applications consist of calibrated predictive models packaged
in a device-compatible format. Unlike ProxiMate’s file-based structure
(.nax, .cal, .prj), ProxiScout applications use JSON-based serialization
synchronized through the NeoSpectra Portal.

A typical ProxiScout workflow involves:

1.  Loading and preparing spectral data

2.  Building and validating calibration models

3.  Preprocessing configuration matching device algorithms

4.  Exporting models in ProxiScout-compatible format

See the ProxiScout Structure vignette for detailed information on
application file formats and metadata.

## 2 Setup

``` r

library("proximetricsR")
```

## 3 Workflow overview

### 3.1 Prepare spectral data

Load your spectral data. Data should include:

- Spectral matrix (samples × wavenumbers)

- Reference property values (calibration targets)

- Sample metadata (optional)

Here, a demo dataset from the `prospectr` package ([Stevens and
Ramirez-Lopez 2026](#ref-prospectr2026)). This is used in these examples
as it covers all the spectral regions measured by ProxiScout devices:

``` r

data("NIRsoil", package = "prospectr")

# NIRsoil is in nanometers and absorbance
mdata <- data.frame(
  sampleName = rownames(NIRsoil), 
  Ciso = NIRsoil$Ciso, 
  Nt = NIRsoil$Nt,
  CEC = NIRsoil$CEC
)

# ProxiScout data comes in reflectance in percentages, so we convert to 
# reflectance and scale to 0-100 range
mdata$spc <- 100 * 1 / 10^(NIRsoil$spc)

# Get wavelengths and convert from nm to wavenumbers (cm^-1)
wav_nm <- as.numeric(colnames(mdata$spc))
wav_cm <- 10000000 / wav_nm

# Update column names to wavenumbers for ProxiScout compatibility
colnames(mdata$spc) <- wav_cm

head(colnames(mdata$spc))
```

    [1] "9090.90909090909" "9074.41016333938" "9057.97101449275" "9041.59132007233"
    [5] "9025.27075812274" "9009.00900900901"

``` r

class(mdata) <- c("proxiscout_data", class(mdata))
```

ProxiScout works with wavenumbers (cm⁻¹) in the NeoSpectra range
(~3922-7407 cm⁻¹). The NIRsoil data spans ~400-2500 nm (4000-25000
cm⁻¹), but resampling to the ProxiScout grid will retain only
overlapping wavenumbers.

### 3.2 Define preprocessing recipe

ProxiScout supports device-specific preprocessing via the NeoSpectra
wavenumber grid. Define your preprocessing sequence:

``` r

recipe_01 <- preprocess_recipe(
  prep_resample(grid = "proxiscout"), # necessary for almost all ProxiScout recipe
  prep_derivative(m = 2, w = 9, p = 2, algorithm = "savitzky-golay"),
  prep_snv(),
  device = "proxiscout"
)

recipe_01
```

    Spectral preprocessing recipe (device: "proxiscout"):
     - Step 1: prep_resample
     - Step 2: prep_derivative
        m: 2; w: 9; p: 2; algorithm: 'savitzky-golay'
     - Step 3: prep_snv

Key points: - `prep_resample(grid = "proxiscout")` resamples to the
standard NeoSpectra wavenumber grid, retaining only overlapping
wavenumbers

- Smoothing uses Savitzky-Golay (not moving-average)

- Derivatives support Savitzky-Golay or gap-segment algorithms

- Additional steps like
  [`prep_detrend()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_detrend.md),
  [`prep_transform()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_transform.md),
  and
  [`prep_wav_trim()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_wav_trim.md)
  are available

- Data is already in absorbance, so no conversion needed

### 3.3 Build calibration model

#### 3.3.1 Example 1: Build a single model

Apply preprocessing and build the model:

``` r

model_c <- calibrate(
  Ciso ~ spc,
  data = mdata,
  preprocess = recipe_01,
  method = fit_plsr(ncomp = 12, type = "modified"),
  control = calibration_control(
    validation_type = "kfold",
    number = 5,
    seed = 42
  ),
  verbose = FALSE
)
```

Check model performance:

``` r

model_c
```

``` r

plot(model_c)
```

##### 3.3.1.1 Serialize the model for deployment

The model can be exported to ProxiScout format for deployment. Here we
can see how that model is serialized:

``` r

my_serialised_model_c <- proxiscout_write_model(model_c, file = NULL)
my_serialised_model_c
```

To write the json file:

``` r

proxiscout_write_model(model_c, file = "my_model_c.json")
```

#### 3.3.2 Example 2: Build multiple models at once testing different pre-processings

To test multiple preprocessing recipes and build multiple models at
once, use the
[`calibrate_models()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate_models.md)
function. This function allows you to specify a list of formulas,
preprocessing recipes, and modeling methods to systematically evaluate
different combinations.

Here is an example of how to build multiple models at once:

First, build the list of formulas representing the calibration models we
need to build:

``` r

my_formulas <- list(Ciso ~ spc, CEC ~ spc)
```

Now let’s define multiple preprocessing recipes to test. For example, we
can compare the performance of a simple derivative-based recipe with a
more complex one that includes wavenumber trimming:

``` r

recipe_02 <- preprocess_recipe(
  prep_resample(grid = "proxiscout"),
  prep_derivative(m = 1, w = 7, p = 2, algorithm = "savitzky-golay"),
  device = "proxiscout"
)

recipe_03 <- preprocess_recipe(
  prep_resample(grid = "proxiscout"),
  prep_wav_trim(
    band = c(4000, 7000),
    trim_constant_edges = TRUE
  ),
  prep_derivative(m = 1, w = 7, p = 2, algorithm = "savitzky-golay"),
  device = "proxiscout"
)

my_recipes <- list(recipe_01, recipe_02, recipe_03)
```

Define the multiple model fitting methods:

``` r

my_fitting <- list(
  fit_plsr(ncomp = 12, type = "modified"), 
  fit_plsr(ncomp = 10, type = "standard")
)
```

Then, define the how to control the validations. This object will be
used for all the models we are going to build:

``` r

my_control <- calibration_control(
    validation_type = "kfold",
    number = 5,
    remove_outliers = 1,
    seed = 42
)
```

Finally, build all the models at once:

``` r

multiple_models <- calibrate_models(
  formulas = my_formulas,
  data = mdata, 
  preprocess_recipes = my_recipes,
  methods = my_fitting,
  control = my_control,
  save_all = TRUE
)
```

``` r

multiple_models
```

    Grid search results:
           formula recipe min property max property ncomp  rsq rmse
    1 * Ciso ~ spc      1          0.1         9.72     6 0.81 0.52
    2   Ciso ~ spc      2          0.1         8.03     5 0.69 0.69
    3   Ciso ~ spc      3          0.1         8.03     5 0.69 0.67
    4 * CEC ~ spc       1          1.4        39.00     6 0.62 2.92
    5   CEC ~ spc       2          1.0        38.90     7 0.61 3.03
    6   CEC ~ spc       3          1.0        38.90     7 0.62 2.97
      largest_residual outliers         method
    1             3.38       35 PLS (standard)
    2             3.62       34 PLS (modified)
    3             3.44       38 PLS (modified)
    4            11.24       21 PLS (modified)
    5            14.40       22 PLS (standard)
    6            11.82       23 PLS (standard)

    *best model
    ---
    Suggested models:
    Model:  Ciso ~ spc
    Spectral preprocessing recipe (device: "proxiscout"):
     - Step 1: prep_resample
     - Step 2: prep_derivative
        m: 2; w: 9; p: 2; algorithm: 'savitzky-golay'
     - Step 3: prep_snv
    Method:  PLS (standard)

    Model:  CEC ~ spc
    Spectral preprocessing recipe (device: "proxiscout"):
     - Step 1: prep_resample
     - Step 2: prep_derivative
        m: 2; w: 9; p: 2; algorithm: 'savitzky-golay'
     - Step 3: prep_snv
    Method:  PLS (modified) 

##### 3.3.2.1 Serialize the multiple models for deployment

``` r

proxiscout_write_model(
  multiple_models$final_models$`Ciso ~ spc`, file = "my_model_c2.json"
)

proxiscout_write_model(
  multiple_models$final_models$`CEC ~ spc`, file = "my_model_cec.json"
)
```

### 3.4 Export for ProxiScout

Once satisfied with model performance, export to ProxiScout format.
Refer to the Structure vignette for export details.

## 4 Device-specific considerations

**NeoSpectra wavenumber grid:** ProxiScout instruments measure at fixed
wavenumber positions. Always resample to `"proxiscout"` grid when
building models for deployment.

**Algorithm selection:** Choose from:

- Smoothing: Savitzky-Golay only

- Derivatives: Savitzky-Golay or gap-segment

- Additional: detrending, reflectance/absorbance conversion

**Advanced preprocessing:** ProxiScout’s broader algorithm support
allows more flexible preprocessing pipelines compared to ProxiMate.

## References

Stevens, Antoine, and Leornardo Ramirez-Lopez. 2026. *An Introduction to
the Prospectr Package*.
