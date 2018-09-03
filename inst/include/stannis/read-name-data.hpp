#ifndef READ_HEADER_DATA_HPP
#define READ_HEADER_DATA_HPP

#include <boost/filesystem.hpp>

#include <string>
#include <cstdint>
#include <vector>

namespace stannis {
 
  /* Read the names of the (potentially multi-dimensional) parameters
   *
   * The number of names is the number of NAMED parametesr
   * in the model.
   *
   * @param path to the name file
   * @return vector of parameter names
   */
  std::vector<std::string> get_names(
    const boost::filesystem::path path
  );


}

#endif
