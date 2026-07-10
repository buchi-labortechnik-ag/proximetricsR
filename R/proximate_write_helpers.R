#' @title Generates a template for .prj files
#' @param file_version a string, either \code{c('prj', 'cal')}, indicating which
#' type of template should be produced.
#' @param v1 a boolean. For `cal` files, should the line for version 1.0 be printed?
#' @return a vector of characters, which may be filled with correct values of
#' the computed model.
#' @keywords internal
template <- function(file_version = c("prj", "cal"), v1 = TRUE) {
  file_version <- match.arg(file_version)
  if (file_version == "prj") {
    c(
      i_proj_name = '"Project1","i_proj_name"',
      '"Files","Files",#TRUE#,"Project1",""',
      '"Files:File1","<DblClick to load ID-file>",#FALSE#,"Files"',
      i_tsv_path = "i_tsv_path",
      '"Selector1","Selector",#TRUE#,"Project1",""',
      i_check = '"Selector1:Query1","Check = True",#TRUE#,"Selector1","i_check"',
      i_recipe_comp = "i_recipe_comp",
      i_n_query = '"Selector1:Queryi_n_query","<field> = <pattern>",#FALSE#,"Selector1",""',
      '"Selector1:Y","Recipe 0 100 ?;*;?",#FALSE#,"Selector1",""',
      '"Selector1:Y1","ID 0 100 ?;*;?",#FALSE#,"Selector1",""',
      i_reference = '"i_reference',
      i_empty_ref = '"Selector1:Yi_empty_ref","<parameter> <min> <max> <format>",#FALSE#,"Selector1",""',
      '"Pretreat1","Pretreat",#TRUE#,"Project1",""',
      # '"Pretreat1:X","[#]#*",#TRUE#,"Pretreat1"',
      # i_spline1 = '"Pretreat1:Treat1","Spline [#]X1 [#]X2 [#]X3 i_spline1,"Pretreat1"',
      # '"Pretreat1:Treat2","Spline [#]X1 [#]X2 [#]X3 400 1700 4",#FALSE#,"Pretreat1"',
      # '"Pretreat1:Treat3","Spline [#]X1 [#]X2 [#]X3 400 900 4",#FALSE#,"Pretreat1"',
      # i_pret_param1 = '"Pretreat1:Treat4","i_pret_param1,"Pretreat1"',
      # i_pret_param2 = '"Pretreat1:Treat5","i_pret_param2,"Pretreat1"',
      # i_pret_param3 = '"Pretreat1:Treat6","i_pret_param3,"Pretreat1"',
      # '"Pretreat1:Treat7","<new treatment>",#FALSE#,"Pretreat1"',
      i_preprocess = '"Pretreat1:X","[#]#*",#TRUE#,"Pretreat1"i_preprocess',
      i_pret_wavel = '"Pretreat1.Wavelengths","Wavelengths",#TRUE#,"Pretreat1","i_pret_wavel"',
      i_snrs = '"Pretreat1.SNRs","SNRs",#TRUE#,"Pretreat1","i_snrs"',
      '"Pretreat1.WLCs","WLCs",#TRUE#,"Pretreat1",""',
      i_x_means = '"Pretreat1.Means","Means",#TRUE#,"Pretreat1","i_x_means',
      i_mean_y = '"Pretreat1.Targets","Targets",#TRUE#,"Pretreat1","i_mean_y',
      '"Pretreat1.OSC","OSC",#TRUE#,"Pretreat1",""',
      i_variations = '"Pretreat1.Variations","Variations",#TRUE#,"Pretreat1","i_variations"',
      '"Model1","Model",#TRUE#,"Project1",""',
      i_mod_type = '"Model1:Type","i_mod_type",#TRUE#,"Model1",""',
      '"Model1:Validate","3",#FALSE#,"Model1",""',
      i_cv = '"Model1:CrossValidate","i_cv,"Model1",""',
      i_factors = '"Model1:Factors","i_factors,"Model1",""',
      i_autodel = '"Model1:AutoDelete","i_autodel,"Model1",""',
      i_del = "i_del",
      i_wavelengths = '"Model1.Wavelengths","Wavelengths",#TRUE#,"Model1","i_wavelengths"',
      i_indexes = '"Indexes","Indexes",#TRUE#,"Model1","i_indexes"',
      i_dates = '"Model1.Dates","Dates",#TRUE#,"Model1","i_dates"',
      i_ids = '"Model1.IDs","IDs",#TRUE#,"Model1","i_ids"',
      i_target = '"Target","Target",#TRUE#,"Model1","i_target"',
      i_observations = '"Observations","Observations",#TRUE#,"Model1","i_observations"',
      i_cent_obs = '"ObservationsZ","ObservationsZ",#TRUE#,"Model1","i_cent_obs"',
      i_zero = '"Zero","Zero",#TRUE#,"Model1","i_zero"',
      i_mean_y_two = '"Center","Center",#TRUE#,"Model1","i_mean_y_two',
      i_weights = '"Weights","Weights",#TRUE#,"Model1","i_weights"',
      i_loads = '"Loads","Loads",#TRUE#,"Model1","i_loads"',
      i_scale = '"Scale","Scale",#TRUE#,"Model1","i_scale"',
      i_regressions = '"Regressions","Regressions",#TRUE#,"Model1","i_regressions"',
      i_press = '"Press","Press",#TRUE#,"Model1","i_press"',
      i_scores = '"Scores","Scores",#TRUE#,"Model1","i_scores"',
      i_score_scal = '"Scores Scaled","Scores Scaled",#TRUE#,"Model1","i_score_scal"',
      i_mahal = '"Mahalanobis","Mahalanobis",#TRUE#,"Model1","i_mahal"',
      i_residuums = '"Residuums","Residuums",#TRUE#,"Model1","i_residuums"',
      i_bias = '"Bias","Bias",#TRUE#,"Model1","i_bias"',
      i_estimates = '"Estimates","Estimates",#TRUE#,"Model1","i_estimates"',
      '"Skew","Skew",#TRUE#,"Model1",""',
      '"SkewBias","SkewBias",#TRUE#,"Model1",""',
      i_residuals = '"Residuals","Residuals",#TRUE#,"Model1","i_residuals"',
      i_est_cv = '"CVEstimates","CVEstimates",#TRUE#,"Model1","i_est_cv"',
      i_resid_cv = '"CVResiduals","CVResiduals",#TRUE#,"Model1","i_resid_cv"',
      i_testimates = '"TEstimates","TEstimates",#TRUE#,"Model1","i_testimates"',
      i_tresiduals = '"TResiduals","TResiduals",#TRUE#,"Model1","i_tresiduals"',
      '"Validation","Validation",#TRUE#,"Model1",""',
      '"Validation.Indexes","Indexes",#TRUE#,"Validation",""',
      '"Validation.IDs","IDs",#TRUE#,"Validation",""',
      '"Validation.Targets","Targets",#TRUE#,"Validation",""',
      '"Validation.Observations","Observations",#TRUE#,"Validation",""',
      '"Validation.Scores","Scores",#TRUE#,"Validation",""',
      '"Validation.Mahalanobis","Mahalanobis",#TRUE#,"Validation",""',
      '"Validation.Residuums","Residuums",#TRUE#,"Validation",""',
      '"Validation.Estimates","Estimates",#TRUE#,"Validation",""',
      '"Validation.Residuals","Residuals",#TRUE#,"Validation",""',
      ""
    )
  } else {
    c(
      if (v1) "Version\t1.0",
      "Project1\ti_proj_name",
      "Files\tFiles",
      "i_tsv_path",
      "Selector1\tSelector",
      "Selector1:Query1\tCheck = True",
      "Selector1:Yi_reference",
      "Pretreat1\tPretreat",
      "Pretreat1:X\t[#]#*i_pretreatments",
      "Pretreat1.Wavelengths\ti_wavelengths",
      "Pretreat1.SNRs\ti_snrs",
      "Pretreat1.WLCs\t",
      "Pretreat1.Means\ti_x_means",
      "Pretreat1.Targets\tTargets",
      "Pretreat1.OSC\t",
      "Pretreat1.Variations\tVariations",
      "Model1\tModel",
      "Model1:Type\ti_model_typei_model",
      "Model1.Wavelengths\ti_wavelengths",
      "Indexes\tIndexes",
      "Model1.Dates\ti_dates",
      "Model1.IDs\ti_ids",
      "Target\ti_target",
      "Observations\tObservations",
      "ObservationsZ\tObservationsZ",
      "Zero\ti_zero",
      "Center\ti_mean_y",
      "Weights\ti_weights",
      "Loads\ti_loads",
      "Scale\ti_scale",
      "Regressions\tRegressions",
      "Press\ti_press",
      "Scores\ti_scores",
      "Scores Scaled\tScores Scaled",
      "Mahalanobis\tMahalanobis",
      "Residuums\tResiduums",
      "Bias\ti_bias",
      "Estimates\tEstimates",
      "Skew\t",
      "SkewBias\t",
      "Residuals\tResiduals",
      "CVEstimates\ti_cv_est",
      "CVResiduals\tCVResiduals",
      "TEstimates\tTEstimates",
      "TResiduals\tTResiduals",
      "Validation\tValidation",
      "Validation.Indexes\tIndexes",
      "Validation.IDs\tIDs",
      "Validation.Targets\tTargets",
      "Validation.Observations\tObservations",
      "Validation.Scores\tScores",
      "Validation.Mahalanobis\tMahalanobis",
      "Validation.Residuums\tResiduums",
      "Validation.Estimates\tEstimates",
      "Validation.Residuals\tResiduals",
      ""
    )
  }
}
#' @title Converts a matrix into a string in style of .prj files
#' @param object matrix to be converted into string
#' @param transp a logical. Should the matrix be transposed?
#' @return character of length 1, where each row is separated by \verb{"\\n"}
#' and all values in each row is separated by \verb{"\\t"}
#' @keywords internal
matrix_prj_string <- function(object, transp = FALSE) {
  paste(c(apply(round(object, digits = 8), MARGIN = 1 + transp, FUN = paste, collapse = "\t"), ""), collapse = "\n")
}

#' @title Converts a matrix into a string in style of .cal files
#' @param object matrix to be converted into string
#' @return character of length 1, where each row is separated by ';' and all
#' values in each row is separated by ','
#' @keywords internal
matrix_cal_string <- function(object) {
  paste(c(apply(object, 1, paste, collapse = ","), ""), collapse = ";")
}

#' @title Adds a chosen number of columns with entries equal to zero to a matrix object
#' @param object matrix
#' @param n_zero_cols an integer for the number of columns to be added
#' @return the matrix with \code{n_zero_cols} zero-columns added to the left and right
#' side of object
#' @keywords internal
add_zero_cols <- function(object, n_zero_cols) {
  cbind(matrix(0, nrow = nrow(object), ncol = n_zero_cols), object, matrix(0, nrow = nrow(object), ncol = n_zero_cols))
}

#' @title Create a string from a single preprocess step
#' @param p an object of class \code{preprocess_recipe}
#' @return a string with the preprocess parameters added
#' @keywords internal
prepro_to_string <- function(p) {
  m <- p$method
  if (is.null(m)) {
    return("")
  } else if (m == "prep_snv") {
    return("SNVT")
  } else if (m == "prep_smooth") {
    return(sprintf("SMOOTH %s", p$half_w))
  } else if (m == "prep_resample") {
    return(sprintf("Spline [#]X1 [#]X2 [#]X3 %s %s %s", p$min_wav, p$max_wav, p$resolution))
  } else if (m == "prep_derivative") {
    return(sprintf("DG %s %s %s", p$m, p$half_w, p$half_s))
  }
  return("")
}

#' @title Create a string for prj files from a recipe
#' @param recipe a list of preprocess steps, of class \code{preprocess_recipe}
#' @return a string, containing the preprocessing steps in style of prj files
#' @keywords internal
#' @noRd
recipe_to_prj_string <- function(recipe, min_wavs, max_wavs, resolution) {
  n_recipe <- preprocess_recipe(
    prep_resample(grid = c(min_wavs, max_wavs, resolution)),
    prep_resample(grid = c(400, 1700, 4)),
    prep_resample(grid = c(400, 900, 4)),
    device = "proximate"
  )$steps
  if (length(recipe) == 0) {
    pp_output <- paste0(
      '\r\n"Pretreat1:Treat', 1:3, '","',
      mapply(prepro_to_string, n_recipe), '",#FALSE#,"Pretreat1"',
      collapse = ""
    )
    return(paste0(pp_output, '\r\n"Pretreat1:Treat4","<new treatment>",#FALSE#,"Pretreat1"', collapse = ""))
  }
  hs <- any(sapply(recipe, FUN = "[[", MARGIN = "method") %in% "prep_resample")
  j <- ifelse(hs, 1, 4)
  if (hs) {
    pp_output <- NULL
  } else {
    pp_output <- paste0(
      '\r\n"Pretreat1:Treat', 1:3, '","', mapply(prepro_to_string, n_recipe), '",#FALSE#,"Pretreat1"'
    )
  }
  for (i in seq_along(recipe)) {
    is_resample <- recipe[[i]]$method == "prep_resample"
    if (is_resample) {
      s_recipe <- preprocess_recipe(
        recipe[[i]],
        prep_resample(grid = c(400, 1700, 4)),
        prep_resample(grid = c(400, 900, 4)),
        device = "proximate"
      )
      pp_output <- append(
        pp_output,
        paste0(
          '\r\n"Pretreat1:Treat', j:(j + 2), '","', mapply(prepro_to_string, s_recipe$steps), '",#', c(TRUE, FALSE, FALSE), '#,"Pretreat1"',
          collapse = ""
        )
      )
    } else {
      pp_output <- append(
        pp_output,
        paste0(
          '\r\n"Pretreat1:Treat', j, '","', prepro_to_string(recipe[[i]]), '",#TRUE#,"Pretreat1"'
        )
      )
    }
    j <- j + ifelse(is_resample, 3, 1)
  }
  paste0(c(pp_output, sprintf('\r\n"Pretreat1:Treat%s","<new treatment>",#FALSE#,"Pretreat1"', j)), collapse = "")
}
