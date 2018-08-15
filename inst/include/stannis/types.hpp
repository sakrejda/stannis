#ifndef TYPES_HPP
#define TYPES_HPP

#include <tuple>
#include <vector>
#include <string>

typedef std::vector<double>::size_type dv_size_t;
typedef std::vector<double>::size_type iv_size_t;

// 0: n_col
// 1: n_parameters (named), 
// 2: parameter_names, 
// 3: n_dim (per parameter), 
// 4: dimension of each parameter, 
// 5: index where to find each parameter, 
// 6: offset for start of each parameter, 
// 7: number of scalars in each parameter
typedef std::tuple<int, int, std::vector<std::string>, std::vector<int>, 
        std::vector<std::vector<int>>, std::vector<std::vector<int>>,
	std::vector<int>, std::vector<int>> header_t;
typedef std::tuple<double, std::vector<double>> mm_t;
typedef std::vector<std::vector<double>> parameter_t;
typedef std::vector<double> timing_t;

#endif
