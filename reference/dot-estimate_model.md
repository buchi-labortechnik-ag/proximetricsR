# A method for estimating the model

Compute partial least squares (PLS) or extended partial least squares
(XLS) regression models for a response variable and its associated set
of predictors based on the methods available in the BUCHI NIRWise PLUS
calibration software.

## Usage

``` r
.estimate_model(X, Y, method = fit_plsr(ncomp = min(15, dim(X))))
# S3 method for class 'spectral_fit'
predict(object, newdata, ...)
```

## Arguments

- X:

  a numeric matrix of spectral data.

- Y:

  a matrix of one column with the response variable.

- method:

  an object of class `fit_constructor` specifying the regression method,
  as returned by
  [`fit_plsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md)
  or
  [`fit_xlsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md).

- object:

  an object of class `spectral_fit`.

- newdata:

  a matrix containing new spectral data.

- ...:

  not currently used.

## Value

For `.estimate_model`, an object of class `spectral_fit`, which is a
list with the following elements:

- **`method`:** A character specifying the method used to obtain the
  regression model.

- **`explained_variance`:** A list containing two matrices:

  - **`x_variance`:** A numerical matrix containing the variance
    explained by each component with respect to X. Contains the
    following rows:  
    `"pls_var"`, the absolute explained variance of X for each included
    component;  
    `x_expl_var`, the relative explained variance of X for each included
    component;  
    and `x_expl_var_cum`, the cumulated relative explained variance of X
    for each component.

  - **`y_variance`:**A numerical matrix of one row, containing the
    relative explained variance of the reference values `Y`.

- **`x_means`:** A numerical matrix of one row, containing the means of
  the columns of input `X`.

- **`weights`:** A numerical matrix containing the weights.

- **`scores`:** A numerical matrix with the scores.

- **`sd_scores`:** A vector of standard deviations for each column in
  the matrix of scores.

- **`scaled_scores`:** A numerical matrix containing the scores scaled
  by their standard deviations.

- **`x_loadings`:** A numerical matrix of loadings.

- **`projection_m`:** A numerical matrix of projections. It can be used
  to project new spectral data onto the score space.

- **`intercept`:** A numeric for the intercept of the model. It is
  defined by the mean of the reference values `Y`.

- **`coefficients`:** A numerical matrix of regression coefficients.

- **`fitted_y`:** A numerical matrix containing the fitted values
  corresponding to the reference values `Y` for each component.

- **`cal_error`:** A numerical matrix, containing the estimated error
  statistics for each component. Contains 3 columns: the number of
  included components, the root mean squared error of calibration for
  each components, and the largest obtained residuals.

- **`x_residuals`:** A numerical matrix containing the spectral
  residuals obtained for each component.

- **`n_observations`:** A single numerical, indicating the number of
  observations used for regression.

- **`y_quantiles`:** A numerical vector containing the quantiles of the
  reference values `Y`.

For `predict`, a list with one element:

- **`predictions`:** A numerical matrix of the predicted values of the
  response variable.

## Details

The regression method (PLS or XLS) and its parameters are controlled
entirely through the `method` argument. See
[`fit_plsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md)
and
[`fit_xlsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md)
for the available methods and their options.

## See also

[`fit_plsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md),
[`fit_xlsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md),
[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)

## Author

Leonardo Ramirez-Lopez and Claudio Orellano
