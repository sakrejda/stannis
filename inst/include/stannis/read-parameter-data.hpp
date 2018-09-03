#ifndef READ_PARAMETER_DATA_HPP
#define READ_PARAMETER_DATA_HPP

#include <boost/filesystem.hpp>

#include <vector>

namespace stannis {
 
  /* Gets sample draws
   *
   * @param path path to parameter-specific draws file.
   * @return vector of draws
   */
  std::vector<double> get_draws(
    const boost::filesystem::path draw_path);

}

#endif
