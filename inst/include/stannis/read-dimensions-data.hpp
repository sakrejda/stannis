#ifndef READ_DIMENSIONS_DATA_HPP
#define READ_DIMENSIONS_DATA_HPP

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
  std::vector<std::uint_least32_t> get_ndim(
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


}

#endif
