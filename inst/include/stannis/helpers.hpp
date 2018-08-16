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
  
}

#endif
