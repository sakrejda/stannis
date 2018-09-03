#ifndef RESHAPE_PARAMETERS_HPP
#define RESHAPE_PARAMETERS_HPP

#include <boost/filesystem.hpp>

#include <string>
#include <vector>
#include <algorithm>
#include <ios>

namespace stannis {
 
  /* Read parameters from a source file and reshape them 
   * to binary files in a root directory.  Do this for all 
   * parameters in the model.
   *
   * @param root path to directory where binary files are written
   * @return true if the rewrite is successful for all parameters.
   */
  bool reshape_parameters(
    const boost::filesystem::path & root_
  );

  /* Reshape parameter in file 'in' write to file 'out', use
   * supplied dimensiosn.
   *
   * @param root path to directory where binary files are written.
   * @return true if hte rewrite is successful.
   */
  bool reshape_one(
    const boost::filesystem::path & in,
    const boost::filesystem::path & out,
    const std::vector<std::uint_least32_t> & dimensions
  );

}

#endif
