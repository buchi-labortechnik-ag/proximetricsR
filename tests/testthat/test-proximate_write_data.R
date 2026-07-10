data("NIRcannabis", package = "proximetricsR")
path <- tempdir()
filename <- paste0(path, "/tempfile.tsv")
filename_2 <- paste0(path, "/tempfile2.tsv")

############################
# CHECK IF WRITE TSV WORKS #
############################

# When supplied with all parameters
test_that("Creating a tsv from NIRcannabis works", {
  proximate_write_data(
    x = NIRcannabis,
    file = filename,
    id = NIRcannabis$ID,
    spc = "spc",
    spc_round = 8,
    barcode = NIRcannabis$Barcode,
    properties = c("CBDA", "THCA", "CBD", "THC"),
    note = NIRcannabis$Note,
    recipe = NIRcannabis$Recipe,
    created = NIRcannabis$Begin,
    snr = NIRcannabis$SNR
  )
  expect_true(file.exists(filename))
})

# Create a dataset with random entries as spectrum, with non-constant resolution
# Example taken from vignette
coefs_rand <- list(X1 = 4, X2 = 13, X3 = list(c(2.04E-10, -1.28E-07, 2.80E-05, -4.76e-3, 3.89, 880.06)))
getwavs <- function(coeff, spartpixel, endpixel) {
  d <- length(coeff) - 1
  mt <- t(matrix(rep(1 + (spartpixel:endpixel), each = length(coeff)), length(coeff)))
  mt2 <- sweep(mt, MARGIN = 2, STATS = d:0, FUN = "^")
  wavs <- coeff %*% t(mt2)
  return(wavs)
}
rand_wavs <- getwavs(coefs_rand$X3[[1]], coefs_rand$X1, coefs_rand$X2)
withr::with_seed(22, {
  rand_dat <- proximate_data(
    matrix(rnorm(100), 10, 10, dimnames = list(NULL, rand_wavs)),
    sample(letters, 10),
    properties = matrix(rnorm(10), dimnames = list(NULL, "test")),
    coeffs = coefs_rand
  )
})
which_col <- which(colnames(rand_dat) == "Date")
colnames(rand_dat)[which_col] <- "Created"

test_that("Write random dataset of tsv data produces files", {
  proximate_write_data(
    x = rand_dat,
    file = filename_2,
    properties = c("test")
  )
  expect_true(file.exists(filename_2))
})

test_that("Writing a dataset without any date contained in the dataset works", {
  nodate_data <- NIRcannabis
  nodate_data$Date <- nodate_data$Begin <- nodate_data$End <- NULL
  nodate_data$SRN <- nodate_data$SNR
  nodate_data$SNR <- NULL

  nodate_path <- paste0(path, "/nodate.tsv")
  proximate_write_data(
    x = nodate_data,
    file = nodate_path
  )
  expect_true(file.exists(nodate_path))
})

###########################################
# CHECK IF PRODUCED FILES CAN BE IMPORTED #
###########################################

test_that("Original dataset is equal to exported and reimported dataset", {
  file_imported <- proximate_read_data(filename)
  expect_equal(file_imported, NIRcannabis)
  expect_identical(attr(file_imported, "coeffs"), attr(NIRcannabis, "coeffs"))
})

test_that("Random dataset can be correctly exported and reimported", {
  file_2_imported <- proximate_read_data(filename_2)
  colnames(rand_dat)[which_col] <- "Date"
  expect_equal(file_2_imported, rand_dat)
  expect_identical(attr(file_2_imported, "coeffs"), attr(rand_dat, "coeffs"))
})

#################
# SANITY CHECKS #
#################

test_that("The spectrum must be contained in the data", {
  expect_error(proximate_write_data(rand_dat, "", spc = "not"), "The provided data frame does not contain a column named 'not'")
})

test_that("Coefficients must be available for non-constant wavelengths", {
  attr(rand_dat, "coeffs") <- NULL
  expect_error(proximate_write_data(rand_dat, ""), "Wavelength resolution of the spectra has either to be constant or saved as an attribute of the data.frame 'x'.")
})

test_that("proximate_write_data requires at least id as input of not found in data.frame", {
  rand_dat$ID <- NULL
  expect_error(proximate_write_data(rand_dat, ""), "id is missing")
})


on.exit(file.remove(filename))
on.exit(file.remove(filename_2))
