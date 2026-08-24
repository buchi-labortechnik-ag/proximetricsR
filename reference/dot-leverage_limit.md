# Leverage (Mahalanobis) limit for a new observation

Upper control limit for the `ncomp`-normalized Mahalanobis leverage
produced by
[`.gh_distance`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/dot-gh_distance.md),
for an observation that was *not* part of the calibration set. For a
model with `ncomp` components fitted on `n` calibration samples, the
squared Mahalanobis distance of a new observation has upper limit
\\\frac{p(n+1)(n-1)}{n(n-p)} F\_{\alpha; p,\\ n-p}\\. Dividing by
`p = ncomp` (the leverage normalization) gives the limit returned here.
Unlike an in-sample limit, this grows as `ncomp` approaches `n`,
reflecting the wider spread expected of new samples.

## Usage

``` r
.leverage_limit(n, ncomp, conf = 0.95)
```

## Arguments

- n:

  the number of calibration observations.

- ncomp:

  the number of components.

- conf:

  the confidence level of the limit (default `0.95`).

## Value

A single numeric upper limit, or `NA_real_` if it cannot be computed
(non-finite inputs, or `ncomp` not in `1:(n - 1)`).

## References

De Maesschalck, Roy, Delphine Jouan-Rimbaud, and Désiré L. Massart. "The
mahalanobis distance." Chemometrics and intelligent laboratory systems
50.1 (2000): 1-18.
