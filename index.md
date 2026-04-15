# keylist

Lightweight `list` extensions that enforce unique keys, ensuring
predictable key-value access.

## Installation

Install the latest release of keylist from CRAN.

``` r
install.packages("keylist")
```

You can install the development version from GitHub.

``` r
# install.packages("pak")
pak::pak("LJ-Jenkins/keylist")
```

## Overview

keylist provides two lightweight keylist S3 classes `klist` and
`knlist`: extensions of `list` that enforce unique keys. `klist` accepts
both unnamed and named elements, while `knlist` only accepts named
elements.

`knlist` behaves similarly to Python dictionaries/dicts and can serve as
a more idiomatic R, copy-on-modify alternative without reference
semantics.

``` r
library(keylist)

# klist - unnamed or named (if names present, they must be unique).
klist(1, a = 2)
#> <keylist::klist>
#> [[1]]
#> [1] 1
#> 
#> $a
#> [1] 2
klist(1, a = 1, a = 2, b = 1, b = 2)
#> Error in `klist()`:
#> ! Names must be unique.
#> Duplicate names: a, b

# knlist - fully named and unique.
knlist(a = 1, b = 2)
#> <keylist::knlist>
#> $a
#> [1] 1
#> 
#> $b
#> [1] 2
knlist(1, b = 2)
#> Error in `knlist()`:
#> ! All elements must be named.
knlist(a = 1, a = 2, b = 1, b = 2)
#> Error in `knlist()`:
#> ! Names must be unique.
#> Duplicate names: a, b

# keylist as more general function.
class(keylist(1))
#> [1] "klist"
class(keylist(a = 1, .named = TRUE))
#> [1] "knlist"
```

As extensions to `list`, keylists can take any input list can. Inputs
lists are not validated as they are not keylists - keylist validation
operates on its own level so for validation of nested elements they must
also be keylists.

``` r
# input list separate entity.
keylist(1, list(a = 1, a = 1))
#> <keylist::klist>
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [[2]]$a
#> [1] 1
#> 
#> [[2]]$a
#> [1] 1

# each keylist validates its own level.
keylist(1, keylist(a = 1, a = 1))
#> Error in `klist()`:
#> ! Names must be unique.
#> Duplicate names: a
```

All nested elements of a list can be recursively turned into a keylist
when using one of the `as.*` variants.

``` r
x <- list(1, list(a = 1, a = 1))
as.keylist(x, .recursive = TRUE)
#> Error in `as.klist.list()`:
#> ! Names must be unique.
#> Duplicate names: a
```

## Assignment and Modification

Although lists in R can accept duplicate names, R preferentially chooses
the existing list’s name structure when it comes to assignment.
Therefore if you can guarantee that the keys are unique at creation,
there is no way of assigning a duplicate key using the normal R methods
of `[`, `[[` and `$`. See this example:

``` r
x <- list(1, a = 2, 3, b = 4)
x[1] <- list(x = 1)
x[1] # remains unnamed.
#> [[1]]
#> [1] 1

x["a"] <- list(x = 1)
x[2] # name remains 'a'.
#> $a
#> [1] 1

x[5] <- list(k = 10) # index 5 doesn't exist...
x[5] # yet still remains unnamed.
#> [[1]]
#> [1] 10
```

keylist makes use of the above by not implementing any special
validation tricks - it simply ensures the keys are unique upon creation
then let’s you go on your way.

However, assigning by position could enable a non-named element for a
`knlist`. To circumvent this (and to give a clearer definition of type),
`knlist` objects only allow assignment when the indexing is done by
name.

``` r
x <- knlist(a = 1)
x[[1]] <- 1
#> Error:
#> ! Only character indexing is allowed for assignment into knlist objects

# extraction by index is allowed.
x[[1]]
#> [1] 1
```

After creation, the main way that duplicate names may creep into lists
is with direct name editing with
[`names()`](https://rdrr.io/r/base/names.html) or with list
concatenation with [`c()`](https://rdrr.io/r/base/c.html). keylist
includes S3 methods for both `klist` and `knlist` for these functions to
ensure that duplicate keys are not added from these methods.

``` r
x <- klist(1, a = 1)
names(x) <- c("a", "a")
#> Error in `names<-.klist`:
#> ! Names must be unique.
#> Duplicate names: a

x <- knlist(a = 1)
# name removal allowed for klist, but not knlist.
names(x) <- NULL
#> Error in `names<-.knlist`:
#> ! Names cannot be removed from a knlist object.

# knlist doesn't accept "" or NA names (like klist does).
setNames(x, NA)
#> Error in `names<-.knlist`:
#> ! Names cannot be <NA>.

class(c(klist(1, a = 2), 2, list(3)))
#> [1] "klist"
c(klist(1, a = 2), a = 2, list(3))
#> Error in `c.klist()`:
#> ! Names must be unique.
#> Duplicate names: a
```

## Note

All name comparison is done using C’s `strcmp` function.

## Getting help

If you encounter a clear bug, please file an issue with a minimal
reproducible example on
[GitHub](https://github.com/LJ-Jenkins/keylist/issues).

## Code of Conduct

Please note that the keylist project is released with a [Contributor
Code of
Conduct](https://lj-jenkins.github.io/keylist/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.
