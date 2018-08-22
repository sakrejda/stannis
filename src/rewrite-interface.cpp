#include <stannis/exporter.hpp>
#include <stannis/reader.hpp>

#include <Rcpp.h>

#include <boost/filesystem.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_io.hpp>

#include <string>
#include <fstream>

RcppExport SEXP rewrite(SEXP source_, SEXP root_, SEXP tag_, SEXP comment_
) {
  std::ofstream of("/tmp/of.txt", std::ofstream::out);
  of << "rewrite-interface" << std::endl;
  boost::filesystem::path source = Rcpp::as<boost::filesystem::path>(source_);
  boost::filesystem::path root = Rcpp::as<boost::filesystem::path>(root_);
  boost::uuids::uuid tag = Rcpp::as<boost::uuids::uuid>(tag_);
  std::string comment = Rcpp::as<std::string>(comment_);
  bool complete = stannis::rewrite(source, root, tag, comment);
  Rcpp::RObject result = Rcpp::wrap(complete);
  return result;
}

static const R_CallMethodDef CallEntries[] = {
    {"rewrite", (DL_FUNC) &rewrite, 4},
    {NULL, NULL, 0}
};

RcppExport void R_init_stannis(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}


