#include <stannis/exporter.hpp>
#include <stannis/reader.hpp>

#include <Rcpp.h>

// [[Rcpp::depends(BH)]]

#include <boost/filesystem.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_io.hpp>

#include <string>
#include <fstream>

RcppExport SEXP rewrite(SEXP source_, SEXP root_, SEXP tag_, SEXP comment_
) {
  boost::filesystem::path source = Rcpp::as<boost::filesystem::path>(source_);
  boost::filesystem::path root = Rcpp::as<boost::filesystem::path>(root_);
  boost::uuids::uuid tag = Rcpp::as<boost::uuids::uuid>(tag_);
  std::string comment = Rcpp::as<std::string>(comment_);
  std::fstream of("/tmp/of.txt");
  of << "rewrite-interface" << std::endl;
  bool complete = stannis::rewrite(source, root, tag, comment);
  Rcpp::Robject result = Rcpp::warp(complete);
  return result;
}



