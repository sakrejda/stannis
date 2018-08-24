#ifndef RESHAPE_PARAMETERS_HPP
#define RESHAPE_PARAMETERS_HPP

#include <boost/filesystem.hpp>

#include <string>
#include <vector>
#include <algorithm>
#include <ios>

namespace stannis {
 
  /* Read parameters from a source file and reshape them 
   * to binary files in a root directory.
   *
   * @tparam type of the source stream
   * @param source_stream stream to read text from
   * @param dimensions dimension data about each parameter
   * @param root path to directory where binary files are written
   * @param[out] n_iterations reference to variable for counting iterations
   *        rewritten
   * @return true if the last iteration written was complete.
   */
  bool reshape_parameters(
    const std::string & name,
    const boost::filesystem::path & root_
  );

}

#endif
