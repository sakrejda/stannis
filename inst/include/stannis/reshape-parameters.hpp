#ifndef RESHAPE_PARAMETERS_HPP
#define RESHAPE_PARAMETERS_HPP

#include <boost/filesystem.hpp>

#include <string>
#include <vector>
#include <iostreams>
#include <algorithm>

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
  template <class I>
  bool reshape_parameters(
    const std::string & name,
    const boost::filesystem::path & root,
  ) {

    boost::filesystem::path p_in = root /= name.append(".bin");;
    boost::filesystem::path p_out = root /= name.append("-reshape.bin");
    boost::filesystem::fstream is(p_in);
    boost::filesystem::fstream os(p_out);

    std::uint_least32_t n_iterations;
    is.read((char*)(&n_iterations), sizeof(n_iterations));
    os.write((char*)(&n_iterations), sizeof(n_iterations));
    std::uint_least16_t ndim;
    is.read((char*)(&dndim), sizeof(ndim));
    os.write((char*)(&dndim), sizeof(ndim));
    std::vector<std::uint_least32_t> dimensions(ndim);
    is.read((char*)(&dimensions[0]), sizeof(std::uint_least32_t) * ndim);
    os.write((char*)(&dimensions[0]), sizeof(std::uint_least32_t) * ndim);

    std::uint_least32_t n_entries = std::accumulate(
        dimensions[i].begin(), dimensions[i].end(), 1, 
        std::multiplies<std::uint_least32_t>());

    typedef std::uint_least64_t N_size_t;
    header_offset = 
    N_size_t N = n_entries * n_iterations;
    for (N_size_t i = 0; i < N ; ++i) {
      N_size_t k = i % n_entries;  // entry
      N_size_t m = i / n_entries;  // iteration
      is.seek(std::ios::beg + m * n_entries + k);
      double value;
      is.read((char*)(&value), sizeof(double));
      os.write((char*)(&value), sizeof(double));
    }

  }

}

#endif
