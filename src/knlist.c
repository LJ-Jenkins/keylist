#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include "utils.h"

SEXP validate_knlist_node_c(SEXP x)
{
    SEXP names = Rf_getAttrib(x, R_NamesSymbol);
    if (names == R_NilValue)
    {
        Rf_error("All elements must be named.");
    }

    knlist_unique_names(names);
    Rf_setAttrib(x, R_ClassSymbol, Rf_mkString("knlist"));

    return x;
}

SEXP validate_knlist_list_c(SEXP x)
{
    if (TYPEOF(x) != VECSXP)
    {
        return x;
    }

    validate_knlist_node_c(x);

    R_xlen_t n = XLENGTH(x);
    for (R_xlen_t i = 0; i < n; i++)
    {
        validate_knlist_list_c(VECTOR_ELT(x, i));
    }

    Rf_setAttrib(x, R_ClassSymbol, Rf_mkString("knlist"));

    return x;
}