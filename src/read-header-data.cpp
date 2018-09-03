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

  std::vector<std::uint_least32_t> get_version(
    const boost::filesystem::path path
  ) {
    boost::filesystem::fstream stream(path);
    std::vector<std::uint_least32_t> versions;
    versions.resize(4);
    std::string s;
    s.resize(11);
    stream.read((char*)(&s[0]), 11);
    stream.read((char*)(&s[0]), sizeof(std::uint_least32_t));
    stream.read((char*)(&s[1]), sizeof(std::uint_least32_t));
    stream.read((char*)(&s[2]), sizeof(std::uint_least32_t));
    stream.read((char*)(&s[3]), sizeof(std::uint_least32_t));
    return versions;
  }

}

