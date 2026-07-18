# Write a calibration model to ProxiScout JSON format

Serializes a model of class `spectral_model` (including its
preprocessing recipe) into a JSON format that can be imported into the
NeoSpectra NIR Hub and deployed on ProxiScout sensors (see Details).

## Usage

``` r
proxiscout_write_model(object, file = NULL)
```

## Arguments

- object:

  an object of class `spectral_model` that contains the preprocessing
  recipe and final model to be serialized.

- file:

  an optional character string with the path (including file name) where
  the JSON output should be written. If `NULL` (default), no file is
  written and the JSON string is returned. If a path is provided, the
  JSON is written to that file and returned invisibly.

## Value

If `file = NULL` (default), the JSON string is returned visibly so it
can be inspected or assigned to a variable. If `file` is specified, the
JSON string is written to that file and returned invisibly (i.e. it is
not printed to the console, following the standard R convention for
functions called primarily for their side effect).

## Details

The JSON output produced by this function can be imported into the
[NeoSpectra NIR
Hub](https://www.buchi.com/en/products/services/software-apps/neospectra-platform/neospectra-nir-hub)
and used within a ProxiScout application. Once imported, the [NeoSpectra
Scan mobile
app](https://play.google.com/store/apps/details?id=com.neospectrascanapp)
linked to a ProxiScout sensor can access the model and use it to compute
and display spectral predictions.

The JSON pipeline always begins with two hardware-specific steps that
are added automatically, regardless of the preprocessing recipe in
`object`: (1) scaling raw reflectance from the 0–100 range reported by
the sensor to the 0–1 range, and (2) averaging repeated scans of the
same sample. These steps precede any user-defined preprocessing.

**Constraints and supported preprocessing steps:**

- The first step in the preprocessing recipe of `object` must be
  [`prep_resample`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_resample.md),
  as wavenumber alignment with the ProxiScout hardware grid is required.

- All predictor wavenumbers in `object` must match the hardware
  wavenumbers returned by
  [`get_proxiscout_wavenumbers`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/get_proxiscout_wavenumbers.md)
  within a tolerance of 0.1 \\\mathrm{cm}^{-1}\\.

- [`prep_derivative`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_derivative.md)
  and
  [`prep_smooth`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_smooth.md)
  are supported only when `algorithm = "savitzky-golay"`.

- [`prep_transform`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_transform.md)
  is supported only with `to = "absorbance"`; using `to = "reflectance"`
  generates a warning and the step is skipped in the JSON output.

- [`prep_wav_trim`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_wav_trim.md)
  is handled implicitly through wavenumber selection and does not
  produce an explicit JSON step.

## See also

[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md),
[`get_proxiscout_wavenumbers`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/get_proxiscout_wavenumbers.md),
[`prep_resample`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_resample.md)

## Author

Leonardo Ramirez-Lopez and Claudio Orellano

## Examples

``` r
# \donttest{
data("NIRcannabis")
control <- calibration_control(
  validation_type = "kfold", number = 3, folds = "sequential"
)
recipe <- preprocess_recipe(
  prep_resample(grid = "proxiscout"),
  prep_snv(),
  prep_derivative(m = 1, w = 11, p = 2, algorithm = "savitzky-golay"),
  device = "proxiscout"
)
model <- calibrate(
  THCA ~ spc,
  data = NIRcannabis, preprocess = recipe,
  method = fit_plsr(10), control = control, verbose = FALSE
)

json_model <- proxiscout_write_model(model)
json_model
#> [
#>   {
#>     "id": 31,
#>     "params": [],
#>     "index": 0
#>   },
#>   {
#>     "id": 17,
#>     "params": [],
#>     "index": 1
#>   },
#>   {
#>     "id": 37,
#>     "params": [
#>       0.01
#>     ],
#>     "index": 2
#>   },
#>   {
#>     "id": 7,
#>     "params": [
#>       -1
#>     ],
#>     "index": 3
#>   },
#>   {
#>     "id": 2,
#>     "params": [],
#>     "index": 4
#>   },
#>   {
#>     "id": 83,
#>     "params": [
#>       11,
#>       2,
#>       1,
#>       119,
#>       1,
#>       0,
#>       0.04545455,
#>       0.03636364,
#>       0.02727273,
#>       0.01818182,
#>       0.00909091,
#>       0,
#>       -0.00909091,
#>       -0.01818182,
#>       -0.02727273,
#>       -0.03636364,
#>       -0.04545455
#>     ],
#>     "index": 5
#>   },
#>   {
#>     "id": 43,
#>     "params": [
#>       -0.102273,
#>       -0.0907732,
#>       -0.0763295,
#>       -0.0632138,
#>       -0.0499773,
#>       -0.0353521,
#>       -0.0213131,
#>       -0.0092391,
#>       -0.0013105,
#>       0.0034121,
#>       0.0055347,
#>       0.0056329,
#>       0.0046678,
#>       0.0033569,
#>       0.0017648,
#>       0.0015121,
#>       0.0039736,
#>       0.009024,
#>       0.0138633,
#>       0.0174156,
#>       0.0191244,
#>       0.0196891,
#>       0.0195376,
#>       0.0189616,
#>       0.0171723,
#>       0.0147463,
#>       0.0114254,
#>       0.0079267,
#>       0.0055011,
#>       0.0033556,
#>       0.0028502,
#>       0.0030638,
#>       0.0043409,
#>       0.0069101,
#>       0.010433,
#>       0.0139148,
#>       0.0177576,
#>       0.0209348,
#>       0.0232349,
#>       0.0253177,
#>       0.0264064,
#>       0.027732,
#>       0.0288326,
#>       0.0292486,
#>       0.0296291,
#>       0.0291798,
#>       0.0278943,
#>       0.0264863,
#>       0.0246505,
#>       0.0223128,
#>       0.0194736,
#>       0.0157953,
#>       0.0123941,
#>       0.0096378,
#>       0.0068069,
#>       0.0044473,
#>       0.0026961,
#>       0.0010024,
#>       -0.0005791,
#>       -0.0020655,
#>       -0.0038647,
#>       -0.0059111,
#>       -0.0086224,
#>       -0.0117048,
#>       -0.0145798,
#>       -0.0181028,
#>       -0.0219842,
#>       -0.026221,
#>       -0.0312533,
#>       -0.0371999,
#>       -0.0442143,
#>       -0.0526027,
#>       -0.0618039,
#>       -0.0718304,
#>       -0.0825513,
#>       -0.0927731,
#>       -0.1026513,
#>       -0.111732,
#>       -0.1193412,
#>       -0.1251777,
#>       -0.129066,
#>       -0.1308572,
#>       -0.1304374,
#>       -0.1280815,
#>       -0.1242743,
#>       -0.1196033,
#>       -0.1145723,
#>       -0.109846,
#>       -0.1059977,
#>       -0.1024634,
#>       -0.0990306,
#>       -0.0955964,
#>       -0.0916525,
#>       -0.0866373,
#>       -0.0813509,
#>       -0.075854,
#>       -0.0701482,
#>       -0.0648085,
#>       -0.060281,
#>       -0.0570349,
#>       -0.0553388,
#>       -0.0545218
#>     ],
#>     "index": 6
#>   },
#>   {
#>     "id": 13,
#>     "params": [
#>       2.0169989,
#>       -15.261234,
#>       -20.51668,
#>       -15.7895938,
#>       -33.8157179,
#>       -56.2463357,
#>       -48.1046024,
#>       -36.7541356,
#>       -19.9403905,
#>       -3.966786,
#>       9.2771085,
#>       12.6235967,
#>       12.7457436,
#>       16.220968,
#>       17.3632306,
#>       18.5929958,
#>       19.8598643,
#>       20.5361046,
#>       11.5571639,
#>       -13.0061111,
#>       -35.3505313,
#>       -39.6864551,
#>       -39.2732564,
#>       -33.8731772,
#>       -23.3918983,
#>       -11.24804,
#>       0.518172,
#>       11.9718874,
#>       22.2460342,
#>       29.1129496,
#>       31.5977514,
#>       26.5209973,
#>       17.0800078,
#>       3.4518202,
#>       -10.9455808,
#>       -21.8931748,
#>       -31.4448171,
#>       -37.3630821,
#>       -40.4646612,
#>       -41.8154065,
#>       -40.0014277,
#>       -34.8303311,
#>       -25.6986973,
#>       -14.9120473,
#>       -5.7375089,
#>       -0.6576609,
#>       0.7489282,
#>       -3.5393139,
#>       -10.4182045,
#>       -15.4987121,
#>       -18.206531,
#>       -13.2512518,
#>       -2.5811684,
#>       8.4334779,
#>       17.7291943,
#>       24.7829415,
#>       29.9682378,
#>       33.3570327,
#>       33.8518814,
#>       30.264651,
#>       24.7823238,
#>       15.889411,
#>       5.2906579,
#>       -4.4514661,
#>       -13.7238453,
#>       -19.7730569,
#>       -26.1177779,
#>       -30.8215947,
#>       -35.1769618,
#>       -39.5613252,
#>       -44.0480397,
#>       -42.6495894,
#>       -34.7745189,
#>       -24.3109184,
#>       -13.3918847,
#>       -3.8570914,
#>       1.798431,
#>       0.4745361,
#>       -5.2730989,
#>       -7.472966,
#>       1.7220821,
#>       13.1941904,
#>       18.7977329,
#>       17.5400041,
#>       13.548676,
#>       9.9671526,
#>       6.6524457,
#>       1.0897575,
#>       -8.5131004,
#>       -19.8788505,
#>       -28.0114726,
#>       -32.1175537,
#>       -30.5197037,
#>       -18.3215896,
#>       -3.2070119,
#>       2.4217111,
#>       3.4712657,
#>       2.4067036,
#>       -1.8046108,
#>       -10.9038535,
#>       -27.0212038,
#>       -50.2079464,
#>       -71.039035
#>     ],
#>     "index": 7
#>   }
#> ] 

proxiscout_write_model(model, file = file.path(tempdir(), "my_model.json"))
# }
```
