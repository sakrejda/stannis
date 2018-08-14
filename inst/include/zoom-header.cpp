
/* Handle header lines only.  Calculate the number of columns,
 * parameters, names, and structure all in one pass.
 *
 * @param line std::string& representing the header
 * @return header_t tuple with number of column, parameters, names and
 *                  dimensions/index to columns.
 */
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
