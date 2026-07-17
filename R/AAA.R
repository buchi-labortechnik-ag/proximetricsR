# .PROXIMETRICSR_CACHE <- new.env(FALSE, parent = globalenv())

#' @title Get the package version info
#' @description returns package info.
#' @param pkg the package name i.e "proximetricsR"
#' @return A matrix containing package version and related information from the DESCRIPTION file.
#' @keywords internal
pkg_info <- function(pkg = "proximetricsR") {
  fld <- c("Version", "Config/VersionName", "URL")
  pinfo <- read.dcf(system.file("DESCRIPTION", package = pkg), fields = fld)
  pinfo
}


.onAttach <- function(lib, pkg) {
  pkg_v <- pkg_info()

  mss <- paste0(
    "\033[34m",
    pkg, " version ",
    paste(pkg_v[1:2], collapse = " \U002D\U002D "),
    "\033[39m"
  )
  mss2 <- paste0(
    "\033[34mCheck the package repository at: ",
    pkg_v[, "URL"],
    "\033[39m"
  )
  packageStartupMessage(mss)
  packageStartupMessage("\033[1;38;5;71mAn R package for modeling NIR data - BUCHI Labortechnik AG\033[0m")
  packageStartupMessage(mss2)
}
