#include <stannis/write-parameter-dimensions.hpp>

#include <stannis/read-name-data.hpp>
#include <stannis/read-dimension-data.hpp>

#include <boost/filesystem.hpp>

#include <string>
#include <vector>
#include <algorithm>
#include <numeric>
#include <ios>

namespace stannis {

  /* Write dimensions for all parameters to their respective
   * dimension files.
   *
   * @param root directory where binary files are written.
   * @return true if all rewrite are successful.
   */
  bool write_parameter_dimensions(
    const boost::filesystem::path & root_,
    std::uint_least32_t n_iterations
  );  

}

