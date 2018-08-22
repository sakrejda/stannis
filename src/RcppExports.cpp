
#include <stannis/exporter.hpp>
#include <Rcpp.h>

using namespace Rcpp;

#include <boost/filesystem.hpp>
#include <boost/uuid/uuid.hpp>

// rewrite
bool rewrite(const boost::filesystem::path& source, const boost::filesystem::path& root, const boost::uuids::uuid& tag, const std::string& comment);
RcppExport SEXP _stannis_rewrite(SEXP sourceSEXP, SEXP rootSEXP, SEXP tagSEXP, SEXP commentSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const boost::filesystem::path& >::type source(sourceSEXP);
    Rcpp::traits::input_parameter< const boost::filesystem::path& >::type root(rootSEXP);
    Rcpp::traits::input_parameter< const boost::uuids::uuid& >::type tag(tagSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type comment(commentSEXP);
    rcpp_result_gen = Rcpp::wrap(rewrite(source, root, tag, comment));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_stannis_rewrite", (DL_FUNC) &_stannis_rewrite, 4},
    {NULL, NULL, 0}
};

RcppExport void R_init_stannis(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
