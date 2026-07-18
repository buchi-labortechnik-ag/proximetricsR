# Plot results of a given model

Create a html file for a number of useful analytical plots using the R
Quarto file "model_plot_template.qmd" for the given model `x` of class
`spectral_model`.

## Usage

``` r
# S3 method for class 'spectral_model'
plot(x, validations = NULL, output_file = x$target_variable,
  output_dir = NULL,
  spectral = c("weights", "coefficients", "scores", "mahalanobis"),
  cv = c("error", "response", "residuals", "qq", "distributions"),
  regression = NULL,
  validation = if (!is.null(validations)) "all" else NULL,
  verbose = TRUE, open_file = TRUE, ...)
```

## Arguments

- x:

  an object of class `"spectral_model"`. This model should be generated
  using the
  [`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
  function.

- validations:

  an optional object of class `"spectral_validation"`. This object, if
  provided, should be generated using
  [`validate_prediction`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/validate_prediction.md).
  Default is `NULL`.

- output_file:

  a character string for the name of the generated file. Default is the
  target name saved in model `x`.

- output_dir:

  a string for the directory in which the file is generated. Default is
  `NULL`, which writes the file to
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html).

- spectral:

  a character vector of spectral plots to include, `"all"` to include
  every spectral plot, or `NULL` to skip the section entirely. Available
  names: `"raw"`, `"preprocessed"`, `"weights"`, `"loadings"`,
  `"coefficients"`, `"scores"`, `"scores_3d"`, `"scaled_scores"`,
  `"mahalanobis"`.

- cv:

  a character vector of cross-validation plots to include, `"all"` to
  include every CV plot, or `NULL` to skip the section entirely.
  Available names: `"error"`, `"response"`, `"response_overview"`,
  `"residuals"`, `"qq"`, `"q_values"`, `"distributions"`.

- regression:

  a character vector of regression analysis plots to include, `"all"` to
  include every regression plot, or `NULL` (default) to skip the section
  entirely. Available names: `"response"`, `"response_overview"`,
  `"residuals"`, `"qq"`, `"residuals_vs_fitted"`, `"scale_location"`,
  `"leverage"`.

- validation:

  a character vector of validation plots to include, `"all"` to include
  every validation plot, or `NULL` to skip. Available names:
  `"predicted_vs_reference"`. Defaults to `"all"` when `validations` is
  supplied, `NULL` otherwise.

- verbose:

  a logical. When `TRUE` (default), prints the path of the generated
  file. Pandoc output is always suppressed.

- open_file:

  a logical, indicating whether the file should automatically be opened
  in a browser after compilation. Defaults to `TRUE`.

- ...:

  additional graphical parameters. See details.

## Value

NULL. The desired plots are opened in a browser window.

## Details

This function creates a html file from rendering the R Markdown file
'model_plot_template.qmd' using
[`quarto::quarto_render()`](https://quarto-dev.github.io/quarto-r/reference/quarto_render.html).
This will generate an .html file with the given `output_file` as its
name in the directory specified by `output_dir`. Note that any existing
file in the given directory of similar name will be overwritten.

The file opens automatically in the default browser of the system if
`open_file` is set to `TRUE`.

Depending on the size of the provided dataset, the produced file might
take a long time to process, and the files can quickly get quite large.
The four section arguments (`spectral`, `cv`, `regression`,
`validation`) control which plots are included. Each accepts a character
vector of plot names, `"all"` to include the entire section, or `NULL`
to skip it. For example, to render every available plot:

    plot(x, spectral = 'all', cv = 'all', regression = 'all',
         validation = 'all')

The available plots per section are as follows (defaults marked with
\*):

**spectral**

- **Raw Spectra**: A line plot of all raw spectra. Only available if
  input data is saved inside the model `x`, i.e. if the method
  `calibrate` was called with `return_inputs` is set to `TRUE`. Note
  that the depicted spectrum always has a resolution of 10.

- **Preprocessed spectra**: A line plot of all preprocessed spectra.
  Note that the depicted spectrum always has a resolution of 10.

- **Weights\***: A line plot of all weights.

- **Loadings**: A line plot of all loadings.

- **Coefficients\***: A line plot of all regression coefficients.

- **Scores\***: A points plot of scores for each component.

- **3D Scores**: A three dimensional points plot of scores for each
  component. The component for the x-axis can be selected with a slider.
  The corresponding y- and z-axis are the previous and next component,
  respectively.

- **Scaled Scores**: A points plot of the scaled scores for each
  component.

- **Mahalanobis Distance\***: A points plot of the Mahalanobis distance
  of the scaled scores of each component.

**cv**

Only available if the calibration used cross-validation. For
leave-group-out cross-validation, only `"error"` is available.

- **Error measures\***: A plot of error and precision measures. In
  particular, this plot depicts the largest residual, the RMSE and the
  R- squared measures for the cross-validation for all components. The
  optimal component is highlighted.

- **CV Response Plot\***: A points plot of the reference values versus
  the cross-validation predictions made by the model for each component.
  Additionally, the identity line is added, plus a regression line
  fitted with the use of the a linear regression model.

- **CV Response Plot Overview**: An overview of all CV Response Plot in
  a single plot.

- **CV Residuals\***: A points plot of the residuals of the
  cross-validated predictions, for every component.

- **Q-Q Plot of CV Residuals\***: A Q-Q plot of the sample quantiles of
  the standardized cross-validated residuals against the theoretical
  quantiles of a normal distribution for each component. A line with
  intercept zero and slope one is depicted.

- **CV Q-Values**: A points plot of the Q-values of the cross-
  validation in the model for each component. See details of
  [calibrate](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
  for an explanation of the Q-values.

- **Distributions\***: A line plot of the densities of the reference
  values and the cross-validated predictions for each component.

**regression**

These plots do not necessarily indicate model performance - more
components generally improve fit but may overfit. Useful for identifying
outliers. Similar to [`plot.lm`](https://rdrr.io/r/stats/plot.lm.html).

- **Response Plot**: A points plot of the reference values versus the
  fitted values for each component. Additionally, the identity line is
  added and a regression line is fitted using a linear regression model.

- **Response Plots Overview**: An overview of all Response plots in a
  single plot.

- **Residuals**: A points plot of the residuals of the fitted values for
  each component.

- **Q-Q Plot of Residuals**: A Q-Q plot of the sample quantiles of the
  standardized residuals against the theoretical quantiles of a normal
  distribution for each component. A line with intercept zero and slope
  one is depicted.

- **Residuals vs Fitted**: A points plot of the fitted values against
  their residuals for each component. Additionally, a line for the LOESS
  smoother is depicted.

- **Scale Location Plot**: A points plot of the fitted values against
  the square roots of the absolute values of the standardized residuals
  for each component. Additionally, a line for the LOESS smother is
  depicted.

- **Leverage vs Residuals**: A points plot of the leverages of the
  fitted values against the standardized residuals for each component.
  Additionally, a line for the LOESS smother is depicted.

**validation**

Only available when `validations` is supplied (an object of class
`spectral_validation` from
[`validate_prediction`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/validate_prediction.md)).

- **Predicted vs. Reference\***: Shows the predictions of the new data
  obtained from the model versus the actual reference values, with an
  identity line, plus a regression line fitted with the use of a linear
  regression model. Additionally, the \\R^2\\ and `RMSE` of both the
  validated predictions and model is depicted. See
  [`validate_prediction`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/validate_prediction.md)
  and
  [`predict`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
  for more details on the prediction and validation process.

Most of above plots contain a slider, which may be used to adjust the
considered component. The sliders start at the optimal components (if
any calibration control was applied) or at the maximum number of
components (otherwise).

The plots are constructed with the help of the plotly package. As such,
the possibilities to manipulate the plots are as in that package. The
arrangement of the plots is controlled by the quarto package.

Additional graphical parameters may be supplied to this function by
using the ellipsis argument `...`. These arguments will be passed to
some of the scatter and layout functions of plotly. More precisely, the
arguments are passed to possible attributes of `add_trace`, and `layout`
function of plotly. However, the following arguments will always be
ignored:  
`c("p", "sliders", "x", "x0", "dx", "y", "y0", "dy", "visible", "type", "name", "hovertext", "text", "mode")`,  
as well as arguments passable to both
[`add_trace`](https://rdrr.io/pkg/plotly/man/add_trace.html), and
`layout`. The `"line"` attribute is ignored when plotting markers and
vice-versa. Some plots ignore the ellipsis argument altogether.

Possible attributes of these functions may be found by using the
function [`schema`](https://rdrr.io/pkg/plotly/man/schema.html) of
plotly.

## Author

Claudio Orellano, Leonardo Ramirez-Lopez

## Examples

``` r
# \donttest{
data("NIRcannabis")
control <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential")
prepro_recipe <- preprocess_recipe(
  prep_resample(grid = c(1001, 1700, 2)),
  prep_snv(),
  prep_derivative(m = 1, w = 9, p = 7, algorithm = "nwp"),
  device = "proximate"
)
skips <- c(5, 13, 21, 73)
my_model <- calibrate(CBDA ~ spc,
  data = NIRcannabis, preprocess = prepro_recipe,
  method = fit_plsr(15), control = control, skip = skips, verbose = FALSE
)

plot(my_model, output_dir = tempdir())
#> Available plot parameter options:
#> ---
#>  spectral = c(
#>  "raw", "preprocessed", "weights", "loadings", "coefficients", "scores",
#>  "scores_3d", "scaled_scores", "mahalanobis"
#>  )
#> ---
#>  cv = c(
#>  "error", "response", "response_overview", "residuals", "qq", "q_values",
#>  "distributions"
#>  )
#> ---
#>  regression = c(
#>  "response", "response_overview", "residuals", "qq", "residuals_vs_fitted",
#>  "scale_location", "leverage"
#>  )
#> ---
#>  validation = c("predicted_vs_reference")
#> 
#> Use "all" to include every plot in a section, NULL to skip. See ?plot.spectral_model
#> 
#> Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >>                               Output created: /tmp/RtmpUrRWUk/CBDA.html 
# Include every available plot in every section
plot(my_model,
  output_dir = tempdir(),
  spectral = "all", cv = "all", regression = "all", validation = "all"
)
#> Available plot parameter options:
#> ---
#>  spectral = c(
#>  "raw", "preprocessed", "weights", "loadings", "coefficients", "scores",
#>  "scores_3d", "scaled_scores", "mahalanobis"
#>  )
#> ---
#>  cv = c(
#>  "error", "response", "response_overview", "residuals", "qq", "q_values",
#>  "distributions"
#>  )
#> ---
#>  regression = c(
#>  "response", "response_overview", "residuals", "qq", "residuals_vs_fitted",
#>  "scale_location", "leverage"
#>  )
#> ---
#>  validation = c("predicted_vs_reference")
#> 
#> Use "all" to include every plot in a section, NULL to skip. See ?plot.spectral_model
#> 
#> Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html                                Output created: /tmp/RtmpUrRWUk/CBDA.html 
# Custom section selection
plot(
  my_model,
  output_file = "example_plot",
  output_dir = tempdir(),
  spectral = c("weights", "scores"),
  cv = "all",
  regression = NULL
)
#> Available plot parameter options:
#> ---
#>  spectral = c(
#>  "raw", "preprocessed", "weights", "loadings", "coefficients", "scores",
#>  "scores_3d", "scaled_scores", "mahalanobis"
#>  )
#> ---
#>  cv = c(
#>  "error", "response", "response_overview", "residuals", "qq", "q_values",
#>  "distributions"
#>  )
#> ---
#>  regression = c(
#>  "response", "response_overview", "residuals", "qq", "residuals_vs_fitted",
#>  "scale_location", "leverage"
#>  )
#> ---
#>  validation = c("predicted_vs_reference")
#> 
#> Use "all" to include every plot in a section, NULL to skip. See ?plot.spectral_model
#> 
#> Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html                                Output created: /tmp/RtmpUrRWUk/example_plot.html 
# Make predictions and validate
preds <- predict(my_model, NIRcannabis[skips, ])
#> Processing 'newdata':  resample > snv > derivative 
#> Predicting from preprocessed 'newdata'...
#> 
validations <- validate_prediction(preds, NIRcannabis$CBDA[skips])
# Plot validation section only
plot(
  my_model,
  output_dir = tempdir(),
  output_file = "example_plot",
  validations = validations,
  spectral = NULL,
  cv = NULL,
  regression = NULL
)
#> Available plot parameter options:
#> ---
#>  spectral = c(
#>  "raw", "preprocessed", "weights", "loadings", "coefficients", "scores",
#>  "scores_3d", "scaled_scores", "mahalanobis"
#>  )
#> ---
#>  cv = c(
#>  "error", "response", "response_overview", "residuals", "qq", "q_values",
#>  "distributions"
#>  )
#> ---
#>  regression = c(
#>  "response", "response_overview", "residuals", "qq", "residuals_vs_fitted",
#>  "scale_location", "leverage"
#>  )
#> ---
#>  validation = c("predicted_vs_reference")
#> 
#> Use "all" to include every plot in a section, NULL to skip. See ?plot.spectral_model
#> 
#> Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>Generating plots in html  Generating plots in html > Generating plots in html >> Generating plots in html >>>                              Output created: /tmp/RtmpUrRWUk/example_plot.html 
# }
```
