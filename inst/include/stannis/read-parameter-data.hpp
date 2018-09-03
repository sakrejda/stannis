#ifndef READ_PARAMETER_DATA_HPP
#define READ_PARAMETER_DATA_HPP

#include <boost/filesystem.hpp>

#include <string>
#include <cstdint>
#include <vector>

namespace stannis {
 
  /* Gets sample draws */
  std::vector<double> get_draws(
    const boost::filesystem::path draw_path);

}

#endif
