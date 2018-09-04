#include <stannis/exporter.hpp>

#include <stannis/interface-read.hpp>
#include <stannis/read-header-data.hpp>
#include <stannis/read-dimension-data.hpp>
#include <stannis/read-name-data.hpp>
#include <stannis/read-parameter-data.hpp>

#include <Rcpp.h>

#include <boost/filesystem.hpp>

#include <string>
#include <fstream>

RcppExport SEXP get_dimensions(SEXP dim_path_, SEXP name_path_) {
  BEGIN_RCPP
  boost::filesystem::path dim_path = Rcpp::as<boost::filesystem::path>(dim_path_);
  boost::filesystem::path name_path = Rcpp::as<boost::filesystem::path>(name_path_);
  std::vector<std::vector<uint>> dims = stannis::get_dimensions(dim_path);
  std::vector<std::string> names = stannis::get_names(name_path);
  Rcpp::List result;
  for (int i = 0; i < names.size(); ++i)
    result.push_back(dims[i], names[i]);
  return result;
  END_RCPP
}

RcppExport SEXP get_parameter_dimensions(SEXP root_, SEXP name_) {
  BEGIN_RCPP
  std::string name = Rcpp::as<std::vector<std::string>>(name_)[0];
  boost::filesystem::path root = Rcpp::as<boost::filesystem::path>(root_);
  boost::filesystem::path dim_path(root);
  dim_path /= name + "-dimensions.bin";
  std::vector<uint> dims = stannis::get_reshape_dimensions(dim_path);
  return Rcpp::wrap(dims);
  END_RCPP
}


RcppExport SEXP get_parameter(SEXP root_, SEXP name_) {
  BEGIN_RCPP
  std::string name = Rcpp::as<std::vector<std::string>>(name_)[0];
  boost::filesystem::path root = Rcpp::as<boost::filesystem::path>(root_);
  boost::filesystem::path dim_path(root);
  dim_path /= name + "-dimensions.bin";
  std::vector<uint> dims = stannis::get_reshape_dimensions(dim_path);
  std::vector<double> draws = stannis::get_draws(root /= name + "-reshape.bin");
  return Rcpp::List::create(
    Rcpp::Named("data") = draws,
    Rcpp::Named("dims") = dims
  );
  END_RCPP
}

