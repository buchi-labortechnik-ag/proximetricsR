# Write data files for ProxiScout devices

This function writes comma-separated files in a format compatible with
ProxiScout-related software, which typically require separate
comma-separated files - one file for the spectra, another for reference
values, and a third one holding all remaining metadata columns. These
files are created inside the specified directory (argument `path`).

## Usage

``` r
proxiscout_write_data(x, path, file_prefix, properties = NULL, spc = "spc")
```

## Arguments

- x:

  a `data.frame` of spectral data for which to write the data files.
  Typically, this is returned by
  [`proxiscout_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proxiscout_read_data.md)
  and of class `"proxiscout_data"`.

- path:

  a character for the directory in which the files will be saved.

- file_prefix:

  a character for the prefix of the generated files. The files are then
  named as `[file_prefix]_spectra.csv`, `[file_prefix]_properties.csv`
  and `[file_prefix]_metadata.csv`. Default is `proxiscout_export`.

- properties:

  a vector of characters of arbitrary length. Which properties in `x`
  are to be added to the csv? Default is `NULL`.

- spc:

  either a character or a vector of integers. Specifies where the
  spectra can be found inside `x`. Default is `"spc"`.

## Value

A `character` with the paths to the created files.

## Details

This function creates up to three comma separated files in the directory
`path`, which are usable by ProxiScout-related software. These files are
named according to the `file_prefix` argument and contain the spectra
together with the sample names and device ID, respectively the reference
values with the sample names, and a metadata file with the sample names
and all remaining columns.

Typically, the data provided to this function is imported with
[`proxiscout_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proxiscout_read_data.md)
and of class `"proxiscout_data"`, but it is also possible to construct a
`data.frame` by hand and provide it to this function.

The `properties` argument specifies which columns in `x` are the
reference values written to the `[file_prefix]_properties.csv` file. If
empty (default), this file is not created, as it would only contain
sample names. Any row in the provided properties that only contains `NA`
values are dropped. In general, `NA` values are set to an empty string
(`""`)

The sample names are detected automatically from `x` as the column with
a name that contains `"sample"`. If none are detected, the function will
throw an error. This column is named `"sampleName"` in every file.

Similarly, the device ID is a required column and is identified as
having a `"device"` string inside the name of the column. This column is
only written into the `[file_prefix]_spectra.csv` file, with a fixed
name `"deviceId"`.

All other columns in either file only correspond to the spectra
respectively the reference values. All columns in `x` that are not
written to any of the other files - i.e. that are neither the spectra,
the sample name, the device id nor the selected `properties` - are
written to the `[file_prefix]_metadata.csv` file, together with the
sample names (as `"sampleName"`). As with the properties file, this
metadata file is only created when there is at least one such column,
otherwise it would only contain the sample names.

## Author

Leonardo Ramirez-Lopez, Claudio Orellano
