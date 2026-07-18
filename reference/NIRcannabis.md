# NIRcannabis

Selected samples of cannabis NIR measurements for demo purposes. The
dataset contains absorbance spectra of 80 cannabis samples measured
between 1001 nm and 1700 nm at a 3 nm interval. A total number of four
reference vectors is included: `"CBDA"` (Cannabidiolic acid), `"THCA"`
(Tetrahydrocannabinolic acid), `"CBD"` (Cannabidiol) and `"THC"`
(Tetrahydrocannabinol).

## Usage

``` r
data("NIRcannabis")
```

## Format

A `data.frame` containing 80 observations of four response variables,
with their corresponding spectral data.

## Source

BUCHI Labortechnik AG.

## Details

This dataset is an example for a typical data file for ProxiMate
applications, with a total of 80 cannabis samples, selected as a subset
of a larger database. It contains the following rows for each
observation:

- **`ROW`:** Integers for the associated numbers inside the database.

- **`Check`:** Characters, indicating whether the particular observation
  should be included in the construction of the model inside a
  ProxiMate.

- **`Date`:** Characters for the date and time when the measurement was
  taken.

- **`SNR`:** Characters of the serial number of the involved ProxiMate
  device.

- **`ID:`** Characters for the ID's.

- **`Barcode`:** Characters for the barcodes.

- **`Notes`:** Characters for the notes.

- **`Result`:** Characters for the results.

- **`Reference`:** Characters containing all reference values,
  concatented into one character with semicolon separation.

- **`CBDA`:** Numerics for the reference values of Cannabidiolic acid.

- **`THCA`:** Numerics for the references values of
  Tetrahydrocannabinolic acid.

- **`CBD`:** Numerics for the reference values of Cannabidiol.

- **`THC`:** Numerics for the reference values of Tetrahydrocannabinol.

- **`Begin`:** Characters, indicating when the measuring was initiated.

- **`End`:** Characters, indicating when the measurement was completed.

- **`Recipe`:** Characters for the recipe.

- **`Composition`:** Characters for the composition of the sample.

- **`Images`:** Characters for the image of the samples.

- **`spc`:** A numerical matrix of the absorbance spectra, corresponding
  to each individual observation.
