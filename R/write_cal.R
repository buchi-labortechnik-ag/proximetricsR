#' @title Write ProxiMate readable calibration (.cal) files
#' @name write_cal
#' @description
#'
#' \loadmathjax
#' This function allows models produced by the \code{\link{calibrate}} to be
#' exported into a file which is readable by ProxiMate devices.
#'
#' @usage
#'
#' write_cal(object, path, tsv_paths, application_name = "Untitled", verbose = TRUE)
#'
#' @param object a list of objects of class \code{spectral_model}. These models
#' should be generated using the \code{\link{calibrate}} function.
#' @param path a string indicating the directory in which the file should
#' be saved to.
#' @param tsv_paths a vector of character strings for the paths (including the
#' names) of the tsv data files. See details.
#' @param application_name a string with the name of the generated .cal file.
#' Default is \code{"Untitled"}.
#' @param verbose a logical. Should a progress bar for the generated files be
#' printed? Default is \code{TRUE}.
#'
#' @details
#' This function generates calibration files (.cal) for the provided models in
#' \code{object}, which are readable by a ProxiMate device. In particular,
#' this function provides a way to export models produced by R directly into
#' the device.
#'
#' The main usage of this function is to be called by \code{\link{proximate_write_nax}}.
#' However, it might also be beneficial to be run directly.
#'
#' The generated files are named according to the name of the application
#' (provided by \code{application_name}) plus the name of the involved response
#' variables, separated by a single dot. The files are saved into the provided
#' directory (\code{path}).
#'
#' It is required that the models passed to this function are generated using
#' the function \code{\link{calibrate}}. Note that if the models do not contain
#' any input data (e.g. by setting \code{return_inputs} to \code{FALSE}), this
#' function will fail to compute, even if a path to the correct .tsv file is provided.
#' This is because the data contained in that .tsv file can differ from what
#' the considered data actually is. Hence, we suggest to always include the data
#' when creating a NIRWise PLUS related file, i.e. for any of the \code{write_*}
#' functions provided in this package.
#'
#' Lastly, note that there are no checks made on whether the .tsv file exists,
#' as the only part of it that is actually used is where it can be found. An
#' application on a ProxiMate is going to check the path to the file in the end,
#' at which point the file that is named in a .cal file must actually be present.
#' As such, if you are using this function individually and compiling an application
#' (.nax) file yourself, you must ensure that the .tsv file is correctly set up.
#' These possible issues are taken care of when using the \code{\link{proximate_write_nax}}
#' function.
#'
#' @examples
#' data("NIRcannabis")
#' control <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential")
#' modell <- calibrate(CBDA ~ spc,
#'   data = NIRcannabis, preprocess = preprocess_recipe(),
#'   method = fit_plsr(15), control = control, verbose = FALSE
#' )
#'
#' write_cal(
#'   object = list(modell),
#'   path = tempdir(),
#'   tsv_paths = "C:/Data/some_tsv.tsv",
#'   application_name = "Untitled",
#'   verbose = FALSE
#' )
#' @return NULL
#' @author Claudio Orellano, Leonardo Ramirez-Lopez
#' @noRd

write_cal <- function(object, path, tsv_paths = "", application_name = "Untitled", verbose = TRUE) {
  # Sanity checks
  if (missing(object)) {
    stop("Parameter 'object' is required for generating the .prj and .cal files")
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
  if (!is.character(application_name)) {
    stop("'application_name' has to be a character.")
  }
  if (missing(path)) {
    stop("'path' is required. Please provide the directory where the file should be saved.")
  }
  if (sub(".*(?=.{1}$)", "", path, perl = T) != "/") {
    path <- paste0(path, "/")
  }
  if (!dir.exists(path)) {
    dir.create(path)
  }
  if (any(!is.character(tsv_paths))) {
    stop("Please provide the paths to the .tsv files as a vector of character strings.")
  }
  if (all(sapply(sapply(object, FUN = "[[", MARGIN = "input_data"), FUN = "is.null"))) {
    stop(
      "No data found in any model of 'object'. Data is required to be present",
      " when generating calibration files."
    )
  }
  if (!all(mapply(object, FUN = attr, which = "data_hash") == mapply(object, FUN = attr, which = "data_hash")[1])) {
    warning(
      "Caution: Differences found in data used to create the models in 'object'.",
      " This can cause issues when using the calibration files."
    )
  }
  which_model <- which(!sapply(sapply(object, FUN = "[[", MARGIN = "input_data"), FUN = "is.null"))[1]
  tsv_data <- object[[which_model]]$input_data$data

  tsv_paths <- gsub("/", "\\", tsv_paths, fixed = TRUE)
  tsv_paths <- paste0(
    "Files:File", seq_along(tsv_paths) + 1, "\t", tsv_paths,
    collapse = "\r\n"
  )

  if (verbose) {
    cat("\033\033[3mComputing calibration files...\n\033[23m\033[39m")
    pb <- txtProgressBar(min = 0, max = length(object), char = "-", style = 3)
  }

  # "%mydo%" <- get("%do%")
  # allow_parallel <- all(
  #   sapply(lapply(object, FUN = "[[", MARGIN = "control"), FUN = "[[", MARGIN = "allow_parallel"))
  # if (allow_parallel & getDoParRegistered()) {
  #   "%mydo%" <- get("%dopar%")
  # }
  #
  # ith <- NULL
  # a <- foreach(
  #   ith = seq_along(object),
  #   .inorder = FALSE,
  #   .export = NULL
  # ) %mydo% {
  for (model in object) {
    target_name <- model$target_variable
    proj_name <- paste0(application_name, ".", target_name, ".prj")
    save_dir <- paste0(path, application_name, ".", target_name, ".cal")

    # Decompose model
    n_zero_cols <- 0
    ncomp <- model$method$ncomp
    # applied_pp <- unlist(model$preprocess$steps)
    control <- model$control
    wavs <- as.double(model$predictor_variables)
    detected_outliers <- model$detected_outliers$removed
    final_ncomp <- model$final_ncomp
    skipped <- model$skipped_indices$manually_skipped

    final_model <- model$final_model
    model_cv <- final_model$model_cv
    fitted_model <- final_model$model
    cal_stats <- final_model$calibration_statistics_all
    Y <- cal_stats$Target
    relevant_data <- tsv_data[cal_stats$Sample_index, ]

    # Reference
    all_target_names <- sapply(object, FUN = "[[", MARGIN = "target_variable")
    ref_number <- which(target_name == all_target_names)
    if (is.null(object[[ref_number]]$metadata$DecimalPlaces)) {
      decimals_units <- "0.0"
    } else {
      decimals <- paste0(
        "0.",
        paste0(rep("0", object[[ref_number]]$metadata$DecimalPlaces),
          collapse = ""
        )
      )
      if (object[[ref_number]]$metadata$Unit == "%") {
        units <- "%"
      } else {
        units <- ""
      }
      decimals_units <- paste0(decimals, units)
    }
    ref_param <- paste(
      target_name,
      floor(min(Y, na.rm = TRUE)),
      ceiling(max(Y, na.rm = TRUE)),
      decimals_units
    )
    ref_output <- paste0(ref_number + 1, "\t", ref_param)

    # Appropriate .tsv data
    snrs <- na.omit(as.character(unique(relevant_data$SNR[relevant_data$SNR != "NA"])))
    if (length(snrs) == 0) {
      snrs <- na.omit(as.character(unique(relevant_data$SRN[relevant_data$SRN != "NA"])))
      if (length(snrs) == 0) {
        snrs <- "missing"
      }
    }
    snrs <- paste(snrs, collapse = ";")
    dates <- as.character(relevant_data$Date)
    dates <- paste(dates, collapse = ",")
    ids <- as.character(relevant_data$ID)
    ids <- paste(ids, collapse = ",")

    # Preprocessing
    # pp_output <- data.frame(pos = c(101, 100, 102, 103), o = c("", "", "", ""))
    # if ("nwp_spline" %in% applied_pp) {
    #   pos <- match("nwp_spline", applied_pp)
    #   param <- paste(
    #     applied_pp["min_w"],
    #     applied_pp["max_w"],
    #     applied_pp["resolution"]
    #   )
    #   pp_output[1, ] <- c(pos, paste("\tSpline [#]X1 [#]X2 [#]X3", param))
    # }
    # if ("nwp_derivative" %in% applied_pp) {
    #   pos <- match("nwp_derivative", applied_pp)
    #   param <- paste(applied_pp[pos + 1], applied_pp[pos + 2], applied_pp[pos + 3])
    #   pp_output[2, ] <- c(pos, paste("\tDG", param))
    #   n_zero_cols <- n_zero_cols + as.numeric(applied_pp[pos + 2]) + as.numeric(applied_pp[pos + 3])
    # }
    # if ("nwp_snvt" %in% applied_pp) {
    #   pos <- match("nwp_snvt", applied_pp)
    #   pp_output[3, ] <- c(pos, "\tSNVT")
    # }
    # if ("nwp_smooth" %in% applied_pp) {
    #   pos <- match("nwp_smooth", applied_pp)
    #   pp_output[4, ] <- c(pos, paste("\tSMOOTH", applied_pp[pos + 1]))
    # }
    # pp_output <- pp_output[order(as.double(pp_output$pos)), ]
    # pp_output <- subset(pp_output, as.double(pp_output$pos) < 100)
    # if (nrow(pp_output) > 0) {
    #   pp_output$pos <- 1:length(pp_output$pos)
    #   pp_output <- paste0("Pretreat1:Treat",
    #     apply(pp_output, 1, paste, collapse = ""),
    #     collapse = "\r\n"
    #   )
    #   pp_output <- paste0("\r\n", pp_output)
    # } else {
    #   pp_output <- ""
    # }
    applied_pp <- model$preprocess$steps
    if (length(applied_pp) == 0) {
      pp_output <- ""
      v1 <- TRUE
    } else {
      # "Version 1.0" signals the prediction engine to use the current (non-legacy)
      # algorithm variants. All prep_* constructors use the current behaviour.
      v1 <- TRUE

      pp_output <- paste(
        paste0("\r\nPretreat1:Treat", seq_along(applied_pp)),
        mapply(prepro_to_string, applied_pp),
        sep = "\t",
        collapse = ""
      )
      if ("prep_derivative" %in% mapply("[[", applied_pp, MARGIN = "method")) {
        wh <- which(mapply("[[", applied_pp, MARGIN = "method") %in% "prep_derivative")
        n_zero_cols <- n_zero_cols + applied_pp[[wh]]$half_w + applied_pp[[wh]]$half_s
      }
    }

    # Model
    factors <- paste("Model1:Factors", final_ncomp, sep = "\t")
    if (length(skipped) > 0) {
      deletes <- sapply(sapply(
        split(skipped, ceiling(seq_along(skipped) / 10)),
        FUN = "*", MARGIN = 0.0001, simplify = F
      ), FUN = "+", MARGIN = 1.9999, simplify = F)
      del <- paste0(
        "Model1:Delete",
        names(deletes),
        "\t",
        lapply(lapply(deletes, FUN = sprintf, fmt = "%#.4f"), FUN = paste, collapse = ","),
        collapse = "\r\n"
      )
      del <- paste0("\r\n", del)
    } else {
      del <- ""
    }
    if (control$remove_outliers > 0 & length(detected_outliers) > 0) {
      del_indeces <- sapply(sapply(
        split(detected_outliers, ceiling(seq_along(detected_outliers) / 10)),
        FUN = "*", MARGIN = 0.0001, simplify = F
      ), FUN = "+", MARGIN = 1.9999, simplify = F)
      del_indeces <- paste0(
        "Model1:Delete",
        as.numeric(names(del_indeces)) + ceiling(length(skipped) / 10),
        "\tAuto, True.",
        target_name,
        ",",
        lapply(lapply(
          del_indeces,
          FUN = sprintf, fmt = "%#.4f"
        ), FUN = paste, collapse = ","),
        collapse = "\r\n"
      )
      del <- paste0(del, "\r\n", del_indeces)
    }
    if (control$validation_type != "none") {
      if (control$validation_type == "loo") {
        cv <- fitted_model$n_observations
      } else {
        cv <- control$number
      }
      cv <- paste("Model1:CrossValidate", cv, sep = "\t")
      model_set <- paste("", cv, factors, sep = "\r\n")
    } else {
      model_set <- ""
    }
    if (control$remove_outliers > 0) {
      autodel <- paste(
        control$cal_residual_limit, control$mahalanobis_limit,
        control$val_residual_limit
      )
      autodel <- paste("Model1:AutoDelete", autodel, sep = "\t")
      model_set <- paste(model_set, autodel, sep = "\r\n")
    }
    model_set <- paste0(model_set, del)

    # Matrices
    if (n_zero_cols > 0) {
      wavs <- c(
        wavs[1] - n_zero_cols:1 * (wavs[2] - wavs[1]),
        wavs,
        wavs[length(wavs)] + 1:n_zero_cols * (wavs[2] - wavs[1])
      )
    }
    wavelengths <- paste(wavs, collapse = ",")
    zero <- paste(add_zero_cols(t(matrix(fitted_model$x_means)), n_zero_cols), collapse = ",")
    if (is.null(model$initial_fit)) {
      x_means <- paste(c(zero, ""), collapse = ";")
    } else {
      init_means <- paste(add_zero_cols(t(matrix(model$initial_fit$model$x_means)), n_zero_cols), collapse = ",")
      x_means <- paste(c(init_means, ""), collapse = ";")
    }
    model_type <- ""
    fit_method <- fitted_model$method$fit_method
    if (fit_method == "plsr") {
      model_type <- "PLS"
    }
    if (fit_method == "xlsr") {
      model_type <- "XLS"
    }
    target <- paste(Y, collapse = ",")
    mean_y <- paste(fitted_model$intercept, collapse = ",")
    weights <- matrix_cal_string(add_zero_cols(fitted_model$weights, n_zero_cols))
    loads <- matrix_cal_string(add_zero_cols(fitted_model$x_loadings, n_zero_cols))
    scale <- paste(fitted_model$sd_scores, collapse = ",")
    scores <- matrix_cal_string(t(fitted_model$scores))
    bias <- attr(scale(as.vector(Y) - fitted_model$fitted_y, center = TRUE), "scaled:center")
    bias <- paste0(paste0(round(bias, digits = 8), collapse = ";"), ";")

    # Press
    SEC <- fitted_model$cal_error[, 2]
    SECmax <- fitted_model$cal_error[, 3]
    n_press <- 2
    # SEP for validation; not supported
    SEP <- rep(0, ncomp)
    SEPmax <- rep(0, ncomp)
    # Cross-validation
    if (!is.null(model_cv)) {
      n_press <- n_press + 2
      SECV <- model_cv$grid[, "rmse"]
      SECVmax <- model_cv$grid[, "largest_residual"]
    } else {
      SECV <- rep(0, ncomp)
      SECVmax <- rep(0, ncomp)
    }
    press <- rbind(SEC, SEP, SECV, SECmax, SEPmax, SECVmax)
    quadratic_mean <- round(sqrt(colSums(press**2) / n_press), digits = 8)
    press <- matrix_cal_string(rbind(press, quadratic_mean))

    if (!is.null(cal_stats$predicted_y_in_cv)) {
      cv_est <- matrix_cal_string(t(cal_stats$predicted_y_in_cv))
    } else {
      cv_est <- ""
    }

    replacements <- data.frame(
      i_proj_name = proj_name,
      i_tsv_path = tsv_paths,
      i_reference = ref_output,
      i_pretreatments = pp_output,
      i_wavelengths = wavelengths,
      i_snrs = snrs,
      i_x_means = x_means,
      i_model_type = model_type,
      i_model = model_set,
      i_dates = dates,
      i_ids = ids,
      i_target = target,
      i_zero = zero,
      i_mean_y = mean_y,
      i_weights = weights,
      i_loads = loads,
      i_scale = scale,
      i_press = press,
      i_scores = scores,
      i_bias = bias,
      i_cv_est = cv_est
    )

    output_file <- template("cal", v1)
    for (str in colnames(replacements)) {
      output_file <- gsub(str, replacements[str], output_file, fixed = TRUE)
    }
    output_file <- paste0(output_file, collapse = "\r\n")
    writeChar(output_file, con = save_dir, eos = NULL)
    if (verbose) {
      setTxtProgressBar(pb, which(target_name == all_target_names))
    }
  }
  if (verbose) {
    close(pb)
  }
}
