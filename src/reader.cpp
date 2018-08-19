
#include <iostream>
#include <fstream>

#include <string>
#include <vector>
#include <algorithm>
#include <iterator>
#include <numeric>
#include <cstdint>

#include <boost/filesystem.hpp>

#include <stannis/reader.hpp>
#include <stannis/rewrite-header.hpp>
#include <stannis/read-header-data.hpp>
#include <stannis/rewrite-parameters.hpp>
#include <stannis/write-binary-header.hpp>

namespace stannis {

  bool rewrite(
    const boost::filesystem::path & source,
    const boost::filesystem::path & root,
    const boost::uuids::uuid & tag,
    const std::string & comment
  ) {
    boost::filesystem::fstream source_stream;
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

    // Rewrite the CmdStan header into names and dimensions
    boost::filesystem::fstream name_stream(names_path);
    boost::filesystem::fstream dim_stream(dim_path);
    std::string line;
    bool complete = false;

    std::istreambuf_iterator<char> s_it(source_stream);
    std::istreambuf_iterator<char> end_it;
    char c;
    while (s_it != end_it) {
      if (*s_it == '#')
        while (s_it != end_it && *s_it != '\n') 
          s_it++;
      else 
        break;
    }
    
    complete = rewrite_header(s_it, name_stream, dim_stream); 
    name_stream.close();
    dim_stream.close();
    if (!complete)
      return false;

    // Write binary header file
    std::uint_least32_t n_parameters = get_n_parameters(dim_path);
    boost::filesystem::fstream header_stream;
    header_stream.open(header_path);
    write_stantastic_header(header_stream, tag);
    write_description(header_stream, n_parameters);
    write_comment(header_stream, comment);
    header_stream.close();

    std::uint_least32_t n_iterations;
    std::vector<std::string> names 
      = get_names(names_path);
    std::vector<std::vector<std::uint_least32_t>> dimensions
      = get_dimensions(dim_path);
    rewrite_parameters(s_it, names, dimensions, root, n_iterations);
    //rewrite_mass_matrix(s_it_stream); 
    while (s_it != end_it) {
      if (*s_it == '#')
        while (s_it != end_it && *s_it != '\n') 
          s_it++;
      else 
        break;
    }
    rewrite_parameters(s_it, names, dimensions, root, n_iterations);
    header_stream.open(header_path);
    insert_iterations(header_stream, n_iterations);
    header_stream.close();
//    rewrite_timing(f);
    return true;
  }
  
}






















