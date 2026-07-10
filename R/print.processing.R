.use_color <- function() {
  isatty(stdout()) ||
    nzchar(Sys.getenv("RSTUDIO")) ||
    nzchar(Sys.getenv("POSITRON")) ||
    identical(Sys.getenv("TERM_PROGRAM"), "vscode")
}

.bold_red <- function(x, prefix = "- ") {
  if (.use_color()) paste0(prefix, "\033[1;31m", x, "\033[0m") else paste0(prefix, x)
}

.bold_italic <- function(x) {
  if (.use_color()) paste0("\033[1;3m", x, "\033[0m") else x
}

.print_step_params <- function(x) {
  exclude <- c("method", "compatible_devices", "half_w", "half_s")
  params <- x[!names(x) %in% exclude]
  parts <- character(0)
  for (nm in names(params)) {
    val <- params[[nm]]
    if (is.null(val)) next
    if (is.character(val)) {
      parts <- c(parts, paste0(nm, ": '", val, "'"))
    } else if (length(val) > 1) {
      parts <- c(parts, paste0(nm, ": ", paste(val, collapse = ", ")))
    } else {
      parts <- c(parts, paste0(nm, ": ", val))
    }
  }
  if (length(parts) > 0) {
    cat("    ", paste(parts, collapse = "; "), "\n", sep = "")
  }
}

#' @noRd
#' @export
print.preprocessing <- function(x, ...) {
  cat(.bold_red(x$method), "\n")
  .print_step_params(x)
  invisible(x)
}
