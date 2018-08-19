#ifndef WRITE_BINARY_HEADER_HPP
#define WRITE_BINARY_HEADER_HPP

#include <cstdint>
#include <iostream>
#include <boost/uuid/uuid.hpp>

namespace stannis {

  const char* magic = "Stantastic!";
  const std::uint_least32_t file_version = 1;
  const std::uint_least16_t major_stan = 2;
  const std::uint_least16_t minor_stan = 17;
  const std::uint_least16_t patch_stan = 3;

  constexpr std::uint_least8_t n_iterations_position = std::ios::beg + 11 
    + sizeof(std::uint_least32_t) + sizeof(std::uint_least16_t) * 3;

  template<class S>
  void write_stantastic_header(
    S & stream, 
    const boost::uuids::uuid & tag
  ) {
    // Magic string          
    stream.write(stannis::magic, 11);       
    
    // File version
    stream.write((char*)(&stannis::file_version), sizeof(stannis::file_version));
    stream.write((char*)(&stannis::major_stan), sizeof(stannis::major_stan));
    stream.write((char*)(&stannis::minor_stan), sizeof(stannis::minor_stan));
    stream.write((char*)(&stannis::patch_stan), sizeof(stannis::patch_stan));

    // UUID tag
    stream.write((char*)(&tag.data[0]), tag.static_size());
    
    return;
  }

  template <class S>
  void insert_iterations(
    S & stream,
    std::uint_least32_t n_iterations
  ) {
    std::streampos current_position = stream.tellp();
    stream.seekp(stannis::n_iterations_position);
    stream.write((char*)(&n_iterations), sizeof(n_iterations));
    stream.seekp(current_position);
  };

  template <class S>
  void write_description(
    S & stream,
    std::uint_least32_t n_parameters
  ) {
    std::uint_least32_t n_iterations = 0; // modified later
    stream.write((char*)(&n_iterations), sizeof(n_iterations));
    stream.write((char*)(&n_parameters), sizeof(n_parameters));
    return;
  }

  template <class S>
  void write_comment(
    S & stream,
    const std::string & comment
  ) {
    std::uint_least32_t L = comment.length();
    stream.write((char*)(&L), sizeof(L));
    stream.write((char*)(&comment[0]), L);
    return;
  }

} // 


#endif
