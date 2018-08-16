#ifndef SAMPLE_HEADER_HPP
#define SAMPLE_HEADER_HPP

#include <stannis/types.hpp>

#include <boost/filesystem.hpp>
#include <boost/uuids/uuid.hpp>

#include <string>

namespace stannis {

  void read_name(
    std::basic_istream & stream,
    std::array<char> & buffer,
    std::array<char>::iterator & head,
    std::array<char>::iterator & tail
    std::string & name
  ) {
    tail = head;
    while (true) {
      tail++;
      if (*tail == ',' || *tail == '\n') {
	name.resize(tail - head);
        std::copy(head, tail, name);
	break;
      }
      if (tail == buffer.end()) {
        offset = tail - head;
	name.resize(offset);
	std::copy(head, tail, name);
	stream.read(&buffer[0], buffer.size());
      }
    }
    return;
  }

  /* Streaming re-write of text header line to output file. */
  template <class S1, class S2>
  void rewrite_header(
    std::basic_istream & stream,
    S1 & name_stream,
    S2 & dim_stream, 
    int buffer_size = 8192
  ) {
    std::array<char> buffer(buffer_size);
    stream.read(&buffer[0], buffer_size);
    int paved = buffer_size;
    int offset = 0;
    bool end_header = false;
  
    std::array<char>::iterator head = buffer.begin();
    std::array<char>::iterator tail = std::find(head, head + paved, ',');
    if (tail == head + paved) 
      throw std::logic_error("First name is too long.");
    std::array<char>::iterator end = std::find(head, tail, '\n');
    if (end != tail) {
      n_extra = end - tail - 1; // -1 for implicitely dropping the newline!
      tail = end;
      while (n_extra != 0) {
        stream.putback(*(++end));  // pre-increment skips newline
	--n_extra;
      }
      end_header = true;
    }
    std::array<char>::iterator dot = std::find(head, tail, '.');

    std::string previous_name(head, tail);
    std::array<char>::iterator previous_dot;
    std::array<char>::iterator previous_tail;
    while (stream.good()) {
      head = tail + 1;
      tail = std::find(head, head + paved, ',');
      end = std::find(head, tail, '\n');
      if (end != tail) {
        n_extra = end - tail - 1; // -1 for implicitely dropping the newline!
        tail = end;
        while (n_extra != 0) {
          stream.putback(*(++end));  // pre-increment skips newline
  	--n_extra;
        }
        end_header = true;
      }
      dot = std::find(head, tail, '.');


      if (current_name == previous_name) {
	previous_dot = dot;
	previous_tail = tail;
      } else { // handle previous name
        name_stream.write((char*)(&previous_name[0]), previous_name.length());
	std::vector<int> dims;
	while (previous_dot != previous_tail) {
	  dot = std::find(previous_dot, previous_tail, ".");
	  dims.push_back(std::stoi(std::string(previous_dot + 1, dot))); 
          previous_dot = std::find(dot + 1, previous_tail, ".");
        }
	int ndim = dims.size();
	dim_stream.write((char*)(&ndim), sizeof(ndim));
	for (const int d : dims) {
          dim_stream write((char*)(&d), sizeof(d));
	}
      }
      previous_name = current_name;
    }
    return;
  }

}


#endif
