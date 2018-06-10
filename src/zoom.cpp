
#include <iostream>
#include <fstream>
#include <iomanip>

#include <string>
#include <vector>



std::string read_start(std::ifstream& f) {
  std::string start_string;
  while (std::getline(f, start_string)) {
    if (start_string.substr(0,4) == "lp__") {
      std::cout << start_string.substr(0,20) << std::endl;
      break;
    }
  }
  return start_string;
}

int main(int argc, char* argv[]) {
  if(argc != 2) {
    std::cerr << "provide one argument." << std::endl;
    return 1;
  }

  std::ifstream f(argv[1]);
  std::string names;
  names = read_start(f);
  return 0;
}


























