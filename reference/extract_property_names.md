# Extract the property names from a given `data.frame`

This function aims to extract the column names of properties from `x`. A
property in this context is a response vector of numerical values that
then later can be calibrated for predictions (such as with
[`calibrate`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/calibrate.md)).

## Usage

``` r
extract_property_names(x)
```

## Arguments

- x:

  a `data.frame`, as normally obtained by
  [`proximate_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_read_data.md),
  [`read_spc`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/read_spc.md),
  [`proxiscout_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proxiscout_read_data.md),
  or some other data parsing function.

## Value

A character vector, containing only the names of numerical properties.
If no property names were identified, return a character vector of
length 0.

## Details

Depending on the `class` of `x`, the names of the properties are
identified differently. For all cases, only columns which contain
numerical values (including `NA`) are considered as potential
properties.

If `x` is of class `proximate_data`, the property names are identified
as follows:

- Located between columns "Reference" and "Begin".

- Not named according to any of the following names: "ROW", "Check",
  "Date", "SNR", "SRN", "ID", "Barcode", "Note", "Result", "Reference",
  "Begin", "End", "Recipe", "Composition", "Images", "spc".

- Contain only numerical values (including NA).

If `x` is of class `proxiscout_data`, property names are identified as
columns that contain only numerical values (including `NA`) and are not
matched by any of the following, case-insensitive regex (each wrapped by
`^` and `$`):

- `id`

- `sample[_. ]?name`

- `captured[_. ]?at`

- `device[_. ]?id`

- `created[_. ]?(by|at)`

- `on[_. ]?behalf[_. ]?of`

- `lot[_. ]?name`

- `scanner([_. ]?id)?`

- `original[_. ]?value`

- `display[_. ]?value`

- `note`

- `location`

- `supplier`

- `device`

- `spc`

- `predictions`

If `x` is of neither class, all columns with numerical values are
considered to be properties
