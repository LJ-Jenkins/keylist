#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

void knlist_unique_names(SEXP names)
{
    R_xlen_t n = Rf_xlength(names);

    // knlist doesn't accept NA or empties.
    for (R_xlen_t i = 0; i < n; i++)
    {
        SEXP ni = STRING_ELT(names, i);
        if (ni == NA_STRING)
            Rf_error("Names cannot be <NA>.");

        if (CHAR(ni)[0] == '\0')
            Rf_error("All elements must be named.");
    }

    SEXP dups = PROTECT(Rf_allocVector(STRSXP, n));
    int dup_count = 0;

    for (R_xlen_t i = 0; i < n; i++)
    {
        const char *cname = CHAR(STRING_ELT(names, i));

        for (R_xlen_t j = i + 1; j < n; j++)
        {
            if (strcmp(cname, CHAR(STRING_ELT(names, j))) == 0)
            {
                int already_dup = 0;
                for (int k = 0; k < dup_count; k++)
                {
                    if (strcmp(cname, CHAR(STRING_ELT(dups, k))) == 0)
                    {
                        already_dup = 1;
                        break;
                    }
                }
                if (!already_dup)
                    SET_STRING_ELT(dups, dup_count++, STRING_ELT(names, i));
                break;
            }
        }
    }

    if (dup_count > 0)
    {
        const char *prefix = "Names must be unique.\nDuplicate names: ";
        size_t total_len = strlen(prefix);

        for (int i = 0; i < dup_count; i++)
        {
            if (i > 0)
                total_len += 2; // ", "
            total_len += strlen(CHAR(STRING_ELT(dups, i)));
        }
        total_len += 1; // null terminator

        char *msg = (char *)R_alloc(total_len, sizeof(char));
        size_t used = 0;

        used += snprintf(msg + used, total_len - used, "%s", prefix); // write prefix

        for (int i = 0; i < dup_count; i++) // add duplicates
        {
            if (i > 0)
                used += snprintf(msg + used, total_len - used, "%s", ", ");

            used += snprintf(msg + used, total_len - used, "%s",
                             CHAR(STRING_ELT(dups, i)));
        }

        UNPROTECT(1);
        Rf_error("%s", msg);
    }
    UNPROTECT(1);
}

void klist_unique_names(SEXP names)
{
    R_xlen_t n = Rf_xlength(names);

    int na_count = 0;
    for (R_xlen_t i = 0; i < n; i++)
    {
        if (STRING_ELT(names, i) == NA_STRING)
            na_count++;
    }

    SEXP dups = PROTECT(Rf_allocVector(STRSXP, n));
    int dup_count = 0;

    for (R_xlen_t i = 0; i < n; i++)
    {
        SEXP ni = STRING_ELT(names, i);
        if (ni == NA_STRING)
            continue;
        if (CHAR(ni)[0] == '\0')
            continue;

        for (R_xlen_t j = i + 1; j < n; j++)
        {
            SEXP nj = STRING_ELT(names, j);
            if (nj == NA_STRING)
                continue;
            if (CHAR(nj)[0] == '\0')
                continue;

            if (strcmp(CHAR(ni), CHAR(nj)) == 0)
            {
                int already_dup = 0;
                for (int k = 0; k < dup_count; k++)
                {
                    if (strcmp(CHAR(ni), CHAR(STRING_ELT(dups, k))) == 0)
                    {
                        already_dup = 1;
                        break;
                    }
                }
                if (!already_dup)
                    SET_STRING_ELT(dups, dup_count++, ni);
                break;
            }
        }
    }

    if (na_count > 1 || dup_count > 0)
    {
        const char *prefix = "Names must be unique.\nDuplicate names: ";
        size_t total_len = strlen(prefix);

        if (na_count > 1)
        {
            total_len += 4; // "<NA>"
            if (dup_count > 0)
                total_len += 2; // ", "
        }

        for (int i = 0; i < dup_count; i++)
        {
            if (i > 0)
                total_len += 2; // ", "
            total_len += strlen(CHAR(STRING_ELT(dups, i)));
        }
        total_len += 1; // null terminator

        char *msg = (char *)R_alloc(total_len, sizeof(char));
        size_t used = 0;

        used += snprintf(msg + used, total_len - used, "%s", prefix); // write prefix

        if (na_count > 1) // add <NA> if needed
        {
            used += snprintf(msg + used, total_len - used, "%s", "<NA>");
            if (dup_count > 0)
                used += snprintf(msg + used, total_len - used, "%s", ", ");
        }

        for (int i = 0; i < dup_count; i++) // add duplicates
        {
            if (i > 0)
                used += snprintf(msg + used, total_len - used, "%s", ", ");

            used += snprintf(msg + used, total_len - used, "%s",
                             CHAR(STRING_ELT(dups, i)));
        }

        UNPROTECT(1);
        Rf_error("%s", msg);
    }
    UNPROTECT(1);
}

SEXP if_list_force_class(SEXP x, SEXP new_class)
{
    if (TYPEOF(x) == VECSXP)
    {
        Rf_setAttrib(x, R_ClassSymbol, new_class);
    }
    return x;
}