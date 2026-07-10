#' @title Write NIRWise PLUS readable .prj files
#' @name write_prj
#' @description
#'
#' \loadmathjax
#' This function allows a calibration produced by R to be exported in NIRWise PLUS
#' calibration software.
#'
#' @usage
#'
#' write_prj(
#'    object, path, tsv_paths, application_name = "Untitled", verbose = TRUE,
#'    internal_prj_path = NULL
#' )
#'
#' @param object a list of objects of class \code{spectral_model}. These models
#' should be generated using the \code{\link{calibrate}} function.
#' @param path a string indicating the directory in which the file should
#' be saved.
#' @param tsv_paths a vector of character strings for the paths (including the
#' names) of the tsv data files. Defaults to an empty character. See details.
#' @param application_name a string with the name of the generated .prj file.
#' Defaults to \code{"Untitled"}.
#' @param verbose a logical. Should a progress bar for the generated files be
#' printed? Default is \code{TRUE}.
#' @param internal_prj_path a string. Only used for changing the path printed on
#' the first line of the project file. This is necessary mainly for calls from
#' \code{\link{proximate_write_nax}}, as it creates the project file in a temporary file,
#' which would also store that temporary path into the project file. This argument
#' allows you to overwrite that path individually. Otherwise, this parameter may
#' be ignored. If \code{NULL} (default), will be set to \code{path}.
#'
#' @details
#' This function generates project files (.prj) for the provided models in
#' \code{object}, which are readable by NIRWise PLUS calibration software. In
#' particular, this function provides a way to export models produced by R
#' directly into the calibration software.
#'
#' The main usage of this function is to be called by \code{\link{proximate_write_nax}}.
#' However, it might also be beneficial to be run directly.
#'
#' The generated files are named according to the name of the application, as
#' provided by \code{application_name}, plus the name of the involved response
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
#' at which point the file that is named in a .prj file must actually be present.
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
#' write_prj(
#'   object = list(modell),
#'   path = tempdir(),
#'   tsv_paths = "C:/Data/some_tsv.tsv",
#'   application_name = "Untitled",
#'   verbose = FALSE
#' )
#' @return NULL
#' @author Claudio Orellano, Leonardo Ramirez-Lopez
#' @noRd
write_prj <- function(object, path, tsv_paths = "", application_name = "Untitled",
                      verbose = TRUE, internal_prj_path = NULL) {
  # Sanity checks
  if (missing(object)) {
    stop("object is required for generating the .prj and .cal files.")
  }
  if (!is.list(object)) {
    stop("Parameter 'object' has to be a list.")
  } else {
    if (!all(sapply(object, FUN = inherits, what = "spectral_model"))) {
      stop("All entries in 'object' must be of class 'spectral_model'.")
    }
  }
  if (!is.logical(verbose)) {
    stop("Parameter 'verbose' has to be a logical.")
  }
  if (!is.character(application_name)) {
    stop("'application_name' has to be a character.")
  }

  if (missing(path)) {
    stop("'path' is required. Please provide the directory where the file should be saved.")
  }
  if (sub(".*(?=.{1}$)", "", path, perl = TRUE) != "/") {
    path <- paste0(path, "/")
  }
  if (!dir.exists(path)) {
    dir.create(path)
  }
  if (any(!is.character(tsv_paths))) {
    stop("Please provide the paths to the .tsv files as a vector of character strings.")
  }
  if (is.null(internal_prj_path) || !is.character(internal_prj_path)) {
    internal_prj_path <- path
  }
  if (!is.character(internal_prj_path)) {
    stop("'internal_prj_path' has to be a character.")
  }
  dir_name <- gsub("/", "\\", internal_prj_path, fixed = TRUE)
  if (all(sapply(sapply(object, FUN = "[[", MARGIN = "input_data"), FUN = "is.null"))) {
    stop(
      "No data found in any model of 'object'. Data is required to be present",
      " when generating calibration files."
    )
  }
  if (!all(mapply(object, FUN = attr, which = "data_hash") == mapply(object, FUN = attr, which = "data_hash")[1])) {
    warning(
      "Caution: Differences found in data used to create the models in 'object'.",
      " This can cause issues when using the project files."
    )
  }
  which_model <- which(!sapply(sapply(object, FUN = "[[", MARGIN = "input_data"), FUN = "is.null"))[1]
  tsv_data <- object[[which_model]]$input_data$data

  # Transform tsv paths to prj style.
  n_paths <- length(tsv_paths) + 1
  paths <- gsub("/", "\\", tsv_paths, fixed = TRUE)
  paths <- paste0('"Files:File', 2:n_paths, '","', paths, '",#TRUE#,"Files"\r\n', collapse = "")
  paths <- paste0(paths, '"Files:File', n_paths + 1, '","<Dbl-Click to load data-file>",#FALSE#,"Files"')

  # Create prj file for all model in object
  if (verbose) {
    cat("\033\033[3mComputing project files...\n\033[23m\033[39m")
    pb <- txtProgressBar(min = 0, max = length(object), char = "-", style = 3)
  }

  "%mydo%" <- get("%do%")
  allow_parallel <- all(
    sapply(lapply(object, FUN = "[[", MARGIN = "control"), FUN = "[[", MARGIN = "allow_parallel")
  )
  if (allow_parallel & getDoParRegistered()) {
    "%mydo%" <- get("%dopar%")
  }

  ith <- NULL
  # Start looping through all models.
  a <- foreach(
    ith = seq_along(object),
    .inorder = FALSE,
    .export = NULL
  ) %mydo% {
    model <- object[[ith]]
    target_name <- model$target_variable
    proj_name <- paste0(application_name, ".", target_name, ".prj")
    save_dir <- paste0(path, proj_name)
    proj_name <- paste0(proj_name, '",#TRUE#,"","', dir_name)

    # Decompose model
    ncomp <- model$method$ncomp
    control <- model$control
    detected_outliers <- model$detected_outliers$removed
    spectra <- model$preprocessed_X
    # Selector must correspond to the indices of the first fit.
    if (is.null(model$initial_fit)) {
      selector <- model$final_model$calibration_statistics_all$Sample_index
    } else {
      selector <- model$initial_fit$calibration_statistics_all$Sample_index
    }
    skipped <- model$skipped_indices$manually_skipped
    model_cv <- model$final_model$model_cv
    fitted_model <- model$final_model$model
    cal_stats <- model$final_model$calibration_statistics_all
    Y <- cal_stats$Target
    relevant_data <- tsv_data[cal_stats$Sample_index, , drop = FALSE]

    # References, import all from data, not just passed models
    references <- tsv_data[, extract_property_names(tsv_data), drop = FALSE]
    # Create prj reference output for all models that are in any of the passed models.
    ref_output <- NULL
    for (i in seq_along(object)) {
      ref_model <- object[[i]]
      ref_name <- ref_model$target_variable
      ref_logical <- paste0('",#', ref_name == target_name, '#,"Selector1","')
      if (is.null(ref_model$metadata)) {
        units <- ""
        decimals <- "0.0"
      } else {
        decimals <- paste0(
          "0.",
          paste0(rep("0", ref_model$metadata$DecimalPlaces),
            collapse = ""
          )
        )
        if (ref_model$metadata$Unit == "%") {
          units <- "%"
        } else {
          units <- ""
        }
      }
      if (ref_name == target_name) {
        ref_param <- paste(
          ref_model$target_variable,
          floor(min(Y, na.rm = TRUE)),
          ceiling(max(Y, na.rm = TRUE)),
          paste0(decimals, units)
        )
        ref_select <- paste0(paste(selector - 1, collapse = "\t"), '\n"')
      } else {
        ref_select <- '"'
        ref_param <- paste(
          ref_name,
          floor(min(references[ref_name], na.rm = TRUE)),
          ceiling(max(references[ref_name], na.rm = TRUE)),
          paste0(decimals, units)
        )
      }
      ref_line <- paste0(
        "Selector1:Y",
        i + 1,
        '","',
        ref_param,
        ref_logical,
        ref_select
      )
      ref_output <- c(ref_output, ref_line)
    }
    #
    all_target_names <- sapply(object, FUN = "[[", MARGIN = "target_variable")
    include_refs <- which(!colnames(references) %in% all_target_names)
    if (length(include_refs) > 0) {
      i <- 2
      for (refs in include_refs) {
        ref_logical <- '",#FALSE#,"Selector1","'
        ref_select <- '"'
        if (all(is.na(references[refs]))) {
          ref_param <- paste(colnames(references[refs]), 0, 0, "0.0")
        } else {
          ref_param <- paste(
            colnames(references[refs]),
            floor(min(references[refs], na.rm = TRUE)),
            ceiling(max(references[refs], na.rm = TRUE)),
            "0.0"
          )
        }
        ref_line <- paste0(
          "Selector1:Y",
          length(object) + i,
          '","',
          ref_param,
          ref_logical,
          ref_select
        )
        i <- i + 1
        ref_output <- c(ref_output, ref_line)
      }
    }
    ref_output <- paste0(ref_output, "", collapse = '\r\n"')

    # Check output of the prj file.
    check <- paste0(
      paste(which(tsv_data$Check == "True") - 1, collapse = "\t"),
      "\n"
    )

    # Prj output for recipes and composition.
    recipe_comp <- paste(
      '"Selector1:Query2","Recipe = *",#FALSE#,"Selector1",""',
      '"Selector1:Query3","Composition = *",#FALSE#,"Selector1",""',
      sep = "\r\n"
    )
    recipe <- na.omit(as.character(unique(tsv_data$Recipe)))
    recipe <- recipe[recipe != ""]
    len_recipe <- length(recipe)
    composition <- na.omit(as.character(unique(tsv_data$Composition)))
    composition <- composition[composition != ""]
    len_composition <- length(composition)
    n_query <- 4 + len_recipe + len_composition
    if (len_recipe > 0) {
      recipe <- paste0(
        '"Selector1:Query', 4:(3 + len_recipe),
        '","Recipe = ', recipe, '",#FALSE#,"Selector1",""',
        collapse = "\r\n"
      )
      recipe_comp <- paste(recipe_comp, recipe, sep = "\r\n")
    }
    if (len_composition > 0) {
      composition <- paste0(
        '"Selector1:Query', (4 + len_recipe):(n_query - 1),
        '","Composition = ', composition, '",#FALSE#,"Selector1",""',
        collapse = "\r\n"
      )
      recipe_comp <- paste(recipe_comp, composition, sep = "\r\n")
    }

    indexes <- as.double(rownames(relevant_data))
    indexes <- sprintf(2 + 0.0001 * (indexes - 1), fmt = "%#.4f")
    indexes <- paste(indexes, collapse = "\t")
    dates <- as.character(relevant_data$Date)
    dates <- paste(dates, collapse = "\t")
    ids <- as.character(relevant_data$ID)
    ids <- paste(ids, collapse = "\t")

    snrs <- na.omit(as.character(unique(relevant_data$SNR[relevant_data$SNR != "NA"])))
    if (length(snrs) == 0) {
      snrs <- na.omit(as.character(unique(relevant_data$SRN[relevant_data$SRN != "NA"])))
      if (length(snrs) == 0) {
        snrs <- "missing"
      }
    }
    snrs <- paste(snrs, collapse = ";")

    # Preprocessing
    wavs <- as.double(colnames(spectra))
    pp_recipe <- recipe_to_prj_string(model$preprocess$steps, min(wavs), max(wavs), wavs[2] - wavs[1])

    # applied_app <- unlist(model$preprocess$steps)
    # pp_output <- data.frame(
    #   pos = c(100, 99, 101),
    #   o = c(
    #     'DG 1 5 0",#FALSE#',
    #     'SNVT",#FALSE#',
    #     'SMOOTH 3",#FALSE#'
    #   )
    # )
    # if ("nwp_spline" %in% applied_pp) {
    #   spline1 <- paste(
    #     applied_pp["min_w"],
    #     applied_pp["max_w"],
    #     applied_pp["resolution"]
    #   )
    #   spline1 <- paste0(spline1, '",#TRUE#')
    # } else {
    #   wavs <- as.double(colnames(spectra))
    #   spline1 <- paste(min(wavs), max(wavs), wavs[2] - wavs[1])
    #   spline1 <- paste0(spline1, '",#FALSE#')
    # }
    # if ("nwp_derivative" %in% applied_pp) {
    #   pos <- match("nwp_derivative", applied_pp)
    #   param <- paste(applied_pp[pos + 1], applied_pp[pos + 2], applied_pp[pos + 3])
    #   pp_output[1, ] <- c(pos, paste0("DG ", param, '",#TRUE#'))
    # }
    # if ("nwp_snvt" %in% applied_pp) {
    #   pos <- match("nwp_snvt", applied_pp)
    #   pp_output[2, ] <- c(pos, paste0("SNVT", '",#TRUE#'))
    # }
    # if ("nwp_smooth" %in% applied_pp) {
    #   pos <- match("nwp_smooth", applied_pp)
    #   pp_output[3, ] <- c(pos, paste0("SMOOTH ", applied_pp[pos + 1], '",#TRUE#'))
    # }
    # pp_output <- pp_output[order(as.double(pp_output$pos)), ]
    # pp_output$pos <- seq_along(pp_output$pos)
    # pret_param1 <- pp_output$o[1]
    # pret_param2 <- pp_output$o[2]
    # pret_param3 <- pp_output$o[3]

    # Model
    if (length(skipped) > 0) {
      deletes <- sapply(sapply(
        split(skipped, ceiling(seq_along(skipped) / 10)),
        FUN = "*", MARGIN = 0.0001, simplify = F
      ), FUN = "+", MARGIN = 1.9999, simplify = F)
      del <- paste0('"Model1:Delete',
        names(deletes), '","', lapply(lapply(deletes, FUN = sprintf, fmt = "%#.4f"), FUN = paste, collapse = ","), '",#TRUE#,"Model1",""',
        collapse = "\r\n"
      )
      del <- paste0(del, "\r\n")
    } else {
      del <- NULL
    }
    if (length(detected_outliers) > 0 & control$remove_outliers > 0) {
      del_indeces <- sapply(sapply(split(detected_outliers, ceiling(seq_along(detected_outliers) / 10)), FUN = "*", MARGIN = 0.0001, simplify = F), FUN = "+", MARGIN = 1.9999, simplify = F)
      del_indeces <- paste0(
        '"Model1:Delete',
        as.numeric(names(del_indeces)) + ceiling(length(skipped) / 10),
        '","Auto, True.',
        target_name,
        ",",
        lapply(lapply(del_indeces, FUN = sprintf, fmt = "%#.4f"), FUN = paste, collapse = ","),
        '",#TRUE#,"Model1",""',
        collapse = "\r\n"
      )
      del <- paste0(del, del_indeces, "\r\n")
    }
    if (control$validation_type != "none") {
      if (control$validation_type == "kfold") {
        cv <- paste0(control$number, '",#TRUE#')
      } else if (control$validation_type == "loo") {
        cv <- paste0(fitted_model$n_observations, '",#TRUE#')
      } else {
        cv <- paste0(control$number, '",#FALSE#')
      }
      factors <- paste0(model$final_ncomp, '",#', toupper(control$fix_pls_factors), "#")
    } else {
      cv <- '5",#FALSE#'
      factors <- '15",#FALSE#'
    }
    autodel <- paste(
      control$cal_residual_limit, control$mahalanobis_limit,
      control$val_residual_limit
    )
    autodel <- paste0(autodel, '",#', control$remove_outliers > 0, "#")
    deletes <- paste(
      paste0(
        '"Model1:Delete',
        ceiling(length(skipped) / 10) + ceiling(length(detected_outliers) / 10) + 1,
        '","-",#FALSE#,"Model1",""'
      ), paste0(
        '"Model1:Delete', ceiling(length(skipped) / 10) + ceiling(length(detected_outliers) / 10) + 2,
        '","<new deletes>",#FALSE#,"Model1",""'
      ),
      sep = "\r\n"
    )
    del <- paste0(del, deletes)
    # Matrices
    wavelengths <- paste(colnames(spectra), collapse = "\t")
    zero <- paste(round(fitted_model$x_means, digits = 8), collapse = "\t")
    if (is.null(model$initial_fit)) {
      x_means <- paste(zero, '"', sep = "\n")
    } else {
      init_means <- paste(round(model$initial_fit$model$x_means, digits = 8), collapse = "\t")
      x_means <- paste(init_means, '"', sep = "\n")
    }
    mean_y <- paste0(round(fitted_model$intercept, digits = 8), '\n"')
    variations <- paste(paste(round(apply(spectra, 2, sd), digits = 8), collapse = "\t"),
      "",
      sep = "\n"
    )

    model_type <- ""
    fit_method <- fitted_model$method$fit_method
    if (fit_method == "plsr") {
      model_type <- "PLS"
    }
    if (fit_method == "xlsr") {
      model_type <- "XLS"
    }
    target <- paste(Y, collapse = "\t")
    observations <- matrix_prj_string(spectra)
    cent_obs <- matrix_prj_string(scale(spectra, scale = FALSE))
    weights <- matrix_prj_string(fitted_model$weights)
    loads <- matrix_prj_string(fitted_model$x_loadings)
    scale <- paste(round(fitted_model$sd_scores, digits = 8), collapse = "\t")
    regressions <- matrix_prj_string(fitted_model$coefficients)
    score_scal <- matrix_prj_string(fitted_model$scaled_scores, transp = TRUE)
    mahal <- matrix_prj_string(cal_stats$Mahalanobis, transp = TRUE)
    scores <- matrix_prj_string(fitted_model$scores, transp = TRUE)
    residuums <- matrix_prj_string(fitted_model$x_residuals, transp = TRUE)
    # set bias to 0?
    bias <- attr(scale(as.vector(Y) - fitted_model$fitted_y, center = TRUE), "scaled:center")
    bias <- paste(c(round(bias, digits = 8), ""), collapse = "\n")
    estimates <- matrix_prj_string(cal_stats$fitted_y, transp = TRUE)
    residuals <- matrix_prj_string(cal_stats$residual, transp = TRUE)
    testimates <- estimates
    tresiduals <- residuals

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
    quadratic_mean <- sqrt(colSums(press**2) / n_press)
    press <- matrix_prj_string(rbind(press, quadratic_mean))

    if (!is.null(cal_stats$predicted_y_in_cv)) {
      cv_est <- matrix_prj_string(cal_stats$predicted_y_in_cv, transp = TRUE)
      resid_cv <- matrix_prj_string(cal_stats$cv_residual, transp = TRUE)
    } else {
      cv_est <- ""
      resid_cv <- ""
    }

    replacements <- data.frame(
      i_proj_name = proj_name,
      i_tsv_path = paths,
      i_check = check,
      i_recipe_comp = recipe_comp,
      i_n_query = n_query,
      i_reference = ref_output,
      i_empty_ref = length(object) + length(include_refs) + 2,
      # i_spline1 = spline1,
      # i_pret_param1 = pret_param1,
      # i_pret_param2 = pret_param2,
      # i_pret_param3 = pret_param3,
      i_preprocess = pp_recipe,
      i_mod_type = model_type,
      i_cv = cv,
      i_factors = factors,
      i_autodel = autodel,
      i_del = del,
      i_indexes = indexes,
      i_snrs = snrs,
      i_dates = dates,
      i_ids = ids,
      i_target = target,
      i_x_means = x_means,
      i_wavelengths = wavelengths,
      i_pret_wavel = wavelengths,
      i_mean_y = mean_y,
      i_mean_y_two = mean_y,
      i_variations = variations,
      i_zero = zero,
      i_weights = weights,
      i_loads = loads,
      i_scale = scale,
      i_regressions = regressions,
      i_press = press,
      i_scores = scores,
      i_score_scal = score_scal,
      i_mahal = mahal,
      i_residuums = residuums,
      i_bias = bias,
      i_estimates = estimates,
      i_residuals = residuals,
      i_est_cv = cv_est,
      i_resid_cv = resid_cv,
      i_testimates = testimates,
      i_tresiduals = tresiduals,
      i_cent_obs = cent_obs,
      i_observations = observations
    )
    output_file <- template("prj")
    for (istr in colnames(replacements)) {
      output_file[istr] <- sub(istr, replacements[istr], output_file[istr], fixed = TRUE)
    }
    output_file <- paste0(output_file, collapse = "\r\n")
    writeChar(output_file, con = save_dir, eos = NULL)
    if (verbose) {
      setTxtProgressBar(pb, which(target_name == all_target_names))
    }
    target_name
  }
  if (verbose) {
    close(pb)
  }
}
