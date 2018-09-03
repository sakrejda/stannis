#include <stannis/read-parameter-data.hpp>

#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

#include <string>
#include <cstdint>
#include <vector>
#include <algorithm>

namespace stannis {

  std::vector<std::uint_least32_t> get_reshape_dimensions(
    const boost::filesystem::path path
  ) {
    boost::filesystem::fstream stream(path);
    std::uint_least32_t n_iterations;
    stream.read((char*)(&n_iterations), sizeof(n_iterations));
    std::uint_least32_t n_dim;
    stream.read((char*)(&n_dim), sizeof(n_dim));
    std::vector<std::uint_least32_t> dimensions(1 + n_dim);
    dimensions[0] = n_iterations;
    stream.read((char*)(&dimensions[1]), sizeof(std::uint_least32_t) * n_dim);
    return dimensions;
  }

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

