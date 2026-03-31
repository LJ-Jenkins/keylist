#include <R.h>
#include <Rinternals.h>

void knlist_unique_names(SEXP names)
{
    R_xlen_t n = XLENGTH(names);
    for (R_xlen_t i = 0; i < n; i++)
    {
        SEXP ni = STRING_ELT(names, i);

        if (ni == NA_STRING)
        {
            error("Names cannot be NA.");
        }

        const char *cname = CHAR(ni);
        if (cname[0] == '\0')
        {
            error("All elements must be named.");
        }

        for (R_xlen_t j = i + 1; j < n; j++)
        {
            SEXP nj = STRING_ELT(names, j);
            if (strcmp(cname, CHAR(nj)) == 0)
            {
                error("Names must be unique.\nDuplicate name: %s", cname);
            }
        }
    }
}

void klist_unique_names(SEXP names)
{
    R_xlen_t n = XLENGTH(names);
    int na_counter = 0;
    for (R_xlen_t i = 0; i < n; i++)
    {
        SEXP ni = STRING_ELT(names, i);

        if (ni == NA_STRING)
        {
            na_counter++;
            if (na_counter > 1)
            {
                error("Names must be unique.\nDuplicate name: NA");
            }
        }

        const char *cname = CHAR(ni);
        if (cname[0] == '\0')
        {
            continue;
        }

        for (R_xlen_t j = i + 1; j < n; j++)
        {
            SEXP nj = STRING_ELT(names, j);
            const char *cjname = CHAR(nj);
            if (cjname[0] == '\0')
            {
                continue;
            }
            if (strcmp(cname, cjname) == 0)
            {
                error("Names must be unique.\nDuplicate name: %s", cname);
            }
        }
    }
}

SEXP if_list_force_class(SEXP x, SEXP new_class)
{
    if (TYPEOF(x) == VECSXP)
    {
        setAttrib(x, R_ClassSymbol, new_class);
    }
    return x;
}