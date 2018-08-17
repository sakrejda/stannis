#ifndef REWRITE_PARAMETERS_HPP
#define REWRITE_PARAMETERS_HPP

#include <boost/filesystem.hpp>

namespace stannis {
  
  /* Read parameters from a source file and rewrite them 
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
  template <class S>
  rewrite_parameters(
    S & source_stream,
    std::vector<std::vector<std::uint_least32_t> dimensions,
    boost::filesystem::path root,
    std::uint_least32_t & n_iterations
  ) {
  
    boost::filesystem::path name_path = root /= "names.bin";
    boost::filesystem::path dim_path = root /= "dimensions.bin";

    std::vector<std::vector<std::uint_least32_t> dimensions = 
      get_dimensions(dim_path);
    std::vector<std:string> names = get_names(name_path); 
  
    std::vector<boost::filesystem::fstream> streams;
    for (const std::string & name : names ) {
      boost::filesystem::path p = root /= name;
      streams.emplace_back(p);
    }


  //FIXME: Needs implementation... should be easy...
  return true;
  }
}

#endif
