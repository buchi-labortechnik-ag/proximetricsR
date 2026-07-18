# A function for adding model metadata to a `spectral_model` object

This function has two use cases:

i\. If `object` (being a `spectral_model` object) is passed to the
function, it returns the same object with the specified model metadata
added to it.

ii\. Otherwise, the function creates a a list of model metadata that can
be used as input for the argument `metadata` of the
[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
function.

## Usage

``` r
add_model_metadata(object, key = UUIDgenerate(), created, changed,
                   name = c("", NULL), sort_order = 1, tol_min = NULL,
                   tol_max = NULL, decimal_places = 2, unit = "",
                   mahal_limit = 5, corrections = c(bias = 0, slope = 1),
                   limit_min = NULL, limit_max = NULL, target = NULL,
                   wavelength_range = c("Nir", "Vis", "Nir+Vis"),
                   predict_type = "Calibration", arguments = rep("", 4))
```

## Arguments

- object:

  an optional object of class `spectral_model`. See details.

- key:

  a string for the key of the model. Defaults to a newly generated key
  using
  [`UUIDgenerate`](https://rdrr.io/pkg/uuid/man/UUIDgenerate.html).

- created:

  a string for date and time of the addition of the model to the
  application. Default is the current date and time of the system. See
  details for the format in which it has to be provided.

- changed:

  a string for date and time when the model has been changed. Default is
  the current date and time of the system. See details for the format in
  which it has to be provided.

- name:

  a vector of character strings of length 2 for the name and alias of
  the property. If `object` is given or an object returned by this
  function is passed to
  [`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md),
  defaults to the name of the property (but not the alias). Otherwise,
  defaults to an empty character.

- sort_order:

  a numeric, indicating the order in which the properties are shown on a
  ProxiMate device. Defaults to 1.

- tol_min:

  an optional numeric for the minimum error tolerance. Defaults to
  `NULL`.

- tol_max:

  an optional numeric for the maximal error tolerance. Defaults to
  `NULL`.

- decimal_places:

  a numeric for the decimal precision of the measurements of the
  property. Defaults to 2.

- unit:

  a string for the units in which the reference values of the property
  are measured. Defaults to an empty character.

- mahal_limit:

  a numeric for the maximum Mahalanobis distance allowed. Defaults to 5.

- corrections:

  a vector of numerics of length 2 for bias and slope corrections.
  Defaults to no corrections, i.e. `c(0, 1)`.

- limit_min:

  an optional numeric for the lower limit of the reference values.
  Defaults to `NULL`.

- limit_max:

  an optional numeric for the upper limit of the reference values.
  Defaults to `NULL`.

- target:

  an optional numeric for the desired predicted reference values.
  Defaults to `NULL`.

- wavelength_range:

  a string for the considered wavelength range of the spectrum. Must be
  one of `"Nir"` (default), `"Vis"` or `"Nir+Vis"`.

- predict_type:

  a string for the prediction type of the model. Defaults to
  `"Calibration"`.

- arguments:

  a vector of maximal length 4. Contains additional arguments to be
  saved into the metadata. Defaults to a vector of empty characters of
  length 4.

## Value

Either the `spectral_model` object with the added property metadata (if
`object` is provided), or the property metadata, which is a named list.

## Details

This function has two functionalities:

- If `object` (being a `spectral_model` object) is passed to the
  function, it returns the same object with the specified property
  metadata added to it.

- Otherwise, the function creates a a list of property metadata that can
  be used as the argument `metadata` of the
  [`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
  function.

The two-fold functionality of this function allows to add metadata
during the construction of the model, or after the model-building has
been finished. For the former, the model has to be passed in `object`,
and the returned value of this function contains the model including the
chosen metadata. In the latter case, the returned value of this function
may be passed to the parameter `metadata` of function
[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md).

A lot of the parameters can be left unchanged and may be adjusted at a
later stage of the application development (e.g. in a ProxiMate device).

The parameters `created` and `changed` must contain the date
(`YYYY-MM-DD`) and time (`HH:MM:SS`), seperated by a single `"T"`
(without any spaces). For example, the following code returns the
correct format (also, both `created` and `changed` default to this
value):

`gsub(" ", "T", format(Sys.time()))`

## See also

[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md),
[`proximate_write_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_nax.md)

## Author

Claudio Orellano, Leonardo Ramirez-Lopez

## Examples

``` r
# \donttest{
data(NIRcannabis)

# Downview Absorbance of CBDA in percentage
downview_metadata <- add_model_metadata(
  name = "CBDA",
  unit = "%",
  arguments = "Example metadata"
)

# Three ways to add metadata to spectral_model object:
# As a direct argument
simple_model <- calibrate(CBDA ~ spc,
  data = NIRcannabis, preprocess = preprocess_recipe(),
  method = fit_plsr(5), control = calibration_control(),
  metadata = downview_metadata
)
#> Fitting model...
#> Cross-validating...
#>   |                                                                              |                                                                      |   0%  |                                                                              |-                                                                     |   1%  |                                                                              |-                                                                     |   2%  |                                                                              |--                                                                    |   3%  |                                                                              |---                                                                   |   4%  |                                                                              |----                                                                  |   5%  |                                                                              |----                                                                  |   6%  |                                                                              |-----                                                                 |   7%  |                                                                              |------                                                                |   8%  |                                                                              |------                                                                |   9%  |                                                                              |-------                                                               |  10%  |                                                                              |--------                                                              |  11%  |                                                                              |--------                                                              |  12%  |                                                                              |---------                                                             |  13%  |                                                                              |----------                                                            |  14%  |                                                                              |----------                                                            |  15%  |                                                                              |-----------                                                           |  16%  |                                                                              |------------                                                          |  17%  |                                                                              |-------------                                                         |  18%  |                                                                              |-------------                                                         |  19%  |                                                                              |--------------                                                        |  20%  |                                                                              |---------------                                                       |  21%  |                                                                              |---------------                                                       |  22%  |                                                                              |----------------                                                      |  23%  |                                                                              |-----------------                                                     |  24%  |                                                                              |------------------                                                    |  25%  |                                                                              |------------------                                                    |  26%  |                                                                              |-------------------                                                   |  27%  |                                                                              |--------------------                                                  |  28%  |                                                                              |--------------------                                                  |  29%  |                                                                              |---------------------                                                 |  30%  |                                                                              |----------------------                                                |  31%  |                                                                              |----------------------                                                |  32%  |                                                                              |-----------------------                                               |  33%  |                                                                              |------------------------                                              |  34%  |                                                                              |------------------------                                              |  35%  |                                                                              |-------------------------                                             |  36%  |                                                                              |--------------------------                                            |  37%  |                                                                              |---------------------------                                           |  38%  |                                                                              |---------------------------                                           |  39%  |                                                                              |----------------------------                                          |  40%  |                                                                              |-----------------------------                                         |  41%  |                                                                              |-----------------------------                                         |  42%  |                                                                              |------------------------------                                        |  43%  |                                                                              |-------------------------------                                       |  44%  |                                                                              |--------------------------------                                      |  45%  |                                                                              |--------------------------------                                      |  46%  |                                                                              |---------------------------------                                     |  47%  |                                                                              |----------------------------------                                    |  48%  |                                                                              |----------------------------------                                    |  49%  |                                                                              |-----------------------------------                                   |  50%  |                                                                              |------------------------------------                                  |  51%  |                                                                              |------------------------------------                                  |  52%  |                                                                              |-------------------------------------                                 |  53%  |                                                                              |--------------------------------------                                |  54%  |                                                                              |--------------------------------------                                |  55%  |                                                                              |---------------------------------------                               |  56%  |                                                                              |----------------------------------------                              |  57%  |                                                                              |-----------------------------------------                             |  58%  |                                                                              |-----------------------------------------                             |  59%  |                                                                              |------------------------------------------                            |  60%  |                                                                              |-------------------------------------------                           |  61%  |                                                                              |-------------------------------------------                           |  62%  |                                                                              |--------------------------------------------                          |  63%  |                                                                              |---------------------------------------------                         |  64%  |                                                                              |----------------------------------------------                        |  65%  |                                                                              |----------------------------------------------                        |  66%  |                                                                              |-----------------------------------------------                       |  67%  |                                                                              |------------------------------------------------                      |  68%  |                                                                              |------------------------------------------------                      |  69%  |                                                                              |-------------------------------------------------                     |  70%  |                                                                              |--------------------------------------------------                    |  71%  |                                                                              |--------------------------------------------------                    |  72%  |                                                                              |---------------------------------------------------                   |  73%  |                                                                              |----------------------------------------------------                  |  74%  |                                                                              |----------------------------------------------------                  |  75%  |                                                                              |-----------------------------------------------------                 |  76%  |                                                                              |------------------------------------------------------                |  77%  |                                                                              |-------------------------------------------------------               |  78%  |                                                                              |-------------------------------------------------------               |  79%  |                                                                              |--------------------------------------------------------              |  80%  |                                                                              |---------------------------------------------------------             |  81%  |                                                                              |---------------------------------------------------------             |  82%  |                                                                              |----------------------------------------------------------            |  83%  |                                                                              |-----------------------------------------------------------           |  84%  |                                                                              |------------------------------------------------------------          |  85%  |                                                                              |------------------------------------------------------------          |  86%  |                                                                              |-------------------------------------------------------------         |  87%  |                                                                              |--------------------------------------------------------------        |  88%  |                                                                              |--------------------------------------------------------------        |  89%  |                                                                              |---------------------------------------------------------------       |  90%  |                                                                              |----------------------------------------------------------------      |  91%  |                                                                              |----------------------------------------------------------------      |  92%  |                                                                              |-----------------------------------------------------------------     |  93%  |                                                                              |------------------------------------------------------------------    |  94%  |                                                                              |------------------------------------------------------------------    |  95%  |                                                                              |-------------------------------------------------------------------   |  96%  |                                                                              |--------------------------------------------------------------------  |  97%  |                                                                              |--------------------------------------------------------------------- |  98%  |                                                                              |--------------------------------------------------------------------- |  99%  |                                                                              |----------------------------------------------------------------------| 100%

# Passing the model to add_model_metadata
simple_model <- add_model_metadata(
  object = simple_model,
  name = "CBDA",
  unit = "%",
  arguments = "Example metadata"
)

# Adding it directly (not recommended)
simple_model$metadata <- downview_metadata
# }
```
