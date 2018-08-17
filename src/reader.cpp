
#include <iostream>
#include <fstream>

#include <string>
#include <vector>
#include <algorithm>
#include <numeric>
#include <cstdint>

#include <boost/filesystem.hpp>

#include <stannis/helpers.hpp>
#include <stannis/reader.hpp>
#include <stannis/rewrite-column-names.hpp>
#include <stannis/read-header-data.hpp>

namespace stannis {

  bool rewrite(
    const boost::filesystem::path & source,
    const boost::filesystem::path & root,
    const boost::uuids::uuid & tag,
    const std::string & comment
  ) {
    std::uintmax_t source_size = boost::filesystem::file_size(source);
    boost::filesystem::fstream source_stream;
    source_stream.open(source);

    // Shared storage directory
    boost::filesystem::path header_path = root /= "header.bin";
    boost::filesystem::path names_path = root /= "names.bin";
    boost::filesystem::path dim_path = root /= "dimensions.bin";

    // Rewrite the CmdStan header into names and dimensions
    boost::filesystem::fstream name_stream(names_path);
    boost::filesystem::fstream dim_stream(dim_path);
    std::string line;
    bool complete = false;
    while (std::getline(source_stream, line)) {
      if (!is_comment(line)) {
        complete = rewrite_header(line, name_stream, dim_stream);  // FIXME: streams
        break;
      }
    }
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
    header_stream.close()

    std::uint_least32_t n_iterations;
    std::vector<std::vector<std::uint_least32_t>> dimensions = get_dimensions(dim_path);
    rewrite_parameters(source_stream, dimensions, root_path, n_iterations);
    rewrite_mass_matrix(source_stream); 
    rewrite_parameters(source_stream, dimensions, root_path, n_iterations);
    header_stream.open(header_path);
    insert_iterations(n_iterations, header_stream);
    header_stream.close();
    rewrite_timing(f);
    return true;
  }
  
}






















