# NIRWise PLUS modeling methods (basic)

internal function

## Usage

``` r
.calibrate_basic(
  X,
  Y,
  group = NULL,
  method = fit_plsr(ncomp = min(15, dim(X))),
  control = calibration_control(),
  return_inputs = TRUE,
  sample_labels = NULL,
  verbose = TRUE
)
```

## Value

An internal object containing the fitted model and validation results.
