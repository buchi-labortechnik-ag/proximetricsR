#' @title Read and parse ProxiScout data from CSV or XLSX files
#'
#' @description
#'
#' Reads spectral data files in either `.csv` or `.xlsx` format, identifies
#' spectral data columns based on numeric column names, converts reflectance values
#' from percentages to absolute units, and stores them in a matrix under the `spc`
#' column.
#'
#' @usage
#' proxiscout_read_data(file, references_file)
#'
#' @param file A character string specifying the path to the input file. The
#' file must be either have `.csv` or a `.xlsx` extension.
#' @param references_file An optional character string specifying the path to
#' a file containing reference values. See details.
#'
#' @details
#' This function allows the user to give the path to one or two files at once.
#'
#' If two file paths are given, the files are assumed to contain the spectral
#' data in `file`, while `references_file` contains only the reference values.
#' Both files must have a column that contains the regex `sample`,
#' and the entries must coincide (excluding potential repetition identificators).
#' These files are then merged together by the column with the name containing `sample`.
#'
#' If only `file` is given, it must contain the spectral columns, and may or may
#' not contain reference values.
#'
#' In general, inside `file`, any column AFTER the spectra are identified as
#' predictions, and are collected into a `matrix` called `predictions` (if any
#' exist). Columns that contain numerical values and do not contain typical
#' column names (see \code{\link{extract_property_names}} for more details)
#' that appear BEFORE the spectral data columns are identified reference values.
#'
#' The function:
#' - ensures the file extensions are valid (`.csv` or `.xlsx`).
#' - reads CSV files using `read.csv()` and Excel files using `readxl::read_excel()`.
#' - extracts spectral data (columns with numeric names).
#' - if exactly 257 columns with numeric names are found, then:
#'   \itemize{
#'     \item the spectral matrix is assigned the typical proxiscout wavenumbers (\code{\link{get_proxiscout_wavenumbers}})
#'     \item the data is assigned class `"proxiscout_data"`
#'     \item spectral matrix is converted from percentage (0 to 100) to absolute (0 to 1) units.
#'   }
#' - if the number of columns with numeric names is not 257, the spectral matrix is assigned the wavelengths/wavenumbers in the header of the file.
#' - stores the spectral data in a matrix named `spc`.
#' - stores columns after the spectral data in a matrix named `predictions` (if any exist).
#' - merges files together by the sample column if multiple files are given.
#' @note
#' This function assumes spectral column names follow a strict numeric pattern
#' (e.g. "3921.0") and removes any prefixed characters such as "X" that may be added
#' by \code{read.csv}. These names are converted to numeric and used as column names
#' of the spectral matrix.
#'
#' @return A `data.frame` where:
#'   - Spectral data is stored as a **matrix** in the `spc` column.
#'   - Columns identified as predictions are stored as a **matrix** in the `predictions` column.
#'   - Other non-spectral metadata columns remain unchanged.
#'   - Multiple files are merged into a single `data.frame`.
#'   - If the files contain 257 columns in `spc`, the data is assigned class
#'   `"proxiscout_data"`.
#' @author Leonardo Ramirez-Lopez, Claudio Orellano
#'
#' @export
proxiscout_read_data <- function(file, references_file) {
  ext <- file_ext(file)
  if (ext == "csv") {
    x <- read.csv(file, check.names = FALSE)
  } else if (ext == "xlsx") {
    x <- as.data.frame(read_excel(file))
  } else {
    stop(paste("Unsupported file format:", ext))
  }
  x_colnames <- colnames(x)
  cspc <- grep("^[0-9]{3}[0-9]*\\.?[0-9]*[0-9]$|^[0-9]{3,}$", x_colnames)
  num_colnames <- gsub("^X", "", colnames(x[, cspc, drop = FALSE])) |> as.numeric()
  spc <- as.matrix(x[, cspc, drop = FALSE])
  # Make sure that spc is numerical
  spc <- matrix(as.numeric(spc), nrow = nrow(spc))
  if (ncol(spc) == 257L) {
    colnames(spc) <- get_proxiscout_wavenumbers()
    spc <- spc / 100
    assign_class <- TRUE
  } else {
    colnames(spc) <- num_colnames
    assign_class <- FALSE
  }
  # Any columns after the spectra are predictions
  predictions <- NULL
  if (max(cspc) < ncol(x)) {
    cpred <- which(1:ncol(x) > max(cspc))
    predictions <- as.matrix(x[, cpred, drop = FALSE])
    # Make sure predictions are numerical
    predictions <- matrix(as.numeric(predictions), nrow = nrow(predictions))
    colnames(predictions) <- colnames(x)[cpred]
    x <- x[, -cpred, drop = FALSE]
  }
  x <- x[, -cspc, drop = FALSE]

  # If the references file is not missing, read it and merge it to x
  if (!missing(references_file)) {
    ref_ext <- file_ext(references_file)
    if (ref_ext == "csv") {
      refs <- read.csv(references_file, check.names = FALSE)
    } else if (ref_ext == "xlsx") {
      refs <- as.data.frame(read_excel(references_file, na = c("", "NA")))
    } else {
      stop(paste("Unsupported file format for reference file:", ref_ext))
    }
    # Identify the sample columns for both the file and references file
    x_sample_col <- which(grepl("sample", colnames(x), ignore.case = TRUE))
    refs_sample_col <- which(grepl("sample", colnames(refs), ignore.case = TRUE))
    if (length(x_sample_col) < 1) {
      stop("Unable to identify sample ID column in spectral data file for merging files")
    }
    if (length(refs_sample_col) < 1) {
      stop("Unable to identify sample ID column in references file for merging files")
    }
    refs_sample_colname <- colnames(refs)[refs_sample_col[1]]
    # Drop any row in refs that has duplicated sample id
    refs <- refs[!duplicated(refs[[refs_sample_colname]]), , drop = FALSE]

    x$clean_sample_id <- gsub(proxiscout_repetition_pattern(), "", x[[x_sample_col[1]]])
    # For ordering purposes, add a column that we will remove later
    x$.order <- seq_len(nrow(x))

    x <- merge(
      x,
      refs,
      by.x = "clean_sample_id",
      by.y = refs_sample_colname,
      all.x = TRUE,
      sort = FALSE
    )

    # Sort by the order column and remove it
    x <- x[order(x$.order), ]
    x$.order <- NULL
    x$clean_sample_id <- NULL
    rownames(x) <- seq_len(nrow(x))
  }
  # ProxiScout data typically contains a column with "sample" in it
  if (assign_class) {
    class(x) <- c("proxiscout_data", "data.frame")
  }
  x$predictions <- predictions
  x$spc <- spc
  x
}

#' @title ProxiScout repetition pattern
#'
#' @description
#' Returns the pattern that can be used to identify repetitions in the sample ID
#' of ProxiScout data files
#'
#' @usage
#' proxiscout_repetition_pattern()
#'
#' @return A character that can be used as a regex for identifying repetitions
#' in ProxiScout data files
#'
#' @author Claudio Orellano
#' @export
proxiscout_repetition_pattern <- function() {
  "_{1}[0-9]{1,3}$"
}
