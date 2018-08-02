#ifndef ZOOM_T_CPP
#define ZOOM_T_CPP

#include <tuple>
#include <vector>
#include <string>

// n_col, n_parameters (named), parameter_names, n_dim (per parameter), 
// dimension of each parameter, index where to find each parameter
typedef std::tuple<int, int, std::vector<std::string>, std::vector<int>, 
        std::vector<std::vector<int>>, std::vector<std::vector<int>>> header_t;
typedef std::tuple<double, std::vector<double>> mm_t;
typedef std::vector<std::vector<double>> parameter_t;
typedef std::vector<double> timing_t;


#endif
