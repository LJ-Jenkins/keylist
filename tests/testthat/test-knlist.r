test_that("knlist creates a knlist", {
  x <- knlist(a = 1, b = 2)
  expect_s3_class(x, "knlist")
  expect_true(is.knlist(x))
})

test_that("knlist throws an error if any knlist elements are unnamed", {
  expect_error(knlist(1, b = 2))
  expect_error(knlist(list()))
  expect_error(knlist(a = knlist(1), b = 2))
})

test_that("knlist throws an error if any elements are duplicated", {
  expect_error(knlist(a = 1, a = 2))
})

test_that("knlist only applies to knlist inputs", {
  expect_no_error(knlist(a = list(1), b = 2))
  expect_no_error(knlist(a = list(x = 1, x = 2)))
  expect_error(knlist(a = knlist(x = 1, x = 2)))
})

test_that("knlist doesn't accept NA or empty names", {
  x <- knlist(x = 1)
  expect_error(setNames(x, ""))
  x <- knlist(x = 1)
  expect_error(setNames(x, NA))
  x <- knlist(x = 1, y = 2)
  expect_error(names(x) <- c("a", "a"))
})

test_that("knlist only accepts character indexing for assignment", {
  x <- knlist(a = 1, b = 2)
  expect_error(x[[2]] <- 1)
  expect_error(x[2] <- 1)
})

test_that("as.knlist doesn't recurse as default", {
  x <- list(a = 1, b = list(1, 2))
  expect_no_error(as.knlist(x))
  expect_false(inherits(x[[2]], "knlist"))
})


test_that("as.knlist recursively validates and converts to knlist", {
  x <- list(a = 1, list(a = 1, b = 2))
  expect_error(as.knlist(x, .recursive = TRUE))
  x <- setNames(x, c("a", "b"))
  expect_no_error(x <- as.knlist(x, .recursive = TRUE))
  expect_s3_class(x[[2]], "knlist")
})

test_that("as.list removes knlist class", {
  x <- knlist(a = 1, b = 2)
  y <- as.list(x)
  expect_false(inherits(y, "knlist"))
  expect_equal(y, list(a = 1, b = 2))
})

test_that("'[' extraction returns knlist", {
  x <- knlist(a = 1, b = 2, c = 3)
  y <- x[1:2]
  expect_s3_class(y, "knlist")
})

test_that("names<- applies knlist logic", {
  x <- knlist(a = 1, b = 2)
  expect_error(names(x) <- c("a", "a"))
  expect_error(names(x) <- NULL)
  expect_error(names(x) <- c("", ""))
  expect_no_error(names(x) <- c("x", "y"))
})

test_that("c() method for knlist objects validates", {
  x <- knlist(a = 1)
  expect_error(c(x, b = 1, list(a = 2), x = 2))
  expect_error(c(x, a = 1, list(x = 2), y = 2))
  expect_error(c(x, b = 1, list(2), x = 2))
  expect_no_error(c(x, b = 1, list(x = 2), y = 2))
  expect_error(c(x, b = 1, list(list(a = 2)), x = 2))
  expect_no_error(c(x, b = 1, list(z = list(a = 2)), x = 2))
})
