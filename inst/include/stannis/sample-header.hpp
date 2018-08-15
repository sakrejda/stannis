#ifndef SAMPLE_HEADER_HPP
#define SAMPLE_HEADER_HPP

#include <stannis/types.hpp>

#include <boost/filesystem.hpp>
#include <boost/uuids/uuid.hpp>

#include <string>

namespace stannis {

  /* Handle header lines only.  Calculate the number of columns,
   * parameters, names, and structure all in one pass.
   *
   * @param line std::string& representing the header
   * @return header_t tuple with number of column, parameters, names and
   *                  dimensions/index to columns.
   */
  header_t read_header(std::string& line);

  /* Write header to binary stream. */
  bool write_header(
    header_t& h, 
    boost::filesystem::path p,
    boost::uuids::uuid tag
  );

  /* Streaming re-write of text header line to output file. */
  template <class S1, class S2>
  void rewrite_header(
    std::string & line,
    S1 & name_stream,
    S2 & dim_stream
  ) {
    
    auto head = line.begin();
    auto tail = std::find(head, line.end(), ",");
    auto dot = std::find(head, tail, ".");
  
    std::string previous_name(head, dot);
    std::string::iterator previous_dot(dot);
    std::string::iterator previous_tail(tail);
    if (tail == line.end()) {
      int ndim = 0;
      name_stream.write((char*)(&previous_name[0]), previous_name.length());
      dim_stream.write((char*)(&ndim), sizeof(ndim));
    }
    while (head != line.end()) {
      head = tail;
      tail = std::find(head + 1, line.end(), ",");
      dot = std::find(head + 1, tail, ".");
      std::string current_name(head + 1, dot);
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
