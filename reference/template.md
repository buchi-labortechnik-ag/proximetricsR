# Generates a template for .prj files

Generates a template for .prj files

## Usage

``` r
template(file_version = c("prj", "cal"), v1 = TRUE)
```

## Arguments

- file_version:

  a string, either `c('prj', 'cal')`, indicating which type of template
  should be produced.

- v1:

  a boolean. For `cal` files, should the line for version 1.0 be
  printed?

## Value

a vector of characters, which may be filled with correct values of the
computed model.
