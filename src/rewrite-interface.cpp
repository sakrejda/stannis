#include <stannis/exporter.hpp>
#include <stannis/rewrite-stan-csv.hpp>

#include <stannis/read-header-data.hpp>
#include <stannis/read-dimensions-data.hpp>
#include <stannis/read-names-data.hpp>
#include <stannis/read-parameter-data.hpp>

#include <Rcpp.h>

#include <boost/filesystem.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_io.hpp>

#include <string>
#include <fstream>

RcppExport SEXP rewrite_stan_csv(SEXP source_, SEXP root_, SEXP tag_, SEXP comment_
) {
  boost::filesystem::path source = Rcpp::as<boost::filesystem::path>(source_);
  boost::filesystem::path root = Rcpp::as<boost::filesystem::path>(root_);
  boost::uuids::uuid tag = Rcpp::as<boost::uuids::uuid>(tag_);
  std::string comment = Rcpp::as<std::string>(comment_);
  bool complete = stannis::rewrite_stan_csv(source, root, tag, comment);
  Rcpp::RObject result = Rcpp::wrap(complete);
  return result;
}

RcppExport SEXP get_dimensions(SEXP dim_path_, SEXP name_path_, SEXP name_) {
  boost::filesystem::path dim_path = Rcpp::as<boost::filesystem::path>(dim_path_);
  boost::filesystem::path name_path = Rcpp::as<boost::filesystem::path>(name_path_);
  std::vector<std::string> name = Rcpp::as<std::vector<std::string>>(name_);
  std::vector<uint> dims = stannis::get_dimensions(dim_path, name_path, name[0]);
  Rcpp::NumericVector result = Rcpp::wrap(dims);
  return result;
}

RcppExport SEXP get_parameter(SEXP root_, SEXP name_) {
  boost::filesystem::path root = Rcpp::as<boost::filesystem::path>(root_);
  boost::filesystem::path dim_path = Rcpp::as<boost::filesystem::path>(root_);
  dim_path /= "dimensions.bin";
  boost::filesystem::path name_path = Rcpp::as<boost::filesystem::path>(root_);
  name_path /= "names.bin";
  std::string name = Rcpp::as<std::vector<std::string>>(name_)[0];
  std::vector<double> draws = stannis::get_draws(root /= name + "-reshape.bin");
  std::vector<uint> dims = stannis::get_dimensions(dim_path, name_path, name);
  return Rcpp::List::create(
    Rcpp::Named("data") = draws,
    Rcpp::Named("dims") = dims
  );
}

static const R_CallMethodDef CallEntries[] = {
    {"rewrite_stan_csv", (DL_FUNC) &rewrite_stan_csv, 4},
    {"get_dimensions", (DL_FUNC) &get_dimensions, 3},
    {"get_parameter", (DL_FUNC) &get_parameter, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_stannis(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}


