#ifndef REWRITE_PARAMETER_DIMENSIONS_HPP
#define REWRITE_PARAMETER_DIMENSIONS_HPP

#include <boost/filesystem.hpp>

#include <string>
#include <cstdint>

namespace stannis {

  /* Write dimensions for all parameters to their respective
   * dimension files.
   *
   * @param root directory where binary files are written.
   * @return true if all rewrite are successful.
   */
  bool rewrite_parameter_dimensions(
    const boost::filesystem::path & root_,
    std::uint_least32_t n_iterations
  );  

}

#endif
