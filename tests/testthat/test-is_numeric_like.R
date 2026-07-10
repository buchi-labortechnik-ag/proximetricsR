test_that("Numbers are numeric like", {
  expect_true(is_numeric_like(pi))
})

test_that("Integers are numeric like", {
  expect_true(is_numeric_like(5L))
})

test_that("NA values are not numeric like", {
  expect_true(!is_numeric_like(NA))
})

test_that("Characters with numerics only are numeric like", {
  expect_true(is_numeric_like("5.2"))
})

test_that("Integer given as characters are numeric like", {
  expect_true(is_numeric_like("5L"))
})

test_that("String with letters (expect L with a single number) are not numeric like", {
  expect_true(!is_numeric_like("3i"))
  expect_true(!is_numeric_like("L"))
})

test_that("NA strings are correctly identified", {
  expect_true(!is_numeric_like("NA"))
})

test_that("Numbers with an 'e' for exponentials are recognized", {
  expect_true(is_numeric_like("1e5"))
})

test_that("Negative numbers are numeric like", {
  expect_true(is_numeric_like("-5.2"))
})

test_that("Numbers with several decimal points are not numeric like", {
  expect_true(!is_numeric_like("5.5.5"))
})
