#ifndef ZOOM_HELPERS_CPP
#define ZOOM_HELPERS_CPP

#include <vector>
#include <string>
#include <sstream>
#include <zoom-t.hpp>

/* Return a string with the summary of information read from a 
 * header object (tuple).
 *
 * @param h header object, currently a tuple
 */
std::string header_summary(header_t& h) {
  int n_col = 0;
  int n_parameters = 0;
  std::vector<std::string> names;
  std::vector<int> n_dim;
  std::vector<std::vector<int>> dimensions;
  std::vector<std::vector<int>> index;
  std::stringstream s;

  std::tie(n_col, n_parameters, names, n_dim, dimensions, index) = h;
  s << "number of columns: " << n_col << ", number of parameters: " << n_parameters << std::endl;
  for (int i = 0; i < n_parameters; ++i) {
    s << "parameter: " << names[i] << ", number of dimensions: " << n_dim[i];
    if (n_dim[i] > 0) 
      s << ", size: ";
      for (int j = 0; j < dimensions[i].size(); ++j) {
        if (j != 0) 
          s << " x ";
        s << dimensions[i][j];
      }
    s << std::endl;
  }
  return s.str();
}

/* Check if string starts with a '#' character.
 *
 * @param s string to check.
 */
bool is_comment(std::string& s) {
  return *(s.begin()) == '#';
}

/* Check if string starts with the sequence
 * Sequence: '#  Elapsed Time:'
 *
 * @param s string to check.
 */
bool is_timing(std::string& s) {
  return is_comment(s) && s.substr(0,16) == "#  Elapsed Time:";
}

/* Check if string indicates start of a mass matrix
 * Sequence: '#.*mass matrix:'
 *
 * @param s string to check.
 */
bool is_mm_start(std::string& s) {
  return is_comment(s) && s.find(" mass matrix:") != std::string::npos;

#endif
