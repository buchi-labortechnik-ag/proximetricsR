#' @title Read and format spectral data from a file
#' @description
#'
#' This function reads spectral data from a file and extracts the spectral columns
#' based on a specified prefix, or a range of columns. It can handle various delimiters
#' and decimal separators.
#'
#' @usage
#'
#' read_spc(file, sep = "\t", dec = ".", header = TRUE, spectra_prefix = "",
#'          spectra_starts = NA, spectra_ends = NA, ...)
#'
#' @param file a character string specifying the path to the file containing the spectral data.
#' @param sep a character string indicating the field separator character. Defaults to \code{"\t"}.
#' @param dec a character string used for decimal points. Defaults to \code{"."}.
#' @param header  logical value indicating whether the file contains the names
#' of the variables as its first line. Defaults to \code{TRUE}
#' @param spectra_prefix a character string specifying the prefix used for spectral column names. If empty, the function will use column indices instead.
#' @param spectra_starts an integer indicating the starting column index for the spectral data, used when \code{spectra_prefix} is not specified.
#' @param spectra_ends an integer indicating the ending column index for the spectral data, used when \code{spectra_prefix} is not specified. If not provided, defaults to the last column.
#' @param ... additional arguments passed to \code{\link[utils]{read.table}}.
#'
#' @author Leonardo Ramirez-Lopez
#'
#' @examples
#' \donttest{
#' # write a file with spectra
#' data("NIRsoil", package = "prospectr")
#' spc_small <- NIRsoil$spc[1:5, ]
#' colnames(spc_small) <- paste0("X", colnames(spc_small))
#' tmp_df <- data.frame(ID = 1:5, Nt = NIRsoil$Nt[1:5], spc_small, check.names = FALSE)
#' tmp_file <- tempfile(fileext = ".txt")
#' write.table(tmp_df, file = tmp_file, sep = "\t", row.names = FALSE)
#'
#' # read that
#' result <- read_spc(tmp_file, spectra_prefix = "X")
#' }
#'
#' @return a data frame with the original data and a matrix of spectral data
#' stored in the \code{spc} column.
#'
#' @details
#' The function reads a file and extracts the spectral data based on either a
#' column name prefix or specified column indices. The spectral data is returned
#' as a matrix in the \code{spc} column of the resulting data frame.
#'
#' @export
read_spc <- function(
  file,
  sep = "\t",
  dec = ".",
  header = TRUE,
  spectra_prefix = "",
  spectra_starts = NA,
  spectra_ends = NA,
  ...
) {
  if (!is.character(spectra_prefix)) {
    stop("'spectra_prefix' must be a character")
  }
  dat <- read.table(file, sep = sep, dec = dec, header = header, check.names = FALSE, ...)
  cnms <- colnames(dat)
  if (spectra_prefix != "") {
    spectral_columns <- grep(paste0("^", spectra_prefix, "[0-9]{1,10}(\\.[0-9]{1,5})?"), cnms)
  } else {
    if (is.na(spectra_starts)) {
      spectral_columns <- grep(
        "[0-9]{1,10}(\\.[0-9]{1,5})?",
        cnms
      )
    } else {
      if (is.na(spectra_ends)) {
        spectra_ends <- ncol(dat)
      }
      spectral_columns <- spectra_starts:spectra_ends
    }
  }
  spc <- dat[, spectral_columns, drop = FALSE]
  spc <- as.matrix(spc)
  wavs <- colnames(spc)
  wavs <- gsub("^[A-Z a-z]{0,}", "", wavs)
  colnames(spc) <- wavs
  dat <- data.frame(dat)
  dat <- dat[, -spectral_columns, drop = FALSE]
  dat$spc <- spc
  class(dat) <- c("proximate_data", "data.frame")
  dat
}
