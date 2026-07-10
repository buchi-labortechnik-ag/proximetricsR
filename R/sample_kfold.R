#' @title A function to create calibration and validation sample sets for
#' k-fold cross-validation
#' @description for internal use only! This function implements k-fold sampling.
#' based on either a random or sequential selection of observations. If group is
#' provided, the sampling is done based on the groups. This
#' function is used to create groups for k-fold cross-validations.
#' @param N the total number of observations.
#' @param number the number of folds.
#' @param group the labels for each sample in indicating the group each
#' observation belongs to.
#' @param sampling a character vector indicating hw to sample. Options are:
#' \code{"random"} (default) or \code{"sequential"} (the one used in NIRWise PLUS).
#' @param seed an integer for random number generator (default \code{NULL}).
#' @return a list with two matrices (\code{hold_in} and
#' \code{hold_out}) giving the indices of the observations in each
#' column. The number of columns represents the number of sampling repetitions.
#' @keywords internal
sample_kfold <- function(N, number, group = NULL, sampling = c("random", "sequential"), seed = NULL) {
  sampling <- match.arg(sampling)
  if (!is.null(group)) {
    if (length(group) != N) {
      stop(sprintf("The length of 'group' must be equal to 'N = %s'", N))
    }
    indices_vec <- 1:N
    group <- factor(group)
    group_classes <- as.character(unique(group))
    n_group <- length(group_classes)
    if (number > floor(n_group / 2)) {
      stop("Argument 'number' cannot be larger than the half of the number of groups")
    }
    group_folds <- simple_kfold_sampling(n_group, number, sampling = sampling, seed)

    list_calibration_indices <- list_validation_indices <- NULL
    original_group <- group
    levels(group) <- 1:nlevels(group)
    for (i in 1:number) {
      list_calibration_indices[[i]] <- which(group %in% group_folds$hold_in[, i])
      list_validation_indices[[i]] <- which(group %in% group_folds$hold_out[, i])
    }
    n_cal <- sapply(list_calibration_indices, FUN = length)
    n_val <- sapply(list_validation_indices, FUN = length)

    calibration_indices <- matrix(NA, max(n_cal), number)
    validation_indices <- matrix(NA, max(n_val), number)

    for (i in 1:number) {
      calibration_indices[1:n_cal[i], i] <- list_calibration_indices[[i]]
      validation_indices[1:n_val[i], i] <- list_validation_indices[[i]]
    }
    rownames(validation_indices) <- paste0("index_", 1:nrow(validation_indices))
    rownames(calibration_indices) <- paste0("index_", 1:nrow(calibration_indices))
    colnames(calibration_indices) <- colnames(validation_indices) <- paste0(
      "Fold_",
      seq(1:number)
    )

    folds <- list(
      hold_in = calibration_indices,
      hold_out = validation_indices
    )
  } else {
    folds <- simple_kfold_sampling(N, number, sampling = sampling, seed)
  }
  folds
}

#' @title Simple k-fold sampling
#' @description For internal use only
#' @return A list with two matrices (\code{hold_in} and \code{hold_out}) giving the indices of the observations in each column for each fold.
#' @keywords internal
simple_kfold_sampling <- function(N, number, sampling = c("random", "sequential"), seed = NULL) {
  sampling <- match.arg(sampling)
  if (number > floor(N / 2)) {
    stop(sprintf("Argument 'number' cannot be larger than N/2 = %s", floor(N / 2)))
  }

  indices_vec <- 1:N


  if (sampling == "random") {
    n_per_fold <- floor(N / number)
    fold_sizes <- rep(n_per_fold, number)
    to_add <- N - sum(fold_sizes)

    kfold_code <- expression({
      if (to_add > 0) {
        add_to_folds <- sample(length(fold_sizes), to_add)
        for (i in add_to_folds) {
          fold_sizes[i] <- fold_sizes[i] + 1
        }
      }

      validation_indices <- matrix(NA, max(fold_sizes), number)
      calibration_indices <- matrix(NA, N - min(fold_sizes), number)

      indices_vec_tmp <- indices_vec
      for (i in 1:number) {
        selected_s <- sample(
          indices_vec_tmp,
          fold_sizes[i]
        )
        validation_indices[seq_along(selected_s), i] <- sort(selected_s)
        ith_cal <- indices_vec[!indices_vec %in% selected_s]
        calibration_indices[seq_along(ith_cal), i] <- ith_cal
        indices_vec_tmp <- indices_vec_tmp[!indices_vec_tmp %in% validation_indices[seq_along(selected_s), i]]
      }
    })

    if (is.null(seed)) {
      eval(kfold_code)
    } else {
      withr::with_seed(seed, eval(kfold_code))
    }
  }
  if (sampling == "sequential") {
    n_per_fold <- ceiling(N / number)
    add_nas <- (number * n_per_fold) - N

    if (add_nas > 0) {
      (1:add_nas) * (N / add_nas)
      fold_vec <- c(1:N, rep(NA, add_nas))
    } else {
      fold_vec <- 1:N
    }

    validation_indices <- lapply(1:number,
      FUN = function(x, n, i) {
        x[seq(i, length(x), by = n)]
      },
      n = number, x = fold_vec
    )
    validation_indices <- do.call("cbind", validation_indices)
    max_length_cal <- max(N - colSums(!is.na(validation_indices)))
    cal_vec <- rep(NA, max_length_cal)
    calibration_indices <- sapply(1:number,
      FUN = function(val, i, indices, store_vec) {
        indcs <- indices[!indices %in% val[, i]]
        store_vec[seq_along(indcs)] <- indcs
        store_vec
      },
      val = validation_indices,
      indices = 1:N,
      store_vec = cal_vec
    )
  }
  rownames(validation_indices) <- paste0("index_", 1:nrow(validation_indices))
  rownames(calibration_indices) <- paste0("index_", 1:nrow(calibration_indices))

  colnames(calibration_indices) <- colnames(validation_indices) <- paste0(
    "Fold_",
    seq(1:number)
  )

  rows_rm <- !rowSums(is.na(calibration_indices)) == ncol(calibration_indices)
  calibration_indices <- calibration_indices[rows_rm, ]


  list(
    hold_in = calibration_indices,
    hold_out = validation_indices
  )
}
