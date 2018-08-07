
#include <iostream>
#include <fstream>
#include <iomanip>

int main () {
  std::string s1 = "8.48051e-314";
  std::cout << s1 << std::endl;
  double d_s1 = 0.0;
  try {
    d_s1 = std::stod(s1);
  } catch(std::out_of_range& e) {
    std::cout << "error: " << e.what() << std::endl;
  }
  std::cout << d_s1 << std::endl;
  return 0;
}
