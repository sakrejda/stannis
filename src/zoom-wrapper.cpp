#include <fstream>
#include <cerrno>
#include <system_error>
#include <tuple>

#include <zoom.cpp>
#include <Rcpp.h>

/* Function to call from R to get header and parameter sample
 * in a list.
 *
 * @param 
 */
// [[Rcpp::export]]
Rcpp::List read_cmdstan_csv(Rcpp::StringVector file) {
  header_t header;
  parameter_t parameters;
  mm_t mass_matrix;
  timing_t timing;
  std::ifstream f(file[0]);
  if(f.fail())
    throw std::system_error(EBADF, std::system_category(), "Failed to open file.");
  std::tie(header, parameters, mass_matrix, timing) = read_samples(f);
  return Rcpp::List::create(
    Rcpp::Named("n_col") = std::get<0>(header),
    Rcpp::Named("n_parameters") = std::get<1>(header),
    Rcpp::Named("p_names") = std::get<2>(header),
    Rcpp::Named("n_dim") = std::get<3>(header),
    Rcpp::Named("dimensions") = std::get<4>(header),
    Rcpp::Named("index") = std::get<5>(header),
    Rcpp::Named("offsets") = std::get<6>(header),
    Rcpp::Named("sizes") = std::get<7>(header),
    Rcpp::Named("parameters") = parameters, 
    Rcpp::Named("timing") = timing,
    Rcpp::Named("step_size") = std::get<0>(mass_matrix),
    Rcpp::Named("mass_matrix") = std::get<1>(mass_matrix)
  );
}

