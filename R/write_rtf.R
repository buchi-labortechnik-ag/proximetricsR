#' @title Write report files in rich text format
#' @name write_rtf
#' @description
#'
#' \loadmathjax
#' This function converts the results of spectral models in R to a report in rich
#' text format, in a similar output as NIRWise PLUS.
#'
#' @usage
#'
#' write_rtf(object, path, tsv_path, application_name = "Untitled",
#'           verbose = TRUE)
#'
#' @param object a list of object of class \code{spectral_model}. These models
#' should be generated using the \code{\link{calibrate}} function of this package.
#' @param path a string indicating the directory in which the file should
#' be saved to.
#' @param tsv_path a string of the name (and path) of the tsv data file. The data
#' is ignored if any model given by \code{object} contains a list called
#' \code{input_data}.
#' @param application_name a string with the name of the generated .prj file.
#' Defaults to \code{"Untitled"}.
#' @param verbose a logical. Should messages about the generated files be printed?
#'
#' @details
#' This function generates a .rtf file for the computed model, in a similar
#' output as in NIRWise PLUS software. More precisely, it generates a .rtf file
#' with the name \code{paste0(application_name, object$target_variable)} in the
#' directory given by \code{path}.
#'
#' The parameter \code{tsv_path} is ignored, expect if all models given by \code{object}
#' contain no input data, meaning that they all have been constructed with
#' \code{calibrate(..., return_inputs = FALSE)}. In that case, this function
#' searches for an existing tsv file in the given path and uses that data instead.
#'
#' For each model provided by \code{object}, an .rtf file is generated, which
#' should be familiar to users of NIRWise PLUS software. It provides an overview
#' of the results for the models and lists important outcomes in a easy-to-read
#' way.
#'
#' @examples
#' data("NIRcannabis")
#' control <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential")
#' modell <- calibrate(CBDA ~ spc,
#'   data = NIRcannabis, preprocess = preprocess_recipe(),
#'   method = fit_plsr(15), control = control, verbose = FALSE
#' )
#'
#' write_rtf(
#'   object = list(modell),
#'   path = tempdir(),
#'   tsv_path = "C:/Data/some_tsv.tsv",
#'   application_name = "Untitled",
#'   verbose = FALSE
#' )
#' @return The path to the saved file
#' @author Claudio Orellano, Leonardo Ramirez-Lopez
#' @noRd

write_rtf <- function(object, path, tsv_path, application_name = "Untitled",
                      verbose = TRUE) {
  if (tolower(.Platform$OS.type) == "windows") {
    eol <- "\n"
  } else {
    eol <- "\r\n"
  }
  if (missing(object)) {
    stop("object is required for generating the .prj and .cal files")
  }
  if (!is.list(object)) {
    stop("Parameter 'object' has to be a list.")
  } else {
    if (!all(sapply(object, FUN = inherits, what = "spectral_model"))) {
      stop("All entries in 'object' must be of class 'spectral_model'.")
    }
  }
  if (!is.logical(verbose)) {
    stop("Parameter 'verbose' has to be a logical")
  }
  if (missing(path)) {
    stop("'path' is required. Please provide the directory where the file should be saved.")
  }
  if (!is.character(application_name)) {
    stop("'application_name' has to be a character.")
  }
  if (any(!is.character(tsv_path))) {
    stop("Please provide the path to the .tsv file as a character")
  }
  if (sub(".*(?=.{1}$)", "", path, perl = T) != "/") {
    path <- paste0(path, "/")
  }
  if (!dir.exists(path)) {
    dir.create(path)
  }

  if (all(sapply(sapply(object, FUN = "[[", MARGIN = "input_data"), FUN = "is.null"))) {
    stop(
      "No data found in any model of 'object'. Data is required to be present",
      " when generating report files."
    )
  }
  if (!all(mapply(object, FUN = attr, which = "data_hash") == mapply(object, FUN = attr, which = "data_hash")[1])) {
    warning(
      "Caution: Differences found in data used to create the models in 'object'.",
      " This can cause issues in the report files."
    )
  }
  which_model <- which(!sapply(sapply(object, FUN = "[[", MARGIN = "input_data"), FUN = "is.null"))[1]
  tsv_data <- object[[which_model]]$input_data$data

  number <- 2
  if (verbose) {
    cat("\033\033[3mComputing report files...\n\033[23m\033[39m")
    pb <- txtProgressBar(min = 0, max = length(object), char = "-", style = 3)
  }
  for (model in object) {
    target_name <- model$target_variable
    proj_name <- paste0(application_name, ".", target_name, ".rtf")
    save_dir <- paste0(path, proj_name)
    if (is.null(model$initial_fit)) {
      model_p <- "final_model"
    } else {
      model_p <- "initial_fit"
    }
    Y <- model[[model_p]]$calibration_statistics_all$Target
    target_line <- paste(model$target_variable, floor(min(Y, na.rm = T)), ceiling(max(Y, na.rm = T)))
    if (is.null(model$metadata)) {
      target_line <- paste(target_line, "0.0")
    } else {
      decimals <- paste0(
        "0.",
        paste0(rep("0", model$metadata$DecimalPlaces),
          collapse = ""
        )
      )
      target_line <- paste(
        target_line,
        paste0(decimals, model$metadata$Unit)
      )
    }
    snrs <- as.character(unique(tsv_data$SNR[tsv_data$SNR != "NA"]))
    if (length(snrs) == 0) {
      snrs <- as.character(unique(tsv_data$SRN[tsv_data$SRN != "NA"]))
      if (length(snrs) == 0) {
        snrs <- "missing"
      }
    }
    snrs <- snrs[1]

    sample_ids <- model[[model_p]]$calibration_statistics_all$Sample_index
    records <- NULL
    start <- sample_ids[1]
    for (indces in sample_ids) {
      if (!(indces + 1) %in% sample_ids) {
        if (indces == start) {
          records <- c(records, paste0(start))
        } else {
          records <- c(records, paste0(start, "-", indces))
        }
        start <- sample_ids[2]
      }
      sample_ids <- sample_ids[-1]
    }

    if (is.null(model[[model_p]]$model_cv$grid)) {
      model_type <- ""
      fit_method <- model[[model_p]]$model$method$fit_method
      if (fit_method == "plsr") {
        model_type <- "PLS"
      }
      if (fit_method == "xlsr") {
        model_type <- "XLS"
      }
      first_results <- paste0(
        "\\pard\\fi-2880\\li2880\\tx720\\tx1440\\tx2160\\tx2880\\tx3600\\tx4320\\tx5040\\b ",
        toupper(model_type),
        "\\tab XVAR", "\\tab SEC", "\\tab CMAX", "\\tab Outliers\\b0"
      )
      for (i in 1:model$method$ncomp) {
        results <- paste(
          if (i == model[[model_p]]$ncomp) {
            paste0("\\b ", i)
          } else {
            i
          },
          paste0(
            round(
              model[[model_p]]$model$explained_variance$x_variance["x_expl_var", i] * 100,
              digits = 2
            ),
            "%"
          ),
          signif(model[[model_p]]$model$cal_error[i, "cal_set_error"]),
          signif(model[[model_p]]$model$cal_error[i, "max_residuals"]),
          paste(
            sprintf(
              2 + 0.0001 * (unlist(model[[model_p]]$detected_outliers_all[[i]]) - 1),
              fmt = "%#.4f"
            ),
            collapse = ", "
          ),
          sep = "\\tab "
        )
        if (i == model[[model_p]]$ncomp) {
          results <- paste0(results, "\\b0")
        }
        first_results <- c(
          first_results,
          results
        )
      }
    } else {
      model_type <- ""
      fit_method <- model[[model_p]]$model$method$fit_method
      if (fit_method == "plsr") {
        model_type <- "PLS"
      }
      if (fit_method == "xlsr") {
        model_type <- "XLS"
      }
      first_results <- paste0(
        "\\pard\\fi-4320\\li4320\\tx720\\tx1440\\tx2160\\tx2880\\tx3600\\tx4320\\tx5040\\b ",
        toupper(model_type),
        "\\tab XVAR", "\\tab SEC", "\\tab SECV", "\\tab CMAX", "\\tab CVMAX", "\\tab Outliers\\b0"
      )
      for (i in 1:model$method$ncomp) {
        results <- paste(
          if (i == model[[model_p]]$ncomp) {
            paste0("\\b ", i)
          } else {
            i
          },
          paste0(
            round(
              model[[model_p]]$model$explained_variance$x_variance["x_expl_var", i] * 100,
              digits = 2
            ),
            "%"
          ),
          signif(model[[model_p]]$model$cal_error[i, "cal_set_error"]),
          signif(model[[model_p]]$model_cv$grid[i, "rmse"]),
          signif(model[[model_p]]$model$cal_error[i, "max_residuals"]),
          signif(model[[model_p]]$model_cv$grid[i, "largest_residual"]),
          paste(
            sprintf(
              2 + 0.0001 * (unlist(model[[model_p]]$detected_outliers_all[[i]]) - 1),
              fmt = "%#.4f"
            ),
            collapse = ", "
          ),
          sep = "\\tab "
        )
        if (i == model[[model_p]]$ncomp) {
          results <- paste0(results, "\\b0")
        }
        first_results <- c(
          first_results,
          results
        )
      }
    }
    first_results <- paste(first_results, collapse = paste0(eol, "\\par "))

    calibration_results <- paste(
      "\\pard\\fi-9120\\li9120\\tx420\\tx1420\\tx1820\\tx3640\\tx4660\\tx5620\\tx6580\\tx7920\\b Sample",
      "Set",
      "N",
      "ID",
      "Target",
      "Estimate",
      "Residual",
      "Mahalanobis\\b0",
      if (model$control$validation_type %in% c("loo", "kfold")) {
        "\\b QVAL\\b0"
      },
      sep = "\\tab "
    )
    opt_comp <- model[[model_p]]$ncomp
    end <- length(model[[model_p]]$calibration_statistics_all$Sample_index)
    if (end > 200) {
      start <- end - 200
    } else {
      start <- 1
    }
    for (i in start:end) {
      get_id <- tsv_data[model[[model_p]]$calibration_statistics_all$Sample_index[i], "ID"]
      if (get_id == "NA") {
        get_id <- "missing"
      }
      calibration_results <- c(
        calibration_results,
        paste(i,
          paste0("2:", snrs),
          "1",
          strtrim(get_id, width = 25),
          signif(model[[model_p]]$calibration_statistics[i, "Target"]),
          signif(model[[model_p]]$calibration_statistics[i, "fitted_y"]),
          signif(model[[model_p]]$calibration_statistics[i, "residual"]),
          signif(model[[model_p]]$calibration_statistics[i, "Mahalanobis"]),
          if (model$control$validation_type %in% c("loo", "kfold")) {
            signif(model[[model_p]]$calibration_statistics[i, "Q_value"])
          },
          sep = "\\tab "
        )
      )
    }
    calibration_results <- paste(calibration_results, collapse = paste0(eol, "\\par "))

    r_sq <- (cor(
      model[[model_p]]$calibration_statistics_all$Target,
      model[[model_p]]$calibration_statistics_all$fitted_y
    )^2)[opt_comp]
    if (!is.null(model[[model_p]]$model_cv)) {
      r_sq_cv <- paste0(
        "\\tab R{\\sub cv}\\'b2=",
        signif(model[[model_p]]$model_cv$grid[opt_comp, "rsq"])
      )
      if (!is.null(model[[model_p]]$calibration_statistics_all$cv_residual)) {
        sigma_cv <- paste0(
          "\\tab \\u0963?{\\sub cv}=",
          signif(sd(model[[model_p]]$calibration_statistics[, "cv_residual"]))
        )
      } else {
        sigma_cv <- ""
      }
    } else {
      r_sq_cv <- ""
      sigma_cv <- ""
    }

    rtf_style <- "{\\rtf1\\ansi\\ansicpg1252\\deff0\\deflang1033{\\fonttbl{\\f0\\fnil\\fcharset0 Segoe UI;}{\\f1\\fnil\\fcharset0 Tahoma;}{\\f2\\fnil\\fcharset161 Segoe UI;}}"
    tsv_path <- gsub("\\", "/", tsv_path, fixed = TRUE)
    output <- c(
      rtf_style,
      "\\viewkind4\\uc1\\pard\\b\\f0\\fs9 Loading\\b0",
      paste0("\\tab ", tsv_path),
      "\\b Select\\b0\\pard\\fi-4800\\li4800\\tx320\\tx740\\tx2100\\tx2700\\tx3300\\tx4000\\tx4800 ",
      paste0("\\tab \\b Query1\\b0\\tab Check = True"),
      paste0("\\tab \\b Y", number, "\\b0\\tab ", target_line),
      paste("\\tab \\b File", "Unit", "ID's", "Targets", "Observations", "Range", "Records\\b0", sep = "\\tab "),
      paste("\\tab File2",
        snrs,
        length(Y),
        length(unique(Y)),
        length(Y),
        paste0(signif(min(Y), digits = 3), "- ", signif(max(Y), digits = 3)),
        paste0(records, collapse = ", "),
        sep = "\\tab "
      ),
      "",
      paste0(
        "\\tab \\b TOTAL OBSERVATIONS DELETED\\tab \\tab ",
        length(model$skipped_indices$manually_skipped),
        " (",
        round(
          length(model$skipped_indices$manually_skipped) /
            (model[[model_p]]$model$n_observations +
              length(model$skipped_indices$manually_skipped)) * 100,
          digits = 1
        ),
        "%)\\b0"
      ),
      "",
      first_results,
      "",
      "\\b Calibration Results\\b0",
      calibration_results,
      paste0(
        "\\tab \\tab \\tab \\tab \\b R\\'b2=",
        signif(r_sq),
        "\\tab\\u0963?{\\sub i}=",
        signif(sd(model[[model_p]]$calibration_statistics[, "residual"])),
        r_sq_cv,
        sigma_cv,
        "\\b0 \\f0"
      ),
      "\\pard\\fi-7920\\li7920\\tx720",
      "\\b SNR\\tab \\b0 ALL",
      paste0(
        "\\b SEC/MAX\\b0\\tab ",
        signif(model[[model_p]]$model$cal_error[opt_comp, "cal_set_error"]),
        "/",
        signif(model[[model_p]]$model$cal_error[opt_comp, "max_residuals"])
      ),
      "\\b Bias\\b0\\tab 0.000",
      paste0("\\b N\\b0\\tab ", model[[model_p]]$model$n_observations)
    )
    # Final model if initial_fit exists, skip otherwise
    if (!is.null(model$initial_fit)) {
      n_deletes <- length(model$detected_outliers$removed)
      output <- c(
        output,
        "",
        paste0("\\b Deleting ", n_deletes, " samples and restarting...\\b0"),
        ""
      )
      n_deletes <- n_deletes + length(model$skipped_indices$manually_skipped)
      Y <- model$final_model$calibration_statistics_all$Target
      target_line <- paste(model$target_variable, floor(min(Y, na.rm = T)), ceiling(max(Y, na.rm = T)))
      if (is.null(model$metadata)) {
        target_line <- paste(target_line, "0.0")
      } else {
        target_line <- paste(
          target_line,
          paste0(decimals, model$metadata$Unit)
        )
      }
      snrs <- as.character(unique(tsv_data$SNR[tsv_data$SNR != "NA"]))
      if (length(snrs) == 0) {
        snrs <- as.character(unique(tsv_data$SRN[tsv_data$SRN != "NA"]))
        if (length(snrs) == 0) {
          snrs <- "missing"
        }
      }
      snrs <- snrs[1]

      sample_ids <- model$final_model$calibration_statistics_all$Sample_index
      records <- NULL
      start <- sample_ids[1]
      for (indces in sample_ids) {
        if (!(indces + 1) %in% sample_ids) {
          if (indces == start) {
            records <- c(records, paste0(start))
          } else {
            records <- c(records, paste0(start, "-", indces))
          }
          start <- sample_ids[2]
        }
        sample_ids <- sample_ids[-1]
      }


      if (is.null(model$final_model$model_cv$grid)) {
        model_type <- ""
        fit_method <- model$final_model$model$method$fit_method
        if (fit_method == "plsr") {
          model_type <- "PLS"
        }
        if (fit_method == "xlsr") {
          model_type <- "XLS"
        }
        first_results <- paste0(
          "\\pard\\fi-4320\\li4320\\tx720\\tx1440\\tx2160\\tx2880\\tx3600\\tx4320\\tx5040\\b ",
          toupper(model_type),
          "\\tab XVAR", "\\tab SEC", "\\tab CMAX", "\\tab Outliers\\b0"
        )
        for (i in 1:model$method$ncomp) {
          results <- paste(
            if (i == model$final_model$ncomp) {
              paste0("\\b ", i)
            } else {
              i
            },
            paste0(
              round(
                model$final_model$model$explained_variance$x_variance["x_expl_var", i] * 100,
                digits = 2
              ),
              "%"
            ),
            signif(model$final_model$model$cal_error[i, "cal_set_error"]),
            signif(model$final_model$model$cal_error[i, "max_residuals"]),
            paste(
              sprintf(
                2 + 0.0001 * (unlist(model$final_model$detected_outliers_all[[i]]) - 1),
                fmt = "%#.4f"
              ),
              collapse = ", "
            ),
            sep = "\\tab "
          )
          if (i == model$final_model$ncomp) {
            results <- paste0(results, "\\b0")
          }
          first_results <- c(
            first_results,
            results
          )
        }
      } else {
        model_type <- ""
        fit_method <- model$final_model$model$method$fit_method
        if (fit_method == "plsr") {
          model_type <- "PLS"
        }
        if (fit_method == "xlsr") {
          model_type <- "XLS"
        }
        first_results <- paste0(
          "\\pard\\fi-4320\\li4320\\tx720\\tx1440\\tx2160\\tx2880\\tx3600\\tx4320\\b ",
          toupper(model_type),
          "\\tab XVAR", "\\tab SEC", "\\tab SECV", "\\tab CMAX", "\\tab CVMAX", "\\tab Outliers\\b0"
        )
        for (i in 1:model$method$ncomp) {
          results <- paste(
            if (i == model$final_model$ncomp) {
              paste0("\\b ", i)
            } else {
              i
            },
            paste0(
              round(
                model$final_model$model$explained_variance$x_variance["x_expl_var", i] * 100,
                digits = 2
              ),
              "%"
            ),
            signif(model$final_model$model$cal_error[i, "cal_set_error"]),
            signif(model$final_model$model_cv$grid[i, "rmse"]),
            signif(model$final_model$model$cal_error[i, "max_residuals"]),
            signif(model$final_model$model_cv$grid[i, "largest_residual"]),
            paste(
              sprintf(
                2 + 0.0001 * (unlist(model$final_model$detected_outliers_all[[i]]) - 1),
                fmt = "%#.4f"
              ),
              collapse = ", "
            ),
            sep = "\\tab "
          )
          if (i == model$final_model$ncomp) {
            results <- paste0(results, "\\b0")
          }
          first_results <- c(
            first_results,
            results
          )
        }
      }
      first_results <- paste(first_results, collapse = paste0(eol, "\\par "))

      calibration_results <- paste(
        "\\pard\\fi-9120\\li9120\\tx420\\tx1420\\tx1820\\tx3640\\tx4660\\tx5620\\tx6580\\tx7920\\b Sample",
        "Set",
        "N",
        "ID",
        "Target",
        "Estimate",
        "Residual",
        "Mahalanobis\\b0",
        if (model$control$validation_type %in% c("loo", "kfold")) {
          "\\b QVAL\\b0"
        },
        sep = "\\tab "
      )

      opt_comp <- model$final_model$ncomp
      end <- length(model$final_model$calibration_statistics_all$Sample_index)
      if (end > 200) {
        start <- end - 200
      } else {
        start <- 1
      }
      for (i in start:end) {
        get_id <- tsv_data[model$final_model$calibration_statistics_all$Sample_index[i], "ID"]
        if (get_id == "") {
          get_id <- "missing"
        }
        calibration_results <- c(
          calibration_results,
          paste(i,
            paste0("2:", snrs),
            "1",
            strtrim(get_id, width = 25),
            signif(model$final_model$calibration_statistics[i, "Target"]),
            signif(model$final_model$calibration_statistics[i, "fitted_y"]),
            signif(model$final_model$calibration_statistics[i, "residual"]),
            signif(model$final_model$calibration_statistics[i, "Mahalanobis"]),
            if (model$control$validation_type %in% c("loo", "kfold")) {
              signif(model$final_model$calibration_statistics[i, "Q_value"])
            },
            sep = "\\tab "
          )
        )
      }
      calibration_results <- paste(calibration_results, collapse = paste0(eol, "\\par "))

      r_sq <- (cor(
        model$final_model$calibration_statistics_all$Target,
        model$final_model$calibration_statistics_all$fitted_y
      )^2)[opt_comp]
      if (!is.null(model$final_model$model_cv)) {
        r_sq_cv <- paste0(
          "\\tab R{\\sub cv}\\'b2=",
          signif(model$final_model$model_cv$grid[opt_comp, "rsq"])
        )
        if (!is.null(model$final_model$calibration_statistics_all$cv_residual)) {
          sigma_cv <- paste0(
            "\\tab \\u0963?{\\sub cv}=",
            signif(sd(model$final_model$calibration_statistics[, "cv_residual"]))
          )
        } else {
          sigma_cv <- ""
        }
      } else {
        r_sq_cv <- ""
        sigma_cv <- ""
      }

      output <- c(
        output,
        "\\b Select\\b0\\pard\\fi-4800\\li4800\\tx320\\tx740\\tx2100\\tx2700\\tx3300\\tx4000\\tx4800 ",
        paste0("\\tab \\b Query1\\b0\\tab Check = True"),
        paste0("\\tab \\b Y", number, "\\b0\\tab ", target_line),
        paste("\\tab \\b File", "Unit", "ID's", "Targets", "Observations", "Range", "Records\\b0", sep = "\\tab "),
        paste("\\tab File2",
          snrs,
          length(Y),
          length(unique(Y)),
          length(Y),
          paste0(signif(min(Y), digits = 3), "- ", signif(max(Y), digits = 3)),
          paste0(records, collapse = ", "),
          sep = "\\tab "
        ),
        "",
        paste0(
          "\\tab \\b TOTAL OBSERVATIONS DELETED\\tab \\tab ",
          n_deletes,
          " (",
          round(
            n_deletes /
              (model[[model_p]]$model$n_observations +
                length(model$skipped_indices$manually_skipped)) * 100,
            digits = 1
          ),
          "%)\\b0"
        ),
        "",
        first_results,
        "",
        "\\b Calibration Results\\b0",
        calibration_results,
        paste0(
          "\\tab \\tab \\tab \\tab \\b R\\'b2=",
          signif(r_sq),
          "\\tab\\u0963?{\\sub i}=",
          signif(sd(model$final_model$calibration_statistics[, "residual"])),
          r_sq_cv,
          sigma_cv,
          "\\b0 \\f0"
        ),
        "\\pard\\fi-7920\\li7920\\tx720",
        "\\b SNR\\tab \\b0 ALL",
        paste0(
          "\\b SEC/MAX\\b0\\tab ",
          signif(model$final_model$model$cal_error[opt_comp, "cal_set_error"]),
          "/",
          signif(model$final_model$model$cal_error[opt_comp, "max_residuals"])
        ),
        "\\b Bias\\b0\\tab 0.000",
        paste0("\\b N\\b0\\tab ", model$final_model$model$n_observations)
      )
    }
    output <- paste(output, collapse = paste0(eol, "\\par "))
    writeLines(paste0(output, "}"), con = save_dir)
    if (verbose) {
      setTxtProgressBar(pb, number - 1)
    }
    number <- number + 1
  }
  if (verbose) {
    close(pb)
  }
}
