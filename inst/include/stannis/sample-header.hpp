#ifndef SAMPLE_HEADER_HPP
#define SAMPLE_HEADER_HPP

#include <stannis/types.hpp>

#include <boost/filesystem.hpp>
#include <boost/uuids/uuid.hpp>

#include <string>

namespace stannis {

  /* Read a name from a stream and copy it to a string. 
   *
   * - expects to only be called if there are more names to read,
   *   that is this is the first read or the last read ended on
   *   a ',' character.
   *
   * @tparam S a stream type with the 'read' method
   * @param stream a stream of type S
   * @param buffer used for buffered reads from the stream
   * @param head iterator into the buffer to start read from
   * @param tail iterator into the buffer to end read at
   * @return true if there are more names to read
   */

  template <class S>
  int read_name(
    S & stream,
    std::array<char> & buffer,
    std::array<char>::iterator & head,
    std::array<char>::iterator & tail
    std::string & name
  ) {
    int offset = 0;
    if (buffer.size() == 0) 
      throw std::logic_error("Read buffer size must be greater than zero.");
    tail = head;
    while (true) {
      tail++;
      if (tail != buffer.end() && (*tail == ',' || *tail == '\n' || *tail == '.')) {
	name.resize(offset + (tail - head));
        std::copy(head, tail, name.begin());
	head = tail;
	break;
      }
      if (tail == buffer.end()) {
        offset += tail - head;
	name.resize(offset);
	std::copy(head, tail, name.begin());
	stream.read(&buffer[0], buffer.size());
	if (stream.gcount() == 0)
	  throw std::logic_error("Unfinished name and unreadable stream.");
	head = buffer.begin();
	tail = head;
	if (*tail == ',' || *tail = '\n' || *tail == '.')
	  break;
      }
    }
    return (*head != '\n');
  }

  template <class S>
  int read_dims(
    S & stream,
    std::array<char> & buffer,
    std::array<char>::iterator & head,
    std::array<char>::iterator & tail
    std::string & name
  ) {

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
    std::array<char>::iterator head = buffer.begin();
    std::array<char>::iterator tail = buffer.begin();
    std::string previous_name;
    std::streampos previous_pos;
    std::string current_name;

    bool read_more = read_name(stream, buffer, head, tail, previous_name);
    previous_pos = stream.tellg() - (buffer.size() - head);

    if (!read_more) {
      name_stream.write((char*)(&previous_name[0]), previous_name.length());
      std::uint_least16_t d = 1;
      dim_stream.write((char*)(&d), sizeof(d));
      dim_stream.write((char*)(&d), sizeof(d));
      return;
    }
    if (*head == '.') {
      read_more = read_dims(stream, buffer, ++head, ++tail, d);
    }

    while (stream.good()) {
      read_more = read_name(stream, head, tail, previous_name);
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
