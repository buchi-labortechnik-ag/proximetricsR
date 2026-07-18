# Write calibration (.cal), project (.prj) and report (.rtf) files to a specified directory

This function allows to write native ProxiMate calibration, project and
report files from a `spectral_model` object.

## Usage

``` r
proximate_write_model(object, path, tsv_paths, application_name = "Untitled",
                      cal = TRUE, prj = TRUE, rtf = TRUE,
                      verbose = TRUE, internal_prj_path = NULL)
```

## Arguments

- object:

  a list of models of class `spectral_model`. These models should be
  generated using the
  [`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)
  function.

- path:

  a string for the directory in which the files should be saved.

- tsv_paths:

  a vector of character strings for the paths (including the names) of
  the tsv data files. See details.

- application_name:

  a string with the name of the generated files. Defaults to
  `"Untitled"`.

- cal:

  a logical. Should a calibration file (.cal) be written? Default is
  `TRUE`.

- prj:

  a logical. Should a project file (.prj) be written? Default is `TRUE`.

- rtf:

  a logical. Should a report in rich text format (.rtf) be written?
  Default is `TRUE`.

- verbose:

  a logical. Should progress bars for the generated files be printed?
  Default is `TRUE`.

- internal_prj_path:

  a string. Only used for changing the path printed on the first line of
  the project file. This is necessary mainly for calls from
  [`proximate_write_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_nax.md),
  as it creates the project file in a temporary file, which would also
  store that temporary path into the project file. This argument allows
  you to overwrite that path individually. Otherwise, this parameter may
  be ignored. If `NULL` (default), will be set to `path`.

## Value

Invisibly returns `NULL`. Called for its side effect of writing
calibration, project and/or report files to `path`.

## Details

This function generates files with extensions ".prj" (project file),
".cal" (calibration file), and ".rtf" (report) for the provided models
of class `spectral_model` in the argument `object`. Each file type can
be individually enabled or disabled via the `cal`, `prj`, and `rtf`
arguments. All files will be named according to the chosen name of the
application (given by `application_name`). Note that in contrast to
[`proximate_write_nax`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_nax.md),
the metadata does not influence the name of the application. This allows
models to be passed directly to this function without the need for
metadata. Additionally, the name of the response variable is
automatically added to the names of the produced files, so that all
generated files have unique names.

## Author

Claudio Orellano, Leonardo Ramirez-Lopez

## Examples

``` r
# \donttest{
data("NIRcannabis")
control <- calibration_control(validation_type = "kfold", number = 3, folds = "sequential")
amodel <- calibrate(CBDA ~ spc,
  data = NIRcannabis, preprocess = preprocess_recipe(),
  method = fit_plsr(5), control = control, verbose = FALSE
)

proximate_write_model(
  object = list(amodel),
  path = tempdir(),
  tsv_paths = tempfile(fileext = ".tsv"),
  application_name = "Untitled",
  cal = TRUE, prj = TRUE, rtf = TRUE,
  verbose = FALSE
)
# }
```
