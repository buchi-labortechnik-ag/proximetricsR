#' @title Recalibrate a nax file
#'
#' @description
#'
#' \loadmathjax
#' This function updates a nax file
#' @usage
#'
#' proximate_recalibrate_nax(x,
#'                           preprocess_recipes = NULL,
#'                           methods = NULL,
#'                           control = calibration_control(seed = 1),
#'                           name,
#'                           add = NULL)
#' 
#' @param x an object of class \code{nax} as returned by the
#' \code{\link{proximate_read_nax}} function.
#' @param preprocess_recipes an optional list with one or more objects of class
#' \code{\link{preprocess_recipe}} that are to be tested for finding the
#' optimal one for each model in the list passed to \code{formulas}.
#' @param methods an optional list containing one ore more objects of class
#' \code{fit_constructor} which are as returned by one of the
#' \code{\link{fit_constructors}} functions, indicating what type of regression method
#' to use along with its parameters.
#' @param control a \code{calibration_control} object as returned by the
#' \code{\link{calibration_control}} function, indicating how some aspects of
#' the calibration process must be conducted (e.g. cross-validation and outlier
#' detection). Default is \code{calibration_control(seed = 1)}. See details.
#' @param name a vector length at most 2, consisting of characters for the name
#' and alias of the application. Defaults to "Untitled".
#' @param add an optional object of class \code{nax_augment} as returned by the
#' \code{\link{proximate_add2nax}} function.
#'
#' @author
#' Leonardo Ramirez-Lopez and Claudio Orellano
#'
#' @return
#'
#' A list of class \code{"spectral_multimodel"}. See \code{\link{calibrate_models}}
#' function.
#'
#' @seealso
#'
#' \code{\link{proximate_add2nax}}
#'
#' \code{\link{calibrate}},
#'
#' \code{\link{preprocess_recipe}},
#'
#' \code{\link{fit_plsr}},
#'
#' \code{\link{fit_xlsr}},
#'
#' \code{\link{calibration_control}},
#'
#' \code{\link{calibrate_models}}
#'
#' @export


# # to include in the update/autocal function:
# # - a field for a tsv
# # - a field for preprocessing recipes
# # - a field for formulas/properties
# # - a filed for calibration control
# # - a field for method
# # - a filed for fixing the IDs
# # all this must be in the same order as in optimize model
# # Considerations:
# # - Not all the properties need to be updated. But probably all of them need to
# # be recalibrated... the local files might be of importance for some cal files :/
# # - the name of the tsv must remain identical and all the files
# # - the new tsv must cover at least the same spectral range as in the nax tsv
#

#
#
# my_app = "/home/rl_leonardo/Downloads/Wheat Flour Up.nax"
#


# x
# x$cal_info$file_info[[1]]
#
#
# my_nax
#

proximate_recalibrate_nax <- function(x,
                                      preprocess_recipes = NULL,
                                      methods = NULL,
                                      control = calibration_control(seed = 1),
                                      name,
                                      add = NULL) {
  if ("Protected" %in% x$data$summary) {
    warning("The calibration data in 'x' is protected. Aborting update.")
    return(NULL)
  }

  if ("Protected" %in% x$cal_info$summary) {
    warning("Protected calibration model(s) in 'x'. Aborting update.")
    return(NULL)
  }

  warning("This is an experiental function!\U0001f609 Feedback is highly appreciated \U0001f64c")

  rformulas <- lapply(paste0(x$cal_info$summary$Property, " ~ spc"), FUN = formula)

  x$data$summary$path <- paste0("/", x$data$summary$Location, "/", x$data$summary$File, ".tsv")

  if (missing(name)) {
    name <- x$nad_info$summary$app_name
    name <- paste0(name, "-", Sys.Date())
    alias <- x$nad_info$data[[1]]$value[x$nad_info$data[[1]]$param == "Alias"]
    if (grepl("alias", alias, ignore.case = TRUE)) {
      name <- c(name = name, alias = alias)
    }
  }

  new_indices <- NULL
  ith_n <- 0
  for (i in 1:nrow(x$data$summary)) {
    if (x$data$summary$n[i] > 0) {
      new_indices <- rbind(
        new_indices,
        data.frame(
          path = x$data$summary$path[i],
          orig_index = 1:x$data$summary$n[i],
          new_indices = (1:x$data$summary$n[i]) + ith_n
        )
      )
      ith_n <- ith_n + nrow(new_indices)
    }
  }

  skip_idcs <- NULL
  for (i in seq_along(x$cal_info$file_info)) {
    new_idc <- numeric()
    for (j in x$cal_info$file_info[[i]]$files$File) {
      x$cal_info$file_info[[i]]$skipped_indices[[j]]
      x$data$summary$File
      idx <- which(x$cal_info$file_info[[i]]$files$File == j)
      fname <- x$cal_info$file_info[[i]]$files$Path[idx]
      x$data$summary$path %in% fname
      ij_toskip <- x$cal_info$file_info[[i]]$skipped_indices[[j]]
      ij_idcs <- new_indices$new_indices[new_indices$path %in% fname]
      ij_idcs <- ij_idcs[x$cal_info$file_info[[i]]$skipped_indices[[j]]]
      new_idc <- c(new_idc, ij_idcs)
    }
    skip_idcs[[i]] <- sort(new_idc)
  }

  skip_idcs

  metad_m <- NULL
  iter <- 1
  for (i in x$cal_info$summary$Property) {
    nad_idx <- sapply(
      x$nad_info$data,
      FUN = function(xx, test) xx$value[xx$param == "Name"] == test,
      test = i
    )
    ith_meta <- x$nad_info$data[[which(nad_idx)]]
    dec_p <- as.numeric(ith_meta$value[ith_meta$param == "DecimalPlaces"])
    p_unit <- ith_meta$value[ith_meta$param == "Unit"]
    p_unit <- ifelse(p_unit == "null", "", p_unit)
    mahal <- as.numeric(ith_meta$value[ith_meta$param == "MahalanobisLimit"])
    wav_range <- ith_meta$value[ith_meta$param == "WavelengthRange"]
    ## FIXME: DOCUMENT WHAT IS NOT UPDATED OR WHAT IS RESET
    metad_m[[iter]] <- add_model_metadata(
      # name = c("", NULL),
      # sort_order = 1,
      # tol_min = NULL,
      # tol_max = NULL,
      decimal_places = dec_p,
      unit = p_unit,
      mahal_limit = mahal,
      # corrections = c(bias = 0, slope = 1),
      # limit_min = NULL,
      # limit_max = NULL,
      # target = NULL,
      wavelength_range = wav_range
    )
    iter <- 1 + iter
  }

  iter <- 1
  p_recipes <- NULL
  for (i in x$cal_info$summary$Property) {
    cidx <- which(names(x$cal_info$meta_param) %in% i)
    p_recipes[[iter]] <- x$cal_info$meta_param[[cidx]]$precipe
    iter <- 1 + iter
  }

  mdata <- proximate_merge(x$data$data[!is.na(x$data$data)])

  if (!is.null(add)) {
    if (!"nax_augment" %in% class(add)) {
      stop("Invalid object passed to argument 'add'. It must be of class 'nax_augment', as generated by proximate_add2nax()")
    }

    if (!is.null(add$formulas)) {
      rformulas <- c(rformulas, add$formulas)
    }

    n_orig <- nrow(mdata)
    mdata <- proximate_merge(list(mdata, add$data))

    add_meta <- NULL
    if (!is.null(add$metadata_list)) {
      add_meta <- add$metadata_list
    } else {
      if (!is.null(add$formulas)) {
        add_meta <- lapply(
          seq_along(add$formulas),
          FUN = function(x) add_model_metadata()
        )
      }
    }
    metad_m <- c(metad_m, add_meta)

    add_skip <- NULL
    if (!is.null(add$skip_indices_list)) {
      add_skip <- lapply(
        add$skip_indices_list,
        FUN = function(x, offset) add$skip_indices_list + offset,
        offset = n_orig
      )
    } else {
      if (!is.null(add$formulas)) {
        add_skip <- lapply(
          seq_along(add$formulas),
          FUN = function(x) numeric()
        )
      }
    }
    skip_idcs <- c(skip_idcs, add_skip)
  }
  p_recipes <- unique(c(p_recipes, preprocess_recipes))

  if (is.null(methods)) {
    mtds <- unique(x$cal_info$summary$Method)
    methods <- list()
    if (mtds %in% "PLS") {
      methods$mpls <- fit_plsr(15)
    }

    if (mtds %in% "XLS") {
      methods$mxls <- fit_xlsr(15)
    }
  }
  # FIXME: make proper use of ...
  omodels <- calibrate_models(
    formulas = rformulas,
    data = mdata,
    group = NULL,
    preprocess_recipes = p_recipes,
    methods = methods,
    control = control,
    metadata_list = metad_m,
    skip_indices_list = skip_idcs,
    return_inputs = TRUE,
    verbose = TRUE,
    save_all = FALSE
  )


  nview <- x$nad_info$data[[1]]$value[x$nad_info$data[[1]]$param == "ViewType"]
  nmode <- x$nad_info$data[[1]]$value[x$nad_info$data[[1]]$param == "MeasurementMode"]

  # add some important metadata to the application/model list
  omodels <- add_application_metadata(
    omodels$final_models,
    view = nview,
    measurement_mode = nmode,
    name = name,
    description = "created with proximetricsR R software - recalibrated"
  )

  return(omodels)
}
