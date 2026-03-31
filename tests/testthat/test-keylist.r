test_that("klist creates a klist/knlist object", {
  x <- keylist(1)
  expect_s3_class(x, "klist")
  y <- keylist(a = 1, .named = TRUE)
  expect_s3_class(y, "knlist")
  expect_true(is.keylist(x))
  expect_true(is.keylist(y))
  expect_error(y[[2]] <- 1)
  expect_error(y[2] <- 1)
})

test_that("as.keylist doesn't recurse as default", {
  x <- list(1, list(a = 1, a = 2))
  expect_no_error(as.keylist(x))
  expect_false(inherits(x[[2]], "klist"))

  x <- list(a = 1, b = list(1, 2))
  expect_no_error(as.keylist(x, .named = TRUE))
  expect_false(inherits(x[[2]], "knlist"))
})

test_that("as.keylist recursively validates and converts to klist", {
  x <- list(1, list(a = 1, a = 2))
  expect_error(as.keylist(x, .recursive = TRUE))
  names(x[[2]]) <- NULL
  expect_no_error(x <- as.keylist(x, .recursive = TRUE))
  expect_s3_class(x[[2]], "klist")

  x <- list(a = 1, list(a = 1, b = 2))
  expect_error(as.keylist(x, .named = TRUE, .recursive = TRUE))
  x <- setNames(x, c("a", "b"))
  expect_no_error(x <- as.keylist(x, .named = TRUE, .recursive = TRUE))
  expect_s3_class(x[[2]], "knlist")
})

test_that("keylist.append appends elements correctly", {
  x <- keylist(1)
  y <- keylist(2)
  z <- keylist.append(x, y)
  expect_s3_class(z, "klist")
  expect_equal(length(z), 2)
})

test_that("keylist.append creates keylist even if values aren't a keylist", {
  z <- keylist.append(klist(1), list(2))
  expect_s3_class(z, "klist")
  expect_equal(length(z), 2)
  z <- keylist.append(klist(1), 1:10)
  expect_s3_class(z, "klist")
  expect_equal(length(z), 11)
})

test_that("keylist.append validates the resulting object", {
  x <- keylist(a = 1)
  expect_error(keylist.append(x, list(a = 2)))
  expect_error(keylist.append(x, c(a = 2)))
  expect_no_error(keylist.append(x, list(1)))
  expect_no_error(keylist.append(x, c(b = 1)))

  x <- keylist(a = 1, .named = TRUE)
  expect_error(keylist.append(x, list(a = 2)))
  expect_error(keylist.append(x, list(1)))
  expect_error(keylist.append(x, 1))
  expect_error(keylist.append(x, c(a = 2)))
  expect_no_error(keylist.append(x, c(b = 2)))
})
