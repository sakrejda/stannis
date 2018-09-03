#ifndef READ_HEADER_DATA_HPP
#define READ_HEADER_DATA_HPP

#include <boost/filesystem.hpp>

#include <string>
#include <cstdint>
#include <vector>

namespace stannis {
 
  /* Gets the (expect 11 character) magic string. */
  std::string get_magic(
    const boost::filesystem::path path
  );

  /* Gets version data. */
  std::vector<std::uint_least32_t> get_version(
    const boost::filesystem::path path
  );

}

#endif
