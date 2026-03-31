#include <R.h>
#include <Rinternals.h>
#include "utils.h"

SEXP validate_klist_node_c(SEXP x)
{
    SEXP names = getAttrib(x, R_NamesSymbol);
    if (names != R_NilValue)
    {
        klist_unique_names(names);
    }

    setAttrib(x, R_ClassSymbol, Rf_mkString("klist"));

    return x;
}

SEXP validate_klist_list_c(SEXP x)
{
    if (TYPEOF(x) != VECSXP)
    {
        return x;
    }

    validate_klist_node_c(x);

    R_xlen_t n = XLENGTH(x);
    for (R_xlen_t i = 0; i < n; i++)
    {
        validate_klist_list_c(VECTOR_ELT(x, i));
    }

    setAttrib(x, R_ClassSymbol, Rf_mkString("klist"));

    return x;
}