#' @title Prepare data for augmenting a nax application
#'
#' @description
#'
#' \loadmathjax
#' This function collects all the necessary data that is required prior
#' updating a nax application.
#' @usage
#'
#' proximate_add2nax(formulas = NULL, data, metadata_list = NULL, skip_indices_list = NULL)
#'
#' @param formulas a list containing one or more objects of class
#' \code{\link[stats]{formula}} where each of them represents the model to be
#' calibrated.
#' @param data a data.frame containing the data of the variables in
#' the model (as in the \code{\link{calibrate}} function).
#' @param metadata_list a list of containing the specifications for the metadata
#' of each model in \code{formulas} given in the same order. Each element in the
#' list should be defined as in the \code{metadata} argument of
#' \code{\link{calibrate}} using the
#' \code{\link{add_model_metadata}} function. Defaults to \code{NULL}.
#' @param skip_indices_list a list of vectors of integers for the indices in the
#' input data to be skipped for the computation of each of the models in
#' \code{formulas}. The vectors in this list must be provided in the same order
#' as their corresponding counterparts in \code{formulas}. Defaults to \code{NULL}.
#' In case a list is passed, the list components must be filled with
#' \code{numeric()} for those \code{formulas} where there is no indices to be
#' skipped.
#'
#' @author
#' Leonardo Ramirez-Lopez and Claudio Orellano
#'
#' @return
#'
#' A list mirroing the objects passed to the function.
#'
#' @seealso
#' \code{\link{proximate_recalibrate_nax}}
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


proximate_add2nax <- function(formulas = NULL,
                              data,
                              metadata_list = NULL,
                              skip_indices_list = NULL) {
  if (!"proximate_data" %in% class(data)) {
    stop("data must be of calss 'proximate_data' as returned by proximate_read_data")
  }

  if (!is.null(formulas)) {
    ys <- sapply(formulas, FUN = function(x) as.character(x[[2]]))

    if (!all(ys %in% colnames(data))) {
      stop("data does not contain all the response variables specified in 'formulas'")
    }

    if (!is.null(metadata_list)) {
      if (length(metadata_list) != length(formulas)) {
        stop("The number of elements in 'formulas' must match the number of elements in 'metadata_list'")
      }
    }

    if (!is.null(skip_indices_list)) {
      if (length(skip_indices_list) != length(formulas)) {
        stop("The number of elements in 'formulas' must match the number of elements in 'skip_indices_list'")
      }
    }
  }

  to_add <- list(
    formulas = formulas,
    data = data,
    metadata_list = metadata_list,
    skip_indices_list = skip_indices_list
  )
  class(to_add) <- c("list", "nax_augment")
  to_add
}
