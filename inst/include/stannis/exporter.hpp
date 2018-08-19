#ifndef EXPORTER_HPP
#define EXPORTER_HPP

#include <RcppCommon.h>
#include <iostream>
#include <boost/filesystem.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_io.hpp>
#include <boost/uuid/string_generator.hpp>

namespace Rcpp {
  SEXP wrap(boost::filesystem::path p);
  SEXP wrap(boost::filesystem::path & p);
  template <> boost::filesystem::path as(SEXP p);
  // template <> boost::filesystem::path & as(SEXP p);    dangles

  SEXP wrap(boost::uuids::uuid tag);
  SEXP wrap(boost::uuids::uuid & tag);
  template <> boost::uuids::uuid as(SEXP tag);

}

#include <Rcpp.h>

namespace Rcpp {

  SEXP wrap(boost::filesystem::path p) {
    std::string ps = p.native();
    return Rcpp::CharacterVector(ps);
  }

  SEXP wrap(boost::filesystem::path & p) {
    std::string ps = p.native();
    return Rcpp::CharacterVector(ps);
  }

  template <> boost::filesystem::path as(SEXP p) {
    std::vector<std::string> ps = Rcpp::as<std::vector<std::string>>(p);
    return boost::filesystem::path(ps[0]);
  }

  SEXP wrap(boost::uuids::uuid tag) {
    std::string t = boost::uuids::to_string(tag);
    return Rcpp::CharacterVector(t);
  }

  SEXP wrap(boost::uuids::uuid & tag) {
    std::string t = boost::uuids::to_string(tag);
    return Rcpp::CharacterVector(t);
  }

  template <> boost::uuids::uuid as(SEXP tag) {
    std::vector<std::string> ts = Rcpp::as<std::vector<std::string>>(tag);
    boost::uuids::string_generator generator;
    boost::uuids::uuid t = generator(ts[0]);
    return t;
  }

}

#endif
