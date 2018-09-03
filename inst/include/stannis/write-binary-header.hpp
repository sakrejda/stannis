#ifndef WRITE_BINARY_HEADER_HPP
#define WRITE_BINARY_HEADER_HPP

#include <cstdint>
#include <iostream>
#include <boost/uuid/uuid.hpp>

namespace stannis {

  const char* magic = "Stantastic!";
  const std::uint_least32_t file_version = 1;
  const std::uint_least32_t major_stan = 2;
  const std::uint_least32_t minor_stan = 17;
  const std::uint_least32_t patch_stan = 3;

  template<class S>
  void write_stantastic_header(
    S & stream, 
    const boost::uuids::uuid & tag,
    const std::string & comment
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

    // Comment
    std::uint_least32_t L = comment.length();
    stream.write((char*)(&L), sizeof(L));
    stream.write((char*)(&comment[0]), L);

    return;
  }

} // 


#endif
