#' @title A function for adding model metadata to a \code{spectral_model} object
#'
#' @description
#'
#' \loadmathjax
#'
#' This function has two use cases:
#'
#' i. If \code{object} (being a \code{spectral_model} object) is passed to the
#' function, it returns the same object with the specified model metadata added
#' to it.
#'
#' ii. Otherwise, the function creates a a list of model metadata that can be used
#' as input for the argument \code{metadata} of the \code{\link{calibrate}} function.
#'
#' @usage
#' 
#' add_model_metadata(object, key = UUIDgenerate(), created, changed,
#'                    name = c("", NULL), sort_order = 1, tol_min = NULL,
#'                    tol_max = NULL, decimal_places = 2, unit = "",
#'                    mahal_limit = 5, corrections = c(bias = 0, slope = 1),
#'                    limit_min = NULL, limit_max = NULL, target = NULL,
#'                    wavelength_range = c("Nir", "Vis", "Nir+Vis"),
#'                    predict_type = "Calibration", arguments = rep("", 4))
#'
#' @param object an optional object of class \code{spectral_model}. See details.
#' @param key a string for the key of the model. Defaults to a newly
#' generated key using \code{\link[uuid]{UUIDgenerate}}.
#' @param created a string for date and time of the addition of the model
#' to the application. Default is the current date and time of the system.
#' See details for the format in which it has to be provided.
#' @param changed a string for date and time when the model has been changed.
#' Default is the current date and time of the system. See details for the format
#' in which it has to be provided.
#' @param name a vector of character strings of length 2 for the name and alias
#' of the property. If \code{object} is given or an object returned by this
#' function is passed to \code{\link{calibrate}}, defaults to the name of the
#' property (but not the alias). Otherwise, defaults to an empty character.
#' @param sort_order a numeric, indicating the order in which the properties
#' are shown on a ProxiMate device. Defaults to 1.
#' @param tol_min an optional numeric for the minimum error tolerance.
#' Defaults to \code{NULL}.
#' @param tol_max an optional numeric for the maximal error tolerance.
#' Defaults to \code{NULL}.
#' @param decimal_places a numeric for the decimal precision of the measurements
#' of the property. Defaults to 2.
#' @param unit a string for the units in which the reference values of the
#' property are measured. Defaults to an empty character.
#' @param mahal_limit a numeric for the maximum Mahalanobis distance allowed.
#' Defaults to 5.
#' @param corrections a vector of numerics of length 2 for bias and slope
#' corrections. Defaults to no corrections, i.e. \code{c(0, 1)}.
#' @param limit_min an optional numeric for the lower limit of the reference
#' values. Defaults to \code{NULL}.
#' @param limit_max an optional numeric for the upper limit of the reference
#' values. Defaults to \code{NULL}.
#' @param target an optional numeric for the desired predicted reference values.
#' Defaults to \code{NULL}.
#' @param wavelength_range a string for the considered wavelength range of the
#' spectrum. Must be one of \code{"Nir"} (default), \code{"Vis"} or \code{"Nir+Vis"}.
#' @param predict_type a string for the prediction type of the model. Defaults
#' to \code{"Calibration"}.
#' @param arguments a vector of maximal length 4. Contains additional arguments
#' to be saved into the metadata. Defaults to a vector of empty characters of length 4.
#'
#' @details
#' This function has two functionalities:
#'
#' \itemize{
#' \item If \code{object} (being a \code{spectral_model} object) is passed
#' to the function, it returns the same object with the specified property
#' metadata added to it.
#'
#' \item Otherwise, the function creates a a list of property metadata
#' that can be used as the argument \code{metadata} of the \code{\link{calibrate}} function.
#' }
#'
#' The two-fold functionality of this function allows to add metadata during the
#' construction of the model, or after the model-building has been finished.
#' For the former, the model has to be passed in \code{object}, and the returned
#' value of this function contains the model including the chosen metadata.
#' In the latter case, the returned value of this function may be passed to the
#' parameter \code{metadata} of function \code{\link{calibrate}}.
#'
#' A lot of the parameters can be left unchanged and may be adjusted at a later
#' stage of the application development (e.g. in a ProxiMate device).
#'
#' The parameters \code{created} and \code{changed} must contain the date
#' (\code{YYYY-MM-DD}) and time (\code{HH:MM:SS}), seperated by a single
#' \code{"T"} (without any spaces). For example, the following code returns
#' the correct format (also, both \code{created} and \code{changed} default to this
#' value):
#'
#' \code{gsub(" ", "T", format(Sys.time()))}
#'
#'
#' @return Either the \code{spectral_model} object with the added property metadata
#' (if \code{object} is provided), or the property metadata, which is a named list.
#'
#' @seealso \code{\link{calibrate}}, \code{\link{proximate_write_nax}}
#' @examples
#' \donttest{
#' data(NIRcannabis)
#'
#' # Downview Absorbance of CBDA in percentage
#' downview_metadata <- add_model_metadata(
#'   name = "CBDA",
#'   unit = "%",
#'   arguments = "Example metadata"
#' )
#'
#' # Three ways to add metadata to spectral_model object:
#' # As a direct argument
#' simple_model <- calibrate(CBDA ~ spc,
#'   data = NIRcannabis, preprocess = preprocess_recipe(),
#'   method = fit_plsr(5), control = calibration_control(),
#'   metadata = downview_metadata
#' )
#'
#' # Passing the model to add_model_metadata
#' simple_model <- add_model_metadata(
#'   object = simple_model,
#'   name = "CBDA",
#'   unit = "%",
#'   arguments = "Example metadata"
#' )
#'
#' # Adding it directly (not recommended)
#' simple_model$metadata <- downview_metadata
#' }
#' @author Claudio Orellano, Leonardo Ramirez-Lopez
#' @import uuid
#' @export

add_model_metadata <- function(
  object,
  key = UUIDgenerate(),
  created,
  changed,
  name = c("", NULL),
  sort_order = 1,
  tol_min = NULL,
  tol_max = NULL,
  decimal_places = 2,
  unit = "",
  mahal_limit = 5,
  corrections = c(bias = 0, slope = 1),
  limit_min = NULL,
  limit_max = NULL,
  target = NULL,
  wavelength_range = c("Nir", "Vis", "Nir+Vis"),
  predict_type = "Calibration",
  arguments = rep("", 4)
) {
  wavelength_range <- match.arg(wavelength_range)
  if (!missing(object)) {
    if (!"spectral_model" %in% class(object)) {
      stop("If provided, parameter 'object' must be of class 'spectral_model'.")
    }
  }
  orig_secs <- getOption("digits.secs")
  options(digits.secs = 6)
  on.exit(options(digits.secs = orig_secs))

  if (missing(created)) {
    created <- gsub(" ", "T", format(Sys.time()))
  }
  if (missing(changed)) {
    changed <- gsub(" ", "T", format(Sys.time()))
  }
  if (!is.character(created) || !is.character(changed)) {
    stop("The parameters 'created' and 'change' must be characters")
  }
  if (!grepl("T", created, fixed = TRUE) || !grepl("T", changed, fixed = TRUE)) {
    wrn <- paste(
      "Both created and changed must be of the following form:",
      "'dateTtime'. Might result in errors while importing.",
      "The following returns the correct format for the current time:",
      "gsub(' ', 'T', format(Sys.time()))"
    )
    warning(wrn)
  }
  if (!is.character(key)) {
    stop("Parameter 'key' has to be a character")
  }
  if (!all(is.character(name))) {
    stop("Property name and alias ('name') has to be a vector of characters")
  }
  if (length(name) > 1) {
    alias <- name[2]
  } else {
    alias <- NULL
  }
  if (!is.numeric(sort_order)) {
    stop("Parameter 'sort_order' has to be a numeric")
  }
  if (!is.numeric(tol_min) & !is.null(tol_min)) {
    stop("Parameter 'tol_min' has to be a numeric or 'NULL'")
  }
  if (!is.numeric(tol_max) & !is.null(tol_max)) {
    stop("Parameter 'tol_max' has to be a numeric or 'NULL'")
  }
  if (!is.numeric(decimal_places)) {
    stop("Parameter 'decimal_places' has to be a numeric")
  }
  if (!is.numeric(mahal_limit)) {
    stop("Parameter 'mahal_limit' has to be a numeric")
  }
  if (!is.character(unit)) {
    stop("Parameter 'unit' has to be a character")
  }
  if (!is.numeric(corrections) || length(corrections) != 2) {
    stop("Invalid bias and slope correction parameter 'corrections'. Has to be a vector of numerics of length 2")
  }
  if (!is.numeric(limit_min) & !is.null(limit_min)) {
    stop("Parameter 'limit_min' has to be a numeric or 'NULL'.")
  }
  if (!is.numeric(limit_max) & !is.null(limit_max)) {
    stop("Paramter 'limit_max' has to be a numeric or 'NULL'.")
  }
  if (!is.character(target) & !is.null(target)) {
    stop("Parameter 'target' has to be either a character or 'NULL'.")
  }
  if (!predict_type %in% c("Calibration")) {
    stop("Parameter 'predict_type' has to be one of 'Calibration', ... ")
  }
  if (length(arguments) < 4) {
    arguments <- c(arguments, rep("", 4 - length(arguments)))
  }

  property_meta <- list(
    Key = key,
    Created = created,
    Changed = changed,
    Name = unname(name[1]),
    Alias = unname(alias),
    SortOrder = sort_order,
    ToleranceMin = tol_min,
    DecimalPlaces = decimal_places,
    Unit = unit,
    ToleranceMax = tol_max,
    MahalanobisLimit = mahal_limit,
    Bias = unname(corrections[1]),
    Slope = unname(corrections[2]),
    LimitMin = limit_min,
    LimitMax = limit_max,
    Target = target,
    WavelengthRange = wavelength_range,
    PredictionType = paste0(predict_type, "Model"),
    Argument1 = NULL,
    Argument2 = arguments[1],
    Argument3 = arguments[2],
    Argument4 = arguments[3],
    Argument5 = arguments[4]
  )
  class(property_meta) <- c("list", "model_metadata")
  if (!missing(object)) {
    if (!is.null(object$target_variable)) {
      if (property_meta$Name == "") {
        property_meta$Name <- object$target_variable
      }
    }
    object$metadata <- property_meta
    return_object <- object
  } else {
    return_object <- property_meta
  }
  return_object
}


#' @title A function for adding application metadata to a list of \code{spectral_model}
#' objects
#'
#' @description
#'
#' \loadmathjax
#'
#' This function has two use cases:
#'
#' i. If \code{object} (a list of \code{spectral_model} objects) is passed to the
#' function, it returns the same object with the specified application metadata
#' added to it.
#'
#' ii. Otherwise, the function can be used to create a list of application
#' metadata that can be used as input for the argument \code{metadata} of the
#' \code{\link{proximate_write_nax}} function.
#'
#' @usage
#'
#' add_application_metadata(object, key = UUIDgenerate(),
#'                          name = c(name = "Untitled", alias = NULL),
#'                          view = c("Up", "Down"), 
#'                          measurement_mode = c("DrIwr", "TrIwr"),
#'                          measurement_time = 15,
#'                          absorbmask_low = c(min = 0, max = 0),
#'                          absorbmask_high = c(min = 0, max = 0),
#'                          rotate_sample = TRUE,
#'                          selectable = TRUE, created, changed,
#'                          composition = NULL,
#'                          description = "created with proximetricsR",
#'                          sop = "",
#'                          presentation_id = "Default")
#' 
#' @param object an optional object, consisting of a list of objects
#' of class \code{spectral_model}. See details.
#' @param key a string for the key of the application. Defaults to a newly
#' generated key using \code{\link[uuid]{UUIDgenerate}}.
#' @param name a vector length at most 2, consisting of characters for
#' the name and alias of the application. Defaults to \code{"Untitled"}.
#' @param view a string for the type of view in the application. Has to be either
#' \code{"Up"} (default) or \code{"Down"}.
#' @param measurement_mode a string, indicating how the samples were measured.
#' Has to be either Diffuse Reflection (\code{"DrIwr"}, default) or
#' Transflection (\code{"TrIwr"}).
#' @param measurement_time a numeric for the time each sample in the application
#' should be measured, in seconds. Defaults to 15 seconds.
#' @param absorbmask_low a vector of numerics of length 2 for the minimum and
#' maximum of the lower absorbance mask. Defaults to a vector of zeros.
#' @param absorbmask_high a vector of numerics of length 2 for the minimum and
#' maximum of the higher absorbance mask. Defaults to a vector of zeros.
#' @param rotate_sample a logical. Should the sample be rotated? Defaults to
#' \code{TRUE}.
#' @param selectable a logical, whether the application should be selectable.
#' Defaults to \code{TRUE}.
#' @param created a string of date and time of the creation of the
#' application. Default is the current date and time of the system. See
#' details for the format in which it has to be provided.
#' @param changed a string of date and time when the application was changed.
#' Defaults to the current date and time of the system. See details for the
#' format in which it has to be provided.
#' @param composition an optional string for the composition of the application.
#' Defaults to \code{NULL}.
#' @param description an optional string for the description of the application.
#' Defaults to \code{"created with proximetricsR"}.
#' @param sop a string for the standard operating procedure (sop) for this
#' particular application. Defaults to an empty character.
#' @param presentation_id a string for the sample presentation ID of the
#' application. Default is \code{"Default"}.
#'
#' @details
#' This function has two functionalities:
#'
#' \itemize{
#' \item If \code{object} (a list of \code{spectral_model} objects) is passed to the
#' function, it returns the same object with the specified application metadata
#' added to it.
#' \item Otherwise, the function can be used to create a list of application
#' metadata that can be used as input for the argument \code{metadata} of the
#' \code{\link{proximate_write_nax}} function.
#' }
#'
#' The application metadata is required for the import of an application into a
#' ProxiMate device.
#'
#' The two-fold functionality of this function allows to add application metadata
#' during the construction of the models, or after the model-building processes
#' have been finished. In the former case, a list of models of class \code{spectral_model}
#' must be passed in \code{object}. Then, the returned object of this function
#' contains the same list of models, including the specified metadata. Models can
#' also be added or removed from that list, without changing the application
#' metadata.
#' In the latter case, the returned value of this function may be passed to the
#' parameter \code{metadata} of function \code{\link{proximate_write_nax}}.
#'
#' A lot of the parameters can be left unchanged and may be adjusted at a later
#' stage of the application development (e.g. in a ProxiMate device). However,
#' several parameters are of great importance for a successful migration of the
#' application:
#'
#' The parameter \code{view} describes if the spectrum is measured by either
#' up-view \code{"Up"} or down-view \code{"Down"}.
#'
#' The \code{measurement_mode} describes how the samples are measured, with
#' the following possibilities: Diffuse Reflection \code{"DrIwr"} or Transflection
#' \code{"TrIwr"}.
#'
#' The parameters \code{created} and \code{changed} must contain the date
#' (\code{YYYY-MM-DD}) and time (\code{HH:MM:SS}), seperated by a single
#' \code{"T"} (without any spaces).
#' For example, the following code returns the correct format (both
#' \code{created} and \code{changed} default to this value):
#'
#' \code{gsub(" ", "T", format(Sys.time()))}
#'
#' @return Either the list of \code{spectral_model} objects with the added application
#' metadata (if \code{object} is provided), or the application metadata as a named list.
#'
#' @seealso \code{\link{calibrate}}, \code{\link{proximate_write_nax}}
#' @examples
#' \donttest{
#' data(NIRcannabis)
#'
#' # Downview Absorbance of CBDA in percentage
#' downview_metadata <- add_application_metadata(
#'   name = "CBDA Downview",
#'   view = "Down",
#'   measurement_mode = "DrIwr"
#' )
#'
#' # Create a simple model with default model metadata
#' simple_model <- calibrate(CBDA ~ spc,
#'   data = NIRcannabis, preprocess = preprocess_recipe(),
#'   method = fit_plsr(5), control = calibration_control(),
#'   metadata = add_model_metadata(), verbose = FALSE
#' )
#'
#' # Two ways to add application metadata to a list of spectral_model objects:
#' model_list <- list(simple_model)
#'
#' # Using the add_application_metadata 'object' argument
#' model_list <- add_application_metadata(
#'   object = model_list,
#'   name = "CBDA Downview",
#'   view = "Down",
#'   measurement_mode = "TrIwr"
#' )
#'
#' # Adding it manually
#' model_list$metadata <- downview_metadata
#'
#' # Alternatively, if you are creating an application, you can also pass
#' # application metadata to 'proximate_write_nax':
#' proximate_write_nax(
#'   object = model_list,
#'   path = tempdir(),
#'   metadata = downview_metadata,
#'   tsv_name = "some_tsv",
#'   empty_tsv_name = "another_tsv",
#'   report = TRUE,
#'   verbose = FALSE
#' )
#' }
#' @author Claudio Orellano, Leonardo Ramirez-Lopez
#' @import uuid
#' @export
add_application_metadata <- function(
  object,
  key = UUIDgenerate(),
  name = c(name = "Untitled", alias = NULL),
  view = c("Up", "Down"),
  measurement_mode = c("DrIwr", "TrIwr"),
  measurement_time = 15,
  absorbmask_low = c(min = 0, max = 0),
  absorbmask_high = c(min = 0, max = 0),
  rotate_sample = TRUE,
  selectable = TRUE,
  created,
  changed,
  composition = NULL,
  description = "created with proximetricsR",
  sop = "",
  presentation_id = "Default"
) {
  view <- match.arg(view)
  measurement_mode <- match.arg(measurement_mode)
  if (!missing(object)) {
    if (!is.list(object)) {
      stop("If provided, the 'object' must be a list.")
    }
    if (!is.null(object$metadata)) {
      # Overwrite metadata if it already exists.
      object$metadata <- NULL
    }
    if (!all(sapply(object, inherits, "spectral_model"))) {
      stop("If provided, all list elements of 'object' should be of class 'spectral_model'.")
    }
  }
  orig_secs <- getOption("digits.secs")
  options(digits.secs = 6)
  on.exit(options(digits.secs = orig_secs))
  if (missing(created)) {
    created <- gsub(" ", "T", format(Sys.time()))
  }
  if (missing(changed)) {
    changed <- gsub(" ", "T", format(Sys.time()))
  }
  if (!all(is.character(name))) {
    stop("Application name and alias ('name') has to be a vector of characters")
  }
  if (length(name) > 1) {
    alias <- name[2]
  } else {
    alias <- NULL
  }
  if (!is.character(key)) {
    stop("Parameter 'key' has to be a character.")
  }
  if (!is.numeric(measurement_time)) {
    stop("Parameter 'measurement_time' has to be a numeric.")
  }
  if (!is.numeric(absorbmask_low) || !is.numeric(absorbmask_high)) {
    stop("Parameters for the absorbance masks have to be vectors of numerics.")
  }
  if (length(absorbmask_low) != 2 || length(absorbmask_high) != 2) {
    stop("Parameters for the absorbance masks have to be vectors of length 2.")
  }
  if (!is.logical(rotate_sample)) {
    stop("Parameter 'rotate_sample' has to be a logical.")
  }
  if (!is.logical(selectable)) {
    stop("Parameter 'selectable' has to be a logical.")
  }
  if (!is.character(created) | !is.character(changed)) {
    stop("The time for creation and change must both be a character.")
  }
  if (!grepl("T", created, fixed = TRUE) || !grepl("T", changed, fixed = TRUE)) {
    wrn <- paste(
      "Both created and changed must be of the following form:",
      "'dateTtime'. Might result in errors while importing.",
      "The following returns the correct format for the current time:",
      "gsub(' ', 'T', format(Sys.time()))"
    )
    warning(wrn)
  }
  if (!is.character(description)) {
    stop("Parameter 'description' has to be a character.")
  }
  if (!is.character(sop)) {
    stop("Parameter 'sop' has to be a character.")
  }
  if (!is.null(composition) & !is.character(composition)) {
    stop("Parameter 'composition' has to be either a character or 'NULL'.")
  }
  if (!is.character(presentation_id)) {
    stop("Paramter 'presentation_id' has to be a character.")
  }
  application_meta <- list(
    Key = key,
    Name = unname(name[1]),
    Alias = unname(alias),
    ViewType = view,
    MeasurementMode = measurement_mode,
    MeasurementTime = measurement_time,
    AbsorbancemaskLowMax = unname(absorbmask_low[2]),
    AbsorbancemaskLowMin = unname(absorbmask_low[1]),
    AbsorbancemaskHighMax = unname(absorbmask_high[2]),
    AbsorbancemaskHighMin = unname(absorbmask_high[1]),
    RotateSample = rotate_sample,
    Selectable = selectable,
    Created = created,
    Changed = changed,
    Composition = composition,
    Description = description,
    Sop = sop,
    SamplePresentationId = presentation_id
  )
  class(application_meta) <- c("list", "application_metadata")
  if (!missing(object)) {
    object$metadata <- application_meta
    return_object <- object
  } else {
    return_object <- application_meta
  }
  return_object
}
