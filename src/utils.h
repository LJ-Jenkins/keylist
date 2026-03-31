// utils.h
#ifndef UTILS_H
#define UTILS_H

#include <R.h>
#include <Rinternals.h>

// Function declaration
void knlist_unique_names(SEXP names);
void klist_unique_names(SEXP names);
SEXP if_list_force_class(SEXP x, SEXP new_class);

#endif