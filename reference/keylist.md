# Create a List With Unique Keys

Create a list with unique keys (either fully named,
[knlist](https://lj-jenkins.github.io/keylist/reference/knlist.md), or a
mix of named and unnamed,
[klist](https://lj-jenkins.github.io/keylist/reference/klist.md)),
erroring if duplicate keys are found.

## Usage

``` r
keylist(..., .named = FALSE)

is.keylist(x)

as.keylist(x, ...)

# Default S3 method
as.keylist(x, ..., .named = FALSE, .recursive = FALSE)

keylist.append(klst, values, after = length(klst))
```

## Arguments

- ...:

  for `keylist`: objects, possibly named, for `as.keylist`: passed to
  other methods.

- .named:

  boolean indicating whether the list should be fully named or not. If
  `TRUE` then all elements must be named and unique, if `FALSE` then
  names are not required but if they are present they must be unique.

- x:

  object to be coerced or tested.

- .recursive:

  boolean indicating whether to recursively validate nested lists. If
  `TRUE` then all nested lists will be validated and converted to
  keylists, if `FALSE` then only the top level list will be validated
  and converted to a keylist.

- klst:

  passed to [append](https://rdrr.io/r/base/append.html): the keylist to
  which the values are to be appended.

- values:

  passed to [append](https://rdrr.io/r/base/append.html): the values to
  be included in the modified keylist.

- after:

  passed to [append](https://rdrr.io/r/base/append.html): a subscript,
  after which the values are to be appended.

## Value

A list object of class `klist` or `knlist`. For `is.keylist()` a
boolean.

## Details

`keylist()` creates one of the two keylist objects:
[`klist`](https://lj-jenkins.github.io/keylist/reference/klist.md) or
[`knlist`](https://lj-jenkins.github.io/keylist/reference/knlist.md),
depending on the value of the `.named` argument. Those methods are
generally preferred as they are more explicit.

`is.keylist()` checks if an object inherits from either `klist` or
`knlist`.

`keylist.append()` applies [append](https://rdrr.io/r/base/append.html)
to a keylist and validates the result depending on whether the input was
a `klist` or `knlist`.

keylist objects accept any R object as elements, but the keys must be
unique. The key validation is done at the top level, so nested lists are
not validated unless they are also keylists. To recursively turn a
nested list structure into keylists, use
`as.keylist(x, .recursive = TRUE)` or one of the lower level variants.

## Note

keylists compare names using C's `strcmp` function.

## See also

[klist](https://lj-jenkins.github.io/keylist/reference/klist.md) and
[knlist](https://lj-jenkins.github.io/keylist/reference/knlist.md).

## Examples

``` r
keylist(a = 1, 2, b = 3) # default is a klist
#> $a
#> [1] 1
#> 
#> [[2]]
#> [1] 2
#> 
#> $b
#> [1] 3
#> 
try(keylist(1, a = 2, a = 1)) # duplicate keys not allowed
#> Error in klist(...) : Names must be unique.
#> Duplicate names: a

x <- keylist(a = 1, b = 2, .named = TRUE) # create a knlist
try(keylist(1, b = 2, .named = TRUE)) # unnamed keys not allowed
#> Error in knlist(...) : All elements must be named.
try(x[[1]] <- 1) # knlist only accepts character indexing for assignment
#> Error : Only character indexing is allowed for assignment into knlist objects

# objects within a keylist are not subject to validation
keylist(1, list(a = 1, a = 2))
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [[2]]$a
#> [1] 1
#> 
#> [[2]]$a
#> [1] 2
#> 
#> 
try(keylist(1, keylist(a = 1, a = 2))) # but nested keylists are
#> Error in klist(...) : Names must be unique.
#> Duplicate names: a

# recursively validate and convert to keylist
x <- list(1, list(1, 2))
x <- as.keylist(x, .recursive = TRUE)
class(x[[2]]) # nested list is now a keylist
#> [1] "klist"

is.keylist(klist(1)) && is.keylist(knlist(a = 1)) # TRUE
#> [1] TRUE

keylist.append(klist(a = 1), list(2, b = 3)) # append to a klist
#> $a
#> [1] 1
#> 
#> [[2]]
#> [1] 2
#> 
#> $b
#> [1] 3
#> 
# c() method for keylist objects also validates
try(c(keylist(a = 1), list(a = 3)))
#> Error in c.klist(keylist(a = 1), list(a = 3)) : Names must be unique.
#> Duplicate names: a
```
