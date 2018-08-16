#ifndef READER_HPP
#define READER_HPP

#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>

#include <tuple>
#include <string>
#include <vector>
#include <algorithm>
#include <numeric>

#include <stannis/types.hpp>
#include <stannis/file-helpers.hpp>
#include <stannis/sample-header.hpp>

namespace stannis {

  /* Reshapes parameters from [parameter, idx x iteration] to
   * [parameter, iteration, idx]
   *
   * @rparam p reference to parameters to reshape.
   */
  void reshape_parameters(const header_t& h, parameter_t& p);
  
  /* Must handle all the lines of the 'mass matrix' portion within
   * the .csv. 
   *
   * @param commented lines within .csv file.
   * @return mass matrix (mm_t) 
   */
  mm_t read_mass_matrix(std::ifstream& f);
  
  /* Must handle all the lines of the 'timing' portion at the tail of 
   * the .csv. 
   *
   * @param commented lines within .csv file.
   * @return timing (timing_t)
   */
  timing_t read_timing(std::ifstream& f);
    
  /* Reads header, mass matrix, and parameter values from file stream.
   * Assumes a CmdStan sampling file structure.
   *
   * @param input file stream (f) 
   * @return tuple with header and parameters parsed
   */
  std::tuple<header_t, parameter_t, mm_t, timing_t> 
  read_samples(std::ifstream& f);

}

#endif





















