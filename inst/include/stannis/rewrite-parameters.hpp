#ifndef REWRITE_PARAMETERS_HPP
#define REWRITE_PARAMETERS_HPP

#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

#include <iostream>
#include <clocale>
#include <locale>
#include <cstdint>
#include <vector>
#include <string>
#include <memory>
#include <exception>
#include <ios>

namespace stannis {
  
  /* Read parameters from a source file and rewrite them 
   * to binary files in a root directory.
   *
   * @tparam type of the source stream
   * @param iterator to read values from
   * @param names names of all parameters
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

    while (*head == '\n')
      head++;

    std::vector<std::string> names(names_);
    int n_parameters = names.size();
    std::vector<std::vector<std::uint_least32_t>> dimensions(dimensions_);
    boost::filesystem::path root(root_);
  
    std::vector<std::shared_ptr<boost::filesystem::ofstream>> streams;
    std::vector<std::uint_least32_t> n_entries(n_parameters);
    for (int i = 0; i < n_parameters; ++i) {
      root = root_;
      boost::filesystem::path p = root /= names[i].append(".bin");
      std::shared_ptr<boost::filesystem::ofstream> stream_ptr(new boost::filesystem::ofstream);
      stream_ptr->open(p, mode);
      streams.push_back(stream_ptr);
      n_entries[i] = std::accumulate(
        dimensions[i].begin(), dimensions[i].end(), 1, 
        std::multiplies<std::uint_least32_t>());
    }

    std::uint_least16_t p = 0;
    std::uint_least32_t i = 0;
    char buffer[100];
    std::fill_n(buffer, 100, '_');
    double val;
    int bi = 0;
    char* bj;
    while (head != end && *head != '#') {
      while (head != end && *head != ',' && *head != '\n') 
        buffer[bi++] = *head++;
      if (head == end)
        return false;
      val = std::strtod(&buffer[0], &bj);
      if (*bj != '_')
	throw std::logic_error(std::string(buffer));
      std::fill_n(buffer, 100, '_');
      bi = 0;
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

    std::uint_least32_t n_it = n_iterations;

    for (int i = 0; i < n_parameters; ++i)
      streams[i]->close();

    return true;
  }

}

#endif
