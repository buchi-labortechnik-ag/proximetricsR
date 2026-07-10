#' @title Resampling constructor for spectral preprocessing
#'
#' @description
#'
#' \loadmathjax
#'
#' Creates a preprocessing constructor for resampling spectral data to a new
#' wavelength grid. The constructor is intended to be passed to
#' \code{\link{preprocess_recipe}} and executed via \code{\link{process}}.
#'
#' @usage
#' prep_resample(grid)
#'
#' @param grid Either a numeric vector of length 3 specifying the target
#' wavelength grid as \code{c(min_wav, max_wav, resolution)}, or the character
#' string \code{"proxiscout"} to resample to the standard NeoSpectra wavenumber
#' grid (see Details).
#'
#' When \code{grid} is a numeric vector:
#' \itemize{
#'   \item \code{grid[1]} (\code{min_wav}): minimum wavelength of the target grid.
#'   \item \code{grid[2]} (\code{max_wav}): maximum wavelength; must be greater
#'     than \code{min_wav}.
#'   \item \code{grid[3]} (\code{resolution}): spacing between wavelengths;
#'     must be positive.
#' }
#'
#' Extrapolation beyond the range of the input wavelengths is never allowed.
#'
#' @return An object of class \code{preprocessing} to be used in
#' \code{\link{preprocess_recipe}} and executed by \code{\link{process}}.
#'
#' @details
#' \strong{User-defined grid} (\code{grid = c(min_wav, max_wav, resolution)}):
#' resamples spectra to the specified target grid using natural spline
#' interpolation via \code{\link[prospectr]{resample}}. Column names of
#' \code{X} must be coercible to numeric wavelength values. This mode is
#' compatible with the \code{"proximate"} device.
#'
#' \strong{NeoSpectra grid} (\code{grid = "proxiscout"}): resamples spectra to
#' the standard wavenumber grid of NeoSpectra NIR scanners
#' (approx. 3921.569 to 7407.407 \eqn{cm^{-1}}, ~256 channels at ~13.617
#' \eqn{cm^{-1}} steps). Only wavenumbers overlapping with the input range are
#' retained. This mode is compatible with the \code{"proxiscout"} device.
#'
#' @author Leonardo Ramirez-Lopez and Claudio Orellano
#'
#' @examples
#' data("NIRcannabis")
#' X <- NIRcannabis$spc
#'
#' # User-defined grid (proximate)
#' rs <- prep_resample(grid = c(1001, 1700, 2))
#' recipe <- preprocess_recipe(rs, device = "proximate")
#' X_rs <- process(X, recipe)
#'
#' @seealso \code{\link{preprocess_recipe}}, \code{\link{process}},
#' \code{\link{get_proxiscout_wavenumbers}}
#' @export
prep_resample <- function(grid) {
  if (missing(grid)) {
    stop(
      "'grid' is required. ",
      "Provide c(min_wav, max_wav, resolution) or \"proxiscout\"."
    )
  }

  if (is.character(grid)) {
    grid <- match.arg(grid, "proxiscout")
    return(
      structure(
        list(
          method = "prep_resample",
          min_wav = NULL,
          max_wav = NULL,
          resolution = NULL,
          compatible_devices = "proxiscout"
        ),
        class = c("preprocessing", "list")
      )
    )
  }

  if (!is.numeric(grid) || length(grid) != 3) {
    stop(
      "'grid' must be a numeric vector of length 3: ",
      "c(min_wav, max_wav, resolution)."
    )
  }
  if (any(is.na(grid))) {
    stop("'grid' cannot contain NA values.")
  }

  min_wav <- grid[[1]]
  max_wav <- grid[[2]]
  resolution <- grid[[3]]

  if (max_wav <= min_wav) {
    stop("grid[2] (max_wav) must be greater than grid[1] (min_wav).")
  }
  if (resolution <= 0) {
    stop("grid[3] (resolution) must be positive.")
  }

  structure(
    list(
      method = "prep_resample",
      min_wav = min_wav,
      max_wav = max_wav,
      resolution = resolution,
      compatible_devices = "proximate"
    ),
    class = c("preprocessing", "list")
  )
}


#' @keywords internal
.exec_resample <- function(X, step) {
  wav_current <- as.numeric(colnames(X))

  if (is.null(step$min_wav)) {
    hw_wavs <- get_proxiscout_wavenumbers()
    wav_new <- hw_wavs[hw_wavs >= min(wav_current) & hw_wavs <= max(wav_current)]
    if (length(wav_new) == 0) {
      wav_current <- 10000000 / wav_current
    }
    wav_new <- hw_wavs[hw_wavs >= min(wav_current) & hw_wavs <= max(wav_current)]

    if (length(wav_new) < 3) {
      stop(
        "Too few or no overlapping wavenumbers between NeoSpectra grid and X."
      )
    }
    resampled <- resample(
      X, wav_current,
      wav_new,
      interpol = "spline"
    )
  } else {
    wav_new <- seq(step$min_wav, step$max_wav, step$resolution)

    if (min(wav_current) > min(wav_new)) {
      stop(
        "Extrapolation not allowed: target min ", min(wav_new),
        " is below data min ", min(wav_current), "."
      )
    }

    if (max(wav_current) < max(wav_new)) {
      stop(
        "Extrapolation not allowed: target max ", max(wav_new),
        " is above data max ", max(wav_current), "."
      )
    }
    resampled <- resample(
      X, wav_current,
      wav_new,
      interpol = "spline",
      ties = mean,
      method = "natural"
    )
  }
  return(resampled)
}
