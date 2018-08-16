
#include <iostream>
#include <fstream>

#include <string>
#include <vector>
#include <algorithm>
#include <numeric>
#include <cstdint>

#include <boost/filesystem.hpp>

#include <stannis/file-helpers.hpp>
#include <stannis/reader.hpp>
#include <stannis/write-file-header.hpp>
#include <stannis/sample-header.hpp>

namespace stannis {

  bool rewrite(
    const boost::filesystem::path & source,
    const boost::filesystem::path & root,
    const std::string & name,
    const boost::uuids::uuid & tag,
    const std::uint_least32_t n_parameters;
    const std::string & comment
  ) {
    std::uintmax_t source_size = boost::filesystem::file_size(source);
    boost::filesystem::fstream source_stream;
    source_stream.open(source);

    // Shared storage directory
    boost::filesystem::path storage_path = root /= name;
    boost::filesystem::path header_path = storage_path /= "header.bin";
    boost::filesystem::path names_path = storage_path /= "names.bin";
    boost::filesystem::path dim_path = storage_path /= "dimensions.bin";
    boost::filesystem::path storage_path = create_storage_file(root, name, 2 * source_size);

    // Name file
    boost::filesystem::fstream os;
    os.open(header_path);
    write_stantastic_header(os, tag);
    write_description(os, n_parameters);
    write_comment(os, comment);
    os.close()

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
    if (!complete)
      return false;

    boost::iostreams::mapped_file_sink storage(storage_path); 
    //boost::iostreams::stream<boost::iostreams::mapped_file_sink> os(storage);
    rewrite_parameters(source_stream, names, dims, path);
    rewrite_mass_matrix(source_stream); 
    rewrite_parameters(source_stream, names, dims, path);
    rewrite_timing(f);
    return true;
  }
  
}






















