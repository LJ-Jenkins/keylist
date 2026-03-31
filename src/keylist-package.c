#define R_NO_REMAP
#include <R.h>
#include <Rinternals.h>

extern SEXP validate_knlist_list_c(SEXP x);
extern SEXP validate_knlist_node_c(SEXP x);
extern SEXP validate_klist_list_c(SEXP x);
extern SEXP validate_klist_node_c(SEXP x);
extern SEXP if_list_force_class(SEXP x, SEXP new_class);

static const R_CallMethodDef callMethods[] = {
    {"validate_knlist_list_c", (DL_FUNC)&validate_knlist_list_c, 1},
    {"validate_knlist_node_c", (DL_FUNC)&validate_knlist_node_c, 1},
    {"validate_klist_list_c", (DL_FUNC)&validate_klist_list_c, 1},
    {"validate_klist_node_c", (DL_FUNC)&validate_klist_node_c, 1},
    {"if_list_force_class", (DL_FUNC)&if_list_force_class, 2},
    {NULL, NULL, 0}};

void R_init_keylist(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, callMethods, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
