#include <stannis/reshape-parameters.hpp>

#include <boost/filesystem.hpp>

#include <string>
#include <vector>
#include <algorithm>
#include <ios>

namespace stannis {

  // See header file.
  bool reshape_parameters(
    const std::string & name,
    const boost::filesystem::path & root_
  ) {
    boost::filesystem::path root(root_);
    boost::filesystem::path p_in = root /= name.append(".bin");
    root = root_;
    boost::filesystem::path p_out = root /= name.append("-reshape.bin");

    boost::filesystem::fstream is(p_in);
    boost::filesystem::fstream os(p_out, std::ofstream::out | std::ofstream::trunc);

    std::uint_least32_t n_iterations;
    is.read((char*)(&n_iterations), sizeof(n_iterations));
    os.write((char*)(&n_iterations), sizeof(n_iterations));
    if (!is.good() || !os.good())
      return false;
    std::uint_least16_t ndim;
    is.read((char*)(&dndim), sizeof(ndim));
    os.write((char*)(&dndim), sizeof(ndim));
    if (!is.good() || !os.good())
      return false;
    std::vector<std::uint_least32_t> dimensions(ndim);
    is.read((char*)(&dimensions[0]), sizeof(std::uint_least32_t) * ndim);
    os.write((char*)(&dimensions[0]), sizeof(std::uint_least32_t) * ndim);
    if (!is.good() || !os.good())
      return false;

    std::uint_least32_t n_entries = std::accumulate(
        dimensions[i].begin(), dimensions[i].end(), 1, 
        std::multiplies<std::uint_least32_t>());

    typedef std::uint_least64_t N_size_t;
    std::fpos header_offset = std::ios::beg
      + sizeof(std::uint_least32_t) + sizeof(std::uint_least16_t)
      + sizeof(std::uint_least32_t) * ndim;

    N_size_t N = n_entries * n_iterations;
    for (N_size_t i = 0; i < N ; ++i) {
      N_size_t k = i % n_entries;  // entry
      N_size_t m = i / n_entries;  // iteration
      is.seekg(header_offset + sizeof(double) * (m * n_entries + k));
      double value;
      is.read((char*)(&value), sizeof(double));
      os.write((char*)(&value), sizeof(double));
      if (!is.good() || !os.good())
	return false;
    }
    return true;
  }

}

