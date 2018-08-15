#ifndef FILE_HELPERS_HPP
#define FILE_HELPERS_HPP

#include <vector>
#include <string>

namespace stannis {

  /* Check if string starts with a '#' character.
   *
   * @param s string to check.
   */
  bool is_comment(std::string& s);
  
  /* Check if string starts with the sequence
   * Sequence: '#  Elapsed Time:'
   *
   * @param s string to check.
   */
  bool is_timing(std::string& s);
  
  /* Check if string indicates start of a mass matrix
   * Sequence: '#.*mass matrix:'
   *
   * @param s string to check.
   */
  bool is_mm_start(std::string& s);
  
  std::vector<double> read_csv_vector(const std::string& s);

}

#endif
