
#' Extract array set from a Stan file set.
#'
#' @param set object created by `read_stan_set`
#' @return list of arrays, one per chain in set 
#' @export
create_array_set <- function(set) {
  for (i in 1:set[['n_chains']]) {
    set[['data']][[i]] <- generate_parameter_arrays(set[['data']][[i]]) 
  }
  return(set)
}

#' Extract a single parameter array from a Stan file set.
#'
#' @param set object created by `read_stan_set`
#' @return list of arrays, one per chain in set 
#' @export
extract_array <- function(set, parameter) {
  o <- list()
  for (i in seq_along(set[['data']])) {
    wh = colnames(set[['data']][[i]]) %>% get_split_column_indexes()
    sub_data <- set[['data']][[i]][,wh[[parameter]]]
    o[[i]] <- generate_parameter_array(sub_data)
  }
  return(o)
}

#' Label parameter array 
#'
#' @param array, Stan-dimension (+1 for iteration) array of 
#'        parameter samples
#' @param labels, list, matching array dimensions, used to
#'        label array margins, one list element per dimension, 
#'        name is the dimension name, each entry is a vector
#'        with labels or each entry of the dimension index.
label_array <- function(A, labels) { 
  dimnames(A) <- labels 
  return(A)
}

#' Array to long-form
#'
#' @param array
#' @param labels
#'
array_to_long_form <- function(A, labels) {}


