#include <stannis/read-header-data.hpp>

#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

#include <string>
#include <cstdint>
#include <vector>
#include <algorithm>

namespace stannis {
  
  std::uint_least32_t get_n_parameters(
    const boost::filesystem::path path
  ) {
    boost::filesystem::fstream stream(path);
    std::uint_least32_t n_parameters = 0;
    while (stream.good()) {
      std::uint_least16_t ndim;
      stream.read((char*)(&ndim), sizeof(ndim));
      if (!stream.good())
        break;
      stream.seekg(sizeof(std::uint_least32_t) * ndim + stream.tellg());
      n_parameters++;
    }
    return n_parameters;
  }

  std::vector<std::uint_least16_t> get_ndim(
    const boost::filesystem::path path
  ) {
    boost::filesystem::fstream stream(path);
    std::vector<std::uint_least16_t> ndim_vec;
    while (stream.good()) {
      std::uint_least16_t ndim;
      stream.read((char*)(&ndim), sizeof(ndim));
      if (!stream.good())
        break;
      ndim_vec.push_back(ndim);
      stream.seekg(sizeof(std::uint_least32_t) * ndim + stream.tellg());
    }
    return ndim_vec;
  }

  std::vector<std::vector<std::uint_least32_t>> get_dimensions(
    const boost::filesystem::path path
  ) {
    boost::filesystem::fstream stream(path);
    std::vector<std::vector<std::uint_least32_t>> dimensions;
    std::uint_least16_t ndim;
    while (stream.read((char*)(&ndim), sizeof(ndim))) {
      std::vector<std::uint_least32_t> d(ndim);
      stream.read((char*)(&d[0]), ndim * sizeof(std::uint_least32_t));
      dimensions.push_back(d);
    }
    return dimensions;
  }

  std::vector<std::string> get_names(
    const boost::filesystem::path path
  ) {
    boost::filesystem::fstream stream(path);
    std::vector<std::string> names;
    while (stream.good()) {
      std::uint_least16_t L;
      stream.read((char*)(&L), sizeof(L));
      if (!stream.good())
        break;
      std::string name;
      name.resize(L);
      stream.read((char*)(&name[0]), L);
      names.push_back(name);
    }
    return names;
  }

}

