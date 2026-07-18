# A function for adding application metadata to a list of `spectral_model` objects

This function has two use cases:

i\. If `object` (a list of `spectral_model` objects) is passed to the
function, it returns the same object with the specified application
metadata added to it.

ii\. Otherwise, the function can be used to create a list of application
metadata that can be used as input for the argument `metadata` of the
[`proximate_write_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_nax.md)
function.

## Usage

``` r
add_application_metadata(object, key = UUIDgenerate(),
                         name = c(name = "Untitled", alias = NULL),
                         view = c("Up", "Down"), 
                         measurement_mode = c("DrIwr", "TrIwr"),
                         measurement_time = 15,
                         absorbmask_low = c(min = 0, max = 0),
                         absorbmask_high = c(min = 0, max = 0),
                         rotate_sample = TRUE,
                         selectable = TRUE, created, changed,
                         composition = NULL,
                         description = "created with proximetricsR",
                         sop = "",
                         presentation_id = "Default")
```

## Arguments

- object:

  an optional object, consisting of a list of objects of class
  `spectral_model`. See details.

- key:

  a string for the key of the application. Defaults to a newly generated
  key using
  [`UUIDgenerate`](https://rdrr.io/pkg/uuid/man/UUIDgenerate.html).

- name:

  a vector length at most 2, consisting of characters for the name and
  alias of the application. Defaults to `"Untitled"`.

- view:

  a string for the type of view in the application. Has to be either
  `"Up"` (default) or `"Down"`.

- measurement_mode:

  a string, indicating how the samples were measured. Has to be either
  Diffuse Reflection (`"DrIwr"`, default) or Transflection (`"TrIwr"`).

- measurement_time:

  a numeric for the time each sample in the application should be
  measured, in seconds. Defaults to 15 seconds.

- absorbmask_low:

  a vector of numerics of length 2 for the minimum and maximum of the
  lower absorbance mask. Defaults to a vector of zeros.

- absorbmask_high:

  a vector of numerics of length 2 for the minimum and maximum of the
  higher absorbance mask. Defaults to a vector of zeros.

- rotate_sample:

  a logical. Should the sample be rotated? Defaults to `TRUE`.

- selectable:

  a logical, whether the application should be selectable. Defaults to
  `TRUE`.

- created:

  a string of date and time of the creation of the application. Default
  is the current date and time of the system. See details for the format
  in which it has to be provided.

- changed:

  a string of date and time when the application was changed. Defaults
  to the current date and time of the system. See details for the format
  in which it has to be provided.

- composition:

  an optional string for the composition of the application. Defaults to
  `NULL`.

- description:

  an optional string for the description of the application. Defaults to
  `"created with proximetricsR"`.

- sop:

  a string for the standard operating procedure (sop) for this
  particular application. Defaults to an empty character.

- presentation_id:

  a string for the sample presentation ID of the application. Default is
  `"Default"`.

## Value

Either the list of `spectral_model` objects with the added application
metadata (if `object` is provided), or the application metadata as a
named list.

## Details

This function has two functionalities:

- If `object` (a list of `spectral_model` objects) is passed to the
  function, it returns the same object with the specified application
  metadata added to it.

- Otherwise, the function can be used to create a list of application
  metadata that can be used as input for the argument `metadata` of the
  [`proximate_write_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_nax.md)
  function.

The application metadata is required for the import of an application
into a ProxiMate device.

The two-fold functionality of this function allows to add application
metadata during the construction of the models, or after the
model-building processes have been finished. In the former case, a list
of models of class `spectral_model` must be passed in `object`. Then,
the returned object of this function contains the same list of models,
including the specified metadata. Models can also be added or removed
from that list, without changing the application metadata. In the latter
case, the returned value of this function may be passed to the parameter
`metadata` of function
[`proximate_write_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_nax.md).

A lot of the parameters can be left unchanged and may be adjusted at a
later stage of the application development (e.g. in a ProxiMate device).
However, several parameters are of great importance for a successful
migration of the application:

The parameter `view` describes if the spectrum is measured by either
up-view `"Up"` or down-view `"Down"`.

The `measurement_mode` describes how the samples are measured, with the
following possibilities: Diffuse Reflection `"DrIwr"` or Transflection
`"TrIwr"`.

The parameters `created` and `changed` must contain the date
(`YYYY-MM-DD`) and time (`HH:MM:SS`), seperated by a single `"T"`
(without any spaces). For example, the following code returns the
correct format (both `created` and `changed` default to this value):

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
downview_metadata <- add_application_metadata(
  name = "CBDA Downview",
  view = "Down",
  measurement_mode = "DrIwr"
)

# Create a simple model with default model metadata
simple_model <- calibrate(CBDA ~ spc,
  data = NIRcannabis, preprocess = preprocess_recipe(),
  method = fit_plsr(5), control = calibration_control(),
  metadata = add_model_metadata(), verbose = FALSE
)

# Two ways to add application metadata to a list of spectral_model objects:
model_list <- list(simple_model)

# Using the add_application_metadata 'object' argument
model_list <- add_application_metadata(
  object = model_list,
  name = "CBDA Downview",
  view = "Down",
  measurement_mode = "TrIwr"
)

# Adding it manually
model_list$metadata <- downview_metadata

# Alternatively, if you are creating an application, you can also pass
# application metadata to 'proximate_write_nax':
proximate_write_nax(
  object = model_list,
  path = tempdir(),
  metadata = downview_metadata,
  tsv_name = "some_tsv",
  empty_tsv_name = "another_tsv",
  report = TRUE,
  verbose = FALSE
)
# }
```
