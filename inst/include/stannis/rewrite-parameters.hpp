#ifndef REWRITE_PARAMETERS_HPP
#define REWRITE_PARAMETERS_HPP

#include <boost/filesystem.hpp>
#include <iostreams>

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
  template <class I>
  bool rewrite_parameters(
    I & head,
    std::vector<std::string> names,
    std::vector<std::vector<std::uint_least32_t> dimensions,
    boost::filesystem::path root,
    std::uint_least32_t & n_iterations
  ) {
    I tail();
    I end();
  
    int n_parameters = names.size();
  
    std::vector<boost::filesystem::fstream> streams;
    std::vector<std::uint_least32_t> n_entries(n_parameters);
    for (int i = 0; i < n_parameters; ++i) {
      boost::filesystem::path p = root /= names[i].append(".bin");
      streams.emplace_back(p);
      streams[i].write((char*)(&n_iterations), sizeof(n_iterations));
      std::uint_least16_t ndim = dimensions[i].size();
      streams[i].write((char*)(&dndim), sizeof(ndim));
      n_entries[i] = std::accumulate(
        dimensions[i].begin(), dimensions[i].end(), 1, 
        std::multiplies<std::uint_least32_t>());
      streams[i].write((char*)(&dimensions[i][0]),
        sizeof(std::uint_least32_t) * ndim);
    }

    std::uint_least16_t p = 0;
    std::uint_least32_t i = 0;
    std::vector<char> ds;
    double val;
    while (head != end && *head != '#') {
      while (head != end && *head != ',' && *head != '\n') {
        ds.push_back(*head);
      }
      if (head == end)
        return false;
      val = std::strtod(&ds[0]);
      ds.clear();
      streams[p].write((char*)(&val), sizeof(double));
      i++;
      if (i >= n_entries[p]) {
        p++; 
        i = 0;
      }
      if (*head == '\n') {
        p = 0;
        i = 0;
        n_iterations++;
      }
      head++;
    }
    for (int i = 0; i < n_parameters; ++i) {
      streams[i].seek(std::ios::beg);
      streams[i].write((char*)(&n_iterations), sizeof(n_iterations);
    }
    return true;
  }

}

#endif
