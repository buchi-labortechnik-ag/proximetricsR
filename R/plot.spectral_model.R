#' @title Plot results of a given model
#' @name plot.spectral_model
#' @description
#'
#' \loadmathjax
#' Create a html file for a number of useful analytical plots using the R
#' Quarto file "model_plot_template.qmd" for the given model \code{x} of class
#' \code{spectral_model}.
#'
#' @usage
#' \method{plot}{spectral_model}(
#'   x,
#'   validations = NULL,
#'   output_file = x$target_variable,
#'   output_dir = NULL,
#'   spectral = c("weights", "coefficients", "scores", "mahalanobis"),
#'   cv = c("error", "response", "residuals", "qq", "distributions"),
#'   regression = NULL,
#'   validation = if (!is.null(validations)) "all" else NULL,
#'   sample_group = NULL,
#'   verbose = TRUE, open_file = TRUE, ...)
#'
#' @param x an object of class \code{"spectral_model"}. This model should be
#' generated using the \code{\link{calibrate}} function.
#' @param validations an optional object of class \code{"spectral_validation"}. This
#' object, if provided, should be generated using \code{\link{validate_prediction}}.
#' Default is \code{NULL}.
#' @param output_file a character string for the name of the generated file.
#' Default is the target name saved in model \code{x}.
#' @param output_dir a string for the directory in which the file is generated.
#' Default is \code{NULL}, which writes the file to \code{tempdir()}.
#' @param spectral a character vector of spectral plots to include, \code{"all"}
#' to include every spectral plot, or \code{NULL} to skip the section entirely.
#' Available names:
#' \code{"raw"}, \code{"preprocessed"}, \code{"weights"}, \code{"loadings"},
#' \code{"coefficients"}, \code{"scores"}, \code{"scores_3d"},
#' \code{"scaled_scores"}, \code{"mahalanobis"}.
#' @param cv a character vector of cross-validation plots to include, \code{"all"}
#' to include every CV plot, or \code{NULL} to skip the section entirely.
#' Available names:
#' \code{"error"}, \code{"response"}, \code{"response_overview"},
#' \code{"residuals"}, \code{"qq"}, \code{"q_values"}, \code{"distributions"}.
#' @param regression a character vector of regression analysis plots to include,
#' \code{"all"} to include every regression plot, or \code{NULL} (default) to
#' skip the section entirely. Available names:
#' \code{"response"}, \code{"response_overview"}, \code{"residuals"},
#' \code{"qq"}, \code{"residuals_vs_fitted"}, \code{"scale_location"},
#' \code{"leverage"}.
#' @param validation a character vector of validation plots to include,
#' \code{"all"} to include every validation plot, or \code{NULL} to skip.
#' Available names: \code{"predicted_vs_reference"}. Defaults to \code{"all"}
#' when \code{validations} is supplied, \code{NULL} otherwise.
#' @param sample_group a named list of samples that should have the same color.
#' See details. Default is `NULL`, meaning no grouping is done. Note that this
#' is only to distinguish samples for the plots; the model itself remains unchanged.
#' @param verbose a logical. When \code{TRUE} (default), prints the path of the
#' generated file. Pandoc output is always suppressed.
#' @param open_file a logical, indicating whether the file should automatically
#' be opened in a browser after compilation. Defaults to \code{TRUE}.
#' @param ... additional graphical parameters. See details.
#'
#' @details
#' This function creates a html file from rendering the R Markdown file
#' 'model_plot_template.qmd' using \code{quarto::quarto_render()}. This will
#' generate an .html file with the given \code{output_file} as its name in the
#' directory specified by \code{output_dir}. Note that any existing file in the
#' given directory of similar name will be overwritten.
#'
#' The file opens automatically in the default browser of the system if
#' \code{open_file} is set to \code{TRUE}.
#'
#' Depending on the size of the provided dataset, the produced file might take a
#' long time to process, and the files can quickly get quite large. The four
#' section arguments (\code{spectral}, \code{cv}, \code{regression},
#' \code{validation}) control which plots are included. Each accepts a character
#' vector of plot names, \code{"all"} to include the entire section, or
#' \code{NULL} to skip it. For example, to render every available plot:
#'
#' \preformatted{plot(x, spectral = 'all', cv = 'all', regression = 'all',
#'      validation = 'all')}
#'
#' The available plots per section are as follows (defaults marked with *):
#'
#' \strong{spectral}
#' \itemize{
#'     \item {\strong{Raw Spectra}:}  A line plot of all raw spectra. Only available if
#'     input data is saved inside the model \code{x}, i.e. if the method
#'     \code{calibrate} was called with \code{return_inputs} is set to \code{TRUE}.
#'     Note that the depicted spectrum always has a resolution of 10.
#'     \item {\strong{Preprocessed spectra}:}  A line plot of all preprocessed
#'     spectra. Note that the depicted spectrum always has a resolution of 10.
#'     \item {\strong{Weights*}:}  A line plot of all weights.
#'     \item {\strong{Loadings}:}  A line plot of all loadings.
#'     \item {\strong{Coefficients*}:}  A line plot of all regression coefficients.
#'     \item {\strong{Scores*}:}  A points plot of scores for each component.
#'     \item {\strong{3D Scores}:}  A three dimensional points plot of scores for each
#'     component. The component for the x-axis can be selected with a slider.
#'     The corresponding y- and z-axis are the previous and next component,
#'     respectively.
#'     \item {\strong{Scaled Scores}:}  A points plot of the scaled scores for each
#'     component.
#'     \item {\strong{Mahalanobis Distance*}:}  A points plot of the Mahalanobis distance
#'     of the scaled scores of each component.
#'     }
#'
#' \strong{cv}
#'
#' Only available if the calibration used cross-validation. For
#' leave-group-out cross-validation, only \code{"error"} is available.
#' \itemize{
#'     \item {\strong{Error measures*}:} A plot of error and precision measures. In
#'     particular, this plot depicts the largest residual, the RMSE and the R-
#'     squared measures for the cross-validation for all components.
#'     The optimal component is highlighted.
#'     \item {\strong{CV Response Plot*}:} A points plot of the reference values versus
#'     the cross-validation predictions made by the model for each component.
#'     Additionally, the identity line is added, plus a regression line fitted
#'     with the use of the a linear regression model.
#'     \item {\strong{CV Response Plot Overview}:}  An overview of all CV Response Plot
#'     in a single plot.
#'     \item {\strong{CV Residuals*}:} A points plot of the residuals of the
#'     cross-validated predictions, for every component.
#'     \item {\strong{Q-Q Plot of CV Residuals*}:}  A Q-Q plot of the sample quantiles of
#'     the standardized cross-validated residuals against the theoretical
#'     quantiles of a normal distribution for each component. A line with
#'     intercept zero and slope one is depicted.
#'     \item {\strong{CV Q-Values}:} A points plot of the Q-values of the cross-
#'     validation in the model for each component. See details of
#'     \link{calibrate} for an explanation of the Q-values.
#'     \item {\strong{Distributions*}:}  A line plot of the densities of the reference
#'     values and the cross-validated predictions for each component.
#'     }
#'
#' \strong{regression}
#'
#' These plots do not necessarily indicate model performance - more components
#' generally improve fit but may overfit. Useful for identifying outliers.
#' Similar to \code{\link[stats]{plot.lm}}.
#' \itemize{
#'     \item {\strong{Response Plot}:} A points plot of the reference values versus the
#'     fitted values for each component. Additionally, the identity line is
#'     added and a regression line is fitted using a linear regression model.
#'     \item {\strong{Response Plots Overview}:} An overview of all Response plots in
#'     a single plot.
#'     \item {\strong{Residuals}:} A points plot of the residuals of the fitted values
#'     for each component.
#'     \item {\strong{Q-Q Plot of Residuals}:} A Q-Q plot of the sample quantiles of
#'     the standardized residuals against the theoretical quantiles of a normal
#'     distribution for each component. A line with intercept zero and slope one
#'     is depicted.
#'     \item {\strong{Residuals vs Fitted}:} A points plot of the fitted values against
#'     their residuals for each component. Additionally, a line for the LOESS
#'     smoother is depicted.
#'     \item {\strong{Scale Location Plot}:} A points plot of the fitted values against
#'     the square roots of the absolute values of the standardized residuals for
#'     each component. Additionally, a line for the LOESS smother is depicted.
#'     \item {\strong{Leverage vs Residuals}:} A points plot of the leverages of the
#'     fitted values against the standardized residuals for each component.
#'     Additionally, a line for the LOESS smother is depicted.
#'     }
#'
#' \strong{validation}
#'
#' Only available when \code{validations} is supplied (an object of class
#' \code{spectral_validation} from \code{\link{validate_prediction}}).
#' \itemize{
#'     \item {\strong{Predicted vs. Reference*}:} Shows the predictions of the
#'     new data obtained from the model versus the actual reference values,
#'     with an identity line, plus a regression line fitted with the use of a
#'     linear regression model. Additionally, the \mjeqn{R^2}{R^2} and \code{RMSE}
#'     of both the validated predictions and model is depicted. See
#'     \code{\link{validate_prediction}} and \code{\link[=predict.spectral_model]{predict}} for more details on the
#'     prediction and validation process.
#'     }
#'
#' Most of above plots contain a slider, which may be used to adjust the considered
#' component. The sliders start at the optimal components (if any calibration
#' control was applied) or at the maximum number of components (otherwise).
#' 
#' \strong{Sample groups}
#' 
#' The parameter `sample_group` defines samples that belong to the same group and
#' should be displayed with the same color. The legend displays each group by
#' the name given in the list (and an "Other" group for samples not listed).
#' 
#' The idea of this parameter is to allow the user to distinguish e.g. between
#' different instruments. Each sample must belong to a single group, otherwise,
#' this argument is ignored. Indices refer to the sample indices in the calibration
#' statistics in the model.
#' 
#' \strong{Additional parameters for graphics}
#'
#' The plots are constructed with the help of the plotly package. As such,
#' the possibilities to manipulate the plots are as in that package.
#' The arrangement of the plots is controlled by the quarto package.
#'
#' Additional graphical parameters may be supplied to this function by using the
#' ellipsis argument \code{...}. These arguments will be passed to some of the
#' scatter and layout functions of plotly. More precisely, the arguments are passed
#' to possible attributes of \code{add_trace}, and \code{layout} function of
#' plotly. However, the following arguments will always be ignored:\cr
#' \code{c("p", "sliders", "x", "x0", "dx", "y", "y0", "dy", "visible", "type", "name",
#' "hovertext", "text", "mode")},\cr
#' as well as arguments passable to both
#' \code{\link[plotly]{add_trace}}, and \code{\link[plotly]{layout}}. The
#' \code{"line"} attribute is ignored when plotting markers and vice-versa. Some
#' plots ignore the ellipsis argument altogether.
#'
#' Possible attributes of these functions may be found by using the function
#' \code{\link[plotly]{schema}} of plotly.
#'
#' @examples
#' \donttest{
#' data("NIRcannabis")
#' control <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential")
#' prepro_recipe <- preprocess_recipe(
#'   prep_resample(grid = c(1001, 1700, 2)),
#'   prep_snv(),
#'   prep_derivative(m = 1, w = 9, p = 7, algorithm = "nwp"),
#'   device = "proximate"
#' )
#' skips <- c(5, 13, 21, 73)
#' my_model <- calibrate(CBDA ~ spc,
#'   data = NIRcannabis, preprocess = prepro_recipe,
#'   method = fit_plsr(15), control = control, skip = skips, verbose = FALSE
#' )
#'
#' plot(my_model, output_dir = tempdir())
#' # Include every available plot in every section
#' plot(my_model,
#'   output_dir = tempdir(),
#'   spectral = "all", cv = "all", regression = "all", validation = "all"
#' )
#' # Custom section selection with sample grouping
#' plot(
#'   my_model,
#'   output_file = "example_plot",
#'   output_dir = tempdir(),
#'   spectral = c("weights", "scores"),
#'   cv = "all",
#'   regression = NULL,
#'   sample_group = list(
#'     "Batch A" = 1:20,
#'     "Batch B" = 21:60,
#'     "Batch C" = 61:80
#'   )
#' )
#' # Make predictions and validate
#' preds <- predict(my_model, NIRcannabis[skips, ])
#' validations <- validate_prediction(preds, NIRcannabis$CBDA[skips])
#' # Plot validation section only
#' plot(
#'   my_model,
#'   output_dir = tempdir(),
#'   output_file = "example_plot",
#'   validations = validations,
#'   spectral = NULL,
#'   cv = NULL,
#'   regression = NULL
#' )
#' }
#' @return NULL. The desired plots are opened in a browser window.
#' @author Claudio Orellano, Leonardo Ramirez-Lopez
#' @import quarto
#' @import plotly
#' @import utils
#' @importFrom callr r_bg
#' @export
plot.spectral_model <- function(
  x,
  validations = NULL,
  output_file = x$target_variable,
  output_dir = NULL,
  spectral = c("weights", "coefficients", "scores", "mahalanobis"),
  cv = c("error", "response", "residuals", "qq", "distributions"),
  regression = NULL,
  validation = if (!is.null(validations)) "all" else NULL,
  sample_group = NULL,
  verbose = TRUE,
  open_file = TRUE,
  ...
) {
  if (missing(x)) {
    stop("Please specify the model.")
  }
  if (!is.null(validations)) {
    if (!"spectral_validation" %in% class(validations)) {
      stop(
        "Validations have to be of class 'spectral_validation'. ",
        "Use validate_prediction() on an object of class 'spectral_prediction'."
      )
    }
  }
  # Sample group validation
  if (!is.null(sample_group)) {
    if (!all(vapply(sample_group, is.numeric, logical(1)))) {
      stop("'sample_group' must contain only numeric sample indices.")
    }
    if (!is.list(sample_group) || is.null(names(sample_group))) {
      warning("'sample_group' should be a named list")
      sample_group <- NULL
    }
    if (anyDuplicated(unlist(sample_group))) {
      warning("ignoring 'sample_group' due to duplicated sample indices.")
      sample_group <- NULL
    }
  }
      
  if (!is.logical(verbose)) {
    stop("'verbose' must be a logical.")
  }

  selection <- c(
    .resolve_plots(spectral, .spectral_plot_map),
    .resolve_plots(cv, .cv_plot_map),
    .resolve_plots(regression, .regression_plot_map),
    .resolve_plots(validation, .validation_plot_map)
  )
  if (length(selection) == 0) {
    stop("No plots selected. Provide at least one section argument.")
  }

  if (is.null(quarto::quarto_path())) {
    stop(
      "The Quarto CLI is required to generate plots but was not found.\n",
      "Install it from https://quarto.org/docs/get-started/"
    )
  }

  if (is.null(output_dir)) output_dir <- tempdir()
  out_path <- file.path(output_dir, paste0(output_file, ".html"))
  html_fname <- paste0(output_file, ".html")

  tmp_dir <- file.path(tempdir(), paste0("proximetrics_plot_", uuid::UUIDgenerate()))
  tmp_model <- file.path(tmp_dir, "model.rds")
  tmp_validations <- file.path(tmp_dir, "validations.rds")
  tmp_qmd <- file.path(tmp_dir, "model_plot_template.qmd")
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  if (verbose) {
    .print_plot_options(spectral, cv, regression, validation)
    cat("\nUse \"all\" to include every plot in a section, NULL to skip. See ?plot.spectral_model\n\n")
  }

  dir.create(tmp_dir, showWarnings = FALSE)
  file.copy(system.file("model_plot_template.qmd", package = "proximetricsR"), tmp_qmd)
  saveRDS(x, tmp_model)
  saveRDS(validations, tmp_validations)

  render_params <- list(
    model_path = tmp_model,
    validations_path = tmp_validations,
    selection = selection,
    sample_group = sample_group,
    graph_params = list(...),
    subtitle = paste0(x$target_variable, " - ", Sys.Date())
  )

  # callr::r_bg() is used to run quarto_render() in a background R process,
  # which allows the main R session to remain responsive and display a progress
  # spinner.
  bg <- callr::r_bg(
    function(tmp_qmd, render_params, html_fname) {
      quarto::quarto_render(
        input = tmp_qmd,
        execute_params = render_params,
        output_file = html_fname,
        quiet = TRUE
      )
    },
    args = list(tmp_qmd, render_params, html_fname),
    supervise = FALSE
  )

  if (verbose) {
    spinner <- c("> ", ">> ", ">>>", " ")
    i <- 0L
    while (bg$is_alive()) {
      cat("\rGenerating plots in html", spinner[(i %% 4L) + 1L])
      flush.console()
      Sys.sleep(0.3)
      i <- i + 1L
    }
    cat("\r", strrep(" ", 30), "\r", sep = "")
  } else {
    bg$wait()
  }

  bg$get_result()

  file.copy(file.path(tmp_dir, html_fname), out_path, overwrite = TRUE)

  if (verbose) {
    cat("Output created:", out_path, "\n")
  }

  if (open_file) browseURL(paste0("file://", out_path))
}

.spectral_plot_map <- c(
  raw = 1.1, preprocessed = 1.2, weights = 1.3, loadings = 1.4,
  coefficients = 1.5, scores = 1.6, scores_3d = 1.7,
  scaled_scores = 1.8, mahalanobis = 1.9
)
.cv_plot_map <- c(
  error = 2.1, response = 2.2, response_overview = 2.3,
  residuals = 2.4, qq = 2.5, q_values = 2.6, distributions = 2.7
)
.regression_plot_map <- c(
  response = 3.1, response_overview = 3.2, residuals = 3.3,
  qq = 3.4, residuals_vs_fitted = 3.5, scale_location = 3.6, leverage = 3.7
)
.validation_plot_map <- c(predicted_vs_reference = 4.1)

.print_plot_options <- function(spectral, cv, regression, validation) {
  use_col <- .use_color()

  .fmt_section <- function(label, map, selected) {
    if (identical(selected, "all")) selected <- names(map)
    if (is.null(selected)) selected <- character(0)

    nms <- names(map)

    fmt_nm <- function(nm) {
      q <- paste0('"', nm, '"')
      if (nm %in% selected && use_col) {
        paste0("\033[1;31m", q, "\033[0m")
      } else {
        q
      }
    }

    fmt_items <- sapply(nms, fmt_nm)
    vis_w <- nchar(nms) + 2L

    # single-line check (visual width only)
    single_vis <- 2L + nchar(label) + 5L + sum(vis_w) +
      max(0L, (length(nms) - 1L) * 2L) + 1L
    if (single_vis <= 80L) {
      cat(paste0(" ", label, " = c(", paste(fmt_items, collapse = ", "), ")\n"))
      return(invisible(NULL))
    }

    # multi-line: items indented 4 spaces, closing ) on own line
    cat(paste0(" ", label, " = c(\n"))
    cur_line <- " "
    cur_vis <- 4L

    for (i in seq_along(nms)) {
      item_vis <- vis_w[i]
      is_last <- i == length(nms)
      sep_vis <- if (is_last) 0L else 2L

      if (cur_vis > 4L && cur_vis + item_vis + sep_vis > 80L) {
        cat(cur_line, ",\n", sep = "")
        cur_line <- paste0(" ", fmt_items[i])
        cur_vis <- 4L + item_vis
      } else {
        if (cur_vis > 4L) {
          cur_line <- paste0(cur_line, ", ", fmt_items[i])
          cur_vis <- cur_vis + 2L + item_vis
        } else {
          cur_line <- paste0(cur_line, fmt_items[i])
          cur_vis <- cur_vis + item_vis
        }
      }
    }
    cat(cur_line, "\n )\n", sep = "")
  }

  cat("Available plot parameter options:\n")
  cat("---\n")
  .fmt_section("spectral", .spectral_plot_map, spectral)
  cat("---\n")
  .fmt_section("cv", .cv_plot_map, cv)
  cat("---\n")
  .fmt_section("regression", .regression_plot_map, regression)
  cat("---\n")
  .fmt_section("validation", .validation_plot_map, validation)

  if (use_col) {
    cat(
      "\nLegend:",
      paste0("\033[1;31m\"name\"\033[0m"), "included ",
      "\"name\"", "not rendered\n"
    )
  }
}

.resolve_plots <- function(arg, map) {
  if (is.null(arg)) {
    return(NULL)
  }
  if (identical(arg, "all")) {
    return(unname(map))
  }
  bad <- arg[!arg %in% names(map)]
  if (length(bad) > 0) {
    stop(
      "Unknown plot(s): ", paste(bad, collapse = ", "),
      ". Available: ", paste(names(map), collapse = ", "), "."
    )
  }
  unname(map[arg])
}
