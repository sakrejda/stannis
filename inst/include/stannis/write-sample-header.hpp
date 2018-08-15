#ifndef WRITE_SAMPLE_HEADER_HPP
#define WRITE_SAMPLE_HEADER_HPP

#include <cstdint>
#include <iostream>

namespace stannis {

  template <class S, class T>
  void insert(S & stream, std::streampos pos, T x) {
    std::streampos current = stream.tellp();
    stream.seekp(pos);
    stream.write((char*)(&x), sizeof(x));
    stream.seekp(current);
    return;
  }

  template <class S>
  void write_names(
    S & stream, 
    const std::vector<std::string> & names
  ) {
    std::uint_least64_t offset_pos = stream.tellp();
    stream.write((char*)(&offset), sizeof(offset));
    for (const std::string& s : names) {
      std::uint_least16_t L = s.length();
      stream.write((char*)(&L), sizeof(L));
      stream.write((char*)(&s[0]), L);
    }
    return;
  }

  template <class S>
  void write_dimensions(
    S & stream,
    const std::vector<std::vector<int>> & dimensions
  ) {
    for(const std::vector<int> & dims : dimensions) {
      int ndim dims.size();
      stream.write((char*)(&ndim), sizeof(ndim));
      for (const int d : dims)
	stream.write((char*)(&d), sizeof(int));
    }
    return;
  }

}


#endif




