
#include <iostream>
#include <fstream>
#include <iomanip>

#include <tuple>
#include <string>
#include <vector>
#include <algorithm>

typedef std::tuple<int, int, std::vector<std::string>, std::vector<int>, std::vector<std::vector<int>>, std::vector<std::vector<int>>> header_t;
typedef std::vector<double> mm_t;
typedef std::vector<std::vector<double>> parameter_t;

void modify_dimensions(std::string::iterator head, std::string::iterator end, std::vector<int>& dim) {
  int i = 0;
  std::string::iterator tail;;
  for (head = std::find(head, end, '.'); head != end; head = std::find(head + 1, end, '.')) {
    tail = std::find(head + 1, end, '.');
    dim[i++] = std::stoi(std::string(head + 1, tail));
  }
}

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

std::string header_summary(header_t& h) {
  int n_col = 0;
  int n_parameters = 0;
  std::vector<std::string> names;
  std::vector<int> n_dim;
  std::vector<std::vector<int>> dimensions;
  std::vector<std::vector<int>> index;
  std::stringstream s;

  std::tie(n_col, n_parameters, names, n_dim, dimensions, index) = h;
  s << "number of columns: " << n_col << ", number of parameters: " << n_parameters << std::endl;
  for (int i = 0; i < n_parameters; ++i) {
    s << "parameter: " << names[i] << ", number of dimensions: " << n_dim[i];
    if (n_dim[i] > 0) 
      s << ", size: ";
      for (int j = 0; j < dimensions[i].size(); ++j) {
        if (j != 0) 
          s << " x ";
        s << dimensions[i][j];
      }
    s << std::endl;
  }
  return s.str();
}

bool is_comment(std::string& s) {
  return *(s.begin()) == '#';
}

void read_parameters(std::string& line, header_t& h, parameter_t& p) {
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

mm_t read_mass_matrix(std::string& line) {
  mm_t mm;
  return mm;
}

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
  return std::make_tuple(header, parameters);
}

int main(int argc, char* argv[]) {
  if(argc != 2) {
    std::cerr << "provide one argument." << std::endl;
    return 1;
  }

  header_t header;
  parameter_t parameters;
  std::ifstream f(argv[1]);
  std::tie(header, parameters) = read_samples(f);

  std::cout << header_summary(header);
  return 0;
}

























