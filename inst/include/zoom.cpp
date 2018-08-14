
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>

#include <tuple>
#include <string>
#include <vector>
#include <algorithm>
#include <numeric>

#include <zoom-t.hpp>
#include <zoom-helpers.cpp>
#include <write-header.hpp>

/* Helper function that takes iterators to a CmdStan .csv format 
 * column and adjusts the vector of dimensions to be consistent
 * with the name (usually upping the dimension sizes.
 *
 * @param head beginning of column name string
 * @param end one-past-end of column name string
 * @rparam dim vector of dimension sizes
 */
void update_dimensions(std::string::iterator head, std::string::iterator end, std::vector<int>& dim) {
  int i = 0;
  std::string::iterator tail;;
  for (head = std::find(head, end, '.'); head != end; head = std::find(head + 1, end, '.')) {
    tail = std::find(head + 1, end, '.');
    dim[i++] = std::stoi(std::string(head + 1, tail));
  }
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
  std::vector<int> ndim = std::get<3>(h);
  std::vector<std::vector<int>> dims = std::get<4>(h);
  for (auto i = 0; i < ndim.size(); ++i) {
    storage_stream.write((char*)(&ndim[i]), sizeof(ndim[i]));
    for (auto d = 0; d < ndim[i]; ++d) {
      storage_stream.write((char*)(&dims[i][d]), sizeof(dims[i][d]));
    }
  }
  std::streampos dimension_section_end = storage_stream.tellp();
  storage_stream.seekp(dimension_section_offset); // use it before you loose it
  dimension_section_offset = dimension_section_end - dimension_section_offset;
  storage_stream.write((char*)(&dimension_section_offset), sizeof(dimension_section_offset));
  storage_stream.seekp(dimension_section_end);

  // Samples section

  storage_stream.close();
}

/* Must handle all non-commented lines after the header.
 *
 * @param line, the line (std::string reference) to read.
 * @param h, const header tuple reference with indexing info.
 * @param p, reference to parameter_t to modify with new samples.
 * */ 
bool read_parameters(std::string& line, const header_t& h, parameter_t& p) {
  std::stringstream data_stream(line);

  int n_parameters = std::get<1>(h);
  std::vector<std::vector<int>> index = std::get<5>(h);
  p.resize(n_parameters);
 
  std::vector<double> x = read_csv_vector(line);
  if (x.size() < n_parameters)
    return false;
  for (unsigned int i = 0; i < index.size(); ++i) {
    for (unsigned int j = 0; j < index[i].size(); j++) {
      p[i].push_back(x[index[i][j]]);  
    }
  }
  return true;
}

/* Reshapes parameters from [parameter, idx x iteration] to
 * [parameter, iteration, idx]
 *
 * @rparam p reference to parameters to reshape.
 */
void reshape_parameters(const header_t& h, parameter_t& p) {
  int n_parameters = p.size();
  std::vector<std::vector<int>> dimensions = std::get<4>(h);
  for (dv_size_t i = 0; i < p.size(); ++i) {
    dv_size_t n_entries = std::accumulate(
      dimensions[i].begin(), dimensions[i].end(), 1, std::multiplies<dv_size_t>());
    dv_size_t n_iterations = p[i].size() / n_entries;
    std::vector<double> x(p[i].size());
    for (dv_size_t j = 0; j < x.size(); ++j) {
      dv_size_t k = j % n_iterations;
      dv_size_t m = j / n_iterations;
      dv_size_t n = k * n_entries + m;  
      x[j] = p[i][n];
    }
    p[i] = x;
  }  
}

/* Must handle all the lines of the 'mass matrix' portion within
 * the .csv. 
 *
 * @param commented lines within .csv file.
 * @return mass matrix (mm_t) 
 */
mm_t read_mass_matrix(std::ifstream& f) {
  std::string line;
  std::getline(f, line);
  auto head = std::find(line.begin(), line.end(), '=') + 1;
  auto tail = line.end();
  double step_size = std::stod(std::string(head, tail));

  std::getline(f, line);
  std::getline(f, line);
  std::vector<double> mm = read_csv_vector(line.substr(1));
  return std::make_tuple(step_size, mm);
}

/* Must handle all the lines of the 'timing' portion at the tail of 
 * the .csv. 
 *
 * @param commented lines within .csv file.
 * @return timing (timing_t)
 */
timing_t read_timing(std::ifstream& f) {
  std::string line;
  timing_t tt;
  std::getline(f, line);
  auto head = std::find(line.begin() + 1, line.end(), ':') + 1;
  auto tail = std::find(head, line.end(), 's');
  tt.push_back(std::stod(std::string(head, tail)));
  std::getline(f, line);
  head = line.begin() + 1;
  tail = std::find(head, line.end(), 's');
  tt.push_back(std::stod(std::string(head, tail)));
  std::getline(f, line);
  head = line.begin() + 1;
  tail = std::find(head, line.end(), 's');
  tt.push_back(std::stod(std::string(head, tail)));
  return tt;
}
  
/* Reads header, mass matrix, and parameter values from file stream.
 * Assumes a CmdStan sampling file structure.
 *
 * @param input file stream (f) 
 * @return tuple with header and parameters parsed
 */
std::tuple<header_t, parameter_t, mm_t, timing_t> read_samples(std::ifstream& f) {
  header_t header;
  parameter_t parameters;
  mm_t mm;
  timing_t tt;

  std::string line;
  bool got_header = false;
  while (std::getline(f, line)) {
    if (!got_header && !is_comment(line)) {
      header = read_header(line);
      got_header = true;
    } else if (got_header && !is_comment(line)) {
      read_parameters(line, header, parameters);
    } else if (is_mm_start(line)) {
      mm = read_mass_matrix(f);  // advances past line
    } else if (got_header && is_comment(line)) {
      tt = read_timing(f); // advances past line
      break;
    }
  }
  reshape_parameters(header, parameters);
  return std::make_tuple(header, parameters, mm, tt);
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

























