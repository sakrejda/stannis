#include <stannis/types.hpp>
#include <stannis/sample-header.hpp>

#include <boost/uuids/uuid.hpp>

#include <tuple>
#include <vector>
#include <iostream>
#include <string>

namespace stannis {
  header_t read_header(std::string& line) {
    int n_col = 0;
    int n_parameters = 0;
    std::vector<std::string> names;
    std::vector<int> n_dim;
    std::vector<std::vector<int>> dimensions;
    std::vector<std::vector<int>> index;
    std::vector<int> offsets;
    std::vector<int> sizes;
  
    auto head = line.begin();
    auto tail = line.begin();
  
    std::string current_name;
    std::string last_name = "";
    while (tail != line.end()) {
      tail = std::find(head, line.end(), ',');
      n_col++;
      current_name = std::string(head, std::find(head, tail, '.'));
  
      if (current_name != last_name) {
        n_parameters++;
        names.push_back(current_name); 
        int current_dim = std::count(head, tail, '.');
        n_dim.push_back(current_dim);
        std::vector<int> dim(0);
        for (int i = 0; i < current_dim; ++i) {
          dim.push_back(1);
        }
        dimensions.push_back(dim);
        index.push_back({n_col - 1});
      } else {
        index[index.size() - 1].push_back(n_col - 1);
        update_dimensions(head, tail, dimensions[dimensions.size() - 1]); 
      }
      last_name = current_name;
      if (tail != line.end())
        head = tail + 1;
    }
    for (iv_size_t i = 0; i < index.size(); ++i) {
      offsets.push_back(index[i][0]);
      sizes.push_back(index[i].size());
    }
    return std::make_tuple(n_col, n_parameters, names, n_dim, dimensions, index, offsets, sizes);
  }
  
  /* Write a header in an (easily seekable) binary format.
   *
   * @param header_t tuple with header data.
   * @param file_path boost::filesystem::path to write to
   * @return bool, 0 success 1 on failure
   */
  bool write_header(
    header_t& h, 
    boost::filesystem::path p,
    boost::uuids::uuid tag
  ) {
    boost::filesystem::fstream storage_stream;
    storage_stream.open(p, std::ios::out);
  
    write_stantastic_header(storage_stream, tag);
    write_description(storage_stream, std::get<1>(h)); 
    write_comment(storage_stream, "");
    
    std::uint_least64_t name_section_offset(storage_stream.tellp());  // modified later, leave space
    write_names(storage_stream, std::get<2>(h));
    insert(storage_stream, name_section_offset, storage_stream.tellp() - name_section_offset);
  
  
    // Dimensions seaction
    std::uint_least64_t dimension_section_offset(storage_stream.tellp()); // modified later
    write_dimensions(storage_stream, std::get<4>(h));
    insert(storage_stream, dimension_section_offset, 
      storage_stream.tellp() - dimension_section_offset);
    // Samples section
  
    storage_stream.close();
  }

}

