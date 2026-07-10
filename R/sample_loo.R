#' @title A function to create calibration and validation sample sets for
#' leave-one-out cross-validation
#' @description for internal use only! If group is provided, the
#' sampling is done based on the groups.
#' @param N the total number of observations.
#' @param group the labels for each sample in \code{y} indicating the group each
#' observation belongs to.
#' @return a list with two matrices (\code{hold_in} and
#' \code{hold_out}) giving the indices of the observations in each
#' column. The number of columns represents the number of sampling repetitions.
#' @keywords internal

sample_loo <- function(N, group = NULL) {
  if (!is.null(group)) {
    if (length(group) != N) {
      stop(sprintf("The length of 'group' must be equal to 'N = %s'", N))
    }
    indices_vec <- 1:N
    group <- factor(group)
    max_n_group <- range(table(group))
    min_n_group <- max_n_group[1]
    max_n_group <- max_n_group[2]
    group_classes <- as.character(unique(group))
    n_group <- length(group_classes)
    samples <- sample_loo_basic(n_group)

    cal_sets <- matrix(NA, N - min_n_group, n_group)
    val_sets <- matrix(NA, max_n_group, n_group)
    rownames(cal_sets) <- paste0("index_", 1:nrow(cal_sets))
    rownames(val_sets) <- paste0("index_", 1:nrow(val_sets))

    for (i in 1:n_group) {
      ith_groups_cal <- samples$hold_in[, i]
      ith_groups_val <- samples$hold_out[, i]
      ith_cal <- which(group %in% group_classes[ith_groups_cal])
      ith_val <- which(group %in% group_classes[ith_groups_val])
      cal_sets[seq_along(ith_cal), i] <- ith_cal
      val_sets[seq_along(ith_val), i] <- ith_val
    }
    list(
      hold_in = cal_sets,
      hold_out = val_sets
    )
  } else {
    sample_loo_basic(N)
  }
}

#' @title Simple leave-one-out sampling
#' @description For internal use only
#' @return A list with hold_in (calibration indices) and hold_out (validation indices) matrices.
#' @keywords internal
sample_loo_basic <- function(N) {
  val_sets <- 1:N
  cal_sets <- matrix(rep(val_sets, N), N)
  diag(cal_sets) <- NA
  cal_sets <- cal_sets[-which(is.na(cal_sets))]
  cal_sets <- matrix(cal_sets, N - 1)
  val_sets <- t(val_sets)
  rownames(cal_sets) <- paste0("index_", 1:nrow(cal_sets))
  rownames(val_sets) <- paste0("index_", 1)
  list(
    hold_in = cal_sets,
    hold_out = val_sets
  )
}
