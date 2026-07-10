#
# as.spectra <- function(x,
#                        freq = NULL,
#                        freq_units = NULL,
#                        varnames_to_freq = FALSE) {
#   if (is.data.frame(x)) {
#     x <- as.matrix(x)
#   }
#
#   if (!(is.matrix(x) | is.vector(x))) {
#     stop("x must be of class matrix, vector or data.frame")
#   }
#
#   if (is.vector(x)) {
#     name_f <- base::names
#     assign_names <- function(x, names) {
#       if (length(names) > 1) {
#         attr(x, "names") <- names
#       }
#       x
#     }
#     n_vars <- length(x)
#   } else {
#     name_f <- base::colnames
#     assign_names <- function(x, names) {
#       attr(x, "dimnames")[[2]] <- names
#       x
#     }
#     n_vars <- ncol(x)
#   }
#
#   if (varnames_to_freq) {
#     freq <- name_f(x)
#     freq <- gsub("^X.", "", freq)
#     names_val <- sapply(freq,
#       function(y) {
#         nchar(y) == length(attr(gregexpr("[[:digit:]]", y)[[1]], "match.length"))
#       },
#       simplify = TRUE, USE.NAMES = FALSE
#     )
#
#     if (any(!names_val)) {
#       stop("frequency cannot be inferred from the variable names")
#     }
#     freq <- as.numeric(freq)
#   }
#
#   if (!is.null(freq)) {
#     attr(x, "frequency") <- freq
#     x <- assign_names(x, freq)
#   }
#
#   if (!is.null(freq_units)) {
#     attr(x, "frequency_units") <- freq_units
#   }
#
#   attr(x, "n_vars") <- n_vars
#
#   class(x) <- c("spectra", class(x))
#   x
# }
#
# is.spectra <- function(x) {
#   "spectra" %in% class(x)
# }
#
#
# "[.spectra" <- function(x, i, j, drop = TRUE, ...) {
#   if (!is.spectra(x)) stop("method is only for spectra objects")
#   org_classes <- class(x)
#   class(x) <- org_classes[!org_classes %in% "spectra"]
#
#   n <- NROW(x)
#   n2 <- ifelse(nargs() == 1, length(as.vector(x)), n)
#   if (missing(i)) {
#     i <- 1:n
#   }
#
#   if (inherits(i, "matrix")) {
#     i <- as.vector(i)
#   }
#   ## also support that i can be index:
#   ## if i is not numeric/integer/logical, it is interpreted to be the index
#   if (inherits(i, "logical")) {
#     i <- which(rep(i, length.out = n2))
#   }
#
#   freq <- attr(x, "frequency")[j]
#   freq_units <- attr(x, "frequency_units")
#   if (length(dim(x)) == 2) {
#     drop. <- ifelse(length(i) == 1, FALSE, drop)
#     x <- if (missing(j)) {
#       x[i, , drop = drop., ...]
#     } else {
#       x[i, j, drop = drop., ...]
#     }
#
#     if (drop && length(x) == 1) {
#       x <- c(x)
#     }
#     x <- as.spectra(x,
#       freq = freq,
#       freq_units = freq_units
#     )
#   } else {
#     x <- as.spectra(x[i],
#       freq = freq,
#       freq_units = freq_units
#     )
#   }
#   return(x)
# }
#
# rev.spectra <- function(x) {
#   var_freq <- attr(x, "frequency")
#   if (is.null(var_freq)) {
#     var_freq <- 1:attr(x, "n_vars")
#   }
#   ix <- rev(order(var_freq))
#   if (is.vector(x)) {
#     x <- x[ix]
#   } else {
#     x <- x[, ix]
#   }
#   x
# }
#
#
# # summary.spectra <- function()
