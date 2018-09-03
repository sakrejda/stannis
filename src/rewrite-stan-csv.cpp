
#include <stannis/rewrite-stan-csv.hpp>
#include <stannis/rewrite-header.hpp>

#include <stannis/write-binary-header.hpp>
#include <stannis/read-header-data.hpp>
#include <stannis/read-name-data.hpp>
#include <stannis/read-dimension-data.hpp>

#include <stannis/rewrite-parameters.hpp>
#include <stannis/rewrite-parameter-dimensions.hpp>
#include <stannis/reshape-parameters.hpp>

#include <boost/filesystem.hpp>

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>
#include <iterator>
#include <numeric>
#include <cstdint>



namespace stannis {

  // See header.
  bool rewrite_stan_csv(
    const boost::filesystem::path & source,
    const boost::filesystem::path & root,
    const boost::uuids::uuid & tag,
    const std::string & comment,
    const bool try_mass_matrix
  ) {
    // Stream from CmdStan file
    boost::filesystem::ifstream source_stream;
    source_stream.open(source);
    
    // Shared storage directory
    boost::filesystem::path header_path(root);
    header_path /= "header.bin";
    boost::filesystem::path names_path(root);
    names_path /= "names.bin";
    boost::filesystem::path dim_path(root);
    dim_path /= "dimensions.bin";
    boost::filesystem::path mm_path(root); 
    mm_path /= "mass_matrix.bin";

    // output streams (open later)
    boost::filesystem::fstream name_stream(names_path, std::ofstream::out | std::ofstream::trunc);
    boost::filesystem::fstream dim_stream(dim_path, std::ofstream::out | std::ofstream::trunc);
    std::istreambuf_iterator<char> s_it(source_stream);
    boost::filesystem::fstream header_stream;

    bool complete = skip_comments(s_it);
    if (!complete)
      return false;
    
    // Rewrite the CmdStan header into names and dimensions
    complete = rewrite_header(s_it, name_stream, dim_stream); 
    name_stream.close();
    dim_stream.close();
    if (!complete)
      return false;

    // Write binary header file
    header_stream.open(header_path, std::ofstream::out | std::ofstream::trunc);
    write_stantastic_header(header_stream, tag, comment);
    header_stream.close();

    // Rewrite parameters in binary
    std::uint_least32_t n_iterations = 0;
    std::vector<std::string> names 
      = get_names(names_path);
    std::vector<std::uint_least32_t> ndims 
      = get_ndim(dim_path);
    std::vector<std::vector<std::uint_least32_t>> dimensions
      = get_dimensions(dim_path);
    complete = rewrite_parameters(s_it, names, dimensions, root, n_iterations,
      std::ofstream::out | std::ofstream::trunc);
    if (!complete)
      return false;

    //rewrite_mass_matrix(s_it_stream); 
    //skip mass matrix for now...
    complete = skip_comments(s_it);  
    if (!complete)
      return false;
   
    // Rewrite rest of iterations
    complete = rewrite_parameters(s_it, names, dimensions, root, n_iterations, 
      std::ofstream::out | std::ofstream::app);
    if (!complete)
      return false;

    // Rewrite per-parameter dimensions files:
    complete = rewrite_parameter_dimensions(root, n_iterations);
    if (!complete)
      return false;

    // Reshape each per-parameter file:
    complete = reshape_parameters(root);
    if (!complete)
      return false;

//    rewrite_timing(f);
    return true;
  }
  
}






















