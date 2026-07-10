#' @title Write data files for ProxiScout devices
#'
#' @description
#'
#' \loadmathjax
#'
#' This function writes comma-separated files in a format compatible with
#' ProxiScout-related software, which typically require two separate comma-separated
#' files - one file for the spectra, and another file for reference values.
#' These files are created inside the specified directory (argument `path`).
#' @usage
#' proxiscout_write_data(x, path, file_prefix, properties = NULL, spc = "spc")
#' @param x a `data.frame` of spectral data for which to write the data files.
#' Typically, this is returned by \code{\link{proxiscout_read_data}} and of class
#' `"proxiscout_data"`.
#' @param path a character for the directory in which the files will be saved.
#' @param file_prefix a character for the prefix of the generated files. The files
#' are then named as `[file_prefix]_spectra.csv` and `[file_prefix]_properties.csv`.
#' Default is `proxiscout_export`.
#' @param properties a vector of characters of arbitrary length. Which properties
#' in \code{x} are to be added to the csv? Default is \code{NULL}.
#' @param spc either a character or a vector of integers. Specifies where the
#' spectra can be found inside \code{x}. Default is \code{"spc"}.
#' @return A `character` with the paths to the created files.
#'
#' @details
#' This function creates up to two comma separated files in the directory `path`,
#' which are usable by ProxiScout-related software. These files are named according
#' to the `file_prefix` argument and contain the spectra together with the sample
#' names and device ID, respectively the reference values with the sample names.
#'
#' Typically, the data provided to this function is imported with \code{\link{proxiscout_read_data}}
#' and of class `"proxiscout_data"`, but it is also possible to construct a `data.frame`
#' by hand and provide it to this function.
#'
#' The `properties` argument specifies which columns in `x` are the reference values
#' written to the `[file_prefix]_properties.csv` file. If empty (default), this
#' file is not created, as it would only contain sample names. Any row in the
#' provided properties that only contains `NA` values are dropped. In general,
#' `NA` values are set to an empty string (`""`)
#'
#' The sample names are detected automatically from `x` as the column with a name
#' that contains `"sample"`. If none are detected, the function will throw an
#' error. This column will be named `"Sample Name"` in the `[file_prefix]_spectra.csv`
#' file, and `"sampleName"` in the `[file_prefix]_properties.csv` file.
#'
#' Similarly, the device ID is a required column and is identified as having a
#' `"device"` string inside the name of the column. This column is only written into
#' the `[file_prefix]_spectra.csv` file, with a fixed named `"Device Id"`.
#'
#' All other columns in either file only correspond to the spectra respectively
#' the reference values. In particular, other columns in `x` are dropped.
#'
#' @author Leonardo Ramirez-Lopez, Claudio Orellano
#' @export
proxiscout_write_data <- function(x, path, file_prefix = "proxiscout_export", properties = NULL, spc = "spc") {
  # If there are no properties, set to NULL, otherwise check that all are in the
  # columns of x
  if (length(properties) < 1) {
    properties <- NULL
  } else {
    prop_err <- which(!properties %in% colnames(x))
    if (length(prop_err) > 0) {
      stop(paste0("Properties not found in 'x': ", paste0(properties[prop_err], collapse = ", "), "."))
    }
  }
  # If x contains no column with "sample", but a column ID, rename it to "sampleName"
  if (!any(grepl("sample", colnames(x), ignore.case = TRUE)) && any("ID" == colnames(x))) {
    colnames(x)[which("ID" == colnames(x))[1]] <- "sampleName"
  }
  # If x contains no column with "device" or "scanner", but a column SNR/SRN, rename it to deviceId
  if (!any(grepl("^(device|scanner)", colnames(x), ignore.case = TRUE)) && any(c("SNR", "SRN") %in% colnames(x))) {
    colnames(x)[which(c("SNR", "SRN") %in% colnames(x))[1]] <- "deviceId"
  }
  # Find the sample and device/scanner columns
  sample_col_index <- which(grepl("sample", colnames(x), ignore.case = TRUE))
  # Throw an error if no sample column is detected
  if (length(sample_col_index) < 1) stop("No sample column detected.")
  sample_col <- x[, sample_col_index[1]]
  device_col_index <- which(grepl("^(device|scanner)", colnames(x), ignore.case = TRUE))
  # Throw an error if no device or scanner column is detected
  if (length(device_col_index) < 1) stop("No device or scanner column detected.")
  device_col <- x[, device_col_index[1]]


  # Write the spectra file, containing columns "Sample Name", "Device Id", and
  # columns with numerical values in the header for the spectra
  file_paths <- file.path(path, paste0(file_prefix, "_spectra.csv"))
  spectra_df <- data.frame(
    "Sample Name" = sample_col,
    "Device Id" = device_col,
    x[[spc]] * 100, # Multiply by 100; to have values between 0 and 100
    check.names = FALSE
  )

  if (!is.null(properties)) {
    file_paths <- c(file_paths, file.path(path, paste0(file_prefix, "_properties.csv")))
    # For the references, we do not want to put repetitions into the file, so we
    # remove the repetition pattern from the sample name column
    clean_sample_col <- gsub(proxiscout_repetition_pattern(), "", sample_col)
    # Filter out any property that has only NA reference values
    property_df <- x[, properties, drop = FALSE]
    all_na_rows <- apply(property_df, 1, function(row) all(is.na(row)))
    references_df <- data.frame("sampleName" = clean_sample_col, property_df)
    write.csv(
      unique(references_df[!all_na_rows, , drop = FALSE]), # Unique drops any duplicated rows
      file = file_paths[length(file_paths)],
      row.names = FALSE,
      quote = FALSE,
      na = ""
    )
  }
  write.csv(
    spectra_df,
    file = file_paths[1],
    row.names = FALSE,
    quote = FALSE,
    na = ""
  )

  invisible(file_paths)
}
