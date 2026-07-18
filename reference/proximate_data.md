# Create a data frame for NIRWise PLUS applications

Create a data frame of class `"proximate_data"`, similar to
[`proximate_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_read_data.md),
but without the need for a file. Instead, data can be supplied directly
from `R`.

## Usage

``` r
proximate_data(
  spc, id, properties = NULL, row = seq_len(nrow(spc)), check = "True", date = Sys.time(),
  snr = NULL, barcode = "", note = "", begin = Sys.time(), end = Sys.time(),
  recipe = "", coeffs = NULL
)
```

## Arguments

- spc:

  A matrix containing the spectral data. Note that the names of the
  columns must indicate the corresponding wavelength range at which the
  spectra was measured. Hence, the column names must be convertible to
  numerical values.

- id:

  A vector of length equal to the number of rows of `spc`. Corresponds
  to the ID of the spectra, and must be provided.

- properties:

  Either `NULL` (default) or a matrix containing numerical values,
  indicating the reference values of each property, where the column
  names correspond to the names of the properties. If a matrix is
  provided, it must contain the same number of rows as `spc`, but can
  contain `NA` values.

- row:

  A vector of length equal to the number of rows of `spc`. Contains the
  row number of the observation.

- check:

  A vector of characters with length equal to the number of rows of
  `spc` or a single character. Must only contain characters `"True"` or
  `"False"`. Defaults to `"True"`.

- date:

  A vector of length equal to the number of rows of `spc` or a single
  character. Indicates the date when the measurement was taken. Format
  should be: `"year-month-day hour:min:sec"`. In case an object
  inheriting from `"POSIXct"`, formatting will be done automatically.
  Defaults to [`Sys.time()`](https://rdrr.io/r/base/Sys.time.html).

- snr:

  A vector of length equal to the number of rows of `spc`, a single
  character or `NULL`. Indicated the serial number of the instrument the
  measurement was taken with. Defaults to `NULL`, in which case the
  serial numbers are all equal to `"0000000000"`.

- barcode:

  A vector of length equal to the number of rows of `spc` or a single
  character. Contains the barcodes for the measurement. Defaults to an
  empty string.

- note:

  A vector of length equal to the number of rows of `spc` or a single
  character. Contains notes for the measurements. Defaults to an empty
  string.

- begin:

  A vector of length equal to the number of rows of `spc` or a single
  character. Contains the time and date of the beginning of the
  measurement process. Format should be:
  `"year-month-day hour:min:sec"`. In case an object inheriting from
  `"POSIXct"`, formatting will be done automatically. Defaults to the
  system's current date and time.

- end:

  A vector of length equal to the number of rows of `spc` or a single
  character. Contains the time and date of the ending of the measurement
  process. Format should be: `"year-month-day hour:min:sec"`. In case an
  object inheriting from `"POSIXct"`, formatting will be done
  automatically. Defaults to the system's current date and time.

- recipe:

  A vector of length equal to the number of rows of `spc` or a single
  character. Contains the recipe for the measurements. Defaults to an
  empty string.

- coeffs:

  A list with exactly three entries. Parameter is ignored if the
  wavelength resolution of `spc` is constant. For non-constant
  resolution, this parameter must be supplied. See details on this
  parameter needs to be defined. Default is `NULL`.

## Value

A `data.frame` of class `proximate_data` containing all the metadata,
response variables and spectra. The spectra is returned in a matrix
embedded in the data.frame which can be accessed as `...$spc`.

## Details

This function provides an alternative way of creating a `data.frame`
with the necessary structure that is required by many functions of this
package. In particular, this function does not require any already
existing files like
[`proximate_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_read_data.md).

Note that only the first two arguments to this function are required for
creating the data frame. However, the `properties` argument should most
often also be provided, as these contain the necessary reference values
for the process of modeling and creating an application with the
spectral data.

Most parameters of this function can either have length equal to the
number of rows of `spc` or length equal to one. In latter case, the
value is recycled for every row of the returned data frame.

Furthermore, we emphasize that the column names of matrix `spc` must
contain the wavelength ranges of the spectra.

In case these spectra do not have a constant resolution, the function
will require additional information on how the spectral wavelength range
can be recovered. Then, the parameter `coeffs` will be mandatory and
must contain information on the polynomial coefficients that were used
to obtain the wavelengths. More information, including an example, can
be seen in the vignette about the  
`vignette(ProxiMate-Structure-of-the-application-files)`. A concrete
example is also given below.

The `coeffs` must be a named list with exactly 3 entries: `X1`, `X2`,
`X3`. In ProxiMate data files (.tsv), they can be seen at columns \#X1,
\#X2, \#X3. Note that both `X1` and `X2` must be vectors of either
length 1 or 2, containing the start and end pixels respectively, while
`X3` is a list of length 1 or 2, containing polynomial coefficients as
vectors of arbitrary length. The entries of the `coeffs` can either be
for a near-infrared only (i.e. length 1), or for both the visible and
near-infrared range (i.e. length 2).

The coefficients are attached to the returned `data.frame` as an
attribute `"coeffs"`.

## Author

Claudio Orellano

## Examples

``` r
data("NIRcannabis")
dat <- NIRcannabis

# Reconstruct NIRcannabis with properties in a different order
spc <- dat$spc
properties <- matrix(
  c(dat$CBD, dat$CBDA, dat$THC, dat$THCA),
  ncol = 4, dimnames = list(NULL, c("CBD", "CBDA", "THC", "THCA"))
)
datc <- proximate_data(
  spc, dat$ID, properties, dat$ROW,
  date = dat$Date, snr = dat$SNR, barcode = dat$Barcode,
  note = dat$Note, begin = dat$Begin, end = dat$End, recipe = dat$Recipe
)

# They are similar to each other (except the order of properties):
dat_refs <- which(names(dat) %in% c("Reference", colnames(properties)))
datc_refs <- which(names(datc) %in% c("Reference", colnames(properties)))
all.equal(dat[, -dat_refs], datc[, -datc_refs]) # TRUE
#> [1] TRUE

# In case of non-constant wavelengths, have to pass the coefficients to the function.
# Coefficients are usually given as #X1, #X2, #X3 in ProxiMate .tsv files,
# e.g. using coefficients example of vignette(Structure-of-the-application-files):
coeffs <- list(
  X1 = c(823, 4),
  X2 = c(1074, 272),
  X3 = list(
    c(0, 0, 0, -3.618926e-05, 2.137782, -1.333363e+03),
    c(2.04E-10, -1.28E-07, 2.80E-05, -4.76e-3, 3.89, 880.06)
  )
)

# You can extract the wavelengths in nm using these coefficients like this:
# Note that NIR pixels must be shifted by one to the right, as they are zero-based
pixel_seq <- list((coeffs$X1[1]:coeffs$X2[1]), (coeffs$X1[2]:coeffs$X2[2]) + 1)
vis_wavs <- mapply(
  pixel_seq[[1]],
  FUN = function(x) coeffs$X3[[1]] %*% c(x^5, x^4, x^3, x^2, x^1, 1)
)
nir_wavs <- mapply(
  pixel_seq[[2]],
  FUN = function(x) coeffs$X3[[2]] %*% c(x^5, x^4, x^3, x^2, x^1, 1)
)
wavs <- c(vis_wavs, nir_wavs)

# Above coefficients now have to be passed to the proximate_data()
# function since there are non-constant wavelengths.

# If we (wrongly) assume that NIRcannabis has such wavelengths:
rand_mat <- matrix(rnorm((length(wavs) - ncol(spc)) * nrow(spc)), nrow = nrow(spc))
spc <- cbind(rand_mat, spc)
colnames(spc) <- wavs

# Now we can create data object with coefficients
datcc <- proximate_data(
  spc, dat$ID, properties, dat$ROW,
  date = dat$Date, snr = dat$SNR, barcode = dat$Barcode,
  note = dat$Note, begin = dat$Begin, end = dat$End, recipe = dat$Recipe,
  coeffs = coeffs
)

# Coefficients can be viewed with
attr(datcc, "coeffs")
#> $X1
#> [1] 823   4
#> 
#> $X2
#> [1] 1074  272
#> 
#> $X3
#> $X3[[1]]
#> [1]  0.000000e+00  0.000000e+00  0.000000e+00 -3.618926e-05  2.137782e+00
#> [6] -1.333363e+03
#> 
#> $X3[[2]]
#> [1]  2.0400e-10 -1.2800e-07  2.8000e-05 -4.7600e-03  3.8900e+00  8.8006e+02
#> 
#> 
```
