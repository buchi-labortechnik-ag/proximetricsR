#' @title Write NIRWise PLUS readable tab-separated files
#'
#' @description
#'
#' \loadmathjax
#'
#' This function writes tab-separated value files in a readable NIRWise PLUS
#' software format. These files contain visible and Near-Infrared absorbance
#' spectra along with response variables and metainformation (e.g. sample ID,
#' date, comments, etc).
#' @usage
#' proximate_write_data(x, 
#'                      file, 
#'                      id, 
#'                      spc, 
#'                      spc_round = 8, 
#'                      barcode = "", 
#'                      properties = NULL, 
#'                      note = "", 
#'                      recipe = "", 
#'                      created, 
#'                      snr)
#' @param x a data.frame of spectral data and metadata, for which the tab
#' separated value file should be generated. See details.
#' @param file a character for the path (and name) in which the tsv will be saved.
#' @param id a vector of characters of length equal to the number of observations
#' in \code{x} or of length 1. Each entry gives an observation a specific ID. If
#' length is 1, this entry is recycled for every observation.
#' @param spc either a character or a vector of integers. Specifies where the
#' spectra can be found inside \code{x}. Default is \code{"spc"}.
#' @param spc_round an integer. To how many decimal places should the spectra be
#' rounded? Defaults to 8 decimal places.
#' @param barcode a vector of characters of length equal to the number of
#' observations in \code{x} or of length 1. Each entry specifies the barcode for
#' each observation; if length is 1, the entry is recycled for every observation.
#' Default is an empty character.
#' @param properties a vector of characters of arbitrary length. Which properties
#' in \code{x} are to be added to the tsv? Note that any missing reference values
#' for the properties are set to 0. Default is \code{NULL}.
#' @param note a vector of characters of length equal to the number of observations
#' in \code{x} or of length 1. The vector corresponds to the notes for each
#' observation, or, if the vector is of length one, to all notes of all
#' observations. Defaults to an empty character.
#' @param recipe a vector of characters of length equal to the number of observations
#' in \code{x} or of length 1. This vector corresponds to the recipe for each
#' observation, or, if the vector is of length one, to all recipes of all
#' observations. Defaults to an empty character.
#' @param created a vector of characters of length equal to the number of observations
#' in \code{x}. This vector should contain the date and time of when each
#' observation was measured. If not provided and not contained in \code{x}, this
#' parameter will be set to the current date and time of the system.
#' @param snr a vector of characters, corresponding to the serial number of the
#' device on which the measurement was taken. If not provided and not found in
#' \code{x}, this parameter will be set to a vector of character of length
#' equal to the number of rows in \code{x}, where each individual character is given
#' by \code{0000000000}.
#' @return Invisibly returns \code{NULL}. Called for its side effect of
#' writing a tab-separated value file to \code{file}.
#'
#' @details
#' This function creates a tab separated value file, which is readable by both
#' NIRWise PLUS software and the \code{\link{proximate_read_data}} function.
#'
#' The main usage is to transform an already given data file into a format which
#' is readable by NIRWise PLUS. Therefore, if some data of the given object
#' \code{x} is already of the correct form, one can pass the corresponding values
#' simply by passing the specific row of \code{x} to this function; for example,
#' by passing \code{note = x$Note}.
#'
#' @examples
#' \donttest{
#' data("NIRcannabis")
#' filename <- file.path(tempdir(), "NIRcannabis.tsv")
#'
#' proximate_write_data(
#'   x = NIRcannabis,
#'   file = filename,
#'   id = NIRcannabis$ID,
#'   spc = "spc",
#'   spc_round = 8,
#'   barcode = NIRcannabis$Barcode,
#'   properties = c("CBDA", "THCA", "CBD", "THC"),
#'   note = NIRcannabis$Note,
#'   recipe = NIRcannabis$Recipe,
#'   created = NIRcannabis$Begin
#' )
#'
#' # Since we do not change anything, the following produces the same tsv:
#' proximate_write_data(
#'   x = NIRcannabis,
#'   file = filename,
#'   properties = c("CBDA", "THCA", "CBD", "THC")
#' )
#' # Delete the file
#' file.remove(filename)
#' }
#'
#' @author Leonardo Ramirez-Lopez
#' @export
proximate_write_data <- function(x, file, id, spc = "spc", spc_round = 8, barcode = x$Barcode,
                                 properties = NULL, note = x$Note, recipe = x$Recipe, created, snr) {
  if (missing(created)) {
    if (!is.null(x$Created)) {
      get_date <- sapply(x$Created,
        FUN = function(x) {
          a <- gregexpr(":", x)[[1]]
          if (length(a) == 2) {
            rs <- a[2]
            # rs <- substr(x, 1, rs-1)
            rs <- substr(x, 1, rs + 2)
          } else {
            rs <- x
          }
          rs <- gsub("/", "-", rs)
          return(rs)
        }
      )
      get_begin <- get_end <- get_date
    } else {
      if (is.null(x$Date)) {
        get_date <- Sys.time() + 1:nrow(x)
        get_date <- format(get_date, "%Y-%m-%d %H:%M:%S")
      } else {
        get_date <- x$Date
      }
      if (is.null(x$Begin)) {
        get_begin <- Sys.time() + 1:nrow(x)
        get_begin <- format(get_begin, "%Y-%m-%d %H:%M:%S")
      } else {
        get_begin <- x$Begin
      }
      if (is.null(x$End)) {
        get_end <- Sys.time() + 1:nrow(x)
        get_end <- format(get_end, "%Y-%m-%d %H:%M:%S")
      } else {
        get_end <- x$End
      }
    }
  } else {
    get_date <- get_begin <- get_end <- created
  }
  if (missing(snr)) {
    if (!is.null(x$`Instrument serial`)) {
      snr <- x$`Instrument serial`
    } else {
      if (is.null(x$SNR)) {
        # Check if tsv uses SRN instead
        if (is.null(x$SRN)) {
          snr <- rep(paste(c(1, rep(0, 9)), collapse = ""), nrow(x))
        } else {
          snr <- x$SRN
        }
      } else {
        snr <- x$SNR
      }
    }
  }
  if (missing(id)) {
    if (!is.null(x$ID)) {
      id <- x$ID
    } else {
      stop("id is missing")
    }
  }

  if (!spc %in% colnames(x)) {
    stop("The provided data frame does not contain a column named '", spc, "'")
  }
  spc <- x[, spc]
  spc <- spc[, complete.cases(t(spc)), drop = FALSE]

  wavs <- as.numeric(colnames(spc))
  colnames(spc) <- 1:ncol(spc)
  rln <- unique(diff(wavs))

  # Constant wavelength resolution
  if (length(rln) == 1) {
    x1 <- 0
    x2 <- ncol(spc) - 1
    x3 <- paste("0;", rln, ";", min(wavs) - rln, sep = "")
  } else {
    # Non-constant wavelength resolution
    coeffs <- attr(x, "coeffs")
    if (is.null(coeffs)) {
      stop("Wavelength resolution of the spectra has either to be constant or saved as an attribute of the data.frame 'x'.")
    }
    x1 <- paste(coeffs$X1, collapse = ", ")
    x2 <- paste(coeffs$X2, collapse = ", ")
    x3 <- paste(mapply(coeffs$X3, FUN = paste, collapse = ";"), collapse = ", ")
  }

  reslutc <- rep(paste(rep(0, length(properties)), collapse = " ; "), nrow(x))
  x[, properties][is.na(x[, properties])] <- "0"

  referencec <- sapply(1:nrow(x),
    FUN = function(x, ..i..) paste(x[..i.., ], collapse = " ; "),
    x = x[, properties, drop = FALSE]
  )

  if (!missing(spc_round)) {
    spc <- round(spc, spc_round)
  }

  prpts <- x[, properties, drop = FALSE]
  colnames(prpts) <- gsub("[[:punct:]]", "_", colnames(prpts))
  colnames(prpts) <- gsub("^_|_$", "", colnames(prpts))

  if (!is.null(x$ROW) && is.numeric(x$ROW)) {
    rows <- x$ROW
  } else {
    rows <- 1:nrow(x)
  }
  if (!is.null(x$Check)) {
    check <- x$Check
  } else {
    check <- "True"
  }

  tsv <- data.frame(
    ROW = rows,
    Check = check,
    Date = get_date,
    SNR = snr,
    ID = id,
    Barcode = barcode,
    Note = note,
    Result = reslutc,
    Reference = referencec,
    prpts,
    Begin = get_begin,
    End = get_end,
    Recipe = recipe,
    Composition = "",
    Images = "",
    X1 = x1,
    X2 = x2,
    X3 = x3,
    spc,
    check.names = FALSE
  )

  colnames(tsv) <- gsub(" ", "_", colnames(tsv))
  nms <- colnames(tsv)
  colnames(tsv)[which(nms == "X1"):ncol(tsv)] <- paste("#", nms[which(nms == "X1"):ncol(tsv)], sep = "")


  if (tolower(.Platform$OS.type) == "windows") {
    eol <- "\n"
  } else {
    eol <- "\r\n"
  }

  write.table(tsv,
    file = file,
    sep = "\t",
    eol = eol,
    row.names = FALSE,
    # quote = which(colnames(tsv) %in% c("Result", "Reference")),
    quote = FALSE,
    col.names = TRUE
  )
}
