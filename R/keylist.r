#' Create a List With Unique Keys
#'
#' @description
#' Create a list with unique keys (either fully named, [knlist], or a
#' mix of named and unnamed, [klist]), erroring if duplicate keys are found.
#' @param ...
#' for `keylist`: objects, possibly named, for `as.keylist`: passed to other
#' methods.
#' @param .named
#' boolean indicating whether the list should be fully named or not.
#' If `TRUE` then all elements must be named and unique, if `FALSE` then
#' names are not required but if they are present they must be unique.
#' @param x
#' object to be coerced or tested.
#' @param .recursive
#' boolean indicating whether to recursively validate nested lists.
#' If `TRUE` then all nested lists will be validated and converted to
#' keylists, if `FALSE` then only the top level list will be validated
#' and converted to a keylist.
#' @param klst
#' passed to [append]: the keylist to which the values are to be appended.
#' @param values
#' passed to [append]: the values to be included in the modified keylist.
#' @param after
#' passed to [append]: a subscript, after which the values are to be appended.
#' @details
#' `keylist()` creates one of the two keylist objects: [`klist`] or [`knlist`],
#' depending on the value of the `.named` argument. Those methods are
#' generally preferred as they are more explicit.
#'
#' `is.keylist()` checks if an object inherits from either `klist` or `knlist`.
#'
#' `keylist.append()` applies [append] to a keylist and validates the result
#' depending on whether the input was a `klist` or `knlist`.
#'
#' keylist objects accept any R object as elements, but the keys must be
#' unique. The key validation is done at the top level, so nested lists
#' are not validated unless they are also keylists. To recursively turn
#' a nested list structure into keylists, use
#' `as.keylist(x, .recursive = TRUE)` or one of the lower level variants.
#' @seealso
#' [klist] and [knlist].
#' @note
#' keylists compare names using C's `strcmp` function.
#' @returns
#' A list of class `klist` or `knlist`. For `is.keylist()` a boolean.
#' @examples
#' keylist(a = 1, 2, b = 3) # default is a klist
#' try(keylist(1, a = 2, a = 1)) # duplicate keys not allowed
#'
#' x <- keylist(a = 1, b = 2, .named = TRUE) # create a knlist
#' try(keylist(1, b = 2, .named = TRUE)) # unnamed keys not allowed
#' try(x[[1]] <- 1) # knlist only accepts character indexing for assignment
#'
#' # objects within a keylist are not subject to validation
#' keylist(1, list(a = 1, a = 2))
#' try(keylist(1, keylist(a = 1, a = 2))) # but nested keylists are
#'
#' # recursively validate and convert to keylist
#' x <- list(1, list(1, 2))
#' x <- as.keylist(x, .recursive = TRUE)
#' class(x[[2]]) # nested list is now a keylist
#'
#' is.keylist(klist(1)) && is.keylist(knlist(a = 1)) # TRUE
#'
#' keylist.append(klist(a = 1), list(2, b = 3)) # append to a klist
#' # c() method for keylist objects also validates
#' try(c(keylist(a = 1), list(a = 3)))
#' @export
keylist <- function(..., .named = FALSE) {
  if (isTRUE(.named)) {
    knlist(...)
  } else {
    klist(...)
  }
}

#' @rdname keylist
#' @export
is.keylist <- function(x) inherits(x, c("klist", "knlist"))

#' @rdname keylist
#' @export
as.keylist <- function(x, ...) {
  UseMethod("as.keylist", x)
}

#' @rdname keylist
#' @export
as.keylist.default <- function(x, ..., .named = FALSE, .recursive = FALSE) {
  if (isTRUE(.named)) {
    as.knlist(x, ..., .recursive = .recursive)
  } else {
    as.klist(x, ..., .recursive = .recursive)
  }
}

#' @rdname keylist
#' @export
keylist.append <- function(klst, values, after = length(klst)) {
  if (!is.keylist(klst)) {
    stop("Only keylist objects can be appended to.")
  }
  cl <- which(c("klist", "knlist") %in% class(klst))
  if (length(cl) > 1) {
    stop("Object cannot be both a klist and a knlist.")
  }

  x <- append(klst, values, after = after)

  switch(cl,
    .Call(validate_klist_node_c, x),
    .Call(validate_knlist_node_c, x)
  )
}
