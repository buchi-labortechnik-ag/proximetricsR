# Writes metadata required for a Proximate application file

Internal function for generating a metadata file required for creating a
ProxiMate application.

## Usage

``` r
write_nad(object, path, application_meta, external_properties = NULL, verbose = TRUE)
```

## Arguments

- object:

  a list of models of class `spectral_model` for which the metadata
  files should be generated.

- path:

  a string for the directory in which the files will be saved.

- application_meta:

  a list of class `application_metadata`, containing the metadata for
  the application. See
  [`add_application_metadata`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/add_application_metadata.md).

- external_properties:

  a list of external properties. More details in
  [`proximate_write_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_nax.md).
  Defaults to `NULL`.

- verbose:

  a logical. Should messages about the generated files be printed?
  Default is `TRUE`.

## Value

Invisibly returns `NULL`. Called for its side effect of writing a `.nad`
metadata file to `path`.

## Details

This function takes a list of models of class `spectral_model` and
generates the corresponding metadata file (.nad). This file allows the
ProxiMate calibration software to import a .nax file. Thus, the main
purpose of this file is to added to the zip structure of an application
file (.nax). See
[`proximate_write_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_nax.md)
for more details on how this file is used.

Note that it is crucial for all provided models to have some metadata
added.

## Author

Claudio Orellano, Leonardo Ramirez-Lopez
