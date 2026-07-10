test_that("add_application_metadata does not change option 'digits.secs'", {
  original_secs <- getOption("digits.secs")
  a_metadata <- add_application_metadata()
  expect_identical(getOption("digits.secs"), original_secs)
})

test_that("add_application_metadata can be added to an object of class 'spectral_model' using object argument", {
  # Pretend to have a spectral_model object to avoid using function 'spectral_model' here
  empty_object <- list()
  empty_object$target_variable <- "target_variable"
  class(empty_object) <- c("spectral_model", "list")
  object_metadata <- add_application_metadata(object = list(empty_object))

  # Check the classes of object_metadata
  expect_type(object_metadata, "list")
  expect_s3_class(object_metadata[[1]], "spectral_model")
  # Check the classes of metadata inside object_metadata
  expect_type(object_metadata$metadata, "list")
  expect_s3_class(object_metadata$metadata, "application_metadata")
  # Check that the metadata is correctly setup in object_metadata
  expect_length(object_metadata, 2)
  expect_length(object_metadata$metadata, 18)
  expect_named(object_metadata[[1]], c("target_variable"))
  application_metadata_names <- c(
    "Key", "Name", "Alias", "ViewType", "MeasurementMode",
    "MeasurementTime", "AbsorbancemaskLowMax", "AbsorbancemaskLowMin",
    "AbsorbancemaskHighMax", "AbsorbancemaskHighMin", "RotateSample",
    "Selectable", "Created", "Changed", "Composition", "Description",
    "Sop", "SamplePresentationId"
  )
  expect_named(object_metadata$metadata, application_metadata_names)
})

##################################################
# Check the defaults of add_application_metadata:#
##################################################

test_that("add_application_metadata defaults are named correctly", {
  application_metadata_names <- c(
    "Key", "Name", "Alias", "ViewType", "MeasurementMode",
    "MeasurementTime", "AbsorbancemaskLowMax", "AbsorbancemaskLowMin",
    "AbsorbancemaskHighMax", "AbsorbancemaskHighMin", "RotateSample",
    "Selectable", "Created", "Changed", "Composition", "Description",
    "Sop", "SamplePresentationId"
  )
  expect_named(add_application_metadata(), application_metadata_names)
})

test_that("add_application_metadata defaults 'Key' is a character", {
  # Key is generated randomly, so just check if it is a character.
  expect_type(add_application_metadata()$Key, "character")
})

test_that("add_application_metadata default 'Name' is 'Untitled'", {
  expect_identical(add_application_metadata()$Name, "Untitled")
})

test_that("add_application_metadata default 'Alias' is NULL", {
  expect_null(add_application_metadata()$Alias)
})

test_that("add_application_metadata default 'ViewType' is 'Up'", {
  expect_identical(add_application_metadata()$ViewType, "Up")
})

test_that("add_application_metadata default 'MeasurementMode' is 'DrIwr'", {
  expect_identical(add_application_metadata()$MeasurementMode, "DrIwr")
})

test_that("add_application_metadata default 'MeasurementTime' is 15", {
  expect_identical(add_application_metadata()$MeasurementTime, 15)
})

test_that("add_application_metadata default Absorbancemasks are all 0", {
  default_metadata <- add_application_metadata()
  expect_true(default_metadata$AbsorbancemaskLowMax == 0)
  expect_true(default_metadata$AbsorbancemaskLowMin == 0)
  expect_true(default_metadata$AbsorbancemaskHighMax == 0)
  expect_true(default_metadata$AbsorbancemaskHighMin == 0)
})

test_that("add_application_metadata default 'RotateSample' and 'Selectable' are TRUE", {
  default_metadata <- add_application_metadata()
  expect_true(default_metadata$RotateSample)
  expect_true(default_metadata$Selectable)
})

test_that("add_application_metadata default 'Created' is correctly set up", {
  default_metadata <- add_application_metadata()
  # Created is time-based, so just check if it is a character, contains T and
  # Dates/times and the number of digits.
  expect_type(default_metadata$Created, "character")
  expect_true(grepl("T", default_metadata$Created))
  expect_s3_class(as.POSIXct(gsub("T", " ", default_metadata$Created)), c("POSIXct", "POSIXt"))
})

test_that("add_application_metadata default 'Changed' is correctly set up", {
  default_metadata <- add_application_metadata()
  # Changed are time-based, so just check if it is a character, contains T and
  # Dates/times, and the number of digits.
  expect_type(default_metadata$Changed, "character")
  expect_true(grepl("T", default_metadata$Changed))
  expect_s3_class(as.POSIXct(gsub("T", " ", default_metadata$Changed)), c("POSIXct", "POSIXt"))
})

test_that("add_application_metadata default 'Composition' is NULL", {
  expect_null(add_application_metadata()$Composition)
})

test_that("add_application_metadata default 'Description' mentions proximetricsR", {
  expect_identical(add_application_metadata()$Description, "created with proximetricsR")
})

test_that("add_application_metadata default 'Sop' is empty character", {
  expect_identical(add_application_metadata()$Sop, "")
})

test_that("add_application_metadata default 'SamplePresentationId' is 'Default'", {
  expect_identical(add_application_metadata()$SamplePresentationId, "Default")
})

test_that("add_application_metadata is of class 'application_metadata'", {
  expect_true(inherits(add_application_metadata(), "application_metadata"))
})

test_that("add_application_metadata is a list", {
  expect_type(add_application_metadata(), "list")
})

##########################
# Check vector arguments #
##########################

test_that("add_application_metadata 'name' of length two changes 'Alias'", {
  some_metadata <- add_application_metadata(name = c("a_name", "an_alias"))
  expect_identical(some_metadata$Name, "a_name")
  expect_identical(some_metadata$Alias, "an_alias")
})

test_that("add_application_metadata 'absorbmask_low' of length 2 changes its min and max", {
  some_other_metadata <- add_application_metadata(absorbmask_low = c(1, 2))
  expect_identical(some_other_metadata$AbsorbancemaskLowMin, 1)
  expect_identical(some_other_metadata$AbsorbancemaskLowMax, 2)
})

test_that("add_application_metadata 'absorbmask_high' of length 2 changes its min and max", {
  more_metadata <- add_application_metadata(absorbmask_high = c(2, 1))
  expect_identical(more_metadata$AbsorbancemaskHighMin, 2)
  expect_identical(more_metadata$AbsorbancemaskHighMax, 1)
})

##########################
# Sanity checks testing: #
##########################

test_that("add_application_metadata 'object' argument must be a list", {
  expect_error(add_application_metadata(object = 1))
})

test_that("add_application_metadata 'object' argument must be of class 'spectral_model'", {
  expect_error(add_application_metadata(object = list(1)))
})

test_that("add_application_metadata 'key' argument must be character", {
  expect_error(add_application_metadata(key = 1), "Parameter 'key' has to be a character")
})

test_that("add_application_metadata 'name' must be a character", {
  expect_error(add_application_metadata(name = 1))
})

test_that("add_application_metadata 'view' must be one of 'Up' or 'Down'", {
  expect_error(add_application_metadata(view = "not_up"))
})

test_that("add_application_metadata 'measurement_mode' must be one of 'DrIwr' or 'TrIwr'", {
  expect_error(
    add_application_metadata(measurement_mode = "")
  )
})

test_that("add_application_metadata 'measurement_time' must be a numeric", {
  expect_error(add_application_metadata(measurement_time = ""), "Parameter 'measurement_time' has to be a numeric.")
})

test_that("add_application_metadata 'absorbmask_low' must be a vector of numerics", {
  expect_error(add_application_metadata(absorbmask_low = c("", "")), "Parameters for the absorbance masks have to be vectors of numerics.")
})

test_that("add_application_metadata 'absorbmask_low' must be a vector of length 2", {
  expect_error(add_application_metadata(absorbmask_low = c(1, 2, 3)), "Parameters for the absorbance masks have to be vectors of length 2.")
})

test_that("add_application_metadata 'absorbmask_high' must be a vector of numerics", {
  expect_error(add_application_metadata(absorbmask_high = c("", "")), "Parameters for the absorbance masks have to be vectors of numerics.")
})

test_that("add_application_metadata 'absorbmask_high' must be a vector of length 2", {
  expect_error(add_application_metadata(absorbmask_high = c(1, 2, 3)), "Parameters for the absorbance masks have to be vectors of length 2.")
})

test_that("add_application_metadata 'rotate_sample' must be a logical", {
  expect_error(add_application_metadata(rotate_sample = 1), "Parameter 'rotate_sample' has to be a logical.")
})

test_that("add_application_metadata 'selectable' must be a logical", {
  expect_error(add_application_metadata(selectable = 1), "Parameter 'selectable' has to be a logical.")
})

test_that("add_application_metadata 'created'/'changed' arguments must be character", {
  expect_error(add_application_metadata(created = 1), "The time for creation and change must both be a character.")
})

test_that("add_application_metadata 'created'/'changed' should contain a 'T'", {
  expect_warning(add_application_metadata(changed = "1"))
})

test_that("add_application_metadata 'composition' must be character or NULL", {
  expect_error(add_application_metadata(composition = 1), "Parameter 'composition' has to be either a character or 'NULL'.")
})

test_that("add_application_metadata 'description' must be character", {
  expect_error(add_application_metadata(description = 1), "Parameter 'description' has to be a character.")
})

test_that("add_application_metadata 'sop' must be a character", {
  expect_error(add_application_metadata(sop = 1), "Parameter 'sop' has to be a character.")
})

test_that("add_application_metadata 'presentation_id' must be a character", {
  expect_error(add_application_metadata(presentation = 1), "Paramter 'presentation_id' has to be a character.")
})
