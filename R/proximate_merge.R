#' @title Merge datasets of class `proximate_data`
#' @name proximate_merge
#'
#' @description
#'
#' This function allows you to quickly merge two separate datasets of class `proximate_data`
#' into a single one. The first dataset must be of class `proximate_data`, while the second
#' may be any kind of list-like format, but must contain at least columns named
#' `spc` and `ID`.
#' @usage
#'
#' proximate_merge(x)
#'
#' @param x a list containing objects of class `proximate_data`, obtained from
#' \code{\link{proximate_read_data}} or via \code{\link{proximate_data}}. The first
#' element in the list is used as the reference for aligning the spectral data
#' of the remaining elements. See details.
#' @details
#' This functions provides a way to merge different datasets into a single table.
#'
#' In cases where the first dataset in the list (the one used as reference for
#' spectral alignment) has spectral data with an spectral range outside the
#' limits of another dataset, the spectral data of such dataset will not be
#' extrapolated. In that case the spectral variables outside such limits will
#' be filled with \code{NA}s.
#'
#' The function checks for any of the standard names of a `.tsv` file of ProxiMate,
#' identifying any unexpected column names as properties.
#'
#' Propeties that are contained in both datasets are merged into a single column.
#' Otherwise, the columns of a property that is only contained in one of the datasets
#' is filled up with `NA`.
#'
#' @return a `data.frame` of class `proximate_data`, containing the merged data.
#' @author Claudio Orellano
#' @seealso \code{\link{proximate_read_data}}, \code{\link{proximate_data}}
#' @examples
#' # to do
#' @export
proximate_merge <- function(x) {
  if (!is.list(x) || is.data.frame(x)) {
    stop("'x' must be a list of 'proximate_data' objects")
  }

  x <- x[!sapply(x, FUN = is.null)]

  no_nwp <- any(sapply(x, FUN = function(x) !inherits(x, "proximate_data")))
  if (no_nwp) {
    stop("'x' must contain data of class 'proximate_data'")
  }

  no_spc <- any(sapply(x, FUN = function(x) is.null(x$spc)))
  if (no_spc) {
    stop("Elements in 'x' must have a column named 'spc'")
  }

  no_id <- any(sapply(x, FUN = function(x) is.null(x$ID)))
  if (no_id) {
    stop("Elements in 'x' must have a column named 'ID'")
  }

  mproperty <- function(x) {
    ps <- grep("Reference", colnames(x)) + 1
    pf <- grep("Begin", colnames(x)) - 1

    if (length(ps) == 0 || length(pf) == 0) {
      return(NULL)
    }
    if ((pf - ps) < 0) {
      return(NULL)
    } else {
      return(colnames(x)[ps:pf])
    }
  }

  lproperties <- lapply(x, FUN = mproperty)
  null_props <- sapply(lproperties, FUN = is.null)
  if (any(null_props)) {
    for (i in seq_along(lproperties)[null_props]) {
      warning("No properties, or these cannot be inferred from the column names for file: ", i)
    }
  }

  std_nms <- c(
    "ROW", "Check", "Date", "SRN", "SNR", "ID", "Barcode", "Note", "Result",
    "Reference", "Begin", "End", "Recipe", "Composition", "Images", "spc"
  )

  if (length(unique(table(unlist(lproperties)))) != 1 && !all(null_props)) {
    warning("The set of properties seems different across elements")
  }

  lnames <- lapply(x, FUN = colnames)
  # std_nms <- colnames(x[[1]])
  std_nms[c(1:grep("Reference", std_nms), grep("Begin", std_nms):length(std_nms))]
  fnames <- c(
    std_nms[c(1:grep("Reference", std_nms))],
    unique(unlist(lproperties)),
    std_nms[c(grep("Begin", std_nms):length(std_nms))]
  )

  dfinal <- NULL
  ncnt <- 0
  for (i in seq_along(x)) {
    ith_x <- x[[i]]
    rownames(ith_x) <- rownames(ith_x$spc) <- (1:nrow(ith_x)) + ncnt
    if (!all(!colnames(ith_x) %in% fnames)) {
      to_add <- fnames[!fnames %in% colnames(ith_x)]
      to_add <- matrix(
        NA,
        nrow(ith_x),
        length(to_add),
        dimnames = list(NULL, to_add)
      )
      to_add <- data.frame(to_add)
      ith_x <- cbind(ith_x, to_add)
      ith_x <- ith_x[, fnames]
    }

    if (i == 1) {
      wavs <- as.numeric(colnames(ith_x$spc))
    } else {
      ith_wavs <- as.numeric(colnames(ith_x$spc))
      ith_x$spc <- resample(
        ith_x$spc,
        ith_wavs,
        wavs,
        interpol = "spline",
        ties = mean,
        method = "natural"
      )

      if (min(ith_wavs) > min(wavs)) {
        bb <- which(wavs >= min(ith_wavs))[1]
        ith_x$spc[, 1:bb] <- NA
        warning("NA(s) have been introduced in the spectra")
      }

      if (max(ith_wavs) < max(wavs)) {
        bb <- which(wavs <= max(ith_wavs))
        bb <- bb[length(bb)]
        ith_x$spc[, (bb + 1):ncol(ith_x$spc)] <- NA
        warning("NA(s) have been introduced in the spectra")
      }
    }
    dfinal <- rbind(dfinal, ith_x)
    ncnt <- nrow(dfinal)
  }
  dfinal$ROW <- 1:nrow(dfinal)
  class(dfinal) <- c("proximate_data", "data.frame")
  dfinal
}
