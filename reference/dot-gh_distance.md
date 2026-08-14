# Computes the Mahalanobis (GH) distance from scaled PLS scores

Computes the squared Mahalanobis distance of each row of `x` to the
origin, using the covariance matrix estimated from `reference`,
normalized by the number of components used. The origin represents the
center of the calibration score space. For calibration statistics, `x`
and `reference` are the same (calibration) scaled scores. For
new/prediction samples, `reference` must be the calibration model's
scaled scores, so that the covariance is estimated from the calibration
set and merely applied to (possibly few) prediction samples, rather than
re-estimated from them.

## Usage

``` r
.gh_distance(x, reference, ncomp)
```

## Arguments

- x:

  a matrix of scores scaled by their calibration standard deviations,
  for which the distance is computed.

- reference:

  a matrix of scores scaled by their calibration standard deviations,
  used to estimate the covariance matrix. Typically the calibration
  model's scaled scores.

- ncomp:

  a vector of component counts to compute the distance for.

## Value

A matrix with one row per sample and one column per entry in `ncomp`.
