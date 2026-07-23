#' @title Read and parse ProxiScout data from CSV or XLSX files
#'
#' @description
#'
#' Reads spectral data files in either \code{.csv} or \code{.xlsx} format, identifies
#' spectral data columns based on numeric column names, converts reflectance values
#' from percentages to absolute units, and stores them in a matrix under the \code{spc}
#' column.
#'
#' @usage
#' proxiscout_read_data(file, references_file)
#'
#' @param file A character string specifying the path to the input file. The
#' file must be either have \code{.csv} or a \code{.xlsx} extension.
#' @param references_file An optional character string specifying the path to
#' a file containing reference values. See details.
#'
#' @details
#' This function allows the user to give the path to one or two files at once.
#'
#' If two file paths are given, the files are assumed to contain the spectral
#' data in \code{file}, while \code{references_file} contains only the reference values.
#' Both files must share a column name with respect to which the files are merged.
#' If no columns match, instead both files must have a column that match with the
#' following regex: \code{"^id$|^sample[ _.-]?name$|^name$|^sample[ _.-]?id$"}.
#' 
#' Entries in these columns must coincide. If none of the entries do, potential
#' repetition indicators are removed (see \code{\link{proxiscout_repetition_pattern}})
#' before the merge.
#'
#' If only \code{file} is given, it must contain the spectral columns, and may or may
#' not contain reference values.
#'
#' In general, inside \code{file}, any column AFTER the spectra are identified as
#' predictions, and are collected into a \code{matrix} called \code{predictions}
#' (if any exist). Columns that contain numerical values and do not contain typical
#' column names (see \code{\link{extract_property_names}} for more details)
#' that appear BEFORE the spectral data columns are identified reference values.
#'
#' The function:
#' - ensures the file extensions are valid (\code{.csv} or \code{.xlsx}).
#' - reads CSV files using \code{\link[utils]{read.csv}} and Excel files using
#' \code{\link[readxl]{read_excel}}.
#' - extracts spectral data (columns with numeric names).
#' - if exactly 257 columns with numeric names are found, then:
#'   \itemize{
#'     \item the spectral matrix is assigned the typical proxiscout wavenumbers
#'        (\code{\link{get_proxiscout_wavenumbers}})
#'     \item the data is assigned class \code{"proxiscout_data"}.
#'     \item spectral matrix is converted from percentage (0 to 100) to absolute (0 to 1) units.
#'   }
#' - if the number of columns with numeric names is not 257, the spectral matrix is assigned the wavelengths/wavenumbers in the header of the file.
#' - stores the spectral data in a matrix named \code{spc}.
#' - stores columns after the spectral data in a matrix named \code{predictions} (if any exist).
#' - merges files together by a common column if multiple files are given.
#' @note
#' This function assumes spectral column names follow a strict numeric pattern
#' (e.g. "3921.0") and removes any prefixed characters such as "X" that may be added
#' by \code{read.csv}. These names are converted to numeric and used as column names
#' of the spectral matrix.
#'
#' @return A \code{data.frame} where:
#'   - Spectral data is stored as a **matrix** in the \code{spc} column.
#'   - Columns identified as predictions are stored as a **matrix** in the \code{predictions} column.
#'   - Other non-spectral metadata columns remain unchanged.
#'   - Multiple files are merged into a single \code{data.frame}.
#'   - If the files contain 257 columns in \code{spc}, the data is assigned class
#'   \code{"proxiscout_data"}.
#'   - A \code{.repetition_group} integer column is added, identifying rows that
#'   correspond to repeated scans of the same sample: for two-file input, rows
#'   merged to the same reference row share a group id; for single-file input,
#'   groups are derived from the sample ID column's repetition suffix (see
#'   \code{\link{proxiscout_repetition_pattern}}), optionally disambiguated by
#'   scanner/device and date columns when present. This column is meant for
#'   downstream aggregation of repeated measurements and is not guaranteed to be
#'   meaningful if no ID-like column is found in the input. For two-file input,
#'   rows in \code{file} with no matching sample in \code{references_file} have
#'   \code{NA} reference columns; \code{.repetition_group} is still assigned for
#'   these rows (grouped by their own sample id) so that their spectra can be
#'   aggregated even though no reference value is available.
#' @author Leonardo Ramirez-Lopez, Claudio Orellano
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
  id_regex <- "^id$|^sample[ _.-]?name$|^name$|^sample[ _.-]?id$"
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
    # Identify the column to use for merging the files. Prefer a common column
    # name that also looks like a sample identifier; if none of the common
    # columns look like an ID, fall back to the first common column.
    common_cols <- intersect(colnames(x), colnames(refs))
    merge_col <- NULL
    if (length(common_cols) >= 1) {
      id_common_cols <- common_cols[grepl(id_regex, common_cols, ignore.case = TRUE)]
      merge_col <- if (length(id_common_cols) >= 1) id_common_cols[1] else common_cols[1]
    }
    if (!is.null(merge_col)) {
      x_sample_col <- which(colnames(x) == merge_col)[1]
      refs_sample_col <- which(colnames(refs) == merge_col)[1]
    } else if (any(grepl(id_regex, colnames(x), ignore.case = TRUE)) &&
               any(grepl(id_regex, colnames(refs), ignore.case = TRUE))) {
      # No common column names; fall back to detecting an ID-like column
      # independently in each file (the ID column names may differ).
      x_sample_col <- grep(id_regex, colnames(x), ignore.case = TRUE) |> head(1)
      refs_sample_col <- grep(id_regex, colnames(refs), ignore.case = TRUE) |> head(1)
    } else {
      # Otherwise, throw an error - we do not know how we can merge those files
      stop("No common column names or sample ID columns detected across files for merging the files")
    }
    # If the names do not contain regex ID, sample or name, rename the columns to sampleName
    if (!grepl(id_regex, colnames(x)[x_sample_col], ignore.case = TRUE)) colnames(x)[x_sample_col] <- "sampleName"
    if (!grepl(id_regex, colnames(refs)[refs_sample_col], ignore.case = TRUE)) colnames(refs)[refs_sample_col] <- "sampleName"
    
    # Drop any row in refs that has duplicated sample id
    refs <- refs[!duplicated(refs[[refs_sample_col]]), , drop = FALSE]
    # Add an internal column for the sample repetitions to the references - after merging,
    # if there were repetitions, the group will indicate to which groups they belong
    refs[[".repetition_group"]] <- seq_len(nrow(refs))
    # For each row, use the raw sample id if it already matches a reference
    # (i.e. no repetition suffix); otherwise fall back to the suffix-stripped
    # id. This supports files where only some samples have repetitions.
    raw_id <- x[[x_sample_col]]
    stripped_id <- gsub(proxiscout_repetition_pattern(), "", raw_id)
    x[[".clean_sample_id"]] <- ifelse(raw_id %in% refs[[refs_sample_col]], raw_id, stripped_id)
    # For ordering purposes, add a column that we will remove later
    x$.order <- seq_len(nrow(x))

    x <- merge(
      x,
      refs,
      by.x = ".clean_sample_id",
      by.y = colnames(refs)[refs_sample_col],
      all.x = TRUE,
      sort = FALSE
    )

    # Sort by the order column and remove it
    x <- x[order(x$.order), ]
    x$.order <- NULL

    # Rows with no matching reference get NA in .repetition_group (and in all
    # reference columns). Fall back to grouping by their own clean sample id instead.
    unmatched <- is.na(x$.repetition_group)
    if (any(unmatched)) {
      next_group <- if (all(unmatched)) 0L else max(x$.repetition_group[!unmatched])
      fallback_group <- match(x$.clean_sample_id[unmatched], unique(x$.clean_sample_id[unmatched]))
      x$.repetition_group[unmatched] <- next_group + fallback_group
    }
    x$.clean_sample_id <- NULL
    rownames(x) <- seq_len(nrow(x))
  } else {
    # Attach column .repetition_group to x
    x[[".repetition_group"]] <- seq_len(nrow(x))
    # If only a single file is given, we check for a column for the sample name
    # This column should indicate whether there are repetitions in the data
    if (any(grepl(id_regex, colnames(x), ignore.case = TRUE))) {
      wh_id <- grep(id_regex, colnames(x), ignore.case = TRUE)
      id_col <- x[[wh_id[1]]]
      # If the data exhibits a repetition pattern, modify the repetition group column
      if (any(grepl(proxiscout_repetition_pattern(), id_col, ignore.case = TRUE))) {
        group_key <- gsub(proxiscout_repetition_pattern(), "", id_col)
        # If there is a column for scanner or for the date, add them to the group key.
        # These are typically different for measurements that are not repeats.
        group_key <- add_regex_col(x, "^(scanner|device)[ _.-]?id$|^(scanner|device)[ _.-]?name$|^(scanner|device)$", group_key)
        group_key <- add_regex_col(x, "^(capturedat|date)$", group_key)
        x[[".repetition_group"]] <- match(group_key, unique(group_key))
      }
    }
  }
  # Assign proxiscout class if the data originates from ProxiScout
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

#' @title Add a column with the given regex to x if it exists
#'
#' @description
#' Adds elements of column with the given regex from data to x if it exists.
#'
#' @usage
#' add_regex_col(data, regex, x)
#'
#' @return x if the regex does not exists; or x pasted together with the first column
#' of x whose column name is detected by the regex.
#'
#' @author Claudio Orellano
#' @keywords internal
add_regex_col <- function(data, regex, x) {
  # Return x if the regex does not appear
  if (!any(grepl(regex, colnames(data), ignore.case = TRUE))) return(x)
  # Find the column where the regex appears
  regex_col <- grep(regex, colnames(data), ignore.case = TRUE)
  # Paste x with the first appearance of the regex column
  paste(x, data[[regex_col[1]]], sep = "::")
  
}
