#' @import prospectr
#' @import foreach
#' @import mathjaxr
#' @import uuid
#' @import plotly
#' @import jsonlite
#' @importFrom utils read.table write.table setTxtProgressBar txtProgressBar read.csv packageDescription packageVersion
#' @importFrom stats sd cor cov reshape quantile aggregate complete.cases na.omit na.pass
#' @importFrom stats formula as.formula model.matrix model.frame model.extract predict
#' @importFrom digest digest
#' @importFrom withr with_seed
#' @importFrom readxl read_excel
#' @importFrom tools file_ext
#' @importFrom callr r_bg
#' @importFrom Rcpp evalCpp
#' @description
#'
#' NIR calibration and application tools for BUCHI ProxiMate and ProxiScout devices.
#' \if{html}{\figure{logo.png}{options: style = 'float: right;' alt = 'logo' width = '120'}}
#'
#' @details
#'
#' This is package version `r packageVersion("proximetricsR")` (`r packageDescription("proximetricsR")[["Config/VersionName"]]`).
#'
#' This package provides \code{R} functions for spectral pre-processing, NIR
#' model calibration, and reading/writing files for BUCHI ProxiMate and
#' ProxiScout devices. The calibration algorithms (\code{\link{fit_plsr}},
#' \code{\link{fit_xlsr}}) and the pre-treatment constructors
#' (\code{\link{prep_smooth}}, \code{\link{prep_snv}},
#' \code{\link{prep_resample}}, \code{\link{prep_derivative}}) reproduce the
#' corresponding algorithms in BUCHI NIRWise PLUS (version 1.1.3000.0),
#' guaranteeing numerical compatibility between models built with this package
#' and those built in NIRWise PLUS.
#'
#' The ProxiScout functions for preprocessing are also numerically equivalent to the
#' ones of the "BUCHI Modeller" software. The regression method in te Modeller is
#' teh classical PLS regression, however, the other PLS algorithms implemented
#' in proximetricsR (modified PLS, standard PLS, and XLS) can also be used to
#' generate models for ProxiScout devices.
#'
#' The functions available for ProxiMate spectral data are:
#' \itemize{
#'   \item{\code{\link{proximate_read_data}}}
#'   \item{\code{\link{proximate_data}}}
#'   \item{\code{\link{proximate_merge}}}
#'   }
#' The functions available for reading generic spectral data files are:
#' \itemize{
#'   \item{\code{\link{read_spc}}}
#'   }
#' The functions available for spectral pre-processing are:
#' \itemize{
#'   \item{\code{\link{prep_resample}}}
#'   \item{\code{\link{prep_smooth}}}
#'   \item{\code{\link{prep_snv}}}
#'   \item{\code{\link{prep_derivative}}}
#'   \item{\code{\link{prep_detrend}}}
#'   \item{\code{\link{prep_transform}}}
#'   \item{\code{\link{prep_wav_trim}}}
#'   \item{\code{\link{preprocess_recipe}}}
#'   \item{\code{\link{process}}}
#'   }
#' The functions available for calibrating NIR regression models are:
#' \itemize{
#'   \item{\code{\link{calibrate}}}
#'   \item{\code{\link{calibrate_models}}}
#'   \item{\code{\link{calibration_control}}}
#'   \item{\code{\link{fit_plsr}}}
#'   \item{\code{\link{fit_xlsr}}}
#'   \item{\code{\link{add_model_metadata}}}
#'   \item{\code{\link{validate_prediction}}}
#'   }
#' The functions available for writing ProxiMate files are:
#' \itemize{
#'   \item{\code{\link{proximate_write_data}}}
#'   \item{\code{\link{proximate_write_model}}}
#'   \item{\code{\link{add_application_metadata}}}
#'   \item{\code{\link{proximate_write_nax}}}
#'   }
#' The functions available for reading and editing ProxiMate application files are:
#' \itemize{
#'   \item{\code{\link{proximate_read_cal}}}
#'   \item{\code{\link{proximate_read_nax}}}
#'   \item{\code{\link{proximate_recalibrate_nax}}}
#'   \item{\code{\link{proximate_add2nax}}}
#'   }
#' The functions available for ProxiScout devices are:
#' \itemize{
#'   \item{\code{\link{proxiscout_read_data}}}
#'   \item{\code{\link{proxiscout_write_data}}}
#'   \item{\code{\link{proxiscout_write_model}}}
#'   \item{\code{\link{get_proxiscout_wavenumbers}}}
#'   \item{\code{\link{proxiscout_repetition_pattern}}}
#'   }
#' The functions available for creating plots are:
#' \itemize{
#'   \item{\code{\link{plot.spectral_model}}}
#'   }
#' Other functions:
#' \itemize{
#'   \item{\code{\link{extract_property_names}}}
#'   }
#' A typical example dataset for a ProxiMate device can be found in:
#' \itemize{
#'   \item{\code{\link{NIRcannabis}}}
#' }
#'
#' @name proximetricsR-package
#' @aliases proximetricsR-package proximetricsR
#' @title Overview of the proximetricsR package
#' @author
#' Leonardo Ramirez-Lopez,
#' Claudio Orellano,
#' Nicolae Cudlenco,
#' Mai Said,
#' Mohamed Abushosha,
#' Marcal Plans
"_PACKAGE"
