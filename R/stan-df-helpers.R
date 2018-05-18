
#' Create an array from a Stan-style data frame for a 
#' given parameter.
#'
#' @param data data frame of the set of columns for a given
#'        parameter.
#' @return array of correct dimension for the given parameter
#'         indexed as in the Stan model.
#' @export
generate_parameter_array <- function(data) {
  column_names <- colnames(data)
  num_rows <- nrow(data)
  names <- extract_parameter_names(column_names)
  dim_dims <- generate_dims(column_names)
  if (length(dim_dims) == 1 && dim_dims == 0) {
    dim_list <- c(iteration=nrow(data))
  } else { 
    dim_list <- c(num_rows,as.list(dim_dims))
    names(dim_list) <- c('iteration',letters[9:(9+length(dim_list)-2)])
  }
	o <- array(data=unlist(data), dim=dim_list)
	return(o)
}

#' Split Stan-style data from a .csv file by parameter.
#'
#' @param x Stan-format .csv parameter data.
#' @return list of Stan-format parameter data, with one 
#'         entry (data.frame) per parameter
#' @export
split_data_by_parameter <- function(data) {
  cn = names(data)
  split_column_idx = get_split_column_indexes(cn)
  o <- list()
  for (name in names(split_column_idx)) {
    o[[name]] <- data[,split_column_idx[[name]], drop=FALSE]
  }
  return(o)
}

#' Generate one properly sized array for each Stan parameter
#' in a given Stan-format data frame.
#'
#' @param data stan .csv file loaded as data.frame
#' @return list of arrays (element per named parameter).
#' @export
generate_parameter_arrays <- function(data) {
  data <- split_data_by_parameter(data)
  d <- list()
  for (name in names(data))
    d[[name]] <- generate_parameter_array(data[[name]])
  return(d)
}




