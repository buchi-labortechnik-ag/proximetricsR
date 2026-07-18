# ProxiScout: Structure of the applications

## 1 Introduction

This package can also be used to build and/or update NIR applications
that are ready to be consumed by the [ProxiScout handheld NIR
sensors](https://www.buchi.com/en/products/instruments/proxiscout)
manufactured by BUCHI Labortechnik AG. Once an application is installed
in a ProxiScout device, it can be used to predict the properties of a
given matrix using the spectral models contained in that application.

This package builds upon the standard structure of the ProxiScout
applications, which are conventionally developed with the
compiled-executable software “BUCHI Modeller” offered by BUCHI.
Therefore, the files output by `proximetricsR` follow the same structure
of the ones output by “BUCHI Modeller”. No changes or improvements on
these output files have been conducted for the development of
`proximetricsR`.

ProxiScout applications differ from ProxiMate applications in their
internal file format: a ProxiScout application consists of two JSON
files (`operations.json` and `model_info.json`) that are uploaded to the
NeoSpectra Portal and subsequently synchronised to the ScanApp Mobile
Application, where predictions are executed locally on the mobile
device.

## 2 ProxiScout predictive application package

### 2.1 Overview

A ProxiScout predictive application is deployed through the NeoSpectra
ecosystem and consists of two JSON files:

- `Operations.json`: Defines the ordered modeling workflow, including
  preprocessing, variable selection, and predictive model execution.

- `Model_Info.json`: Contains model metadata, performance statistics,
  and application configuration settings.

Together, these files define the predictive workflow and configuration
required for deployment. The application package is uploaded to the
NeoSpectra Portal and synchronized to the ScanApp Mobile Application,
where predictions are executed locally on the mobile device.

### 2.2 Deployment workflow

1.  The predictive application package is generated as:

    - `operations.json`

    - `model_info.json`

2.  The files are uploaded to the NeoSpectra Portal.

3.  The application is synchronized to the ScanApp Mobile Application.

4.  ScanApp downloads the application configuration and executes the
    predictive workflow during sample analysis.

## 3 `operations.json`

### 3.1 Purpose

The `operations.json` file defines the complete modeling pipeline used
to transform raw spectral measurements into prediction results.

The pipeline consists of a sequence of operations executed in a
predefined order. These operations may represent spectral preprocessing,
variable selection, feature extraction, scaling, regression,
classification, or any other modeling step required by the predictive
application.

### 3.2 File structure

The file contains an ordered collection of operation objects.

#### 3.2.1 Operation Object

Each operation is represented by a JSON object containing the following
fields:

| Field | Type | Description |
|----|----|----|
| `id` | Integer | Unique identifier representing the operation type. |
| `index` | Integer | Execution order of the operation within the modeling pipeline. |
| `params` | Array | List of operation-specific parameters required during execution. |

#### 3.2.2 Example

``` json
{
    "id": 83,
    "params": [
        9.0,
        3.0,
        1.0
    ],
    "index": 5
}
```

### 3.3 Execution model

Operations are executed sequentially according to the value of the
`index` field.

Each operation receives the output of the previous operation as input
and produces output that is passed to the next operation in the
pipeline.

The modeling workflow may include operations for:

- Spectral preprocessing
- Variable selection
- Data transformation and scaling
- Regression or classification
- Post-processing of prediction results

### 3.4 `proximetricsR` function reference

When using `proximetricsR` to build ProxiScout applications,
preprocessing steps are automatically serialized to the correct JSON
format. This reference maps `proximetricsR` preprocessing functions to
their corresponding ProxiScout operation IDs and JSON structure:

#### 3.4.1 Spectra scale (ID: 37)

- `proximetricsR`: None (spectra must be provided in reflectance,
  0–100%)

- Requires params: Yes (scale factor)

``` json
{
    "id": 37,
    "params": 0.01,
    "index": 0
}
```

#### 3.4.2 Get absorbance (ID: 29)

- `proximetricsR`:
  [`prep_transform()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_transform.md)

- Requires params: No

``` json
{
    "id": 29,
    "params": [],
    "index": 5
}
```

#### 3.4.3 Average readings (ID: 7)

- `proximetricsR`: None

- Requires params: No

``` json
{
    "id": 7,
    "params": [],
    "index": 12
}
```

#### 3.4.4 SNV (ID: 2)

- `proximetricsR`:
  [`prep_snv()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_snv.md)

- Requires params: No

``` json
{
    "id": 2,
    "params": [],
    "index": 0
}
```

#### 3.4.5 Detrending (ID: 3)

- `proximetricsR`:
  [`prep_detrend()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_detrend.md)

- Requires params: Yes (detrending degree)

``` json
{
    "id": 3,
    "params": [2],
    "index": 3
}
```

#### 3.4.6 Savitzky-Golay smoothing and differentiation (ID: 83)

- `proximetricsR`: `prep_derivative(algorithm = "savitzky-golay")` or
  `prep_smooth(algorithm = "savitzky-golay")`

- Requires params: Yes (window length, polynomial order, derivative
  order, coefficients)

``` json
{
    "id": 83,
    "params": [
        9.0,
        7.0,
        1.0,
        105.0,
        1.0,
        0.0,
        -0.0035,
        0.038,
        -0.20,
        0.8,
        8.22e-15,
        -0.8,
        0.2,
        -0.038,
        0.0035
    ],
    "index": 5
}
```

#### 3.4.7 Variable selection (ID: 17)

- `proximetricsR`:
  [`prep_wav_trim()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_wav_trim.md)

- Requires params: Yes (selected variable indices)

``` json
{
    "id": 17,
    "params": [
        17,
        18,
        19,
        200,
        201,
        202,
        203
    ],
    "index": 12
}
```

## 4 `model_info.json`

### 4.1 Purpose

The `model_info.json` file contains metadata associated with the
predictive model and application configuration.

This information is used by ScanApp to display model information,
configure measurement acquisition settings, and provide model
performance statistics.

### 4.2 Contents

The file contains:

- Model performance metrics for calibration, cross-validation, and
  testing
- Prediction range information
- Dataset statistics used during model development
- Measurement and prediction averaging settings
- Application execution configuration

#### 4.2.1 Example

``` json
{
    "executionOrder": 0,
    "RMSECalib": 0.58,
    "R2Calib": 0.814,
    "RMSECV": 0.701,
    "R2CV": 0.73,
    "BiasCV": 0.013,
    "RPDCV": 1.925,
    "RMSETest": 0.598,
    "R2Test": 0.947,
    "BiasTest": 0.145,
    "RPDTest": 2.804,
    "avgReadings": 1,
    "avgPredictions": 1,
    "minValue": 3.1,
    "maxValue": 9.5,
    "NumberOfSamples": 119,
    "NumberOfMeasurements": 6
}
```
