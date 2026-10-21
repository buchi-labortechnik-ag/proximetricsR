# Tests for extract_property_names()

# -----------------------------------------------------------------------
# proxiscout_data branch
# -----------------------------------------------------------------------

make_proxiscout <- function(...) {
  x <- data.frame(..., check.names = FALSE, stringsAsFactors = FALSE)
  class(x) <- c("proxiscout_data", "data.frame")
  x
}

test_that("proxiscout_data: numeric, non-standard columns are returned as properties", {
  x <- make_proxiscout(
    id = c("A", "B"),
    sampleName = c("A", "B"),
    moisture = c(10, 20),
    protein = c(5, 6)
  )
  expect_equal(extract_property_names(x), c("moisture", "protein"))
})

test_that("proxiscout_data: internal .repetition_group column is excluded", {
  # .repetition_group is an internal, numeric bookkeeping column added by
  # proxiscout_read_data() and must not be treated as a property.
  x <- make_proxiscout(
    id = c("A", "B"),
    moisture = c(10, 20),
    ".repetition_group" = c(1L, 2L)
  )
  props <- extract_property_names(x)
  expect_false(".repetition_group" %in% props)
  expect_equal(props, "moisture")
})

test_that("proxiscout_data: exclusion of .repetition_group does not over-match similar names", {
  # The '.' in the exclusion pattern is escaped, so only the literal
  # .repetition_group column is dropped, not e.g. 'xrepetition_group'.
  x <- make_proxiscout(
    moisture = c(10, 20),
    "xrepetition_group" = c(3, 4),
    ".repetition_group" = c(1L, 2L)
  )
  props <- extract_property_names(x)
  expect_true("xrepetition_group" %in% props)
  expect_false(".repetition_group" %in% props)
})

test_that("proxiscout_data: standard metadata columns are excluded (various casing/separators)", {
  x <- make_proxiscout(
    ID = c("A", "B"),
    "sample name" = c("A", "B"),
    "Captured_At" = c("2024-01-01", "2024-01-02"),
    "device.id" = c("d1", "d2"),
    note = c("n1", "n2"),
    spc = c(1, 2),
    predictions = c(0.1, 0.2),
    moisture = c(10, 20)
  )
  expect_equal(extract_property_names(x), "moisture")
})

test_that("proxiscout_data: non-numeric candidate columns are dropped", {
  # A column that is neither excluded nor numeric (and not all-NA) is not a property.
  x <- make_proxiscout(
    moisture = c(10, 20),
    grade = c("high", "low")
  )
  expect_equal(extract_property_names(x), "moisture")
})

test_that("proxiscout_data: all-NA columns are kept as (numeric-like) properties", {
  x <- make_proxiscout(
    moisture = c(10, 20),
    fat = c(NA, NA)
  )
  expect_setequal(extract_property_names(x), c("moisture", "fat"))
})

# -----------------------------------------------------------------------
# proximate_data branch
# -----------------------------------------------------------------------

test_that("proximate_data: properties are the numeric columns between Reference and Begin", {
  x <- data.frame(
    ID = c("A", "B"),
    Reference = c("r1", "r2"),
    moisture = c(10, 20),
    protein = c(5, 6),
    Note = c("x", "y"),
    Begin = c(1, 2),
    End = c(3, 4),
    check.names = FALSE, stringsAsFactors = FALSE
  )
  class(x) <- c("proximate_data", "data.frame")
  expect_equal(extract_property_names(x), c("moisture", "protein"))
})

test_that("proximate_data: returns character(0) when Reference/Begin markers are missing", {
  x <- data.frame(a = c(1, 2), b = c(3, 4))
  class(x) <- c("proximate_data", "data.frame")
  expect_identical(extract_property_names(x), character(0))
})

# -----------------------------------------------------------------------
# default branch (neither class)
# -----------------------------------------------------------------------

test_that("default: returns numeric columns except spc", {
  x <- data.frame(
    moisture = c(10, 20),
    label = c("a", "b"),
    spc = c(1, 2)
  )
  expect_equal(extract_property_names(x), "moisture")
})

# -----------------------------------------------------------------------
# clean_property_names()
# -----------------------------------------------------------------------

test_that("clean_property_names: unsupported characters are replaced", {
  expect_equal(
    clean_property_names(
      c("Fat (%)", "Protein??????", "Moisture{{{{}}}}{}", "a/b:c;d#e,f", "a\tb"),
      notify = FALSE
    ),
    c("Fat_(%)", "Protein", "Moisture", "a_b_c_d_e_f", "a_b")
  )
})

test_that("clean_property_names: supported names are returned unchanged", {
  nms <- c("CBD", "CBD__total", ".repetition_group", "Fat_(%)", "pH-value", "")
  expect_silent(cleaned <- clean_property_names(nms))
  expect_identical(cleaned, nms)
})

test_that("clean_property_names: cleaning twice gives the same result", {
  cleaned <- clean_property_names(c("Fat (%)", "a?_b", " x "), notify = FALSE)
  expect_identical(clean_property_names(cleaned, notify = FALSE), cleaned)
})

test_that("clean_property_names: renamed properties are reported", {
  expect_message(clean_property_names("Fat (%)"), "'Fat (%)' -> 'Fat_(%)'", fixed = TRUE)
})

test_that("clean_property_names: names that collide or become empty raise an error", {
  expect_error(clean_property_names(c("Fat?", "Fat*"), notify = FALSE), "no longer unique")
  expect_error(clean_property_names(c("Fat", "Fat?"), notify = FALSE), "no longer unique")
  expect_error(clean_property_names("???", notify = FALSE), "only contain unsupported characters")
  # Names that were already duplicated before cleaning are not reported
  expect_identical(clean_property_names(c("CBD", "CBD")), c("CBD", "CBD"))
})
