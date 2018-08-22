#include <stannis/exporter.hpp>
#include <stannis/reader.hpp>

#include <Rcpp.h>

// [[Rcpp::depends(BH)]]

#include <boost/filesystem.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_io.hpp>

#include <string>

// [[Rcpp::export]]
bool rewrite(
  const boost::filesystem::path & source,
  const boost::filesystem::path & root,
  const boost::uuids::uuid & tag,
  const std::string & comment
) {
  bool complete = stannis::rewrite(source, root, tag, comment);
  return complete;
}



