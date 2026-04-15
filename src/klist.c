#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>
#include "utils.h"

SEXP validate_klist_node_c(SEXP x)
{
    SEXP names = PROTECT(Rf_getAttrib(x, R_NamesSymbol));
    if (names != R_NilValue)
    {
        klist_unique_names(names);
    }
    UNPROTECT(1);

    SEXP klass = PROTECT(Rf_mkString("klist"));
    Rf_setAttrib(x, R_ClassSymbol, klass);
    UNPROTECT(1);

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

    SEXP klass = PROTECT(Rf_mkString("klist"));
    Rf_setAttrib(x, R_ClassSymbol, klass);
    UNPROTECT(1);

    return x;
}