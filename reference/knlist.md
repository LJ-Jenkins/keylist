# Create a List With Unique Named Keys

Create a list with unique names/keys, erroring if any duplicate
names/keys are found.

## Usage

``` r
knlist(...)

is.knlist(x)

as.knlist(x, ...)

# Default S3 method
as.knlist(x, ..., .recursive = FALSE)

# S3 method for class 'knlist'
names(x) <- value

# S3 method for class 'knlist'
c(...)
```

## Arguments

- ...:

  for `knlist`: named objects, for `as.knlist`: passed to other methods.

- x:

  object to be coerced or tested.

- .recursive:

  boolean indicating whether to recursively validate nested lists. If
  `TRUE` then all nested lists will be validated and converted to
  knlists, if `FALSE` then only the top level list will be validated and
  converted to a knlist.

- value:

  a character vector the same length as x. Resulting names must be
  unique.

## Value

A list object of class `knlist`. For `is.knlist()` a boolean.

## Details

`names<-` method for `knlist` objects will apply the names and then
validate that the resulting names are unique.

`c.knlist` method will combine the objects and then validate that the
resulting knlist's names are unique.

For a list with unique keys of names and indexes, see
[klist](https://lj-jenkins.github.io/keylist/reference/klist.md).

## Note

knlists compare names using C's `strcmp` function.

## See also

[klist](https://lj-jenkins.github.io/keylist/reference/klist.md),
[keylist](https://lj-jenkins.github.io/keylist/reference/keylist.md).

## Examples

``` r
x <- knlist(a = 1, b = 2, c = 3)
try(knlist(b = 1, a = 2, a = 1)) # duplicate keys not allowed
#> Error in knlist(b = 1, a = 2, a = 1) : Names must be unique.
#> Duplicate names: a
try(x[[1]] <- 1) # knlist only accepts character indexing for assignment
#> Error : Only character indexing is allowed for assignment into knlist objects

# objects within a knlist are not subject to validation
knlist(x = 1, y = list(a = 1, a = 2))
#> $x
#> [1] 1
#> 
#> $y
#> $y$a
#> [1] 1
#> 
#> $y$a
#> [1] 2
#> 
#> 
try(knlist(x = 1, y = knlist(a = 1, a = 2))) # but nested knlists are
#> Error in knlist(a = 1, a = 2) : Names must be unique.
#> Duplicate names: a

# recursively validate and convert to knlist
x <- list(a = 1, b = list(x = 1, y = 2))
x <- as.knlist(x, .recursive = TRUE)
class(x[[2]]) # nested list is now a knlist
#> [1] "knlist"

is.knlist(knlist(a = 1)) # TRUE
#> [1] TRUE

try(names(x) <- c("a", "a")) # names are validated when changed
#> Error in `names<-.knlist`(`*tmp*`, value = c("a", "a")) : 
#>   Names must be unique.
#> Duplicate names: a

# c() method for knlist objects also validates
try(c(knlist(a = 1), list(a = 3)))
#> Error in c.knlist(knlist(a = 1), list(a = 3)) : Names must be unique.
#> Duplicate names: a
```
