#include <file-helpers.hpp>

#include <vector>
#include <string>
#include <sstream>

namespace stannis {

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
    return is_comment(s) && s.find("Adaptation terminated") != std::string::npos;
  }
  
  std::vector<double> read_csv_vector(const std::string& s) {
    std::stringstream data_stream(s);
    std::vector<double> x;
    while (data_stream.good()) {
      char comma;
      double value;
      data_stream >> value >> comma;
      x.push_back(value);
    } 
    return x;
  }

}
