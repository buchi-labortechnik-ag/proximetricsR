test_that("add_model_metadata does not change option digits.secs", {
  original_secs <- getOption("digits.secs")
  default_metadata <- add_model_metadata()
  expect_identical(getOption("digits.secs"), original_secs)
})

test_that("add_model_metadata can be added to an object of class 'spectral_model' using object argument", {
  # Pretend to have a spectral_model object to avoid using function 'spectral_model' here
  empty_object <- list()
  empty_object$target_variable <- "target_variable"
  class(empty_object) <- c("spectral_model", "list")
  object_metadata <- add_model_metadata(object = empty_object)

  # Check the classes of object_metadata
  expect_type(object_metadata, "list")
  expect_s3_class(object_metadata, "spectral_model")
  # Check the classes of metadata inside object_metadata
  expect_type(object_metadata$metadata, "list")
  expect_s3_class(object_metadata$metadata, "model_metadata")
  # Check that the metadata is correctly setup in object_metadata
  expect_length(object_metadata, 2)
  expect_length(object_metadata$metadata, 23)
  expect_named(object_metadata, c("target_variable", "metadata"))
  model_metadata_names <- c(
    "Key", "Created", "Changed", "Name", "Alias", "SortOrder", "ToleranceMin",
    "DecimalPlaces", "Unit", "ToleranceMax", "MahalanobisLimit", "Bias",
    "Slope", "LimitMin", "LimitMax", "Target", "WavelengthRange",
    "PredictionType", "Argument1", "Argument2", "Argument3", "Argument4", "Argument5"
  )
  expect_named(object_metadata$metadata, model_metadata_names)
})

############################################
# Check the defaults of add_model_metadata:#
############################################


test_that("add_model_metadata defaults are named correctly", {
  model_metadata_names <- c(
    "Key", "Created", "Changed", "Name", "Alias", "SortOrder", "ToleranceMin",
    "DecimalPlaces", "Unit", "ToleranceMax", "MahalanobisLimit", "Bias",
    "Slope", "LimitMin", "LimitMax", "Target", "WavelengthRange",
    "PredictionType", "Argument1", "Argument2", "Argument3", "Argument4", "Argument5"
  )
  expect_named(add_model_metadata(), model_metadata_names)
})

test_that("add_model_metadata default 'Key' is a character", {
  # Key is generated randomly, so just check if it is a character.
  expect_type(add_model_metadata()$Key, "character")
})

test_that("add_model_metadata default 'Created' is correctly set up", {
  # Created is time-based, so just check if it is a character, contains T and
  # Dates/times.
  default_metadata <- add_model_metadata()
  expect_type(default_metadata$Created, "character")
  expect_true(grepl("T", default_metadata$Created))
  expect_s3_class(as.POSIXct(gsub("T", " ", default_metadata$Created)), c("POSIXct", "POSIXt"))
})

test_that("add_model_metadata default 'Changed' is correctly set up", {
  # Changed are time-based, so just check if it is a character, contains T and
  # Dates/times, and the number of digits.
  default_metadata <- add_model_metadata()
  expect_type(default_metadata$Changed, "character")
  expect_true(grepl("T", default_metadata$Changed))
  expect_s3_class(as.POSIXct(gsub("T", " ", default_metadata$Changed)), c("POSIXct", "POSIXt"))
})

test_that("add_model_metadata default 'Name' is empty character", {
  expect_identical(add_model_metadata()$Name, "")
})

test_that("add_model_metadata default 'Alias' is NULL", {
  expect_null(add_model_metadata()$Alias)
})

test_that("add_model_metadata default 'SortOrder' is 1", {
  expect_true(add_model_metadata()$SortOrder == 1)
})

test_that("add_model_metadata default 'ToleranceMin'/'ToleranceMax' is NULL", {
  expect_null(add_model_metadata()$ToleranceMin)
  expect_null(add_model_metadata()$ToleranceMax)
})

test_that("add_model_metadata default 'DecimalPlace' is 2", {
  expect_true(add_model_metadata()$DecimalPlaces == 2)
})

test_that("add_model_metadata default 'Unit' is empty character", {
  expect_identical(add_model_metadata()$Unit, "")
})

test_that("add_model_metadata default 'MahalanobisLimit' is 5", {
  expect_true(add_model_metadata()$MahalanobisLimit == 5)
})

test_that("add_model_metadata default 'Bias' is 0", {
  expect_true(add_model_metadata()$Bias == 0)
})

test_that("add_model_metadata default 'Slope' is 1", {
  expect_true(add_model_metadata()$Slope == 1)
})

test_that("add_model_metadata default 'LimitMin'/'LimitMax' is NULL", {
  expect_null(add_model_metadata()$LimitMin)
  expect_null(add_model_metadata()$LimitMax)
})

test_that("add_model_metadata default 'Target' is NULL", {
  expect_null(add_model_metadata()$Target)
})

test_that("add_model_metadata default 'WavelengthRange' is 'Nir'", {
  expect_identical(add_model_metadata()$WavelengthRange, "Nir")
})

test_that("add_model_metadata default 'PredictionType' is 'CalibrationModel'", {
  expect_identical(add_model_metadata()$PredictionType, "CalibrationModel")
})

test_that("add_model_metadata default 'Argument1' is NULL", {
  expect_null(add_model_metadata()$Argument1)
})

test_that("add_model_metadata default 'Argument2' to 'Argument5' are empty characters", {
  default_metadata <- add_model_metadata()
  expect_identical(default_metadata$Argument2, "")
  expect_identical(default_metadata$Argument3, "")
  expect_identical(default_metadata$Argument4, "")
  expect_identical(default_metadata$Argument5, "")
})

test_that("add_model_metadata is of class 'model_metadata'", {
  expect_true(inherits(add_model_metadata(), "model_metadata"))
})

test_that("add_model_metadata is a list", {
  expect_type(add_model_metadata(), "list")
})

##########################
# Check vector arguments #
##########################

test_that("add_model_metadata 'name' of length two changes 'Alias'", {
  some_metadata <- add_model_metadata(name = c("a_name", "an_alias"))
  expect_identical(some_metadata$Name, "a_name")
  expect_identical(some_metadata$Alias, "an_alias")
})

test_that("add_model_metadata 'corrections' of length two changes bias and slope", {
  some_other_metadata <- add_model_metadata(corrections = c(1, 5))
  expect_identical(some_other_metadata$Bias, 1)
  expect_identical(some_other_metadata$Slope, 5)
})

test_that("The parameter 'arguments' is correctly capped at length 5", {
  s_metadata <- add_model_metadata(arguments = c("1", "2", "3", "4", "5", "6"))
  expect_null(s_metadata$Argument6)
})

test_that("The parameter 'arguments' is correctly extended to length 5", {
  s_metadata2 <- add_model_metadata(arguments = c("1", "2"))
  expect_identical(s_metadata2$Argument2, "1")
  expect_identical(s_metadata2$Argument3, "2")
  expect_identical(s_metadata2$Argument4, "")
  expect_identical(s_metadata2$Argument5, "")
})

##########################
# Sanity checks testing: #
##########################

test_that("add_model_metadata 'object' argument must be of class 'spectral_model'", {
  expect_error(
    add_model_metadata(object = 1),
    "If provided, parameter 'object' must be of class 'spectral_model'."
  )
})

test_that("add_model_metadata 'key' argument must be character", {
  expect_error(add_model_metadata(key = 1), "Parameter 'key' has to be a character")
})

test_that("add_model_metadata 'created'/'changed' arguments must be character", {
  expect_error(add_model_metadata(created = 1), "The parameters 'created' and 'change' must be characters")
})

test_that("add_model_metadata 'created'/'changed' should contain a 'T'", {
  expect_warning(add_model_metadata(changed = "1"))
})

test_that("add_model_metadata 'name' must be a character", {
  expect_error(add_model_metadata(name = 1))
})

test_that("add_model_metadata 'sort_order' must be numerical", {
  expect_error(add_model_metadata(sort_order = ""), "Parameter 'sort_order' has to be a numeric")
})

test_that("add_model_metadata 'tol_min' and 'tol_max' must be numeric or NULL", {
  expect_error(add_model_metadata(tol_min = ""), "Parameter 'tol_min' has to be a numeric or 'NULL'")
  expect_error(add_model_metadata(tol_max = ""), "Parameter 'tol_max' has to be a numeric or 'NULL'")
})

test_that("add_model_metadata 'decimal_places' must be a numberic", {
  expect_error(add_model_metadata(decimal_places = ""), "Parameter 'decimal_places' has to be a numeric")
})

test_that("add_model_metadata 'unit' must be a character", {
  expect_error(add_model_metadata(unit = 1), "Parameter 'unit' has to be a character")
})

test_that("add_model_metadata 'mahal_limit' must be a numeric", {
  expect_error(add_model_metadata(mahal_limit = ""), "Parameter 'mahal_limit' has to be a numeric")
})

test_that("add_model_metadata 'corrections' must be a vector of numerics with length 2", {
  msg <- "Invalid bias and slope correction parameter 'corrections'. Has to be a vector of numerics of length 2"
  expect_error(add_model_metadata(corrections = c("", "")), msg)
  expect_error(add_model_metadata(corrections = 1), msg)
})

test_that("add_model_metadata 'limit_min' and 'limit_max' must be numerics or NULL", {
  expect_error(add_model_metadata(limit_min = ""), "Parameter 'limit_min' has to be a numeric or 'NULL'.")
  expect_error(add_model_metadata(limit_max = ""), "Paramter 'limit_max' has to be a numeric or 'NULL'.")
})

test_that("add_model_metadata 'target' must be a character or NULL", {
  expect_error(add_model_metadata(target = 1), "Parameter 'target' has to be either a character or 'NULL'.")
})

test_that("add_model_metadata 'wavelength_range' must be one of 'Nir', 'Vis', 'Nir+Vis'", {
  expect_error(add_model_metadata(wavelength_range = ""))
})

test_that("add_model_metadata 'predict_type' must be 'Calibration'", {
  expect_error(add_model_metadata(predict_type = ""), "Parameter 'predict_type' has to be one of 'Calibration', ... ")
})
