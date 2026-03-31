test_that("klist creates a klist", {
  x <- klist(a = 1, 2, b = 3)
  expect_s3_class(x, "klist")
  expect_true(is.klist(x))
})

test_that("klist throws an error if any klist elements are duplicates", {
  expect_no_error(klist(1, b = 2))
  expect_no_error(klist(list()))
  expect_error(klist(a = 1, 2, a = 1))
  expect_error(klist(a = klist(1, b = 2, b = 3), b = 2))
})

test_that("klist validation only applies to klist inputs", {
  expect_no_error(klist(a = list(x = 1, x = 2), b = 2))
  expect_error(klist(a = klist(x = 1, x = 2)))
})

test_that("klist accepts single NA or multiple empty names", {
  x <- klist(x = 1, y = 2)
  expect_no_error(setNames(x, c("", "")))
  y <- klist(x = 1)
  expect_no_error(setNames(y, NA))
  expect_error(setNames(y, c(NA, NA)))
})

test_that("as.klist doesn't recurse as default", {
  x <- list(1, list(a = 1, a = 2))
  expect_no_error(as.klist(x))
  expect_false(inherits(x[[2]], "klist"))
})

test_that("as.klist recursively validates and converts to klist", {
  x <- list(1, list(a = 1, a = 2))
  expect_error(as.klist(x, .recursive = TRUE))
  names(x[[2]]) <- NULL
  expect_no_error(x <- as.klist(x, .recursive = TRUE))
  expect_s3_class(x[[2]], "klist")
})

test_that("as.list removes klist class", {
  x <- klist(a = 1, b = 2)
  y <- as.list(x)
  expect_false(inherits(y, "klist"))
  expect_equal(y, list(a = 1, b = 2))
})

test_that("'[' extraction returns klist", {
  x <- klist(a = 1, b = 2, c = 3)
  y <- x[1:2]
  expect_s3_class(y, "klist")
})

test_that("names<- applies klist logic", {
  x <- klist(a = 1, b = 2)
  expect_error(names(x) <- c("a", "a"))
  expect_no_error(names(x) <- NULL)
  expect_no_error(names(x) <- c("", ""))
})

test_that("c() method for klist objects validates", {
  x <- klist(a = 1)
  expect_error(c(x, 1, list(a = 2), 2))
  expect_no_error(c(x, 1, list(b = 2), 2))
  expect_error(c(x, a = 1, list(2), 2))
  expect_no_error(c(x, 1, list(list(a = 2)), 2))
})
