#include <Rcpp.h>

#include <stannis/interface-helper.hpp>
#include <stannis/interface-read.hpp>
#include <stannis/interface-rewrite.hpp>

static const R_CallMethodDef CallEntries[] = {
    {"hash_to_uuid", (DL_FUNC) &hash_to_uuid, 1},
    {"rewrite_stan_csv", (DL_FUNC) &rewrite_stan_csv, 4},
    {"get_dimensions", (DL_FUNC) &get_dimensions, 2},
    {"get_parameter_dimensions", (DL_FUNC) &get_parameter_dimensions, 2},
    {"get_parameter", (DL_FUNC) &get_parameter, 2},
    {"uuid", (DL_FUNC) &uuid, 0},
    {NULL, NULL, 0}
};


RcppExport void R_init_stannis(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}

