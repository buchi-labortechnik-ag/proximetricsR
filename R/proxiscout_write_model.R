#' @title Write a calibration model to ProxiScout JSON format
#' @name proxiscout_write_model
#' @description
#'
#' \loadmathjax
#'
#' Serializes a model of class \code{spectral_model} (including its
#' preprocessing recipe) into a JSON format that can be imported into
#' the NeoSpectra NIR Hub and deployed on ProxiScout sensors (see Details).
#'
#' @usage
#' proxiscout_write_model(object, file = NULL)
#'
#' @param object an object of class \code{spectral_model} that contains the
#' preprocessing recipe and final model to be serialized.
#' @param file an optional character string with the path (including file name)
#' where the JSON output should be written. If \code{NULL} (default), no file
#' is written and the JSON string is returned. If a path is provided, the JSON
#' is written to that file and returned invisibly.
#'
#' @return If \code{file = NULL} (default), the JSON string is returned
#' visibly so it can be inspected or assigned to a variable. If \code{file}
#' is specified, the JSON string is written to that file and returned
#' invisibly (i.e. it is not printed to the console, following the standard
#' R convention for functions called primarily for their side effect).
#'
#' @details
#' The JSON output produced by this function can be imported into the
#' \href{https://www.buchi.com/en/products/services/software-apps/neospectra-platform/neospectra-nir-hub}{NeoSpectra NIR Hub}
#' and used within a ProxiScout application. Once imported, the
#' \href{https://play.google.com/store/apps/details?id=com.neospectrascanapp}{NeoSpectra Scan mobile app}
#' linked to a ProxiScout sensor can access the model and use it to compute
#' and display spectral predictions.
#'
#' The JSON pipeline always begins with two hardware-specific steps that are
#' added automatically, regardless of the preprocessing recipe in \code{object}:
#' (1) scaling raw reflectance from the 0--100 range reported by the sensor to
#' the 0--1 range, and (2) averaging repeated scans of the same sample. These
#' steps precede any user-defined preprocessing.
#'
#' \strong{Constraints and supported preprocessing steps:}
#' \itemize{
#'   \item The first step in the preprocessing recipe of \code{object} must be
#'     \code{\link{prep_resample}}, as wavenumber alignment with the ProxiScout
#'     hardware grid is required.
#'   \item All predictor wavenumbers in \code{object} must match the hardware
#'     wavenumbers returned by \code{\link{get_proxiscout_wavenumbers}} within a
#'     tolerance of 0.1 \mjeqn{\mathrm{cm}^{-1}}{cm^{-1}}.
#'   \item \code{\link{prep_derivative}} and \code{\link{prep_smooth}} are
#'     supported only when \code{algorithm = "savitzky-golay"}.
#'   \item \code{\link{prep_transform}} is supported only with
#'     \code{to = "absorbance"}; using \code{to = "reflectance"} generates a
#'     warning and the step is skipped in the JSON output.
#'   \item \code{\link{prep_wav_trim}} is handled implicitly through wavenumber
#'     selection and does not produce an explicit JSON step.
#' }
#'
#' @seealso \code{\link{calibrate}}, \code{\link{get_proxiscout_wavenumbers}},
#'   \code{\link{prep_resample}}
#' @author Leonardo Ramirez-Lopez and Claudio Orellano
#' @examples
#' \donttest{
#' data("NIRcannabis")
#' control <- calibration_control(
#'   validation_type = "kfold", number = 3, folds = "sequential"
#' )
#' recipe <- preprocess_recipe(
#'   prep_resample(grid = "proxiscout"),
#'   prep_snv(),
#'   prep_derivative(m = 1, w = 11, p = 2, algorithm = "savitzky-golay"),
#'   device = "proxiscout"
#' )
#' model <- calibrate(
#'   THCA ~ spc,
#'   data = NIRcannabis, preprocess = recipe,
#'   method = fit_plsr(10), control = control, verbose = FALSE
#' )
#'
#' json_model <- proxiscout_write_model(model)
#' json_model
#'
#' proxiscout_write_model(model, file = file.path(tempdir(), "my_model.json"))
#' }
#' @export
proxiscout_write_model <- function(object, file = NULL) {
  if (length(object$preprocess$steps) < 1) {
    stop("No preprocessing detected. You must include at least 'prep_resample()'.")
  }
  if (!object$preprocess$steps[[1]]$method %in% c("prep_resample")) {
    stop("The first preprocessing step must be 'prep_resample()'.")
  }

  # neospectra wavenumbers
  hw_wavs <- get_proxiscout_wavenumbers()
  # Initialize a list to hold the JSON output
  json_output <- list()
  count <- 0 # Count the number of inputs in the JSON
  # If the first preprocess step is a user-defined grid resample, check that the
  # wavenumbers are sufficiently close to the hardware ones. We drop wavenumbers
  # from hw_wavs which are not covered by the window
  if (!is.null(object$preprocess$steps[[1]]$min_wav)) {
    wseq <- seq(
      object$preprocess$steps[[1]]$max_w,
      object$preprocess$steps[[1]]$min_w,
      -object$preprocess$steps[[1]]$resolution
    ) |> sort()

    # Check that all values in the preprocess recipe are close to the hardware wavenumbers
    if (!all(is_close_to_any(wseq, hw_wavs, tol = 0.1))) {
      stop("The model raw spectra contains wavenumbers not measured by neospectra")
    }
    # Take the wavenumbers from the hardware which are closest to the recipe values
    var_sel <- which(is_close_to_any(hw_wavs, wseq, tol = 0.1))
    updated_wavs <- hw_wavs[var_sel]
    # Add variable selection to the JSON output to only select the wavs that are close
    # to the expected ones, if the wavelengths changed
    if (!identical(var_sel, seq_along(hw_wavs))) {
      json_output <- append(
        json_output, list(list(id = 17, params = as.list(var_sel - 1), index = 0)) # 0-based indexing
      )
      count <- count + 1
    }
  } else {
    # For proximate resample, we do not need to check the closeness of the wavenumbers,
    # nor write into the JSON output, but we still need to assign updated_wavs and var_sel
    var_sel <- seq_along(hw_wavs)
    updated_wavs <- hw_wavs
  }
  # ALWAYS REQEST TO CONVERT FROM WAVELENGTHS TO WAVENUMBERS
  # THIS IS RELEVANT FOR DETRENDING
  json_output <- append(
    json_output,
    list(list(id = 31, params = list(), index = count))
  )
  count <- count + 1

  current_wavs <- hw_wavs
  wav_indices <- which(
    is_close_to_any(current_wavs, object$processed_wavs$step_0, tol = 0.1)
  )

  if (length(wav_indices) < length(current_wavs)) {
    json_output <- append(
      json_output,
      list(list(id = 17, params = as.list(wav_indices - 1), index = count))
    )
    count <- count + 1
  }
  current_wavs <- current_wavs[wav_indices]


  # scale si-ware from 0-100 reflectance to 0-1 reflectance
  json_output <- append(
    json_output,
    list(list(id = 37, params = list(0.01), index = count))
  )
  count <- count + 1

  # Average readings (spectra); -1 to average all readings with the same sample name
  json_output <- append(
    json_output, list(list(id = 7, params = list(-1), index = count))
  )
  count <- count + 1

  # Iterate over each preprocessing instruction in the object$preprocess
  i <- 0
  for (preprocess in object$preprocess$steps) {
    i <- i + 1
    preprocess_method <- preprocess$method

    if (!preprocess_method %in% c("prep_resample")) {
      json_instruction <- parse_preprocessing(preprocess_method, preprocess, count)
      if (!is.null(json_instruction)) {
        count <- count + 1
        json_output <- append(json_output, list(json_instruction))
      }
    }

    wav_indices <- which(
      is_close_to_any(current_wavs, object$processed_wavs[[paste0("step_", i)]], tol = 0.1)
    )

    if (length(wav_indices) < length(current_wavs)) {
      json_output <- append(
        json_output,
        list(list(id = 17, params = as.list(wav_indices - 1), index = count))
      )
      count <- count + 1
    }
    current_wavs <- current_wavs[wav_indices]
  }

  # second variable selection for accounting for trimming at the
  # edges of the spectra
  pred_vars <- as.numeric(object$predictor_variables)
  # allow for small decimal discrepancies in wavenumbers
  if (!all(is_close_to_any(pred_vars, hw_wavs, tol = 0.1))) {
    stop("The model raw spectra contains wavenumbers not measured by neospectra")
  }
  # # Take the wavenumbers from the updated wavs which are closest to the predictors
  # var_sel2 <- which(is_close_to_any(updated_wavs, pred_vars, tol = 0.1))
  # if (!identical(var_sel2, var_sel)) {
  #   json_output <- append(
  #     json_output,
  #     list(list(id = 17, params = as.list(var_sel2 - 1), index = count))
  #   )
  #   count <- count + 1
  # }

  # Subtract the X-mean
  json_output <- append(
    json_output,
    list(
      list(
        id = 43,
        params = as.list(as.numeric(format(as.vector(object$final_model$model$x_means), nsmall = 10))),
        index = count
      )
    )
  )
  # Add model
  my_model <- c(
    object$final_model$model$intercept,
    object$final_model$model$coefficients[object$final_model$ncomp, ]
  )
  my_model <- as.vector(my_model)
  json_output <- append(
    json_output,
    list(
      list(
        id = 13,
        params = as.list(my_model),
        index = count + 1
      )
    )
  )
  # Convert the list to JSON format
  json_result <- toJSON(json_output, auto_unbox = TRUE, pretty = TRUE, digits = 8)
  if (!is.null(file)) {
    if (!is.character(file) || length(file) != 1) {
      stop("'file' must be a single character string.")
    }
    writeLines(json_result, con = file)
    return(invisible(json_result))
  }
  json_result
}

# Define a helper function to parse the preprocessing instructions
parse_preprocessing <- function(preprocess_method, preprocess_params, index) {
  if (preprocess_method == "prep_transform") {
    if (preprocess_params$to == "absorbance") {
      return(list(id = 29, params = list(), index = index))
    } else {
      warning(
        "The model contains 'prep_transform' with 'to = reflectance', which",
        " is not supported by ProxiScout and therefore ignored.",
        " Did you mean to use prep_transform(to = 'absorbance') instead?"
      )
      return(NULL)
    }
  } else if (preprocess_method == "prep_snv") {
    return(list(id = 2, params = list(), index = index))
  } else if (preprocess_method == "prep_detrend") {
    p <- preprocess_params$p
    return(list(id = 3, params = list(p), index = index))
  } else if (preprocess_method == "prep_resample") {
    # No need to do anything here
    return(NULL)
  } else if (preprocess_method == "prep_wav_trim") {
    # No need to do anything here, as the wavelength selection handles the trimming
    return(NULL)
  } else if (preprocess_method == "prep_derivative" || preprocess_method == "prep_smooth") {
    m <- preprocess_params[["m"]]
    # For prep_smooth, m is NULL (smoothing only), treat as derivative order 0
    if (is.null(m)) m <- 0L
    w <- preprocess_params$w
    p <- preprocess_params$p
    algorithm <- preprocess_params$algorithm
    if (algorithm == "savitzky-golay") {
      sg_filter <- sgf(p = p, n = w, m = m)
      mode <- 119L # mode option in savgol_filter() function in Python
      return(list(
        id = 83,
        params = c(list(w, p, m, mode, 1.0, 0.0), as.list(rev(sg_filter))),
        index = index
      ))
    } else {
      stop("Only 'savitzky-golay' is supported for ProxiScout serialization.")
    }
  } else {
    stop("Unknown preprocessing command")
  }
}

#' @title Calculate filter for Savitzky-Golay
#' @return A numeric matrix containing the Savitzky-Golay filter coefficients.
#' @keywords internal
sgf <- function(p, n, m = 0) {
  Fm <- matrix(0, 1, n)
  k <- floor(n / 2) + 1
  Ce <- (((1:n) - k) %*% matrix(1, 1, p + 1))^(matrix(1, n) %*% (0:p))
  svd_result <- svd(Ce)
  A <- svd_result$v %*% diag(1 / svd_result$d) %*% t(svd_result$u)
  Fm[1, ] <- A[1 + m, ]
  if (m > 0) {
    Fm <- Fm * prod(1:m)
  }
  Fm
}
