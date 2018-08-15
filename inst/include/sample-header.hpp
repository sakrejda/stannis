#ifndef SAMPLE_HEADER_HPP
#define SAMPLE_HEADER_HPP

#include <zoom-t.hpp>

#include <boost/filesystem.hpp>
#include <boost/uuids/uuid.hpp>

#include <string>

namespace stannis {

  header_t read_header(std::string& line);

  bool write_header(
    header_t& h, 
    boost::filesystem::path p,
    boost::uuids::uuid tag
  );

}


#endif
