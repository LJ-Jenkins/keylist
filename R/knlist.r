#' Create a List With Unique Named Keys
#'
#' @description
#' Create a list with unique names/keys, erroring if any duplicate
#' names/keys are found.
#' @param ...
#' for `knlist`: named objects, for `as.knlist`: passed to other
#' methods.
#' @param x
#' object to be coerced or tested.
#' @param .recursive
#' boolean indicating whether to recursively validate nested lists.
#' If `TRUE` then all nested lists will be validated and converted to
#' knlists, if `FALSE` then only the top level list will be validated
#' and converted to a knlist.
#' @param value
#' a character vector the same length as x. Resulting names
#' must be unique.
#' @details
#' `names<-` method for `knlist` objects will apply the names and then validate
#' that the resulting names are unique.
#'
#' `c.knlist` method will combine the objects and then validate that the
#' resulting knlist's names are unique.
#'
#' For a list with unique keys of names and indexes, see [klist].
#' @seealso
#' [klist], [keylist].
#' @note
#' knlists compare names using C's `strcmp` function.
#' @return
#' A list object of class `knlist`. For `is.knlist()` a boolean.
#' @examples
#' x <- knlist(a = 1, b = 2, c = 3)
#' try(knlist(b = 1, a = 2, a = 1)) # duplicate keys not allowed
#' try(x[[1]] <- 1) # knlist only accepts character indexing for assignment
#'
#' # objects within a knlist are not subject to validation
#' knlist(x = 1, y = list(a = 1, a = 2))
#' try(knlist(x = 1, y = knlist(a = 1, a = 2))) # but nested knlists are
#'
#' # recursively validate and convert to knlist
#' x <- list(a = 1, b = list(x = 1, y = 2))
#' x <- as.knlist(x, .recursive = TRUE)
#' class(x[[2]]) # nested list is now a knlist
#'
#' is.knlist(knlist(a = 1)) # TRUE
#'
#' try(names(x) <- c("a", "a")) # names are validated when changed
#'
#' # c() method for knlist objects also validates
#' try(c(knlist(a = 1), list(a = 3)))
#' @export
knlist <- function(...) {
  .Call(validate_knlist_node_c, list(...))
}

#' @rdname knlist
#' @export
is.knlist <- function(x) inherits(x, "knlist")

#' @rdname knlist
#' @export
as.knlist <- function(x, ...) {
  UseMethod("as.knlist")
}

#' @rdname knlist
#' @export
as.knlist.default <- function(x, ..., .recursive = FALSE) {
  x <- as.list(x, ...)
  if (isTRUE(.recursive)) {
    .Call(validate_knlist_list_c, x)
  } else {
    .Call(validate_knlist_node_c, x)
  }
}

#' @export
as.knlist.list <- function(x, ..., .recursive = FALSE) {
  if (isTRUE(.recursive)) {
    .Call(validate_knlist_list_c, x)
  } else {
    .Call(validate_knlist_node_c, x)
  }
}

#' @export
as.list.knlist <- function(x, ...) {
  class(x) <- setdiff(class(x), "knlist")
  x
}

#' @export
print.knlist <- function(x, ...) {
  x <- as.list(x) # to get rid of the class attr
  NextMethod()
}

# character indexing for assignment as we've forced named elements.
# Using chr's will also mean a duplicate could never be
# created from assignment.

# allow non-character indexing for non-assignment as will just return
# value, and allows RStudio viewer.

# force class to be retained after [ extraction, so that when
# container elements are extracted they are still knlist objects.
# [[ and $ extract the value not the container so not required.

stop_non_chr_assignment <- function(i) {
  if (!is.character(i)) {
    stop(
      "Only character indexing is allowed for assignment ",
      "into knlist objects",
      call. = FALSE
    )
  }
}

#' @export
"[.knlist" <- function(x, i, value) {
  x <- NextMethod()
  .Call(if_list_force_class, x, "knlist")
}

#' @export
"[<-.knlist" <- function(x, i, value) {
  stop_non_chr_assignment(i)
  NextMethod()
}

#' @export
"[[<-.knlist" <- function(x, i, value) {
  stop_non_chr_assignment(i)
  NextMethod()
}

# this will cause setNames to change too

#' @rdname knlist
#' @export
"names<-.knlist" <- function(x, value) {
  if (is.null(value)) {
    stop("Names cannot be removed from a knlist object.")
  }
  x <- NextMethod()
  .Call(validate_knlist_node_c, x)
}

#' @rdname knlist
#' @export
c.knlist <- function(...) {
  x <- NextMethod()
  .Call(validate_knlist_node_c, as.list(x))
}
