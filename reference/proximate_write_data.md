# Write NIRWise PLUS readable tab-separated files

This function writes tab-separated value files in a readable NIRWise
PLUS software format. These files contain visible and Near-Infrared
absorbance spectra along with response variables and metainformation
(e.g. sample ID, date, comments, etc).

## Usage

``` r
proximate_write_data(x, 
                     file, 
                     id, 
                     spc, 
                     spc_round = 8, 
                     barcode = "", 
                     properties = NULL, 
                     note = "", 
                     recipe = "", 
                     created, 
                     snr)
```

## Arguments

- x:

  a data.frame of spectral data and metadata, for which the tab
  separated value file should be generated. See details.

- file:

  a character for the path (and name) in which the tsv will be saved.

- id:

  a vector of characters of length equal to the number of observations
  in `x` or of length 1. Each entry gives an observation a specific ID.
  If length is 1, this entry is recycled for every observation.

- spc:

  either a character or a vector of integers. Specifies where the
  spectra can be found inside `x`. Default is `"spc"`.

- spc_round:

  an integer. To how many decimal places should the spectra be rounded?
  Defaults to 8 decimal places.

- barcode:

  a vector of characters of length equal to the number of observations
  in `x` or of length 1. Each entry specifies the barcode for each
  observation; if length is 1, the entry is recycled for every
  observation. Default is an empty character.

- properties:

  a vector of characters of arbitrary length. Which properties in `x`
  are to be added to the tsv? Note that any missing reference values for
  the properties are set to 0. Default is `NULL`.

- note:

  a vector of characters of length equal to the number of observations
  in `x` or of length 1. The vector corresponds to the notes for each
  observation, or, if the vector is of length one, to all notes of all
  observations. Defaults to an empty character.

- recipe:

  a vector of characters of length equal to the number of observations
  in `x` or of length 1. This vector corresponds to the recipe for each
  observation, or, if the vector is of length one, to all recipes of all
  observations. Defaults to an empty character.

- created:

  a vector of characters of length equal to the number of observations
  in `x`. This vector should contain the date and time of when each
  observation was measured. If not provided and not contained in `x`,
  this parameter will be set to the current date and time of the system.

- snr:

  a vector of characters, corresponding to the serial number of the
  device on which the measurement was taken. If not provided and not
  found in `x`, this parameter will be set to a vector of character of
  length equal to the number of rows in `x`, where each individual
  character is given by `0000000000`.

## Value

Invisibly returns `NULL`. Called for its side effect of writing a
tab-separated value file to `file`.

## Details

This function creates a tab separated value file, which is readable by
both NIRWise PLUS software and the
[`proximate_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_read_data.md)
function.

The main usage is to transform an already given data file into a format
which is readable by NIRWise PLUS. Therefore, if some data of the given
object `x` is already of the correct form, one can pass the
corresponding values simply by passing the specific row of `x` to this
function; for example, by passing `note = x$Note`.

## Author

Leonardo Ramirez-Lopez

## Examples

``` r
# \donttest{
data("NIRcannabis")
filename <- file.path(tempdir(), "NIRcannabis.tsv")

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
  created = NIRcannabis$Begin
)

# Since we do not change anything, the following produces the same tsv:
proximate_write_data(
  x = NIRcannabis,
  file = filename,
  properties = c("CBDA", "THCA", "CBD", "THC")
)
# Delete the file
file.remove(filename)
#> [1] TRUE
# }
```
