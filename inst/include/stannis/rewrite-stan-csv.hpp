#ifndef REWRITE_STAN_CSV_HPP
#define REWRITE_STAN_CSV_HPP

#include <boost/filesystem.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_io.hpp>


#include <string>

namespace stannis {

  /* Function rewrites a CmdStan-format .csv file into a multi-file binary version.
   *
   * @param source path to the CmdStan file
   * @param root path to directory that should hold the binary files
   * @param tag UUID to insert into the binary header
   * @param comment string comment to insert into binary header
   * @return bool true iff the CmdStan format file was complete.
   */
  bool rewrite_stan_csv(
    const boost::filesystem::path & source,
    const boost::filesystem::path & root,
    const boost::uuids::uuid & tag,
    const std::string & comment,
    const bool try_mass_matrix
  );
}

#endif





















