# Derivative constructor for spectral preprocessing

Creates a preprocessing constructor for computing first or second order
derivatives of spectral data. The constructor is intended to be passed
to
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed via
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).

Three algorithms are supported: Savitzky-Golay (`"savitzky-golay"`),
Norris-Gap/Gap-Segment (`"gap-segment"`), and the derivative
pre-treatment from BUCHI NIRWise PLUS software (`"nwp"`).

## Usage

``` r
prep_derivative(m, w, p, algorithm = c("savitzky-golay", "gap-segment", "nwp"))
```

## Arguments

- m:

  An integer indicating the derivative order. Must be `1` (first
  derivative) or `2` (second derivative).

- w:

  A positive odd integer indicating the filter window size. For
  `"gap-segment"`, `w` indicates the gap size (spacing between points
  over which the derivative is computed).

- p:

  An integer. For `"savitzky-golay"`, indicates the polynomial order and
  must satisfy `p < w` and `p >= m`. For `"gap-segment"` and `"nwp"`,
  indicates the segment or smoothing window size and must be a positive
  odd integer.

- algorithm:

  A character string specifying the algorithm. One of `"savitzky-golay"`
  (default), `"gap-segment"`, or `"nwp"`. See Details.

## Value

An object of class `preprocessing` to be used in
[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)
and executed by
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md).
The object is a list containing the method name, all parameters, and
(for `algorithm = "nwp"`) the NIRWise PLUS half-window values (`half_w`,
`half_s`) required for device file serialization.

## Details

**Savitzky-Golay** (`"savitzky-golay"`): fits a polynomial of order `p`
within a moving window of size `w` and differentiates analytically.
Implemented via
[`savitzkyGolay`](https://l-ramirez-lopez.github.io/prospectr/reference/savitzkyGolay.html).

**Gap-Segment** (`"gap-segment"`): computes the derivative over a gap of
`w` points, with optional averaging over a segment of `p` points. When
`p = 1` this reduces to the standard Norris-Gap derivative. Implemented
via
[`gapDer`](https://l-ramirez-lopez.github.io/prospectr/reference/gapDer.html).

**NWP** (`"nwp"`): reproduces the "DG" derivative pre-treatment from
BUCHI NIRWise PLUS calibration software. A moving average of window `p`
is applied first (pre-smoothing), followed by differentiation. For first
order, a gap derivative with gap `w` is used. For second order, a
centered second difference with spacing `half_w` is computed:

\\d^2x_i = \frac{2x_i - (x\_{i+h} + x\_{i-h})}{2h}\\

where \\h = half_w\\. Edge columns affected by the window are removed
from the output.

For the `"nwp"` algorithm, the NIRWise PLUS half-window conventions are:
\\half_w = (w + 1) / 2\\ \\half_s = (p - 1) / 2\\ These are stored
internally for device file serialization and are not user-facing
parameters.

## See also

[`preprocess_recipe`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md),
[`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)

## Author

Leonardo Ramirez-Lopez and Claudio Orellano

## Examples

``` r
data("NIRcannabis")
X <- NIRcannabis$spc

# Savitzky-Golay first derivative, window 11, polynomial order 3
sg <- prep_derivative(m = 1, w = 11, p = 3, algorithm = "savitzky-golay")

# Gap-Segment second derivative, gap 9, segment 3
gs <- prep_derivative(m = 2, w = 9, p = 3, algorithm = "gap-segment")

# NWP first derivative, window 5, pre-smoothing 11
nwp <- prep_derivative(m = 1, w = 5, p = 11, algorithm = "nwp")

# Apply via preprocess_recipe
recipe <- preprocess_recipe(sg, device = "unspecified")
X_der <- process(X, recipe)
```
