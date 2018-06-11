
#include <iostream>
#include <fstream>
#include <iomanip>

#include <tuple>
#include <string>
#include <vector>
#include <algorithm>
#include <numeric>

#include <zoom-t.hpp>
#include <zoom-helpers.cpp>

/* Helper function that takes iterators to a CmdStan .csv format 
 * column and adjusts the vector of dimensions to be consistent
 * with the name (usually upping the dimension sizes.
 *
 * @param head beginning of column name string
 * @param end one-past-end of column name string
 * @rparam dim vector of dimension sizes
 */
void modify_dimensions(std::string::iterator head, std::string::iterator end, std::vector<int>& dim) {
  int i = 0;
  std::string::iterator tail;;
  for (head = std::find(head, end, '.'); head != end; head = std::find(head + 1, end, '.')) {
    tail = std::find(head + 1, end, '.');
    dim[i++] = std::stoi(std::string(head + 1, tail));
  }
}

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
      modify_dimensions(head, tail, dimensions[dimensions.size() - 1]); 
    }
    last_name = current_name;
    if (tail != line.end())
      head = tail + 1;
  }
  return std::make_tuple(n_col, n_parameters, names, n_dim, dimensions, index);
}

/* Must handle all non-commented lines after the header.
 *
 * @param line, the line (std::string reference) to read.
 * @param h, const header tuple reference with indexing info.
 * @param p, reference to parameter_t to modify with new samples.
 * */ 
void read_parameters(std::string& line, const header_t& h, parameter_t& p) {
  auto head = line.begin();
  auto tail = line.begin();

  int n_parameters = 0;
  std::vector<int> n_dim;
  std::vector<std::vector<int>> index;
  std::tie(std::ignore, n_parameters, std::ignore, n_dim, std::ignore, index) = h;
  p.resize(n_parameters);
 
  std::vector<double> x;
  while (tail != line.end()) {
    tail = std::find(head, line.end(), ',');
    x.push_back(std::stod(std::string(head, std::find(head, tail, ','))));
    if (tail != line.end())
      head = tail + 1;
  } 
  for (unsigned int i = 0; i < index.size(); ++i) {
    for (unsigned int j = 0; j < index[i].size(); j++) {
      p[i].push_back(x[index[i][j]]);  
    }
  }
}

/* Reshapes parameters from [parameter, idx x iteration] to
 * [parameter, iteration, idx]
 *
 * @rparam p reference to parameters to reshape.
 */
void reshape_parameters(const header_t& h, parameter_t& p) {
  int n_parameters = p.size();
  std::vector<std::vector<int>> dimensions = std::get<4>(h);
  for (std::vector<double>::size_type i = 0; i < p.size(); ++i) {
    std::vector<double>::size_type n_entries = std::accumulate(
      dimensions[i].begin(), dimensions[i].end(), 1, std::multiplies<std::vector<double>::size_type>());
    std::vector<double>::size_type n_iterations = p[i].size() / n_entries;
    std::vector<double> x(p[i].size());
    for (std::vector<double>::size_type j = 0; j < x.size(); ++j) {
      std::vector<double>::size_type k = j % n_iterations;
      std::vector<double>::size_type m = j / n_iterations;
      std::vector<double>::size_type n = k * n_entries + m;  
      x[j] = p[i][n];
    }
    p[i] = x;
  }  
}

/* Must handle all the lines of the 'mass matrix' portion within
 * the .csv.  Not done yet. 
 *
 * @param commented lines within .csv file.
 * @return mass matrix (mm_t) 
 */
mm_t read_mass_matrix(std::string& line) {
  mm_t mm;
  return mm;
}


/* Reads header, mass matrix, and parameter values from file stream.
 *
 * @param input file stream (f) 
 * @return tuple with header and parameters parsed
 */
std::tuple<header_t, parameter_t> read_samples(std::ifstream& f) {
  header_t header;
  int n_col = 0;
  int n_parameters = 0;
  std::vector<std::string> names;
  std::vector<int> n_dim;
  std::vector<std::vector<int>> dimensions;
  std::vector<std::vector<int>> index;
  parameter_t parameters;

  std::string line;
  bool got_header = false;
  while (std::getline(f, line)) {
    if (!got_header && !is_comment(line)) {
      header = read_header(line);
      std::tie(n_col, n_parameters, names, n_dim, dimensions, index) = header;
      got_header = true;
    } else if (got_header && !is_comment(line)) {
      read_parameters(line, header, parameters);
    } else if (got_header && is_comment(line)) {
      mm_t mm = read_mass_matrix(line);
    }
  }
  reshape_parameters(header, parameters);
  return std::make_tuple(header, parameters);
}

/* Test program. */
//int main(int argc, char* argv[]) {
//  if(argc != 2) {
//    std::cerr << "provide one argument." << std::endl;
//    return 1;
//  }
//
//  header_t header;
//  parameter_t parameters;
//  std::ifstream f(argv[1]);
//  std::tie(header, parameters) = read_samples(f);
//
//  std::cout << header_summary(header);
//  return 0;
//}

























