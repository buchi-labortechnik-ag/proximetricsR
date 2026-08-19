# Freeze data-dependent constant-edge trim steps into a fixed wavelength/wavenumber band

Records, on each `prep_wav_trim` step using
`trim_constant_edges = TRUE`, the exact wavelengths or wavenumbers
retained on the training data (`resolved_wavs`) so `.exec_wav_trim`
reapplies them deterministically to `newdata` instead of re-deriving the
trimming from its own values.

## Usage

``` r
.freeze_trim_steps(recipe, processed_wavs)
```

## Arguments

- recipe:

  A `preprocess_recipe` object.

- processed_wavs:

  A `processed_wavs` object holding the wavelengths or wavenumbers
  retained after each step (from the `"processed_wavs"` attribute of
  [`process`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/preprocess_recipe.md)).

## Value

The `recipe` with `resolved_wavs` set on each fitted step.
