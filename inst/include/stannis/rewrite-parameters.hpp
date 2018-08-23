#ifndef REWRITE_PARAMETERS_HPP
#define REWRITE_PARAMETERS_HPP

#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

#include <iostream>
#include <cstdint>
#include <vector>
#include <string>
#include <memory>
#include <ios>

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
    const std::vector<std::string> & names_,
    const std::vector<std::vector<std::uint_least32_t>> & dimensions_,
    const boost::filesystem::path & root_,
    std::uint_least32_t & n_iterations,
    std::ios_base::openmode mode
  ) {
    I tail;
    I end;
    std::fstream of("/tmp/of.txt", std::ofstream::out | std::ofstream::app);
 
    while (*head == '\n')
      head++;

    std::vector<std::string> names(names_);
    int n_parameters = names.size();
    std::vector<std::vector<std::uint_least32_t>> dimensions(dimensions_);
    boost::filesystem::path root(root_);
  
    std::vector<std::shared_ptr<boost::filesystem::fstream>> streams;
    std::vector<std::uint_least32_t> n_entries(n_parameters);
    for (int i = 0; i < n_parameters; ++i) {
      root = root_;
      boost::filesystem::path p = root /= names[i].append(".bin");
      std::shared_ptr<boost::filesystem::fstream> stream_ptr(
	new boost::filesystem::fstream);
      stream_ptr->open(p, mode);
      streams.push_back(stream_ptr);
      stream_ptr->write((char*)(&n_iterations), sizeof(n_iterations));
      std::uint_least16_t ndim = dimensions[i].size();
      stream_ptr->write((char*)(&ndim), sizeof(ndim));
      n_entries[i] = std::accumulate(
        dimensions[i].begin(), dimensions[i].end(), 1, 
        std::multiplies<std::uint_least32_t>());
      stream_ptr->write((char*)(&dimensions[i][0]),
        sizeof(std::uint_least32_t) * ndim);
    }


    std::uint_least16_t p = 0;
    std::uint_least32_t i = 0;
    std::vector<char> ds;
    double val;
    char* c;
    while (head != end && *head != '#') {
      while (head != end && *head != ',' && *head != '\n') 
        ds.push_back(*head++);
      if (head == end)
        return false;
      val = std::strtod(&ds[0], &c);
      ds.clear();
      streams[p]->write((char*)(&val), sizeof(double));
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
    of << "PART B" << std::endl;
    for (int i = 0; i < n_parameters; ++i) {
      streams[i]->seekg(std::ios::beg);
      streams[i]->write((char*)(&n_iterations), sizeof(n_iterations));
      streams[i]->close();
    }
    of << "PART C" << std::endl;
    return true;
  }

}

#endif
