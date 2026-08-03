# Write the model info into a JSON for ProxiScout devices

Writes a JSON for the provided `object` that contains information about
the model, in the style of ProxiScout devices.

## Usage

``` r
proxiscout_write_model_info(object, n_measurements = 1L, file = NULL)
```

## Arguments

- object:

  An object of class `spectral_model` that contains the preprocessing
  recipe and final model details.

- n_measurements:

  An integer for the number of measurements. This value is directly
  written into the JSON as both the `numberOfMeasurements` and
  `avgReadings`, and represents the number of measurements that were
  taken in the original data per sample. Default is `1`.

- file:

  an optional character string with the path (including the filename)
  where the JSON output should be written. If `NULL` (default), the JSON
  string is returned.

## Value

If `file` is `NULL`, the JSON is returned visibly, otherwise, the JSON
is written to the path specified by `file` and the JSON is returned
invisibly.
