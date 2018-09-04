#include <stannis/exporter.hpp>

#include <stannis/interface-rewrite.hpp>
#include <stannis/rewrite-stan-csv.hpp>

#include <Rcpp.h>

#include <boost/filesystem.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/name_generator.hpp>
#include <boost/uuid/uuid_io.hpp>

#include <string>
#include <fstream>

RcppExport SEXP hash_to_uuid(SEXP hash_) {
  BEGIN_RCPP
  std::vector<std::string> hashes = Rcpp::as<std::vector<std::string>>(hash_);
  std::string tag_string;
  for (auto & s : hashes) 
    tag_string.append(s);
  boost::uuids::name_generator_sha1 gen(boost::uuids::ns::oid());
  boost::uuids::uuid tag = gen(tag_string);
  std::string t = boost::uuids::to_string(tag);
  return Rcpp::CharacterVector(t);
  END_RCPP
}

RcppExport SEXP rewrite_stan_csv(SEXP source_, SEXP root_, SEXP tag_, SEXP comment_
) {
  BEGIN_RCPP
  boost::filesystem::path source = Rcpp::as<boost::filesystem::path>(source_);
  boost::filesystem::path root = Rcpp::as<boost::filesystem::path>(root_);
  boost::uuids::uuid tag = Rcpp::as<boost::uuids::uuid>(tag_);
  std::vector<std::string> comment = Rcpp::as<std::vector<std::string>>(comment_);
  std::string comment_string;
  for (auto & s : comment) 
    comment_string.append(s);
  bool complete = stannis::rewrite_stan_csv(source, root, tag, comment_string);
  Rcpp::RObject result = Rcpp::wrap(complete);
  return result;
  END_RCPP
}


