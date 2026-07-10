#' @title Validate predictions of class \code{'spectral_prediction'}
#' @aliases validate
#'
#' @description
#'
#' \loadmathjax
#'
#' Calculate several prediction validation statistics for a prediction of class
#' \code{'spectral_prediction'}.
#' @usage
#' validate_prediction(prediction, reference)
#' @param prediction an object of class \code{'spectral_prediction'}, as returned by
#' the \code{\link[=predict.spectral_model]{predict}} function.
#' @param reference a vector or a matrix with one column, containing the
#' response variable.
#' @return An object of class \code{"spectral_validation"}, which is a list containing
#' the following validation statistics of the prediction:
#' \itemize{
#'     \item \strong{\code{model_information}:} A list containing information of the
#'     model on which the predictions are based. Mirrors the very same list
#'     contained in the \code{prediction}. See \code{\link[=predict.spectral_model]{predict}}
#'     for more details.
#'     \item \strong{\code{validation}:} A list with the validation statistics. For
#'     each prediction contained in \code{prediction} (which are based on the
#'     number of components), one entry in the list is added. Each of these
#'     elements  exactly one matrix and one vector: \code{val_results} contains
#'     the predicted values and the corresponding errors in a matrix, while
#'     \code{val_stats} is a vector consisting of the coefficient of determination
#'     (\mjeqn{R^2}{R^2}), root mean squared error (\code{RMSE}) and the largest
#'     residual obtained. These statistics are computed based on the \code{prediction}
#'     and \code{reference}, while ignoring any \code{NA}'s.
#' }
#' @author Claudio Orellano
#'
#' @examples
#' data("NIRcannabis")
#' skips <- c(10, 25, 37)
#' simple_model <- calibrate(CBDA ~ spc,
#'   data = NIRcannabis, preprocess = preprocess_recipe(),
#'   method = fit_plsr(5), control = calibration_control("kfold"),
#'   skips = skips, verbose = FALSE
#' )
#'
#' # Predict the skipped indices
#' pred <- predict(simple_model,
#'   newdata = NIRcannabis[skips, ],
#'   ncomp = simple_model$final_ncomp,
#'   verbose = FALSE
#' )
#'
#' # Validate skipped indices
#' validate_prediction(pred, NIRcannabis$CBDA[skips])
#' @export

validate_prediction <- function(prediction, reference) {
  if (!"spectral_prediction" %in% class(prediction)) {
    stop("Parameter 'prediction' must be of class 'spectral_prediction'.")
  }
  if (all(is.na(reference))) {
    stop("'reference' only contains 'NA' values.")
  }
  if (!is.numeric(reference)) {
    stop("Non-numerical values found in 'reference'")
  }

  reference <- as.matrix(reference)
  if (ncol(reference) > 1) {
    stop("Only one column of reference values is allowed.")
  }
  if (nrow(prediction$predictions) != nrow(reference)) {
    stop("Predictions and reference values contain differing number of rows.")
  }
  if (is.null(colnames(reference))) {
    target_var <- prediction$model_information$target_var
  } else {
    target_var <- colnames(reference)
  }

  row_names <- rownames(prediction$predictions)

  validation <- list()
  # Drop NA's for statistics
  drop_na_preds <- prediction$predictions[!is.na(reference), , drop = FALSE]
  drop_na_refs <- reference[!is.na(reference), , drop = FALSE]

  for (i in 1:ncol(prediction$predictions)) {
    pred_resid <- reference - prediction$predictions[, i, drop = FALSE]
    rsq <- cor(drop_na_refs, drop_na_preds[, i, drop = FALSE])^2
    rmse <- matrix(
      sqrt(
        colSums(pred_resid^2, na.rm = TRUE) / apply(pred_resid, MARGIN = 2, FUN = function(x) max(sum(!is.na(x)) - 1, 1))
      ),
      ncol = 1
    )
    max_res <- matrix(apply(pred_resid, MARGIN = 2, FUN = function(x) x[which.max(abs(x))]), ncol = 1)

    val_results <- cbind(prediction$predictions[, i, drop = FALSE], pred_resid)
    colnames(val_results) <- c("y_hat", "error")
    validation[[colnames(drop_na_preds)[i]]] <- list(
      val_results = val_results,
      val_stats = c(rsq = rsq, rmse = rmse, max_res = max_res)
    )
  }
  colnames(reference) <- "y"
  if (is.null(rownames(reference))) {
    if (is.null(row_names)) {
      rownames(reference) <- 1:nrow(reference)
    } else {
      rownames(reference) <- row_names
    }
  }
  result <- list(model_information = prediction$model_information, validation = validation, reference = reference)
  class(result) <- c("spectral_validation", "list")
  result
}


#' @title Print method for an object of class \code{spectral_validation}
#' @description Prints the content of an object of class \code{spectral_validation}
#' @aliases print.spectral_validation
#' @usage \method{print}{spectral_validation}(x, ...)
#' @param x an object of class \code{spectral_validation} (as returned by the
#' \code{\link{validate_prediction}} function).
#' @param ... arguments to be passed to methods (not functional).
#' @return No return value, called for side effects.
#' @author Claudio Orellano
#' @keywords internal
#' @export
print.spectral_validation <- function(x, ...) {
  sys_width <- getOption("width")
  bar_width <- 55

  if (bar_width > sys_width) {
    bar_width <- sys_width
  }
  div <- paste(rep("_", sys_width), collapse = "")
  small_div <- paste(rep("-", sys_width), collapse = "")

  target_var <- x$model_information$target_var
  n_preds <- nrow(x$validation[[1]]$val_results)

  cat("Validating response:", target_var, "\n")
  cat("Number of validated predictions:", n_preds, "\n")
  if (!is.null(x$model_information$unit)) {
    if (x$model_information$unit != "") {
      cat("Units of the predicted response: ", x$model_information$unit, "\n")
    }
  }
  cat("Number of validations:", length(x$validation), "\n")
  cat("Number of components (nc):", paste(gsub("ncomp_", "", names(x$validation)), sep = ", ", collapse = ", "), "\n")
  cat(div, "\n\n")


  if (length(x$validation) > 0) {
    return_mat <- format(x$reference, digits = 3)
    vert_line <- as.matrix(rep("|", nrow(return_mat)))
    for (i in seq_along(x$validation)) {
      wh <- as.numeric(gsub("ncomp_", "", names(x$validation)[i]))
      if (wh < 10) {
        colnames(vert_line) <- paste0("| nc_", wh)
      } else {
        colnames(vert_line) <- paste0("| nc", wh)
      }
      temp_mat <- cbind(
        return_mat,
        vert_line,
        format(
          round(x$validation[[i]]$val_results, digits = 3),
          nsmall = 3
        )
      )

      if (sum(apply(rbind(nchar(temp_mat), nchar(colnames(temp_mat))), 2, max)) < sys_width - 2 * ncol(temp_mat)) {
        return_mat <- temp_mat
        if (i == tail(seq_along(x$validation), 1)) {
          print(return_mat, quote = FALSE, max = 20 * ncol(return_mat))
        }
      } else {
        print(return_mat[1:min(20, nrow(return_mat)), , drop = FALSE], quote = FALSE)
        cat(small_div, "\n")
        return_mat <- cbind(
          format(x$reference, digits = 3),
          vert_line,
          format(
            round(x$validation[[i]]$val_results, digits = 3),
            nsmall = 3
          )
        )
        if (i == tail(seq_along(x$validation), 1)) {
          print(return_mat, quote = FALSE, max = 20 * ncol(return_mat))
        }
      }
    }

    cat(div, "\n")
    if (anyNA(x$reference)) {
      cat("Comparison of model and validation statistics (excluding NA's):\n\n")
    } else {
      cat("Comparison of model and validation statistics:\n\n")
    }

    vert_line <- as.matrix(rep("|", 3))
    first <- TRUE
    for (i in seq_along(x$validation)) {
      wh <- gsub("ncomp_", "", names(x$validation)[i])
      if (as.numeric(wh) < 10) {
        colnames(vert_line) <- paste0("| nc_", wh)
      } else {
        colnames(vert_line) <- paste0("| nc", wh)
      }
      if (is.null(x$model_information$model_grid)) {
        model_stats <- as.matrix(x$validation[[i]]$val_stats)
        colnames(model_stats) <- c("val")
      } else {
        model_stats <- cbind(
          as.matrix(x$validation[[i]]$val_stats),
          t(x$model_information$model_grid[wh, c("rsq", "rmse", "largest_residual"), drop = FALSE])
        )
        colnames(model_stats) <- c("val", "model")
      }
      model_stats <- apply(model_stats, FUN = sprintf, fmt = "%#.3f", 2)
      rownames(model_stats) <- c("R^2", "RMSE", "max_error")
      if (first) {
        return_mat <- cbind(vert_line, model_stats)
        first <- FALSE
      } else {
        temp_mat <- cbind(return_mat, vert_line, model_stats)
        if (sum(apply(rbind(nchar(temp_mat), nchar(colnames(temp_mat))), 2, max)) < sys_width - 2 * ncol(temp_mat)) {
          return_mat <- temp_mat
        } else {
          print(return_mat, quote = FALSE)
          cat(small_div, "\n")
          return_mat <- cbind(vert_line, model_stats)
        }
      }
      if (i == tail(seq_along(x$validation), 1)) {
        print(return_mat, quote = FALSE)
      }
    }
    cat(div, "\n")
  }
  invisible(x)
}
