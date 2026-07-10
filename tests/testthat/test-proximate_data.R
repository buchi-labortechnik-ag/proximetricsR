data("NIRcannabis", package = "proximetricsR")
# Reconstruct NIRcannabis with properties in a different order
spc <- NIRcannabis$spc
properties <- matrix(
  c(NIRcannabis$CBD, NIRcannabis$CBDA, NIRcannabis$THC, NIRcannabis$THCA),
  ncol = 4, dimnames = list(NULL, c("CBD", "CBDA", "THC", "THCA"))
)
data_copy <- proximate_data(
  spc, NIRcannabis$ID, properties, NIRcannabis$ROW,
  date = NIRcannabis$Date, snr = NIRcannabis$SNR, barcode = NIRcannabis$Barcode,
  note = NIRcannabis$Note, begin = NIRcannabis$Begin, end = NIRcannabis$End,
  recipe = NIRcannabis$Recipe
)

# Create another copy of NIRcannabis without any properties
data_noprops <- proximate_data(
  spc, NIRcannabis$ID,
  row = NIRcannabis$ROW,
  date = NIRcannabis$Date, snr = NIRcannabis$SNR, barcode = NIRcannabis$Barcode,
  note = NIRcannabis$Note, begin = NIRcannabis$Begin, end = NIRcannabis$End,
  recipe = NIRcannabis$Recipe
)

test_that("non-property-related values are correctly copied", {
  delete_ref_orig <- which(names(NIRcannabis) %in% c("Reference", colnames(properties)))
  delete_ref_copy <- which(names(data_copy) %in% c("Reference", colnames(properties)))

  expect_identical(NIRcannabis[, -delete_ref_orig], data_copy[, -delete_ref_copy])
  expect_identical(NIRcannabis[, -(8:13)], data_noprops[, -(8:9)])
})

test_that("column names remain the same", {
  expect_true(all(colnames(NIRcannabis) %in% colnames(data_copy)))
})

test_that("property-related values are correctly copied", {
  expect_identical(NIRcannabis[, c("CBD", "CBDA", "THC", "THCA")], data_copy[, c("CBD", "CBDA", "THC", "THCA")])
})

test_that("properties in different order results in different Reference row", {
  expect_false(all(NIRcannabis[, "Reference"] == data_copy[, "Reference"]))
})

test_that("returned objects are data.frames of class proximate_data", {
  expect_true(inherits(NIRcannabis, c("list", "data.frame", "proximate_data")))
  expect_true(inherits(data_copy, c("list", "data.frame", "proximate_data")))
  expect_true(inherits(data_noprops, c("list", "data.frame", "proximate_data")))
})

test_that("coefficients are ignored for constant wavelength resolution", {
  expect_identical(data_copy, proximate_data(
    spc, NIRcannabis$ID, properties, NIRcannabis$ROW,
    date = NIRcannabis$Date, snr = NIRcannabis$SNR, barcode = NIRcannabis$Barcode,
    note = NIRcannabis$Note, begin = NIRcannabis$Begin, end = NIRcannabis$End,
    recipe = NIRcannabis$Recipe, coeffs = list(X1 = 1e6)
  ))
})

test_that("coefficients are correctly copied", {
  expected_coeffs <- list(X1 = 0, X2 = 233, X3 = list(c(0, 3, 998)))
  expect_identical(attr(data_copy, "coeffs"), expected_coeffs)
  expect_identical(attr(NIRcannabis, "coeffs"), expected_coeffs)
  expect_identical(attr(data_noprops, "coeffs"), expected_coeffs)
})

# Construct artificial spectra with non-constant wavelength resolution
non_const <- list(
  X1 = c(823, 4),
  X2 = c(1074, 272),
  X3 = list(
    c(0, 0, -3.618926e-05, 2.137782, -1.333363e+03),
    c(2.04E-10, -1.28E-07, 2.80E-05, -4.76e-3, 3.89, 880.06)
  )
)
pixel_seq <- list((non_const$X1[1]:non_const$X2[1]), (non_const$X1[2]:non_const$X2[2]) + 1)
vis_wavs <- mapply(pixel_seq[[1]], FUN = function(x) non_const$X3[[1]] %*% c(x^4, x^3, x^2, x^1, 1))
nir_wavs <- mapply(pixel_seq[[2]], FUN = function(x) non_const$X3[[2]] %*% c(x^5, x^4, x^3, x^2, x^1, 1))
wavs <- c(vis_wavs, nir_wavs)
spc_nc <- prospectr::resample(spc, as.numeric(colnames(spc)), wavs, interpol = "spline", ties = mean, method = "natural")
colnames(spc_nc) <- wavs
# Create a proximate_data object with non-constant wavelength resolution via coefficients
data_coeff <- proximate_data(
  spc_nc, NIRcannabis$ID, properties, NIRcannabis$ROW,
  date = NIRcannabis$Date, snr = NIRcannabis$SNR, barcode = NIRcannabis$Barcode,
  note = NIRcannabis$Note, begin = NIRcannabis$Begin, end = NIRcannabis$End,
  recipe = NIRcannabis$Recipe, coeffs = non_const
)

test_that("Non-constant wavelength spectra has no influence on non-spectral parameters", {
  expect_equal(data_coeff[, -ncol(data_coeff)], data_copy[, -ncol(data_copy)])
})

test_that("Coefficients are correctly stored in proximate_data", {
  expect_identical(attr(data_coeff, "coeffs"), non_const)
})

test_that("Non-constant wavelength spectra can be used to create & correctly import tsv", {
  tmpfile <- tempfile()
  proximate_write_data(data_coeff, tmpfile, properties = c("CBD", "CBDA", "THC", "THCA"))
  reimp_tsv <- proximate_read_data(tmpfile)
  expect_equal(data_coeff, reimp_tsv)
  expect_identical(attr(data_coeff, "coeffs"), attr(reimp_tsv, "coeffs"))
})

default_proximate_data <- proximate_data(spc, NIRcannabis$ID)

test_that("Default rownames are correct", {
  expect_identical(rownames(default_proximate_data), rownames(data_noprops))
})

test_that("Default colnames are correct", {
  expect_identical(colnames(default_proximate_data), colnames(data_noprops))
})

test_that("Default ROW are numbered from 1 to 80", {
  expect_identical(default_proximate_data$ROW, 1:80)
})

test_that("Default Check are all strings 'True'", {
  expect_true(all(default_proximate_data$Check == "True"))
})

test_that("Default Dates are all equivalent", {
  expect_true(all(duplicated(default_proximate_data$Date)[-1]))
})

test_that("Default serial numbers (SNR) are 1000000000", {
  expect_true(all(default_proximate_data$SNR == 1000000000))
})

test_that("Default Barcode is empty character", {
  expect_true(all(default_proximate_data$Barcode == ""))
})

test_that("Default Note is empty character", {
  expect_true(all(default_proximate_data$Note == ""))
})

test_that("Default Result is empty character", {
  expect_true(all(default_proximate_data$Result == ""))
})

test_that("Default Reference is empty character", {
  expect_true(all(default_proximate_data$Reference == ""))
})

test_that("Default Begin/End are the same as Date", {
  expect_true(all(default_proximate_data$Begin == default_proximate_data$Date))
  expect_true(all(default_proximate_data$End == default_proximate_data$Date))
})

test_that("Default Recipe is empty character", {
  expect_true(all(default_proximate_data$Recipe == ""))
})

test_that("Default Composition is empty character", {
  expect_true(all(default_proximate_data$Composition == ""))
})

test_that("Default Images is empty character", {
  expect_true(all(default_proximate_data$Images == ""))
})

# Sanity checks
id <- NIRcannabis$ID

test_that("Spectrum must be given", {
  expect_error(proximate_data(), "'spc' is missing.")
})

test_that("SPectrum must be a matrix", {
  expect_error(proximate_data(spc = 1:10), "'spc' has to be a matrix")
})

test_that("Spectrum must have column names", {
  expect_error(proximate_data(spc = matrix(1:80), id = id, properties = properties), "Missing column names found in 'spc'.")
})

test_that("Spectrum column names must be convertible to numeric", {
  expect_error(
    proximate_data(spc = matrix(1:80, dimnames = list(NULL, "test")), id = id, properties = properties),
    "Column names of 'spc' must correspond to spectral wavelengths."
  )
})

test_that("Spectrum and ID must have the same number of rows", {
  expect_error(proximate_data(spc = spc_nc, id = ""), "Each spectra must have an 'id'.")
})

test_that("ID must be given", {
  expect_error(proximate_data(spc = matrix(1:10)), "'id' is missing.")
})

test_that("Properties must be given as a matrix", {
  expect_error(proximate_data(spc = spc_nc, id = id, properties = 1), "'properties' must be a matrix.")
})

test_that("Properties matrix must have column names", {
  expect_error(proximate_data(spc = spc_nc, id = id, properties = matrix(1)), "Missing column names found in 'properties'.")
})

test_that("Using non-constant wavelengths without coefficients gives a warning", {
  expect_warning(proximate_data(spc = spc_nc, id = id, properties = properties), "In case of non-constant wavelengths, polynomial coefficients 'coeffs'should be provided, otherwise errors can occur.")
})

test_that("With non-constant wavelengths, coefficients must be in a specific format", {
  # This should give 2 warnings
  expect_warning(expect_warning(proximate_data(spc = spc_nc, id = id, properties = properties, coeffs = list(x = 1))))
})

test_that("With non-constant wavelengths, coefficients should be given in a list", {
  expect_warning(proximate_data(spc = spc_nc, id = id, coeffs = c(X1 = 1)), "Coefficients should be given in a list.")
})

test_that("Check must be either 'True' or 'False'", {
  expect_error(proximate_data(spc = spc, id = id, properties = properties, check = "Test"), "'check' must only consist of characters 'True' or 'False'.")
})

test_that("Spectra and properties must have the same number of rows, 'spc.' is ignored in spc", {
  colnames(spc) <- paste0("spc.", colnames(spc))
  expect_error(
    proximate_data(spc = spc, properties = properties[-1, , drop = FALSE], id = id),
    "'spc' and 'properties' must have the same number of rows."
  )
})
