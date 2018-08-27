#include <stannis/reshape-parameters.hpp>
#include <stannis/read-header-data.hpp>

#include <boost/filesystem.hpp>

#include <string>
#include <vector>
#include <algorithm>
#include <numeric>
#include <ios>

namespace stannis {

  // See header file.
  bool reshape_parameters(
    const std::string & name,
    const boost::filesystem::path & root_
  ) {
    boost::filesystem::path in_path(root_);
    in_path /= name + ".bin";
    boost::filesystem::path out_path(root_);
    out_path /= name + "-reshape.bin";
    boost::filesystem::path name_path(root_);
    name_path /= "names.bin";
    boost::filesystem::path dimension_path(root_);
    dimension_path /= "dimensions.bin";
   
    std::vector<std::uint_least32_t> dimensions = get_dimensions(
      dimension_path, name_path, name);

    std::uint_least32_t n_entries = std::accumulate(
      dimensions.begin(), dimensions.end(), 1, 
      std::multiplies<std::uint_least32_t>());
    std::uint_least32_t n_iterations = 
      (boost::filesystem::file_size(in_path) / sizeof(double)) / n_entries;

    boost::filesystem::fstream os(out_path, std::ofstream::out | std::ofstream::trunc);
    std::vector<double> values = get_draws(in_path);

    for (std::uint_least32_t k = 0; k < n_entries; ++k) {
      for (std::uint_least32_t i = 0; i < n_iterations; ++i) {
        double value = values.at(k + i * n_entries);
        os.write((char*)(&value), sizeof(double));
        if (!os.good())
          return false;
      }
    }
    return true;
  }

}

