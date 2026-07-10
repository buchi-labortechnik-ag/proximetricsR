test_that("Modified pls fitting method is correctly saved", {
  mpls_m <- fit_plsr(15, "modified")
  expect_true(inherits(mpls_m, "fit_plsr"))
  expect_true(inherits(mpls_m, "fit_constructor"))
  expect_identical(mpls_m$type, "modified")
  expect_identical(mpls_m$ncomp, 15L)
})

test_that("Modified pls fitting type is displayed correctly", {
  mpls_m <- fit_plsr(15, "modified")
  expect_snapshot(print(mpls_m))
})

test_that("Standard pls fitting type is correctly saved", {
  pls_m <- fit_plsr(10, "standard")
  expect_true(inherits(pls_m, "fit_plsr"))
  expect_true(inherits(pls_m, "fit_constructor"))
  expect_identical(pls_m$type, "standard")
  expect_identical(pls_m$ncomp, 10L)
})

test_that("Standard pls fitting method is displayed correctly", {
  pls_m <- fit_plsr(10, "standard")
  expect_snapshot(print(pls_m))
})

test_that("NIRWise PLUS pls fitting method is correctly saved", {
  nwppls_m <- fit_plsr(5, "nwp")
  expect_true(inherits(nwppls_m, "fit_plsr"))
  expect_true(inherits(nwppls_m, "fit_constructor"))
  expect_identical(nwppls_m$type, "nwp")
  expect_identical(nwppls_m$ncomp, 5L)
})

test_that("NIRWise PLUS pls fitting method is displayed correctly", {
  nwppls_m <- fit_plsr(5, "nwp")
  expect_snapshot(print(nwppls_m))
})

test_that("Modified xls fitting method is correctly saved", {
  mxls_m <- fit_xlsr(15, "modified", min_w = 5, max_w = 10)
  expect_true(inherits(mxls_m, "fit_xlsr"))
  expect_true(inherits(mxls_m, "fit_constructor"))
  expect_identical(mxls_m$type, "modified")
  expect_identical(mxls_m$ncomp, 15L)
  expect_identical(mxls_m$min_w, 5L)
  expect_identical(mxls_m$max_w, 10L)
})

test_that("Modified xls fitting method is displayed correctly", {
  mxls_m <- fit_xlsr(15, "modified", min_w = 5, max_w = 10)
  expect_snapshot(print(mxls_m))
})

test_that("Standard xls fitting method is correctly saved", {
  xls_m <- fit_xlsr(10, "standard")
  expect_true(inherits(xls_m, "fit_xlsr"))
  expect_true(inherits(xls_m, "fit_constructor"))
  expect_identical(xls_m$type, "standard")
  expect_identical(xls_m$ncomp, 10L)
  expect_identical(xls_m$min_w, 3L)
  expect_identical(xls_m$max_w, 15L)
})

test_that("Standard xls fitting method is displayed correctly", {
  xls_m <- fit_xlsr(10, "standard")
  expect_snapshot(print(xls_m))
})

test_that("NIRWise PLUS xls fitting method is correctly saved", {
  nwpxls_m <- fit_xlsr(5, "nwp")
  expect_true(inherits(nwpxls_m, "fit_xlsr"))
  expect_true(inherits(nwpxls_m, "fit_constructor"))
  expect_identical(nwpxls_m$type, "nwp")
  expect_identical(nwpxls_m$ncomp, 5L)
  expect_identical(nwpxls_m$min_w, 3L)
  expect_identical(nwpxls_m$max_w, 15L)
})

test_that("NIRWise PLUS xls fitting method is displayed correctly", {
  nwpxls_m <- fit_xlsr(5, "nwp")
  expect_snapshot(print(nwpxls_m))
})

test_that("Unrecognized methods are printed correctly", {
  no_pls <- fit_plsr(5)
  no_pls$type <- "no_pls"
  expect_snapshot(print(no_pls))
})

test_that("Default fit method is 'nwp'", {
  expect_identical(fit_plsr(5)$type, "nwp")
  expect_identical(fit_xlsr(5)$type, "nwp")
})

#################
# Sanity checks #
#################

test_that("The number of components must be specified", {
  expect_error(fit_plsr(), "'ncomp' must be specified")
  expect_error(fit_xlsr(), "'ncomp' must be specified")
})

test_that("The number of components must be numerical", {
  expect_error(fit_plsr(""), "'ncomp' must be a single positive integer")
  expect_error(fit_plsr(ncomp = c(1, 2)), "'ncomp' must be a single positive integer")
  expect_error(fit_xlsr(""), "'ncomp' must be a single positive integer")
  expect_error(fit_xlsr(ncomp = c(1, 2)), "'ncomp' must be a single positive integer")
})

test_that("Type of the fitting method must be correct", {
  expect_error(fit_plsr(1, type = ""))
  expect_error(fit_xlsr(1, type = ""))
})

test_that("For xls, min_w must be numerical", {
  expect_error(fit_xlsr(1, min_w = ""), "'min_w' must be a single positive integer")
})

test_that("For xls, max_w must be numerical", {
  expect_error(fit_xlsr(1, max_w = ""), "'max_w' must be a single positive integer")
})

test_that("For xls, 'min_w' must be less than 'max_w'", {
  expect_error(fit_xlsr(1, min_w = 2, max_w = 1), "'min_w' must be less than 'max_w'")
})
