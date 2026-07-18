# Read and parse ProxiScout data from CSV or XLSX files

Reads spectral data files in either `.csv` or `.xlsx` format, identifies
spectral data columns based on numeric column names, converts
reflectance values from percentages to absolute units, and stores them
in a matrix under the `spc` column.

## Usage

``` r
proxiscout_read_data(file, references_file)
```

## Arguments

- file:

  A character string specifying the path to the input file. The file
  must be either have `.csv` or a `.xlsx` extension.

- references_file:

  An optional character string specifying the path to a file containing
  reference values. See details.

## Value

A `data.frame` where:

- Spectral data is stored as a **matrix** in the `spc` column.

- Columns identified as predictions are stored as a **matrix** in the
  `predictions` column.

- Other non-spectral metadata columns remain unchanged.

- Multiple files are merged into a single `data.frame`.

- If the files contain 257 columns in `spc`, the data is assigned class
  `"proxiscout_data"`.

## Details

This function allows the user to give the path to one or two files at
once.

If two file paths are given, the files are assumed to contain the
spectral data in `file`, while `references_file` contains only the
reference values. Both files must have a column that contains the regex
`sample`, and the entries must coincide (excluding potential repetition
identificators). These files are then merged together by the column with
the name containing `sample`.

If only `file` is given, it must contain the spectral columns, and may
or may not contain reference values.

In general, inside `file`, any column AFTER the spectra are identified
as predictions, and are collected into a `matrix` called `predictions`
(if any exist). Columns that contain numerical values and do not contain
typical column names (see
[`extract_property_names`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/extract_property_names.md)
for more details) that appear BEFORE the spectral data columns are
identified reference values.

The function:

- ensures the file extensions are valid (`.csv` or `.xlsx`).

- reads CSV files using
  [`read.csv()`](https://rdrr.io/r/utils/read.table.html) and Excel
  files using
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).

- extracts spectral data (columns with numeric names).

- if exactly 257 columns with numeric names are found, then:

  - the spectral matrix is assigned the typical proxiscout wavenumbers
    ([`get_proxiscout_wavenumbers`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/get_proxiscout_wavenumbers.md))

  - the data is assigned class `"proxiscout_data"`

  - spectral matrix is converted from percentage (0 to 100) to absolute
    (0 to 1) units.

- if the number of columns with numeric names is not 257, the spectral
  matrix is assigned the wavelengths/wavenumbers in the header of the
  file.

- stores the spectral data in a matrix named `spc`.

- stores columns after the spectral data in a matrix named `predictions`
  (if any exist).

- merges files together by the sample column if multiple files are
  given.

## Note

This function assumes spectral column names follow a strict numeric
pattern (e.g. "3921.0") and removes any prefixed characters such as "X"
that may be added by `read.csv`. These names are converted to numeric
and used as column names of the spectral matrix.

## Author

Leonardo Ramirez-Lopez, Claudio Orellano
