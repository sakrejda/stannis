
#include <stannis/interface-helper.hpp>
#include <Rcpp.h>

#include <boost/uuid/uuid.hpp>
#include <boost/uuid/name_generator.hpp>
#include <boost/uuid/uuid_io.hpp>
#include <boost/uuid/random_generator.hpp>

#include <string>
#include <fstream>

RcppExport SEXP uuid() {
  BEGIN_RCPP
  boost::uuids::random_generator generator;
  boost::uuids::uuid uuid = generator();
  std::string uuid_string = boost::uuids::to_string(uuid);
  return Rcpp::CharacterVector(uuid_string);
  END_RCPP
}

