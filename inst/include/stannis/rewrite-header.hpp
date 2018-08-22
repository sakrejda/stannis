#ifndef REWRITE_HEADER_HPP
#define REWRITE_HEADER_HPP

#include <string>
#include <cstdint>
#include <vector>
#include <algorithm>

namespace stannis {

  /* Read a name from a stream and copy it to a string
   *
   * - after the call both head and tail will point to either
   *   '.', ',', or '\n' (if return true) and string::iterator::end() 
   *   (if return false)
   *
   * @tparam I type of iterator to use (std::string::iterator is good).
   * @param head iterator into the sequence to read from
   * @param guard iterator to the end of the sequence
   * @param name std::string to copy name into
   * @return false if stream is truncated (ends without newline).
   */
  template <class I>
  bool read_name(
    I & head,
    I & guard,
    std::string & name
  ) {
    name.clear();
    if (head == guard)
      return false;
    if (*head == ',')
      head++;
      if (head == guard)
        return false;

    auto tail = head;
    while (tail != guard) {
      if (*tail == ',' || *tail == '\n' || *tail == '.')
        break;
      else
	name.append(1, *tail);
      tail++;
    }
    head = tail;
    return (tail != guard);
  }

  /* Read a set of dimensions from a stream and copy it to vector
   *
   * - after the call both head and tail will point to either
   *   ',', or '\n' (if return true) and I::iterator::end() 
   *   (if return false)
   *
   * @tparam I type of iterator (usually std::string::iterator works good)
   * @param head iterator the sequence to read from
   * @param guard iterator to the end of the sequence
   * @param name std::vector<std::uint_least32_t> to read dims into.
   * @return false if stream is truncated (ends without newline).
   */
  template <class I>
  bool read_dims(
    I & head,
    I & guard,
    std::vector<std::uint_least32_t> & dims
  ) {
    std::ofstream of("/tmp/of.txt", std::ofstream::out | std::ofstream::app); 
    if (head == guard) 
      return false;
    if (*head != '.') {
      of << "scalar" << std::endl;
      dims.push_back(1);
      return true;
    } 
    if (++head == guard) {
      return false; 
    } 

    auto tail = head;
    dims.clear();
    std::string ds;
    of << "try it." << std::endl;
    while (tail != guard) {
      of << "trying." << std::endl;
      if (*tail == ',' || *tail == '\n' || *tail == '.') {
        std::uint_least32_t d = std::stoi(ds);
        ds.clear();
        dims.push_back(d);
        if (*tail != '.')
          break;
      } else {
        ds.append(1, *tail);
        tail++;
        head = tail;
      }
      of << ds << std::endl;
    }
    if (tail != guard && dims.size() == 0) 
      dims.push_back(1);
    head = tail;
    return (tail != guard);
  }

  /* Write out a name (to name_stream) and dimensions (to dim_stream)
   *
   * @param name reference to parameter name string.
   * @param head reference to iterator to start dim read from
   * @param guard reference to end of sequence iterator (for dims)
   * @param name_stream where to write names
   * @param dim_stream where to write dims
   * @return bool true of both streams are good after writes.
   */
  template <class I, class S1, class S2>
  bool handle_name(
    std::string & name,
    I & head,
    I & guard,
    S1 & name_stream,
    S2 & dim_stream
  ) {
    std::uint_least16_t L = name.length();
    name_stream.write((char*)(&L), sizeof(L));
    name_stream.write((char*)(&name[0]), L);
    std::vector<std::uint_least32_t> dims;
    read_dims(head, guard, dims);
    std::uint_least16_t ndim = dims.size();
    dim_stream.write((char*)(&ndim), sizeof(ndim));
    for (const std::uint_least32_t d : dims)
      dim_stream.write((char*)(&d), sizeof(d));
    return name_stream.good() && dim_stream.good();
  }
  

  /* Streaming re-write of text header line to output file.
   *
   * Names are only written once per parameter, and dimensiosn are
   * only calculated once per parameter.
   *
   * @tparam S1 type of stream to write names to
   * @tparam S2 type of stream to write dimensions to 
   * @param header std::string with the entire header
   * @param name_stream what to write names to
   * @param dim_stream what to write dimensions to 
   * @return false if the header is incomplete (no final newline)
   */
  template <class I, class S1, class S2>
  bool rewrite_header(
    I & head,
    S1 & name_stream,
    S2 & dim_stream
  ) {
    std::ofstream of("/tmp/of.txt", std::ofstream::out | std::ofstream::app); 
    I dot;
    I end;
    std::string previous_name;
    std::string current_name;

    bool good = read_name(head, end, previous_name);
    dot = head;
    if (*head == '\n') {
      handle_name(previous_name, dot, end, name_stream, dim_stream);
      return true;
    }
    while (head != end && *head != '\n') {
      of << "Good head: " << *head << std::endl;
      of << "previous_name: " << previous_name << std::endl;
      of << "current_name: " << current_name << std::endl;
      if (*head == '.') {
        head = std::find(head, end, ',');
        if (head == end)
          return false;
      }
      if(!read_name(head, end, current_name))
        return false;
      if (current_name != previous_name) 
        handle_name(previous_name, dot, end, name_stream, dim_stream);
      dot = head;
      previous_name = current_name;
    }
    handle_name(current_name, dot, end, name_stream, dim_stream);
    head = dot;
    name_stream.flush();
    dim_stream.flush();
    return true;
  }

}


#endif
