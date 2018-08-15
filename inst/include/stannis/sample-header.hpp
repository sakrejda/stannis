#ifndef SAMPLE_HEADER_HPP
#define SAMPLE_HEADER_HPP

#include <stannis/types.hpp>

#include <boost/filesystem.hpp>
#include <boost/uuids/uuid.hpp>

#include <string>

namespace stannis {

  /* Handle header lines only.  Calculate the number of columns,
   * parameters, names, and structure all in one pass.
   *
   * @param line std::string& representing the header
   * @return header_t tuple with number of column, parameters, names and
   *                  dimensions/index to columns.
   */
  header_t read_header(std::string& line);

  /* Write header to binary stream. */
  bool write_header(
    header_t& h, 
    boost::filesystem::path p,
    boost::uuids::uuid tag
  );

}


#endif
