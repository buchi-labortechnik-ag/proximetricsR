#' @title ProxiScout standard wavenumbers
#' @description Returns the standard wavenumbers used by ProxiScout NIR scanners.
#'
#' @details
#' The standard wavenumbers of ProxiScout (see
#' \href{https://www.si-ware.com/}{https://www.si-ware.com/}) NIR scanners range
#' from approximately 3921.569 \eqn{cm^{-1}} to 7407.407 \eqn{cm^{-1}} in steps
#' (resolution) of around 13.61655 \eqn{cm^{-1}}. This is equivalent to a
#' spectral range of 1350 to 2550 nm, with a varying resolution that starts
#' from 2.486189 nm at 1350 nm and ends with a resolution of 8.823525 nm at
#' 2550 nm.
#'
#' @return A numeric vector containing the standard wavenumbers of ProxiScout
#' NIR scanners.
#' @examples
#' # Get the complete set of ProxiScout wavenumbers
#' wavs <- get_proxiscout_wavenumbers()
#'
#' # Get the corresponding wavelengths (nm)
#' wavelengths_nm <- 10000000 / wavs
#'
#' # Display the range of wavenumbers
#' range(wavs)
#' @export
get_proxiscout_wavenumbers <- function() {
  c(
    3921.568654, 3935.185205, 3948.801765, 3962.418316, 3976.034876, 3989.651427,
    4003.267987, 4016.884537, 4030.501097, 4044.117648, 4057.734208, 4071.350759,
    4084.967319, 4098.58387, 4112.20043, 4125.81698, 4139.43354, 4153.050091,
    4166.666651, 4180.283202, 4193.899762, 4207.516313, 4221.132873, 4234.749423,
    4248.365983, 4261.982534, 4275.599094, 4289.215645, 4302.832205, 4316.448756,
    4330.065316, 4343.681866, 4357.298426, 4370.914977, 4384.531537, 4398.148088,
    4411.764648, 4425.381199, 4438.997759, 4452.614309, 4466.230869, 4479.84742,
    4493.46398, 4507.080531, 4520.697091, 4534.313641, 4547.930202, 4561.546752,
    4575.163312, 4588.779863, 4602.396423, 4616.012974, 4629.629534, 4643.246084,
    4656.862644, 4670.479195, 4684.095755, 4697.712306, 4711.328866, 4724.945417,
    4738.561977, 4752.178527, 4765.795087, 4779.411638, 4793.028198, 4806.644749,
    4820.261309, 4833.87786, 4847.49442, 4861.11097, 4874.72753, 4888.344081,
    4901.960641, 4915.577192, 4929.193752, 4942.810303, 4956.426863, 4970.043413,
    4983.659973, 4997.276524, 5010.893084, 5024.509635, 5038.126195, 5051.742746,
    5065.359306, 5078.975856, 5092.592416, 5106.208967, 5119.825527, 5133.442078,
    5147.058638, 5160.675189, 5174.291749, 5187.908299, 5201.524859, 5215.14141,
    5228.75797, 5242.374521, 5255.991081, 5269.607631, 5283.224192, 5296.840742,
    5310.457302, 5324.073853, 5337.690413, 5351.306964, 5364.923524, 5378.540074,
    5392.156634, 5405.773185, 5419.389745, 5433.006296, 5446.622856, 5460.239407,
    5473.855967, 5487.472517, 5501.089077, 5514.705628, 5528.322188, 5541.938739,
    5555.555299, 5569.17185, 5582.78841, 5596.40496, 5610.02152, 5623.638071,
    5637.254631, 5650.871182, 5664.487742, 5678.104293, 5691.720853, 5705.337403,
    5718.953963, 5732.570514, 5746.187074, 5759.803625, 5773.420185, 5787.036736,
    5800.653296, 5814.269846, 5827.886406, 5841.502957, 5855.119517, 5868.736068,
    5882.352628, 5895.969179, 5909.585739, 5923.202289, 5936.818849, 5950.4354,
    5964.05196, 5977.668511, 5991.285071, 6004.901621, 6018.518182, 6032.134732,
    6045.751292, 6059.367843, 6072.984403, 6086.600954, 6100.217514, 6113.834064,
    6127.450624, 6141.067175, 6154.683735, 6168.300286, 6181.916846, 6195.533397,
    6209.149957, 6222.766507, 6236.383067, 6249.999618, 6263.616178, 6277.232729,
    6290.849289, 6304.46584, 6318.0824, 6331.69895, 6345.31551, 6358.932061,
    6372.548621, 6386.165172, 6399.781732, 6413.398283, 6427.014843, 6440.631393,
    6454.247953, 6467.864504, 6481.481064, 6495.097615, 6508.714175, 6522.330726,
    6535.947286, 6549.563836, 6563.180396, 6576.796947, 6590.413507, 6604.030058,
    6617.646618, 6631.263169, 6644.879729, 6658.496279, 6672.112839, 6685.72939,
    6699.34595, 6712.962501, 6726.579061, 6740.195611, 6753.812172, 6767.428722,
    6781.045282, 6794.661833, 6808.278393, 6821.894944, 6835.511504, 6849.128054,
    6862.744614, 6876.361165, 6889.977725, 6903.594276, 6917.210836, 6930.827387,
    6944.443947, 6958.060497, 6971.677057, 6985.293608, 6998.910168, 7012.526719,
    7026.143279, 7039.75983, 7053.37639, 7066.99294, 7080.6095, 7094.226051,
    7107.842611, 7121.459162, 7135.075722, 7148.692273, 7162.308833, 7175.925383,
    7189.541943, 7203.158494, 7216.775054, 7230.391605, 7244.008165, 7257.624716,
    7271.241276, 7284.857826, 7298.474386, 7312.090937, 7325.707497, 7339.324048,
    7352.940608, 7366.557159, 7380.173719, 7393.790269, 7407.406829
  )
}


#' @title Check which values in one vector are close to any value in another vector
#' @description
#' For each value in vector \code{a}, determines if there is at least one "close" value in vector \code{b},
#' where "close" means within a specified tolerance \code{tol}.
#'
#' @param a A numeric vector to check against vector \code{b}
#' @param b A numeric vector to check against vector \code{a}
#' @param tol A numeric tolerance value. Values are considered "close" if they differ by \code{tol} or less
#'
#' @return A logical vector of the same length as \code{a}: each element is \code{TRUE} if the
#'   corresponding value in \code{a} has at least one value in \code{b} that is within tolerance \code{tol},
#'   \code{FALSE} otherwise
#'
#' @examples
#' # Check which ProxiScout wavenumbers are close to a subset
#' all_wavenumbers <- get_proxiscout_wavenumbers()[1:10]
#' subset_wavenumbers <- all_wavenumbers[c(1, 5, 10)]
#' # Returns vector showing which values are close to any in the subset
#' is_close_to_any(all_wavenumbers, subset_wavenumbers, 1)
#'
#' # Check values against a tolerance
#' is_close_to_any(c(1, 2, 3), c(0.95, 1.95, 3.05), 0.1)
#' @keywords internal
#' @noRd
is_close_to_any <- function(a, b, tol) {
  # Handle empty vector edge cases
  if (length(a) == 0) {
    return(FALSE)
  }
  if (length(b) == 0) {
    return(rep(FALSE, length(a)))
  }

  # For each value in a, check if it's close to any value in b
  sapply(a, function(x) any(abs(x - b) <= tol))
}
