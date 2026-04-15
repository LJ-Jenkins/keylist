# Create a List With Unique Keys (Named or Unnamed)

Create a named/unnamed list with unique keys, erroring if any duplicate
keys (names) are found.

## Usage

``` r
klist(...)

is.klist(x)

as.klist(x, ...)

# Default S3 method
as.klist(x, ..., .recursive = FALSE)

# S3 method for class 'klist'
names(x) <- value

# S3 method for class 'klist'
c(...)
```

## Arguments

- ...:

  for `klist`: objects, possibly named, for `as.klist`: passed to other
  methods.

- x:

  object to be coerced or tested.

- .recursive:

  boolean indicating whether to recursively validate nested lists. If
  `TRUE` then all nested lists will be validated and converted to
  klists, if `FALSE` then only the top level list will be validated and
  converted to a klist.

- value:

  a character vector of up to the same length as x, or NULL. Resulting
  names must be unique.

## Value

A list object of class `klist`. For `is.klist()` a boolean.

## Details

`names<-` method for `klist` objects will apply the names and then
validate that the resulting names are unique.

`c.klist` method will combine the objects and then validate that the
resulting klist's names are unique.

For a list with unique keys of all names, see
[knlist](https://lj-jenkins.github.io/keylist/reference/knlist.md).

## Note

klists compare names using C's `strcmp` function.

[as.list](https://rdrr.io/r/base/list.html) and
[as.vector](https://rdrr.io/r/base/vector.html) methods for klist
objects remove the class and return a base R list or vector.

## See also

[knlist](https://lj-jenkins.github.io/keylist/reference/knlist.md) and
[keylist](https://lj-jenkins.github.io/keylist/reference/keylist.md).

## Examples

``` r
klist(a = 1, 2, b = 3)
#> <keylist::klist>
#> $a
#> [1] 1
#> 
#> [[2]]
#> [1] 2
#> 
#> $b
#> [1] 3
#> 
try(klist(1, a = 2, a = 1)) # duplicate keys not allowed
#> Error in klist(1, a = 2, a = 1) : Names must be unique.
#> Duplicate names: a

# objects within a klist are not subject to validation
klist(1, list(a = 1, a = 2))
#> <keylist::klist>
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
try(klist(1, klist(a = 1, a = 2))) # but nested klists are
#> Error in klist(a = 1, a = 2) : Names must be unique.
#> Duplicate names: a

# recursively validate and convert to klist
x <- list(1, list(1, 2))
x <- as.klist(x, .recursive = TRUE)
class(x[[2]]) # nested list is now a klist
#> [1] "klist"

is.klist(klist(1)) # TRUE
#> [1] TRUE

try(names(x) <- c("a", "a")) # names are validated when changed
#> Error in `names<-.klist`(`*tmp*`, value = c("a", "a")) : 
#>   Names must be unique.
#> Duplicate names: a

# c() method for klist objects also validates
try(c(klist(a = 1), list(a = 3)))
#> Error in c.klist(klist(a = 1), list(a = 3)) : Names must be unique.
#> Duplicate names: a
```
