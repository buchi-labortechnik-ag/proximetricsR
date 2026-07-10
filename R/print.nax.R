#' @title Print method for an object of class \code{nax}
#' @description Prints the contents of an object of class \code{nax}
#' @usage \method{print}{nax}(x, ...)
#' @param x an object of class \code{nax}
#' @param ... not yet functional.
#' @return No return value, called for side effects.
#' @author Leonardo Ramirez-Lopez
#' @keywords internal
#' @export
print.nax <- function(x, ...) {
  cat("\033[31mOverall description:\n\033[39m")
  cat(paste0(" Size: ", x$nax_summary$size, "\n"))
  cat(" Files:\n")
  for (i in seq_along(x$nax_summary$content)) {
    cat(paste0(" ", x$nax_summary$content[i], "\n"))
  }

  cat("\n")
  geom <- paste0(x$nad_info$summary$geometry, ", ", x$nad_info$summary$mode)
  cat(paste0("\033[31mMeasurement geometry: \033[39m", geom, "\n"))

  cat("\n")
  cat("\033[31mProperties: \n\033[39m")
  cat(
    paste0(
      " ",
      x$nad_info$summary$properties$names,
      " [",
      x$nad_info$summary$properties$units,
      "]",
      collapse = "\n"
    )
  )


  cat("\n\n")
  cat("\033[31mModel's summary: \033[39m")
  if (is.data.frame(x$cal_info$summary)) {
    cat("\n")
    print(format(x$cal_info$summary, digits = 3, justify = "left"))
  } else {
    cat(x$cal_info$summary, "\n")
  }

  if (!is.null(x$rtf_info)) {
    app_name <- paste0(x$nad_info$summary$app_name, ".")
    val_summary <- matrix(
      NA,
      length(x$rtf_info$summary),
      ncol(x$rtf_info$summary[[1]]$description),
      dimnames = list(NULL, colnames((x$rtf_info$summary[[1]]$description)))
    ) |> as.data.frame()

    val_summary <- cbind(
      Property = rep(NA, nrow(val_summary)),
      Method = rep(NA, nrow(val_summary)),
      val_summary
    )
    colnames(val_summary) <- gsub("XLS|PLS", "Factors", colnames(val_summary))

    for (i in seq_along(x$rtf_info$summary)) {
      ith_prop <- gsub(app_name, "", x$rtf_info$summary[[i]]$name, fixed = TRUE)
      val_summary$Property[i] <- ith_prop
      val_summary$Method[i] <- names(x$rtf_info$summary[[i]]$description)[1]

      if (is.data.frame(x$cal_info$summary)) {
        idx <- which(grepl(ith_prop, x$cal_info$summary$Property, ignore.case = TRUE))

        if (!is.na(x$rtf_info$summary[[i]]$ncomp)) {
          val_summary[i, -(1:2)] <- x$rtf_info$summary[[i]]$description[x$rtf_info$summary[[i]]$ncomp, ]

          if (!identical(x$rtf_info$summary[[i]]$ncomp, x$cal_info$summary$Factors[idx])) {
            cat(paste0("Calibration model and report for '", ith_prop, "' do not match in the number of components!\n"))
          }
        } else {
          val_summary[i, -(1:2)] <- x$rtf_info$summary[[i]]$description[x$cal_info$summary$Factors[idx], ]
        }
      }

      if (!is.data.frame(x$cal_info$summary) & is.na(x$rtf_info$summary[[i]]$ncomp)) {
        if ("SECV" %in% colnames(x$rtf_info$summary[[i]]$description)) {
          sel <- which.min(x$rtf_info$summary[[i]]$description$SECV)
        } else {
          sel <- which.min(x$rtf_info$summary[[i]]$description$SEC)
        }
        cat(paste0("Inferred number of components!\n"))
        val_summary[i, -1] <- x$rtf_info$summary[[i]]$description[sel, ]
      }
    }
    cat("\n")
    cat("\033[31mValidation's summary: \n\033[39m")
    print(format(val_summary, digits = 3, justify = "left"))
  } else {
    cat("\n")
    cat("\033[31mValidation's summary:\033[39m no rtf reports\n")
  }

  cat("\n")
  data_mss <- "\033[31mCalibration data: \033[39m "
  if (is.data.frame(x$data$summary)) {
    cat(paste0(data_mss, sum(x$data$summary$n), " samples\n"))
  } else {
    cat(paste0(data_mss, x$cal_info$summary), "\n")
  }
  invisible(x)
}
