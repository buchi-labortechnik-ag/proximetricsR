# Merge datasets of class `proximate_data`

This function allows you to quickly merge two separate datasets of class
`proximate_data` into a single one. The first dataset must be of class
`proximate_data`, while the second may be any kind of list-like format,
but must contain at least columns named `spc` and `ID`.

## Usage

``` r
proximate_merge(x)
```

## Arguments

- x:

  a list containing objects of class `proximate_data`, obtained from
  [`proximate_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_read_data.md)
  or via
  [`proximate_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_data.md).
  The first element in the list is used as the reference for aligning
  the spectral data of the remaining elements. See details.

## Value

a `data.frame` of class `proximate_data`, containing the merged data.

## Details

This functions provides a way to merge different datasets into a single
table.

In cases where the first dataset in the list (the one used as reference
for spectral alignment) has spectral data with an spectral range outside
the limits of another dataset, the spectral data of such dataset will
not be extrapolated. In that case the spectral variables outside such
limits will be filled with `NA`s.

The function checks for any of the standard names of a `.tsv` file of
ProxiMate, identifying any unexpected column names as properties.

Propeties that are contained in both datasets are merged into a single
column. Otherwise, the columns of a property that is only contained in
one of the datasets is filled up with `NA`.

## See also

[`proximate_read_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_read_data.md),
[`proximate_data`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_data.md)

## Author

Claudio Orellano

## Examples

``` r
# to do
```
