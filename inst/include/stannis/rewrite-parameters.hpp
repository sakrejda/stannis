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
    int n_parameters = names.size();
  
    std::vector<boost::filesystem::fstream> streams;
    for (const std::string & name : names ) {
      boost::filesystem::path p = root /= name;
      streams.emplace_back(p);
    }

    for (int i = 0; i < n_parameters; ++i) {
      std::uint_least16_t ndim = dimensions[i].size();
      for (std::uint_least16_t d = 0; d < ndim; ++d) {
	for (std::uint_least32_t j = 0; j < dimensions[d]; ++j) {
	  char c;
          double val;
          source_stream >> val;
          streams[i].write((char*)(&val), sizeof(double));
	  source_stream.read(&c, 1);
	}
	// FIXME: that's most of the read, we could use std::async with a reshape here...
      }
    }
    

  return true;
  }
}

#endif
