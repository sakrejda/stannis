#ifndef READ_PARAMETER_DATA_HPP
#define READ_PARAMETER_DATA_HPP

#include <boost/filesystem.hpp>

#include <vector>

namespace stannis {

  /* Read the dimension of a parameter from its
   * dim file.  
   *
   * @param path to the parameter-specific dim file
   * @return dimensions
   */
  std::vector<std::uint_least32_t> get_reshape_dimensions(
    const boost::filesystem::path path
  );

  /* Gets parameter dimensions. */

  /* Gets sample draws
   *
   * @param path path to parameter-specific draws file.
   * @return vector of draws
   */
  std::vector<double> get_draws(
    const boost::filesystem::path draw_path);

}

#endif
