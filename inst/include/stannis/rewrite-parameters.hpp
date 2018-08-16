#ifndef REWRITE_PARAMETERS_HPP
#define REWRITE_PARAMETERS_HPP

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

  //FIXME: Needs implementation... should be easy...
  return true;
  }
}

#endif
