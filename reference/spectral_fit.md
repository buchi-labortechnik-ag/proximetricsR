# The spectral_fit class

An object of class `spectral_fit` represents a fitted PLS or XLS
regression model for a single component sequence. It is produced
internally by
[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
and is accessible via `object$final_model$model`.

A `spectral_fit` object is a list with the following elements:

- **`method`:** The `fit_constructor` object passed to the fitting call.
  See
  [`fit_plsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md)
  and
  [`fit_xlsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md).

- **`explained_variance`:** A list with two matrices: `x_variance`
  (three rows: `pls_var`, `x_expl_var`, `x_expl_var_cum` - absolute,
  relative, and cumulative relative explained variance of X per
  component) and `y_variance` (relative explained variance of the
  response per component).

- **`x_means`:** Named numeric vector of column means of the input
  spectral matrix `X`.

- **`weights`:** Matrix of PLS weights (one row per component).

- **`scores`:** Matrix of scores (one column per component).

- **`sd_scores`:** Named numeric vector of standard deviations for each
  score column.

- **`scaled_scores`:** Matrix of scores scaled by their standard
  deviations.

- **`x_loadings`:** Matrix of X loadings (one row per component).

- **`projection_m`:** Projection matrix that maps new spectra onto the
  score space.

- **`intercept`:** Named numeric scalar; the intercept of the regression
  model (equal to the mean of `Y`).

- **`coefficients`:** Matrix of regression coefficients (one row per
  component, one column per wavelength).

- **`fitted_y`:** Matrix of fitted response values (one column per
  component).

- **`cal_error`:** Matrix with three columns: number of components, root
  mean squared error of calibration, and largest residual.

- **`x_residuals`:** Matrix of spectral residuals (one column per
  component).

- **`n_observations`:** Integer; number of observations used for
  fitting.

- **`y_quantiles`:** Named numeric vector of the 0th, 25th, 50th, 75th,
  and 100th percentiles of the response `Y`.

## See also

[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md),
[`fit_plsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md),
[`fit_xlsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md)

## Author

Leonardo Ramirez-Lopez and Claudio Orellano
