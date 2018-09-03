#include <stannis/read-header-data.hpp>

#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

#include <string>
#include <cstdint>
#include <vector>
#include <algorithm>

namespace stannis {
  
  std::string get_magic(
    const boost::filesystem::path path
  ) {
    boost::filesystem::fstream stream(path);
    std::string s;
    s.resize(11);
    stream.read((char*)(&s[0]), 11);
    return s;
  }

  std::vector<std::uint_least32_t> get_dimensions(
    const boost::filesystem::path dim_path,
    const boost::filesystem::path name_path,
    std::string name
  ) {
    std::vector<std::vector<std::uint_least32_t>> dimensions = 
      get_dimensions(dim_path);
    std::vector<std::string> names = get_names(name_path);
    for (std::size_t i = 0; i < names.size(); ++i)
      if (names[i] == name)
	return dimensions[i];
    throw std::invalid_argument("Name not found.");
  }

}

