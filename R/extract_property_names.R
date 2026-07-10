#' @title Extract the property names from a given `data.frame`
#'
#' @description
#' This function aims to extract the column names of properties from `x`. A property
#' in this context is a response vector of numerical values that then later can
#' be calibrated for predictions (such as with \code{\link{calibrate}}).
#'
#' @param x a `data.frame`, as normally obtained by 
#' \code{\link{proximate_read_data}}, \code{\link{read_spc}},
#' \code{\link{proxiscout_read_data}}, or some other data parsing function.
#'
#' @details
#' Depending on the `class` of `x`,  the names of the properties are identified
#' differently. For all cases, only columns which contain numerical values
#' (including `NA`) are considered as potential properties.
#'
#' If `x` is of class `proximate_data`, the property names are identified as follows:
#' \itemize{
#'   \item{}{Located between columns "Reference" and "Begin".}
#'   \item{}{Not named according to any of the following names: "ROW", "Check",
#'           "Date", "SNR", "SRN", "ID", "Barcode", "Note", "Result", "Reference",
#'           "Begin", "End", "Recipe", "Composition", "Images", "spc".}
#'   \item{}{Contain only numerical values (including NA).}
#' }
#'
#' If `x` is of class `proxiscout_data`, property names are identified as columns that
#' contain only numerical values (including `NA`) and are not matched by any of the
#' following, case-insensitive regex (each wrapped by `^` and `$`):
#' \itemize{
#'   \item{}{`id`}
#'   \item{}{`sample[_. ]?name`}
#'   \item{}{`captured[_. ]?at`}
#'   \item{}{`device[_. ]?id`}
#'   \item{}{`created[_. ]?(by|at)`}
#'   \item{}{`on[_. ]?behalf[_. ]?of`}
#'   \item{}{`lot[_. ]?name`}
#'   \item{}{`scanner([_. ]?id)?`}
#'   \item{}{`original[_. ]?value`}
#'   \item{}{`display[_. ]?value`}
#'   \item{}{`note`}
#'   \item{}{`location`}
#'   \item{}{`supplier`}
#'   \item{}{`device`}
#'   \item{}{`spc`}
#'   \item{}{`predictions`}
#' }
#'
#' If `x` is of neither class, all columns with numerical values are considered to be properties
#'
#' @return A character vector, containing only the names of numerical properties.
#' If no property names were identified, return a character vector of length 0.
#' @export
extract_property_names <- function(x) {
  if (inherits(x, "proximate_data")) {
    std_nms <- c(
      "ROW", "Check", "Date", "SRN", "SNR", "ID", "Barcode", "Note", "Result",
      "Reference", "Begin", "End", "Recipe", "Composition", "Images", "spc"
    )
    ps <- grep("Reference", colnames(x)) + 1
    pf <- grep("Begin", colnames(x)) - 1
    if (length(pf) < 1 || length(ps) < 1 || (pf - ps) < 0) {
      return(character(0))
    }
    property_names <- setdiff(colnames(x)[ps:pf], std_nms)
  } else if (inherits(x, "proxiscout_data")) {
    # Define patterns to exclude (handles various casing and separators)
    exclude_patterns <- c(
      "id",
      "sample[_. ]?name",
      "captured[_. ]?at",
      "device[_. ]?id",
      "created[_. ]?(by|at)",
      "on[_. ]?behalf[_. ]?of",
      "lot[_. ]?name",
      "scanner([_. ]?id)?",
      "original[_. ]?value",
      "display[_. ]?value",
      "note",
      "location",
      "supplier",
      "device",
      "spc",
      "predictions"
    )

    # Combine patterns into single regex
    pattern <- paste0("^(", paste(exclude_patterns, collapse = "|"), ")$")
    property_names <- colnames(x)[!grepl(pattern, colnames(x), ignore.case = TRUE)]
  } else {
    property_names <- setdiff(colnames(x), "spc")
  }
  # If there are any property names, return only numerical ones
  if (length(property_names) > 0) {
    wh_numeric <- which(unlist(lapply(x[, property_names, drop = FALSE], function(x) is.numeric(x) || all(is.na(x)))))
    return(property_names[wh_numeric])
  }
  return(character(0))
}
