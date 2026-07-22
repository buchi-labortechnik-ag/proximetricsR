#' @title Calibrate models for multiple response variables
#' @aliases calibrate_models
#' @aliases predict.spectral_multimodel
#'
#' @description
#'
#' \loadmathjax
#' Calibrate independent models (iteratively) for multiple properties with
#' optimization of both the pre-processing recipe (based on a list of different
#' recipes) and the regression method. This function uses
#' \code{\link{calibrate}} to construct such list of models.
#'
#' @usage
#'
#' calibrate_models(formulas,
#'                  data, group = NULL,
#'                  preprocess_recipes,
#'                  methods,
#'                  control = calibration_control(seed = 1),
#'                  metadata_list = NULL,
#'                  skip_indices_list = NULL,
#'                  return_inputs = TRUE,
#'                  ...,
#'                  na_action = na.pass,
#'                  verbose = TRUE,
#'                  save_all = FALSE)
#' 
#' \method{predict}{spectral_multimodel}(object, newdata, verbose = TRUE, ...)
#'
#' @param formulas a list containing one or more objects of class
#' \code{\link[stats]{formula}} where each of them represents the model to be
#' calibrated.
#' @param data a data.frame containing the data of the variables in
#' the model (as in the \code{\link{calibrate}} function).
#' @param group an optional factor (or character vector that can be coerced to
#' \code{\link[base]{factor}} by \code{as.factor}) that assigns a group/class
#' label to each observation in \code{X} (e.g. groups can be given by spectra
#' collected from the same batch of measurements, from the same observation,
#' from observations with very similar origin, etc). This is taken into account
#' for cross-validation for pls tuning (factor optimization) to avoid pseudo-
#' replication. When one observation is selected for cross-validation, all
#' observations of the same group are removed and assigned to validation.
#' The length of the vector must be equal to the number of observations in
#' \code{X}.
#' @param preprocess_recipes a list with one or more objects of class
#' \code{\link{preprocess_recipe}} that are to be tested for finding the
#' optimal one for each model in the list passed to \code{formulas}.
#' @param methods a list containing one or more objects of class
#' \code{fit_constructor} as returned by \code{\link{fit_plsr}} or
#' \code{\link{fit_xlsr}}, indicating what type of regression method
#' to use along with its parameters.
#' @param control a \code{calibration_control} object as returned by the
#' \code{\link{calibration_control}} function, indicating how some aspects of
#' the calibration process must be conducted (e.g. cross-validation and outlier
#' detection). Default is \code{calibration_control(seed = 1)}. See details.
#' @param metadata_list a list containing the specifications for the metadata
#' of each model in \code{formulas} given in the same order. Each element in the
#' list should be defined as in the \code{metadata} argument of
#' \code{\link{calibrate}} using the
#' \code{\link{add_model_metadata}} function. Defaults to \code{NULL}.
#' @param skip_indices_list a list of vectors of integers for the indices in the
#' input data to be skipped for the computation of each of the models in
#' \code{formulas}. The vectors in this list must be provided in the same order
#' as their corresponding counterparts in \code{formulas}. Defaults to
#' \code{NULL}. In case a list is passed, the list components must be filled
#' with \code{numeric()} for those \code{formulas} where there is no indices to
#' be skipped.
#' @param return_inputs a logical. For \code{calibrate} methods, indicates if
#' the input data should be attached to the returned object. Note that this data
#' is crucial for creating an application file.
#' @param verbose a logical indicating whether or not to print a progress bar
#' for the iterations of the validation along with messages of the execution of
#' the cross-validation. For the predict method, messages about the progress are
#' printed. Default is \code{TRUE}. Note: In case parallel processing is used,
#' these progress bars are not printed.
#' @param ... arguments to be passed to the \code{\link{calibrate}} method. Not
#' currently used for the \code{predict.spectral_multimodel} method.
#' @param na_action a function to specify the action to be taken if \code{NA}s
#' are found in the object passed in \code{data}. Default is
#' \code{\link{na.pass}}.
#' @param save_all a logical indicating if all the models tested (with the
#' different pre-processing recipes) are to be saved. Default is \code{FALSE}.
#' @param object an object of class \code{spectral_multimodel}.
#' @param newdata a data.frame containing the new spectral data of the variables
#' in the model, of similar form as \code{data}. Alternatively, can also be
#' a matrix of spectra.
#'
#' @details
#' The object passed to the \code{control} argument should indicate a seed
#' for the random number generator (RNG). This allows the function to use
#' the same cross-validation validation groups (for leave group-out
#' cross-validation, see \code{\link{calibration_control}}) across the same
#' formula with different recipes. This enables proper model comparisons.
#'
#' @section Parallel cross-validation:
#' The cross-validation loop inside each call to \code{\link{calibrate}} is
#' implemented with \code{\link[foreach]{foreach}}, so it can be parallelised
#' transparently by registering a parallel backend before calling
#' \code{calibrate_models}. Set \code{allow_parallel = TRUE} in
#' \code{\link{calibration_control}} (the default) and register a backend, for
#' example:
#'
#' \preformatted{
#' cl <- parallel::makeCluster(parallel::detectCores() - 1L)
#' doParallel::registerDoParallel(cl)
#'
#' result <- calibrate_models(...)
#'
#' parallel::stopCluster(cl)
#' }
#'
#' When no parallel backend is registered, \code{foreach} falls back silently to
#' sequential execution regardless of the \code{allow_parallel} setting.
#' Note that progress bars are suppressed during parallel execution.
#'
#' @author
#' Leonardo Ramirez-Lopez and Claudio Orellano
#'
#' @return
#'
#' A list of class \code{"spectral_multimodel"} containing the following
#' objects:
#'
#' \itemize{
#'     \item \strong{\code{results_grid}:} a data.frame with the validation results of
#'     the best models found for each pre-processing recipe with the best
#'     regression method applied on the spectral data of the model built for
#'     each formula.
#'     \item \strong{\code{all_models}:} if \code{save_all}, a list with the
#'     \code{spectral_model} objects corresponding to all the models tested.
#'     \item \strong{\code{final_models}:} a list containing only the
#'     \code{spectral_model} objects corresponding to the best models found
#'     for each formula. This list can be used/passed later to the
#'     \code{\link{proximate_write_nax}} function to produce an application file (in that
#'     case it might be convenient to add some metadata to the resulting models
#'     in the list using the \code{\link{add_model_metadata}} function).
#'  }
#'
#' For \code{predict()}, a list with the following elements: \itemize{
#'     \item \strong{\code{predictions}:}  A matrix with the predictions of the
#'     response variable using the new spectral data (\code{newdata}), based on
#'     the provided models (\code{object}). Contains only the predictions of the
#'     optimal number of components (\code{ncomp}).
#'     \item \strong{\code{model_information}:} A list, containing information on the
#'     models inputs in \code{object}. Each component in the list contains the
#'     following information: \itemize{
#'          \item \strong{\code{target_var}:} A character, indicating the name of the
#'          target variable.
#'          \item \strong{\code{preprocess_recipe}:} A character, indicating the
#'          spectral preprocessing recipe and its order.
#'          \item \strong{\code{model_grid}:} A matrix, containing the grid of the
#'          model object, such as the coefficient of determination and the RMSE
#'          of the validation for the requested number of components.
#'          \item \strong{\code{unit}:} A character, indicating the units of the
#'          model.
#'          \item{\code{opt_comp}:} An integer, signifying the optimal number
#'          of components as computed by the validation process of the model.
#'     }
#'     }
#' @seealso
#' \code{\link{calibrate}},
#'
#' \code{\link{preprocess_recipe}},
#'
#' \code{\link{fit_plsr}},
#'
#' \code{\link{fit_xlsr}},
#'
#' \code{\link{calibration_control}}
#'
#' @examples
#' \donttest{
#' data("NIRcannabis")
#' # the list of formulas for the models to be built
#' app_formulas <- list(THC ~ spc, THCA ~ spc, CBD ~ spc, CBDA ~ spc)
#'
#' # the list of pre-processing recipes to be tested
#' precipes <- list(
#'   recipe_1 = preprocess_recipe(
#'     prep_resample(grid = c(1001, 1700, 2)),
#'     prep_snv(),
#'     prep_derivative(m = 1, w = 9, p = 7, algorithm = "nwp"),
#'     device = "proximate"
#'   ),
#'   recipe_2 = preprocess_recipe(
#'     prep_resample(grid = c(1001, 1700, 2)),
#'     prep_snv(),
#'     prep_derivative(m = 2, w = 11, p = 9, algorithm = "nwp"),
#'     device = "proximate"
#'   )
#' )
#'
#' optimized_app <- calibrate_models(
#'   formulas = app_formulas,
#'   data = NIRcannabis,
#'   preprocess_recipes = precipes,
#'   methods = list(fit_plsr(15, type = "nwp")),
#'   return_inputs = TRUE,
#'   save_all = FALSE
#' )
#'
#' optimized_app
#' }
#' @export
calibrate_models <- function(formulas,
                             data, group = NULL,
                             preprocess_recipes,
                             methods,
                             control = calibration_control(seed = 1),
                             metadata_list = NULL,
                             skip_indices_list = NULL,
                             return_inputs = TRUE,
                             ...,
                             na_action = na.pass,
                             verbose = TRUE,
                             save_all = FALSE) {
  final_model_name <- "final_model|refitted_model"

  if (any(duplicated(formulas))) {
    warning("Some formulas are duplicated... removing the duplicates")
  }

  if (missing(preprocess_recipes)) {
    stop("'preprocess_recipes' is missing")
  }

  if (any(duplicated(preprocess_recipes))) {
    warning("Some preprocessing recipes are duplicated... removing the duplicates")
  }

  formulas <- unique(formulas)
  preprocess_recipes <- unique(preprocess_recipes)


  if (!is.null(metadata_list)) {
    if (length(metadata_list) != length(formulas)) {
      stop("The number of elements in 'formulas' must match the number of elements in 'metadata_list'")
    }
  }

  if (!is.null(skip_indices_list)) {
    if (length(skip_indices_list) != length(formulas)) {
      stop("The number of elements in 'formulas' must match the number of elements in 'skip_indices_list'")
    }
  }

  all_models <- NULL
  print_fmls <- sapply(formulas, FUN = function(x) {
    paste(all.vars(x), collapse = " ~ ")
  })

  if (control$tuning_parameter == "none") {
    stop("Value 'none' as tuning parameter is not valid for this function")
  }

  fml_vars <- sapply(formulas, FUN = all.vars) |>
    t() |>
    as.vector() |>
    unique()
  if (!all(fml_vars %in% colnames(data))) {
    missing_vars <- fml_vars[!fml_vars %in% colnames(data)]
    if (length(missing_vars) > 1) {
      mss <- paste0(missing_vars[1:(length(missing_vars) - 1)], collapse = ", ")
      mss <- paste0(c(mss, " and ", missing_vars[length(missing_vars)]), collapse = "")
      stop("The following variables are missing in data: ", mss)
    } else {
      stop("The following variable is missing in data: ", missing_vars)
    }
  }


  results_grid <- expand.grid(
    recipe = seq_along(preprocess_recipes),
    formula = print_fmls
  )[, 2:1]
  niter <- nrow(results_grid)

  list_indx <- rep(seq_along(formulas), each = length(preprocess_recipes))
  method_grid <- NULL
  for (i in 1:niter) {
    ith_formula <- formulas[[list_indx[i]]]
    ith_recipe <- preprocess_recipes[[results_grid$recipe[i]]]
    if (verbose) {
      if (!identical(results_grid$formula[i], results_grid$formula[i - 1])) {
        cat(paste0("\033[31m--- Finding model for ", results_grid$formula[i], " ----\033[39m\n"))
      }
      cat(paste0("\033[31m +\033[39m testing preprocessing recipe index ", results_grid$recipe[i], "\n"))
    }
    ij_th_model <- NULL
    ij_result <- rep(NA, length(methods))
    for (j in seq_along(methods)) {
      ij_th_model[[j]] <- calibrate(
        ith_formula,
        data = data,
        group = group,
        preprocess = ith_recipe,
        method = methods[[j]],
        control = control,
        metadata = metadata_list[[list_indx[[i]]]],
        skip_indices = skip_indices_list[[list_indx[[i]]]],
        return_inputs = return_inputs,
        ...,
        verbose = FALSE,
        na_action = na_action
      )
      ij_comp <- ij_th_model[[j]]$final_ncomp
      ij_result[j] <- ij_th_model[[j]]$final_model$model_cv$grid[ij_comp, control$tuning_parameter]
    }
    if (control$tuning_parameter == "rmse") {
      ij_best <- which.min(ij_result)[[1]]
    }

    if (control$tuning_parameter == "rsq") {
      ij_best <- which.max(ij_result)[[1]]
    }

    ith_model <- ij_th_model[[ij_best]]

    method_grid[[i]] <- ith_model$method

    fit_m <- sub("r$", "", ith_model$method$fit_method)
    method_used <- paste(toupper(fit_m), paste0("(", ith_model$method$type, ")"))

    final_model_idx <- grep(final_model_name, names(ith_model))
    if (length(final_model_idx) == 0) {
      final_model_idx <- grep("fitted_model", names(ith_model))
    }

    ith_best <- ith_model[[final_model_idx]]$model_cv$grid[ith_model$final_ncomp, ]
    ith_best <- c(
      "min property" = min(ith_model$final_model$model$y_quantiles),
      "max property" = max(ith_model$final_model$model$y_quantiles),
      ith_best
    )

    # FIXME: REVIEW THE LIST OF OUTLIERS!
    n_out <- ith_model$detected_outliers$removed |> length()
    if (i == 1) {
      results_grid <- cbind(
        results_grid,
        matrix(
          NA,
          nrow(results_grid),
          length(ith_best),
          dimnames = list(NULL, names(ith_best))
        ),
        outliers = NA,
        method = NA
      )
      tunning_p <- ith_model$control$tuning_parameter
    }

    results_grid[i, names(ith_best)] <- ith_best
    results_grid[i, "outliers"] <- n_out
    results_grid[i, "method"] <- method_used

    if (save_all) {
      all_models[[i]] <- ith_model
    }

    rm(ith_model)
  }

  if (tunning_p %in% "rsq") {
    opt_f <- which.max
  }

  if (tunning_p %in% "rmse") {
    opt_f <- which.min
  }

  results_grid$selection <- FALSE
  for (i in levels(results_grid$formula)) {
    ith_idx <- opt_f(results_grid[results_grid$formula == i, tunning_p])[1]
    results_grid$selection[results_grid$formula == i][ith_idx] <- TRUE
  }

  final_models_idx <- which(results_grid$selection)

  if (save_all) {
    final_models <- all_models[final_models_idx]
  } else {
    this_iter <- 0
    final_models <- NULL
    for (i in final_models_idx) {
      this_iter <- this_iter + 1
      ith_formula <- formulas[[list_indx[i]]]
      if (verbose) {
        cat(paste0("\033[31m--- Fitting final model for ", results_grid$formula[i], " ----\033[39m\n"))
      }

      this_final_recipe <- preprocess_recipes[[results_grid$recipe[i]]]

      final_models[[this_iter]] <- calibrate(
        ith_formula,
        data = data,
        group = group,
        preprocess = this_final_recipe,
        method = method_grid[[i]],
        control = control,
        metadata = metadata_list[[list_indx[[i]]]],
        skip_indices = skip_indices_list[[list_indx[[i]]]],
        return_inputs = return_inputs,
        ...,
        verbose = verbose,
        na_action = na_action
      )
    }
  }
  results_grid$ncomp <- as.integer(results_grid$ncomp)
  names(final_models) <- results_grid$formula[final_models_idx] |> as.character()
  results <- list(
    results_grid = results_grid,
    preprocess_recipes = preprocess_recipes,
    all_models = all_models,
    final_models = final_models
  )
  class(results) <- c("spectral_multimodel", "list")
  results
}

#' @title print method for \code{spectral_multimodel}
#' @return Returns \code{x} invisibly.
#' @keywords internal
#' @export
print.spectral_multimodel <- function(x, ...) {
  cat(.bold_italic("Grid search results:"), "\n")

  obj <- x$results_grid
  obj$selection[obj$selection] <- "*"
  obj$selection[!x$results_grid$selection] <- ""

  colnames(obj)[length(obj)] <- ""
  obj <- obj[, c(length(obj), 1:(length(obj) - 1))]
  dm <- format(obj, digits = 3, justify = "left")
  print(dm, quote = FALSE)
  cat(" \n*best model \n")

  cat("---\n")
  cat("Suggested models: \n")
  for (i in which(x$results_grid$selection)) {
    ith_recipe <- x$results_grid$recipe[i]
    fs <- x$preprocess_recipes[[ith_recipe]]
    cat(
      .bold_italic(paste0("Model: ")),
      .bold_red(as.character(x$results_grid$formula[i]), prefix = ""),
      "\n"
    )
    print(fs)
    cat(
      .bold_italic(paste0("Method: ")),
      .bold_red(x$results_grid$method[i], prefix = ""),
      "\n\n"
    )
  }
  invisible(x)
}

#' @aliases calibrate_models
#' @export
predict.spectral_multimodel <- function(object, newdata, verbose = TRUE, ...) {
  preds <- lapply(object$final_models,
    FUN = function(x, new, verbose) {
      if (verbose) cat(paste0(x$target_variable, ": \n"))
      predict(x, new, verbose = verbose)
    },
    new = newdata,
    verbose = verbose
  )
  minfo <- lapply(preds, FUN = function(x) x$model_information)
  mpreds <- sapply(preds, FUN = function(x) x$predictions)
  mnames <- sapply(
    object$final_models,
    FUN = function(x) x$target_variable,
    USE.NAMES = FALSE
  )
  names(minfo) <- colnames(mpreds) <- mnames
  if (is.null(rownames(newdata))) {
    rownames(mpreds) <- 1:nrow(newdata)
  } else {
    rownames(mpreds) <- rownames(newdata)
  }

  list(
    predictions = mpreds,
    model_information = minfo
  )
}
