#include <stannis/rewrite-parameter-dimensions.hpp>

#include <stannis/read-name-data.hpp>
#include <stannis/read-dimension-data.hpp>

#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

#include <string>
#include <vector>
#include <numeric>
#include <ios>

namespace stannis {

  // See header file
  bool rewrite_parameter_dimensions(
    const boost::filesystem::path & root_,
    std::uint_least32_t n_iterations
  ) { 
    boost::filesystem::path name_path(root_);
    name_path /= "names.bin";
    boost::filesystem::path dimensions_path(root_);
    dimensions_path /= "dimensions.bin";

    std::vector<std::string> names = get_names(name_path);
    std::vector<std::vector<std::uint_least32_t>> dimensions 
      = get_dimensions(dimensions_path);

    bool complete = true;
    for (int i = 0; i < names.size(); ++i) {
      std::uint_least32_t n_dim = dimensions[i].size();
      boost::filesystem::path out_path(root_);
      out_path /= names[i] + "-dimensions.bin";
      boost::filesystem::fstream os(out_path, std::ofstream::out | std::ofstream::trunc);
      os.write((char*)(&n_iterations), sizeof(n_iterations));
      os.write((char*)(&n_dim), sizeof(n_dim));
      os.write((char*)(&dimensions[i][0]), sizeof(std::uint_least32_t) * n_dim);
      os.close();
    }
    return true;
  }
  

}

