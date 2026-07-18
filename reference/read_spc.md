# Read and format spectral data from a file

This function reads spectral data from a file and extracts the spectral
columns based on a specified prefix, or a range of columns. It can
handle various delimiters and decimal separators.

## Usage

``` r
read_spc(file, sep = "\t", dec = ".", header = TRUE, spectra_prefix = "",
         spectra_starts = NA, spectra_ends = NA, ...)
```

## Arguments

- file:

  a character string specifying the path to the file containing the
  spectral data.

- sep:

  a character string indicating the field separator character. Defaults
  to `"\t"`.

- dec:

  a character string used for decimal points. Defaults to `"."`.

- header:

  logical value indicating whether the file contains the names of the
  variables as its first line. Defaults to `TRUE`

- spectra_prefix:

  a character string specifying the prefix used for spectral column
  names. If empty, the function will use column indices instead.

- spectra_starts:

  an integer indicating the starting column index for the spectral data,
  used when `spectra_prefix` is not specified.

- spectra_ends:

  an integer indicating the ending column index for the spectral data,
  used when `spectra_prefix` is not specified. If not provided, defaults
  to the last column.

- ...:

  additional arguments passed to
  [`read.table`](https://rdrr.io/r/utils/read.table.html).

## Value

a data frame with the original data and a matrix of spectral data stored
in the `spc` column.

## Details

The function reads a file and extracts the spectral data based on either
a column name prefix or specified column indices. The spectral data is
returned as a matrix in the `spc` column of the resulting data frame.

## Author

Leonardo Ramirez-Lopez

## Examples

``` r
# \donttest{
# write a file with spectra
data("NIRsoil", package = "prospectr")
spc_small <- NIRsoil$spc[1:5, ]
colnames(spc_small) <- paste0("X", colnames(spc_small))
tmp_df <- data.frame(ID = 1:5, Nt = NIRsoil$Nt[1:5], spc_small, check.names = FALSE)
tmp_file <- tempfile(fileext = ".txt")
write.table(tmp_df, file = tmp_file, sep = "\t", row.names = FALSE)

# read that
result <- read_spc(tmp_file, spectra_prefix = "X")
# }
```
