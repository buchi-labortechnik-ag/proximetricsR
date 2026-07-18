# Calibrate a spectral model

Produce calibrations for predictive partial least squares (pls) or
extended partial least squares (xls) models using cross-validation and
outlier detection. Reproduces the modeling methods in NIRWise PLUS
calibration software.

## Usage

``` r
# S3 method for class 'formula'
calibrate(formula, data, group = NULL,
          preprocess = preprocess_recipe(prep_snv()),
          method,
          metadata = NULL,
          return_inputs = TRUE,
          ...,
          na_action = na.pass)

# Default S3 method
calibrate(X, Y, data = NULL, group = NULL,
          preprocess = preprocess_recipe(prep_snv()),
          method = fit_plsr(ncomp = min(15, dim(X))),
          control = calibration_control(),
          metadata = NULL,
          skip_indices = NULL,
          return_inputs = TRUE,
          verbose = TRUE,
          ...)

# S3 method for class 'spectral_model'
predict(object, newdata, ncomp = object$final_ncomp, verbose = TRUE, ...)
```

## Arguments

- ...:

  not currently used.

- formula:

  an object of class [`formula`](https://rdrr.io/r/stats/formula.html)
  which represents the basic model to be calibrated.

- data:

  a data.frame containing the data of the variables in the model. Must
  be provided if using S3 method for class
  [`formula`](https://rdrr.io/r/stats/formula.html). Otherwise,
  optional; however, if using
  [`proximate_write_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_nax.md)
  for the returned object, this parameter will be required.

- X:

  a numeric matrix of spectral data. The names of the columns must be
  equivalent to wavelengths, such that they can be coerced to class
  numeric.

- Y:

  a matrix of one column with the response variable. The column must be
  named.

- group:

  an optional factor (or character vector that can be coerced to
  [`factor`](https://rdrr.io/r/base/factor.html) by `as.factor`) that
  assigns a group/class label to each observation in `X` (e.g. groups
  can be given by spectra collected from the same batch of measurements,
  from the same observation, from observations with very similar origin,
  etc). This is taken into account for cross-validation for pls tuning
  (factor optimization) to avoid pseudo- replication. When one
  observation is selected for cross-validation, all observations of the
  same group are removed and assigned to validation. The length of the
  vector must be equal to the number of observations in `X`.

- preprocess:

  a `preprocess_recipe` object as returned by the
  [`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
  function, indicating the pretreatments to be applied on the spectra
  before the regression steps.

- method:

  an object of class `fit_constructor`, as returned by
  [`fit_plsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md)
  or
  [`fit_xlsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md),
  indicating what type of regression method to use along with its
  parameters.

- control:

  a `calibration_control` object as returned by the
  [`calibration_control`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibration_control.md)
  function, indicating how some aspects of the calibration process must
  be conducted (e.g. cross-validation and outlier detection).

- metadata:

  either `NULL` or an object as returned by method
  [`add_model_metadata`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/add_model_metadata.md).
  Contains the specifications for the metadata of the model. Defaults to
  `NULL`.

- skip_indices:

  a vector of integers for the indices in the input data to be skipped
  for the regression. Defaults to `NULL`

- return_inputs:

  a logical. For `calibrate` methods, indicates if the input data should
  be attached to the returned object. Note that this data is crucial for
  creating an application file.

- verbose:

  a logical indicating whether or not to print a progress bar for the
  iterations of the validation along with messages of the execution of
  the cross-validation. For the predict method, messages about the
  progress are printed. Default is `TRUE`. Note: In case parallel
  processing is used, these progress bars are not printed.

- object:

  an object of class `spectral_model`.

- newdata:

  a data.frame containing the new spectral data of the variables in the
  model, of similar form as `data`. Alternatively, can also be a matrix
  of spectra.

- ncomp:

  a vector for the number of components to be used in the prediction.
  Default is `object$final_ncomp` i.e. the optimized number of
  components found in the object passed to `predict`.

- na_action:

  a function to specify the action to be taken if `NA`s are found in the
  object passed in `data`. Default is
  [`na.pass`](https://rdrr.io/r/stats/na.fail.html).

## Value

For `calibrate()`, an object of class `spectral_model` which is a list
with the following elements:

- **`formula`**: The formula used (only output if the S3 method for
  class `'formula'` was used).

- **`dataclasses`**: The data classes in the model (only output if the
  S3 method for class `'formula'` was used).

- **`target_variable`**: A character for the name of the target/response
  variable for which the predictive model was built.

- **`predictor_variables`**: A character vector for names of the
  predictor variables (wavelengths) used to build the model.

- **`final_model`**: A list with:

  - **`model_cv`**: A list of cross-validation results.

  - **`ncomp`**: The number of components used for the model. If
    cross-validation is used, this is the optimal number of components
    for the chosen tuning parameter and learning rates (see
    [`calibration_control`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibration_control.md)).

  - **`model`**: An object of class `spectral_fit`. See
    [`spectral_fit`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/spectral_fit.md)
    for the full structure.

  - **`calibration_statistics`**: A matrix showing the prediction
    statistics for each calibration sample for the optimal number of
    components used in the model (if cross-validation is used, see
    [`calibration_control`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibration_control.md)).
    It contains the following columns:

    - **`Sample_index`**: The indices of the samples.

    - **`Target`**: The target/response variable of the samples.

    - **`fitted_y`**: The fitted values of the model of each sample.
      This row is equivalent to the row of the optimal component of
      `fitted_y` inside the fitted model in `model`.

    - **`residual`**: The residuals of the fitted values of each sample.
      Note that the residuals are obtained as the difference of targets
      and fitted values.

    - **`predicted_y_in_cv`**: The predicted values as computed in the
      cross-validation. Only available for k-fold and leave-one-out
      cross-validation.

    - **`cv_residual`**: The residuals of the predicted values of the
      cross-validation. Only available for k-fold and leave-one-out
      cross-validation.

    - **`Mahalanobis`**: The squared Mahalanobis distance of each sample
      in the score space to the origin.

    - **`Q_value`**: The Q-value of each sample. See details

  - **`calibration_statistics_all`**: A list of matrices with the same
    information as in `calibration_statistics`, but for all components.

  - **`detected_outliers_all`**: A list of lists, each containing the
    same information as in the `detected_outliers$model_*` mentioned
    below, but for all components in the fitted model.

- **`detected_outliers`**: A named list, containing the following
  entries:

  - **`model_*`**: A named list, containing all detected outliers of the
    particular model, identified based on the calibration residual limit
    (`"calibration"`), the Mahalanobis distance limit (`"Mahalanobis"`),
    and the validation residual limit (`"validation"`). The number of
    such `model_*` entries depends on the number selected in
    `remove_outliers` of the `control` argument; if it is selected to be
    `0`, then only one model is fitted, so only `model_1` exists; for
    higher choices of `remove_outliers`, the number of models of this
    list is at most `remove_outliers + 1`: for every time a model is
    fitted, a new entry in the `detected_outliers` is generated.

  - **`all`**: A named list, containing all detected outliers of all
    models produced, similarly to `model_*`. In particular, this entry
    is the combination of all detected outliers in the `model_*` entries
    of the list, where the specific type of outlier is retained.

  - **`removed`**: A single vector, containing all removed outliers of
    the final model. This vector is empty whenever the `remove_outliers`
    of the `control` argument is set to 0 or if no outlier has been
    found. Otherwise, this vector is a combination of all different
    outliers that were removed whenever a new model has been fitted,
    while ignoring the specific type of the outlier. In particular, in
    case the last model still contains at least one outlier, this vector
    is a combination of all but the last entry of the `model_*` lists.
    If the last fitted model does not contain any outlier, this vector
    is a combination of all `model_*` lists, and hence the vectorized
    form of the `all` entry of the list.

  See
  [`calibration_control`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibration_control.md)
  for more information on the limits and the outlier removal procedure.

- **`initial_fit`**: A list similar to `final_model`, but before any
  outliers were removed. Only stored if outlier removal is requested
  (i.e. `remove_outliers` in the `control` argument is larger than 0).
  In that case, the model here contains only the very first model that
  was fitted without any detected outliers removed.

- **`final_ncomp`**: An integer, indicating the final/optimal number of
  components to be used.

- **`preprocess`**: A `preprocess_recipe` object mirroring the input of
  the `preprocess` argument.

- **`processed_wavs`**: A `processed_wavs` object providing the spectral
  variables that existed in the data right before each preprocessing
  step.

- **`method`**: A `fit_constructor` object mirroring the input of the
  `method` argument.

- **`control`**: A `calibration_control` object mirroring the input of
  the `control` argument.

- **`preprocessed_X`**: The preprocessed spectral data for the
  observations of the final model. Spectra with missing values, skipped
  indices and removed outliers are discarded from the matrix.

- **`skipped_indices`**: A list with two objects:

  - **`missing_response`**: A vector of indices of observations with
    missing response values.

  - **`manually_skipped`**: A vector of indices mirroring the input of
    the `skip_indices` argument.

- **`input_data`**: A list, which is only returned if `return_inputs` is
  set to `TRUE`. Mirrors the input of the `data` argument.

For [`predict()`](https://rdrr.io/r/stats/predict.html), the output is
an object of class `spectral_prediction`, which is a list with the
following elements:

- **`predictions`**: A matrix with the predictions of the response
  variable using the new spectral data (`newdata`), based on the
  provided model (`object`). Contains only the predictions of the
  requested number of components (`ncomp`).

- **`scores`**: A matrix with the projected new data onto the score
  space of the provided model. Contains the scores of all possible
  number of components.

- **`model_information`**: A list, containing information on the model
  input of `object`:

  - **`target_var`**: A character, indicating the name of the target
    variable.

  - **`preprocess_recipe`**: A character, indicating the spectral
    preprocessing recipe and its order.

  - **`model_grid`**: A matrix, containing the grid of the model object,
    such as the coefficient of determination and the RMSE of the
    validation for the requested number of components.

  - **`unit`**: A character, indicating the units of the model.

  - **`opt_comp`**: An integer, signifying the optimal number of
    components as computed by the validation process of the model.

## Details

The resulting object of the `calibrate` functions provides a complete
list of calibration results.

By using the `group` argument one can specify groups of observations
that have something in common (e.g. observations with very similar
origin). The purpose of `group` is to avoid biased cross-validation
results due to pseudo-replication. This argument allows to select
calibration points that are independent from the validation ones. In
this regard, the `p` argument used in object passed to `control` (and
created with the
[`calibration_control`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibration_control.md)
function), refers to the percentage of groups of observations (rather
than single observations) to be retained in each sampling iteration.

The regression algorithms implemented here correspond to the partial
least squares ("pls") and extended partial least squares ("xls") methods
in NIRWise PLUS calibration software. Note that in these particular
regression algorithms, the Y-loading of each component is constantly
equal to 1, and therefore not considered.

The `calibration_statistics` matrix retrieved in the `final_model` and
also in the `initial_fit` outputs includes a column named `Q_value`.
This value can be used to asses model overfitting. For each observation,
\\q_i\\ is computed as follows:

\\s = \sqrt{ \frac{\sum\_{i=1}^{n} (y_j - \hat{y}\_j)^2} {n - 1}}\\

\\q_i = \frac{\left \|2 y_i - \hat{y}\_i - \ddot{y}\_i \right \|} {s}\\

where for ith observation, \\y\\ is the observed value, \\\hat{y}\\ is
the fitted value (using a model with all the observations) and
\\\ddot{y}\\ is the predicted value during cross-validation.

## Parallel cross-validation

The cross-validation loop is implemented with
[`foreach`](https://rdrr.io/pkg/foreach/man/foreach.html), so it can be
parallelised transparently by registering a parallel backend before
calling `calibrate`. Set `allow_parallel = TRUE` in
[`calibration_control`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibration_control.md)
(the default) and register a backend, for example:


    cl <- parallel::makeCluster(parallel::detectCores() - 1L)
    doParallel::registerDoParallel(cl)

    model <- calibrate(...)

    parallel::stopCluster(cl)

When no parallel backend is registered, `foreach` falls back silently to
sequential execution regardless of the `allow_parallel` setting. Note
that progress bars are suppressed during parallel execution.

## See also

[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md),

[`fit_plsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md),

[`fit_xlsr`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/fit_constructors.md),

[`calibration_control`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibration_control.md),

[`calibrate_models`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate_models.md)

## Author

Leonardo Ramirez-Lopez and Claudio Orellano

## Examples

``` r
# \donttest{
data("NIRcannabis")
simple_model <- calibrate(CBDA ~ spc,
  data = NIRcannabis, preprocess = preprocess_recipe(prep_snv()),
  method = fit_xlsr(5), control = calibration_control("kfold"),
  verbose = FALSE
)

method <- fit_plsr(15)
control <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential")
pretreats <- preprocess_recipe(
  prep_resample(grid = c(1001, 1700, 5)),
  prep_derivative(m = 2, w = 9, p = 5, algorithm = "nwp"),
  prep_snv(),
  prep_smooth(w = 5, algorithm = "moving-average"),
  device = "proximate"
)
skip_indices <- c(5, 13, 21, 73)
# With formula
complex_model_formula <- calibrate(
  CBDA ~ spc,
  data = NIRcannabis, preprocess = pretreats, method = method,
  control = control, skip_indices = skip_indices, verbose = FALSE
)
# Default, need care with Y
Y <- matrix(NIRcannabis$CBDA)
colnames(Y) <- "CBDA"
complex_model_default <- calibrate(
  X = NIRcannabis$spc, Y = Y, data = NIRcannabis, preprocess = pretreats,
  method = method, control = control, skip_indices = skip_indices, verbose = FALSE
)

# Predict the skipped indices
predict(complex_model_formula,
  newdata = NIRcannabis[skip_indices, ],
  ncomp = complex_model_formula$final_ncomp,
  verbose = FALSE
)
#> Predicted response: CBDA 
#> Spectral preprocessing recipe (device: "proximate"): 
#>  - Step 1: prep_resample
#>     min_wav: 1001; max_wav: 1700; resolution: 5
#>  - Step 2: prep_derivative
#>     m: 2; w: 9; p: 5; algorithm: 'nwp'
#>  - Step 3: prep_snv
#>  - Step 4: prep_smooth
#>     w: 5; algorithm: 'moving-average'
#> Number of predictions: 4 
#> Final number of pls factors: 3 
#> _______________________________________________________ 
#> 
#>  Predictions obtained from the model with 'newdata' 
#> 
#>     ncomp_3
#> 5   3.79777
#> 13 13.76610
#> 21  0.00965
#> 73 10.38691
#> _______________________________________________________ 
# }
```
