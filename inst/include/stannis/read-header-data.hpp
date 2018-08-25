#ifndef READ_HEADER_DATA_HPP
#define READ_HEADER_DATA_HPP

#include <boost/filesystem.hpp>

#include <string>
#include <cstdint>
#include <vector>

namespace stannis {
 
  /* Read the number of named parameters from
   * the dimensions file.
   *
   * Skips irrelevant data.
   *
   * @param path path to the dimensions file.
   * @return number of named parameters in the model
   */
  std::uint_least32_t get_n_parameters(
    const boost::filesystem::path path
  );


  /* Read the number of dimension in of each parameters
   * the dimensions file.
   *
   * Skips irrelevant data.
   *
   * @param path path to the dimensions file.
   * @return number of dimensions in each parameter
   */
  std::vector<std::uint_least16_t> get_ndim(
    const boost::filesystem::path path
  ); 

  /* Read the dimension of each parameters from
   * the dimensions file.
   *
   * @param path path to the dimensions file.
   * @return dimension of each parameter
   */
  std::vector<std::vector<std::uint_least32_t>> get_dimensions(
    const boost::filesystem::path path
  );

  /* Read the names of the (potentially multi-dimensional) parameters
   *
   * The number of names is the number of NAMED parametesr
   * in the model.
   *
   * @param path to the name file
   * @return vector of parameter names
   */
  std::vector<std::string> get_names(
    const boost::filesystem::path path
  );

  /* Gets the (expect 11 character) magic string. */
  std::string get_magic(
    const boost::filesystem::path path
  );

}

#endif
