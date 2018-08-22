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

#endif
