# Computes the NIRWise QVAL statistic

QVAL indicates how different the predicted response variable (y) in
cross-validation deviates from the fitted version of y (i.e. the fitted
y values obtained when all calibration observations are used to fit the
model).

## Usage

``` r
.calibration_statistics(
  y,
  fitted_y,
  predicted_y_in_cv = NULL,
  scaled_scores,
  ncomp
)
```

## Arguments

- y:

  a matrix of one column with the response variable.

- fitted_y:

  a matrix with the estimated response variable for each component.

- predicted_y_in_cv:

  the cross-validation estimates of the response variable for every
  component.

- scaled_scores:

  a matrix of the scaled scores of the model.

- ncomp:

  a vector for each included component.

## Value

A list containing calibration statistics including residuals, predicted
values, Mahalanobis distance, and Q-values.

## See also

[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
