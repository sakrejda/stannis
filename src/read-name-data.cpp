#include <stannis/read-name-data.hpp>

#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

#include <string>
#include <cstdint>
#include <vector>

namespace stannis {
  
  std::vector<std::string> get_names(
    const boost::filesystem::path path
  ) {
    boost::filesystem::fstream stream(path);
    std::vector<std::string> names;
    while (stream.good()) {
      std::uint_least32_t L;
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

