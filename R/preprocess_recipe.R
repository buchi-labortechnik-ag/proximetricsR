#' @title Build and execute spectral preprocessing recipes
#' @aliases process
#' @description
#'
#' \loadmathjax
#'
#' The \code{preprocess_recipe} function assembles an ordered sequence of
#' preprocessing steps into a recipe, while \code{process} executes the
#' recipe on a spectral data matrix.
#'
#' @usage
#'
#' preprocess_recipe(..., device)
#'
#' process(X, recipe, device)
#'
#' @param ... one or more objects of class \code{preprocessing} as returned by
#' any of the following constructor functions:
#'
#' \itemize{
#'   \item{\code{\link{prep_resample}}}
#'   \item{\code{\link{prep_smooth}}}
#'   \item{\code{\link{prep_snv}}}
#'   \item{\code{\link{prep_derivative}}}
#'   \item{\code{\link{prep_detrend}}}
#'   \item{\code{\link{prep_transform}}}
#'   \item{\code{\link{prep_wav_trim}}}
#' }
#'
#' The order in which the objects are provided defines the order of execution.
#' If no arguments are provided, an empty recipe is returned and \code{process}
#' will return the input data unchanged.
#'
#' @param device a character string specifying the target device:
#' \code{"unspecified"} (no validation), \code{"proximate"}, or
#' \code{"proxiscout"}. When \code{"proximate"} or \code{"proxiscout"} is
#' specified, \code{preprocess_recipe} validates that all steps are compatible
#' with that device and raises an informative error if not. Pass
#' \code{"unspecified"} to skip validation explicitly.
#'
#' \code{device} is required whenever the recipe contains any preprocessing
#' step, with one exception: a recipe containing only a single
#' \code{\link{prep_snv}} step does not require \code{device}, because SNV is
#' device-agnostic (identical behaviour for both \code{"proximate"} and
#' \code{"proxiscout"}). In that case \code{device} defaults to
#' \code{"unspecified"}.
#' @param X a numeric matrix of spectral data to be preprocessed (samples in
#' rows, wavelengths in columns).
#' @param recipe an object of class \code{preprocess_recipe} as returned by
#' \code{preprocess_recipe}. A single object of class \code{preprocessing} is also
#' accepted and treated as a one-step recipe.
#'
#' @return
#'
#' For \code{preprocess_recipe}, an object of class \code{preprocess_recipe} with
#' three components: \code{steps} (the ordered list of preprocessing step
#' objects), \code{device} (the target device string), and
#' \code{preprocessing_order} (a simplified string summarising the
#' sequence of applied transformations).
#'
#' For \code{process}, a numeric matrix of preprocessed spectral data. The
#' applied recipe is stored as the attribute \code{"preprocess_recipe"} on the
#' returned matrix and can be retrieved with
#' \code{attr(result, "preprocess_recipe")}.
#'
#' @author Leonardo Ramirez-Lopez
#' @seealso \code{\link{prep_smooth}}, \code{\link{prep_snv}},
#' \code{\link{prep_derivative}}, \code{\link{prep_resample}},
#' \code{\link{prep_detrend}}, \code{\link{prep_transform}},
#' \code{\link{prep_wav_trim}}
#' @examples
#' data("NIRcannabis")
#' X <- NIRcannabis$spc
#'
#' # SNV alone — no device needed (SNV is device-agnostic)
#' recipe_snv <- preprocess_recipe(prep_snv())
#' X_snv <- process(X, recipe_snv)
#'
#' # Any other combination requires device
#' recipe <- preprocess_recipe(
#'   prep_smooth(w = 7, p = 1, algorithm = "savitzky-golay"),
#'   prep_snv(),
#'   prep_derivative(m = 1, w = 5, p = 2, algorithm = "savitzky-golay"),
#'   device = "proxiscout"
#' )
#'
#' X_proc <- process(X, recipe)
#' attr(X_proc, "preprocess_recipe")
#' @export
preprocess_recipe <- function(..., device) {
  steps <- list(...)

  # Identify the SNV-only special case: single step that is prep_snv
  is_snv_only <- length(steps) == 1 &&
    inherits(steps[[1]], "preprocessing") &&
    isTRUE(steps[[1]]$method == "prep_snv")

  if (length(steps) > 0) {
    if (missing(device)) {
      if (is_snv_only) {
        device <- "unspecified"
      } else {
        stop(
          "'device' is required. ",
          "Choose one of: 'unspecified', 'proximate', 'proxiscout'. ",
          "Note: 'device' may be omitted only when the recipe contains ",
          "a single prep_snv() step (SNV is device-agnostic)."
        )
      }
    }
  } else {
    if (missing(device)) {
      device <- "unspecified"
    }
  }
  device <- match.arg(device, c("unspecified", "proximate", "proxiscout"))

  if (length(steps) > 0) {
    not_processing <- !sapply(steps, function(s) inherits(s, "preprocessing"))
    if (any(not_processing)) {
      stop(
        "All arguments must be of class 'preprocessing'. ",
        "Invalid argument(s) at position(s): ",
        paste(which(not_processing), collapse = ", "), "."
      )
    }

    if (device != "unspecified") {
      valid <- .device_steps[[device]]
      hints <- .device_hints[[device]]
      methods <- sapply(steps, `[[`, "method")
      bad <- methods[!methods %in% valid]
      if (length(bad) > 0) {
        stop(
          "The following steps are not compatible with device '", device, "':\n",
          paste0("  - ", bad, collapse = "\n"), "\n\n",
          "Valid preprocessing steps for '", device, "':\n",
          paste0("  - ", hints, collapse = "\n")
        )
      }

      for (step in steps) {
        cd <- step$compatible_devices
        if (!is.null(cd) && cd != "unspecified" && !device %in% cd) {
          stop(
            "'", step$method, "' with algorithm = '", step$algorithm,
            "' is only compatible with device '", cd, "'.\n\n",
            "Valid preprocessing steps for '", device, "':\n",
            paste0("  - ", hints, collapse = "\n")
          )
        }
      }
    }
  }

  preprocessing_order <- paste(
    gsub(
      "^prep_",
      "",
      sapply(steps, FUN = function(xx) {
        yy <- gsub("prep_", "", xx$method)
        if (yy == "derivative") {
          if (xx$m == 1) {
            yy <- paste0(yy, " (1st)")
          } else if (xx$m == 2) {
            yy <- paste0(yy, " (2nd)")
          } else {
            yy <- paste0(yy, " (", xx$m, "th)")
          }
        }
        yy
      })
    ),
    collapse = " > "
  )

  structure(
    list(
      steps = steps,
      device = device,
      preprocessing_order = preprocessing_order
    ),
    class = c("preprocess_recipe", "list")
  )
}

#' @noRd
#' @export
print.preprocess_recipe <- function(x, ...) {
  device_label <- x$device
  cat(.bold_italic(paste0("Spectral preprocessing recipe (device: \"", device_label, "\"):")), "\n")
  if (length(x$steps) == 0) {
    cat("  Empty recipe (no preprocessing steps)\n")
    return(invisible(x))
  }
  for (i in seq_along(x$steps)) {
    step <- x$steps[[i]]
    cat(" ", .bold_red(paste0("Step ", i, ": ", step$method)), "\n", sep = "")
    .print_step_params(step)
  }
  invisible(x)
}


#' @aliases preprocess_recipe
#' @export process
process <- function(X, recipe, device = c("unspecified", "proximate", "proxiscout")) {
  device <- match.arg(device)
  if (inherits(recipe, "preprocessing")) {
    recipe <- preprocess_recipe(recipe, device = device)
  }

  if (!inherits(recipe, "preprocess_recipe")) {
    stop("'recipe' must be of class 'preprocess_recipe' or 'preprocessing'.")
  }

  wavs <- list(step_0 = as.numeric(colnames(X)))
  for (step in recipe$steps) {
    i <- length(wavs)
    X <- .dispatch_step(X, step)
    wavs[[paste0("step_", i)]] <- as.numeric(colnames(X))
  }

  class(wavs) <- c("processed_wavs", "list")

  attr(X, "preprocess_recipe") <- recipe
  attr(X, "processed_wavs") <- wavs
  X
}

#' @noRd
#' @export
print.processed_wavs <- function(x, ...) {
  cat("Spectral variables by preprocessing step:\n")
  cat(
    paste0(
      "  ", names(x),
      ": ", sapply(x, length), " spectral variables",
      collapse = "\n"
    ),
    "\n"
  )
  invisible(x)
}

#' @noRd
.dispatch_step <- function(X, step) {
  switch(step$method,
    prep_derivative = .exec_derivative(X, step),
    prep_smooth = .exec_smooth(X, step),
    prep_snv = .exec_snv(X, step),
    prep_resample = .exec_resample(X, step),
    prep_detrend = .exec_detrend(X, step),
    prep_transform = .exec_transform(X, step),
    prep_wav_trim = .exec_wav_trim(X, step),
    stop("No executor found for method '", step$method, "'.")
  )
}


# Device compatibility table.
# Lists the prep_* methods supported by each device.
# Update this table when adding new constructors or adjusting device support.
.device_steps <- list(
  proximate = c(
    "prep_resample",
    "prep_smooth",
    "prep_snv",
    "prep_derivative"
  ),
  proxiscout = c(
    "prep_resample",
    "prep_smooth",
    "prep_snv",
    "prep_derivative",
    "prep_detrend",
    "prep_transform",
    "prep_wav_trim"
  )
)

# Human-readable hints shown in error messages.
# Keep in sync with .device_steps.
.device_hints <- list(
  proximate = c(
    "prep_resample(grid = c(min_wav, max_wav, resolution))",
    'prep_smooth(w, algorithm = "moving-average")',
    "prep_snv()",
    'prep_derivative(m, w, p, algorithm = "nwp")'
  ),
  proxiscout = c(
    'prep_resample(grid = "proxiscout")',
    'prep_smooth(w, p, algorithm = "savitzky-golay")',
    "prep_snv()",
    'prep_derivative(m, w, p, algorithm = c("savitzky-golay", "gap-segment"))',
    "prep_detrend()",
    "prep_transform()",
    "prep_wav_trim()"
  )
)
