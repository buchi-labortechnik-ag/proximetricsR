#' @title Writes metadata required for a Proximate application file
#' @description
#'
#' Internal function for generating a metadata file required for creating a
#' ProxiMate application.
#'
#' @usage
#' write_nad(object, path, application_meta, external_properties = NULL, verbose = TRUE)
#' @param object a list of models of class \code{spectral_model} for which the
#' metadata files should be generated.
#' @param path a string for the directory in which the files will be saved.
#' @param application_meta a list of class \code{application_metadata}, containing
#' the metadata for the application. See \code{\link{add_application_metadata}}.
#' @param external_properties a list of external properties. More details in
#' \code{\link{proximate_write_nax}}. Defaults to \code{NULL}.
#' @param verbose a logical. Should messages about the generated files be printed?
#' Default is \code{TRUE}.
#'
#' @details
#' This function takes a list of models of class \code{spectral_model} and generates
#' the corresponding metadata file (.nad). This file allows the ProxiMate
#' calibration software to import a .nax file. Thus, the main purpose of this
#' file is to added to the zip structure of an application file (.nax). See
#' \code{\link{proximate_write_nax}} for more details on how this file is used.
#'
#' Note that it is crucial for all provided models to have some metadata added.
#'
#' @return Invisibly returns \code{NULL}. Called for its side effect of
#' writing a \code{.nad} metadata file to \code{path}.
#' @author Claudio Orellano, Leonardo Ramirez-Lopez
#' @keywords internal
write_nad <- function(object, path, application_meta, external_properties = NULL, verbose = TRUE) {
  # Sanity checks
  if (!all(sapply(object, inherits, what = "spectral_model"))) {
    stop("All entries in 'object' must be of class 'spectral_model'.")
  }
  if (!is.character(path)) {
    stop("'path' must be a character")
  }
  if (!inherits(application_meta, "application_metadata")) {
    warning("'application_meta' is not of class 'application_metadata', which can cause errors.")
  }
  if (sub(".*(?=.{1}$)", "", path, perl = T) != "/") {
    path <- paste0(path, "/")
  }

  # Create .nad file
  application_name <- application_meta$Name
  file_name <- paste0(path, application_name, ".nad")
  for (meta_name in names(application_meta)) {
    if (is.character(application_meta[[meta_name]])) {
      application_meta[[meta_name]] <- paste0(
        '"',
        application_meta[[meta_name]],
        '"'
      )
    }
    if (is.logical(application_meta[[meta_name]])) {
      if (application_meta[[meta_name]]) {
        application_meta[[meta_name]] <- "true"
      } else {
        application_meta[[meta_name]] <- "false"
      }
    }
    if (is.null(application_meta[[meta_name]])) {
      application_meta[[meta_name]] <- "null"
    }
  }
  string_application_meta <- paste(
    paste0('"', names(application_meta), '"'),
    application_meta,
    sep = ":",
    collapse = ","
  )

  string_property_meta <- list()
  for (model in object) {
    property_meta <- model$metadata
    # Bring everything into right format
    for (meta_name in names(property_meta)) {
      if (is.character(property_meta[[meta_name]])) {
        property_meta[[meta_name]] <- paste0(
          '"',
          property_meta[[meta_name]],
          '"'
        )
      }
      if (is.null(property_meta[[meta_name]])) {
        property_meta[[meta_name]] <- "null"
      }
    }
    string_property_meta <- append(
      string_property_meta,
      paste(
        paste0('"', names(property_meta), '"'),
        property_meta,
        sep = ":",
        collapse = ","
      )
    )
  }

  if (!is.null(external_properties)) {
    for (ext_property in external_properties) {
      ext_property_name <- ext_property$Name
      if (is.null(ext_property$Argument1)) {
        ext_property$Argument1 <- paste0(application_name, ".", ext_property_name, ".cal")
      }
      for (ext_meta_name in names(ext_property)) {
        if (is.character(ext_property[[ext_meta_name]])) {
          ext_property[[ext_meta_name]] <- paste0(
            '"',
            ext_property[[ext_meta_name]],
            '"'
          )
        }
        if (is.null(ext_property[[ext_meta_name]])) {
          ext_property[[ext_meta_name]] <- "null"
        }
      }
      string_property_meta <- append(
        string_property_meta,
        paste(
          paste0('"', names(ext_property), '"'),
          ext_property,
          sep = ":",
          collapse = ","
        )
      )
    }
  }

  string_property_meta <- paste0(
    "[{",
    paste0(string_property_meta, collapse = "},{"),
    "}]"
  )

  output <- paste0(
    "{",
    string_application_meta,
    ',"Properties":',
    string_property_meta,
    "}"
  )
  writeLines(output, con = file_name)
}
