#include <stannis/read-parameter-data.hpp>

#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

#include <string>
#include <cstdint>
#include <vector>
#include <algorithm>

namespace stannis {

  std::vector<double> get_draws(
    const boost::filesystem::path draw_path
  ) {
    boost::filesystem::ifstream stream(draw_path, std::ifstream::in);
    std::uintmax_t n_entries = boost::filesystem::file_size(draw_path) / sizeof(double);
    std::vector<double> draws(n_entries);
    stream.read((char*)(&draws[0]), n_entries * sizeof(double));
    return draws; 
  }


}

