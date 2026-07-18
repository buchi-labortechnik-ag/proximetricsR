# Converts a matrix into a string in style of .prj files

Converts a matrix into a string in style of .prj files

## Usage

``` r
matrix_prj_string(object, transp = FALSE)
```

## Arguments

- object:

  matrix to be converted into string

- transp:

  a logical. Should the matrix be transposed?

## Value

character of length 1, where each row is separated by `"\n"` and all
values in each row is separated by `"\t"`
