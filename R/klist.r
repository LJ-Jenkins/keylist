#' Create a List With Unique Keys (Named or Unnamed)
#'
#' @description
#' Create a named/unnamed list with unique keys, erroring if any duplicate
#' keys (names) are found.
#' @param ...
#' for `klist`: objects, possibly named, for `as.klist`: passed to other
#' methods.
#' @param x
#' object to be coerced or tested.
#' @param .recursive
#' boolean indicating whether to recursively validate nested lists.
#' If `TRUE` then all nested lists will be validated and converted to
#' klists, if `FALSE` then only the top level list will be validated
#' and converted to a klist.
#' @param value
#' a character vector of up to the same length as x, or NULL. Resulting names
#' must be unique.
#' @details
#' `names<-` method for `klist` objects will apply the names and then validate
#' that the resulting names are unique.
#'
#' `c.klist` method will combine the objects and then validate that the
#' resulting klist's names are unique.
#'
#' For a list with unique keys of all names, see [knlist].
#' @seealso
#' [knlist], [keylist].
#' @note
#' klists compare names using C's `strcmp` function.
#' @return
#' A list object of class `klist`. For `is.klist()` a boolean.
#' @examples
#' klist(a = 1, 2, b = 3)
#' try(klist(1, a = 2, a = 1)) # duplicate keys not allowed
#'
#' # objects within a klist are not subject to validation
#' klist(1, list(a = 1, a = 2))
#' try(klist(1, klist(a = 1, a = 2))) # but nested klists are
#'
#' # recursively validate and convert to klist
#' x <- list(1, list(1, 2))
#' x <- as.klist(x, .recursive = TRUE)
#' class(x[[2]]) # nested list is now a klist
#'
#' is.klist(klist(1)) # TRUE
#'
#' try(names(x) <- c("a", "a")) # names are validated when changed
#'
#' # c() method for klist objects also validates
#' try(c(klist(a = 1), list(a = 3)))
#' @export
klist <- function(...) {
  .Call(validate_klist_node_c, list(...))
}

#' @rdname klist
#' @export
is.klist <- function(x) inherits(x, "klist")

#' @rdname klist
#' @export
as.klist <- function(x, ...) {
  UseMethod("as.klist")
}

#' @rdname klist
#' @export
as.klist.default <- function(x, ..., .recursive = FALSE) {
  x <- as.list(x)
  if (isTRUE(.recursive)) {
    .Call(validate_klist_list_c, x)
  } else {
    .Call(validate_klist_node_c, x)
  }
}

#' @export
as.klist.list <- function(x, ..., .recursive = FALSE) {
  if (isTRUE(.recursive)) {
    .Call(validate_klist_list_c, x)
  } else {
    .Call(validate_klist_node_c, x)
  }
}

#' @export
as.list.klist <- function(x, ...) {
  class(x) <- setdiff(class(x), "klist")
  x
}

#' @export
print.klist <- function(x, ...) {
  x <- as.list(x) # to get rid of the class attr
  NextMethod()
}

# character and numeric indexing so base list methods fine.

# no need to offer <- methods as after creation the
# assigning into list is always preferred whether named or not.
# e.g., x[3] <- list(name = 1) will be unnamed even
# if didn't exist prior.
# Therefore no dupluicates can be created.

# force class to be retained after [ extraction, so that when
# list elements are extracted they are still klist objects.
# [[ and $ extract the value not the container so not required.

#' @export
"[.klist" <- function(x, i, value) {
  x <- NextMethod()
  .Call(if_list_force_class, x, "klist")
}

# this will cause setNames to change too

#' @rdname klist
#' @export
"names<-.klist" <- function(x, value) {
  x <- NextMethod()
  .Call(validate_klist_node_c, x)
}

#' @rdname klist
#' @export
c.klist <- function(...) {
  x <- NextMethod()
  .Call(validate_klist_node_c, as.list(x))
}
