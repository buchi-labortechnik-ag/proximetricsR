# Validate predictions of class `'spectral_prediction'`

Calculate several prediction validation statistics for a prediction of
class `'spectral_prediction'`.

## Usage

``` r
validate_prediction(prediction, reference)
```

## Arguments

- prediction:

  an object of class `'spectral_prediction'`, as returned by the
  [`predict`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
  function.

- reference:

  a vector or a matrix with one column, containing the response
  variable.

## Value

An object of class `"spectral_validation"`, which is a list containing
the following validation statistics of the prediction:

- **`model_information`:** A list containing information of the model on
  which the predictions are based. Mirrors the very same list contained
  in the `prediction`. See
  [`predict`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
  for more details.

- **`validation`:** A list with the validation statistics. For each
  prediction contained in `prediction` (which are based on the number of
  components), one entry in the list is added. Each of these elements
  exactly one matrix and one vector: `val_results` contains the
  predicted values and the corresponding errors in a matrix, while
  `val_stats` is a vector consisting of the coefficient of determination
  (\\R^2\\), root mean squared error (`RMSE`) and the largest residual
  obtained. These statistics are computed based on the `prediction` and
  `reference`, while ignoring any `NA`'s.

## Author

Claudio Orellano

## Examples

``` r
data("NIRcannabis")
skips <- c(10, 25, 37)
simple_model <- calibrate(CBDA ~ spc,
  data = NIRcannabis, preprocess = preprocess_recipe(),
  method = fit_plsr(5), control = calibration_control("kfold"),
  skips = skips, verbose = FALSE
)

# Predict the skipped indices
pred <- predict(simple_model,
  newdata = NIRcannabis[skips, ],
  ncomp = simple_model$final_ncomp,
  verbose = FALSE
)

# Validate skipped indices
validate_prediction(pred, NIRcannabis$CBDA[skips])
#> Validating response: CBDA 
#> Number of validated predictions: 3 
#> Number of validations: 1 
#> Number of components (nc): 5 
#> ________________________________________________________________________________ 
#> 
#>    y    | nc_5 y_hat  error 
#> 10 7.59 |       9.457 -1.867
#> 25 0.03 |      -0.851  0.881
#> 37 9.77 |      14.070 -4.302
#> ________________________________________________________________________________ 
#> Comparison of model and validation statistics:
#> 
#>           | nc_5 val    model 
#> R^2       |      0.992  0.486 
#> RMSE      |      3.374  4.379 
#> max_error |      -4.302 19.590
#> ________________________________________________________________________________ 
```
