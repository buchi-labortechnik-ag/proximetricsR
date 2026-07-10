#' @title Write calibration (.cal), project (.prj) and report (.rtf) files to a
#' specified directory
#' @name proximate_write_model
#' @description
#'
#' \loadmathjax
#' This function allows to write native ProxiMate calibration, project and
#' report files from a \code{spectral_model} object.
#'
#' @usage
#'
#' proximate_write_model(object, path, tsv_paths, application_name = "Untitled",
#'                       cal = TRUE, prj = TRUE, rtf = TRUE,
#'                       verbose = TRUE, internal_prj_path = NULL)
#'
#' @param object a list of models of class \code{spectral_model}. These models
#' should be generated using the \code{\link{calibrate}} function.
#' @param path a string for the directory in which the files should
#' be saved.
#' @param tsv_paths a vector of character strings for the paths (including the
#' names) of the tsv data files. See details.
#' @param application_name a string with the name of the generated files.
#' Defaults to \code{"Untitled"}.
#' @param cal a logical. Should a calibration file (.cal) be written?
#' Default is \code{TRUE}.
#' @param prj a logical. Should a project file (.prj) be written?
#' Default is \code{TRUE}.
#' @param rtf a logical. Should a report in rich text format (.rtf) be written?
#' Default is \code{TRUE}.
#' @param verbose a logical. Should progress bars for the generated files be
#' printed? Default is \code{TRUE}.
#' @param internal_prj_path a string. Only used for changing the path printed on
#' the first line of the project file. This is necessary mainly for calls from
#' \code{\link{proximate_write_nax}}, as it creates the project file in a temporary file,
#' which would also store that temporary path into the project file. This argument
#' allows you to overwrite that path individually. Otherwise, this parameter may
#' be ignored. If \code{NULL} (default), will be set to \code{path}.
#'
#' @details
#' This function generates files with extensions ".prj" (project file),
#' ".cal" (calibration file), and ".rtf" (report) for the provided models of
#' class \code{spectral_model} in the argument \code{object}. Each file type can
#' be individually enabled or disabled via the \code{cal}, \code{prj}, and
#' \code{rtf} arguments. All files will be named according to the chosen name
#' of the application (given by \code{application_name}). Note that in contrast
#' to \code{\link{proximate_write_nax}}, the metadata does not influence the name of the
#' application. This allows models to be passed directly to this function without
#' the need for metadata. Additionally, the name of the response variable is
#' automatically added to the names of the produced files, so that all generated
#' files have unique names.
#'
#' @examples
#' \donttest{
#' data("NIRcannabis")
#' control <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential")
#' amodel <- calibrate(CBDA ~ spc,
#'   data = NIRcannabis, preprocess = preprocess_recipe(),
#'   method = fit_plsr(5), control = control, verbose = FALSE
#' )
#'
#' proximate_write_model(
#'   object = list(amodel),
#'   path = tempdir(),
#'   tsv_paths = tempfile(fileext = ".tsv"),
#'   application_name = "Untitled",
#'   cal = TRUE, prj = TRUE, rtf = TRUE,
#'   verbose = FALSE
#' )
#' }
#' @return Invisibly returns \code{NULL}. Called for its side effect of writing
#' calibration, project and/or report files to \code{path}.
#' @author Claudio Orellano, Leonardo Ramirez-Lopez
#' @export
proximate_write_model <- function(object, path, tsv_paths,
                                  application_name = "Untitled",
                                  cal = TRUE, prj = TRUE, rtf = TRUE,
                                  verbose = TRUE, internal_prj_path = NULL) {
  if (missing(object)) {
    stop("'object' is required for generating the .prj and .cal files.")
  }
  if (missing(tsv_paths)) {
    stop("Please provide a path to the .tsv file via 'tsv_paths'.")
  }
  if (missing(path)) {
    stop("'path' is required. Please provide the directory where the files should be saved.")
  }
  if (!is.logical(cal)) {
    stop("'cal' must be a logical.")
  }
  if (!is.logical(prj)) {
    stop("'prj' must be a logical.")
  }
  if (!is.logical(rtf)) {
    stop("'rtf' must be a logical.")
  }
  if (!is.logical(verbose)) {
    stop("'verbose' must be a logical.")
  }
  if (!is.character(application_name)) {
    stop("'application_name' must be a character.")
  }
  if (is.null(internal_prj_path) || !is.character(internal_prj_path)) {
    internal_prj_path <- path
  }
  if (prj) {
    write_prj(
      object = object,
      tsv_paths = tsv_paths,
      application_name = application_name,
      path = path,
      verbose = verbose,
      internal_prj_path = internal_prj_path
    )
  }
  if (cal) {
    write_cal(
      object = object,
      tsv_paths = tsv_paths,
      application_name = application_name,
      path = path,
      verbose = verbose
    )
  }
  if (rtf) {
    write_rtf(
      object = object,
      tsv_path = tsv_paths[1],
      application_name = application_name,
      path = path,
      verbose = verbose
    )
  }
}
