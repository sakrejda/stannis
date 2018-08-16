#ifndef READER_HPP
#define READER_HPP

#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>

#include <tuple>
#include <string>
#include <vector>
#include <algorithm>
#include <numeric>

#include <stannis/types.hpp>
#include <stannis/file-helpers.hpp>
#include <stannis/sample-header.hpp>

namespace stannis {

  /* Rewrite a CmdStan file to mmap-friendly binary format.
   *
   * @param source CmdStan file path
   * @param root directory where to root output files
   * @param tag uuid for the run.
   * @param comment text run description.
   * @return true if a complete rewrite is accomplished.
   */
  bool rewrite(
    const boost::filesystem::path & source,
    const boost::filesystem::path & root,
    const boost::uuids::uuid & tag,
    const std::string & comment
  );
}

#endif





















