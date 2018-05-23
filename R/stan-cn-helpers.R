#' Extract unique parameter names from a set of Stan-format
#' column names.
#' @param x Stan-format column names.
#' @return unique parameter names.
#' @export
extract_parameter_names <- function(x) {
  o <- strsplit(x=x, split='\\.') %>% lapply(`[`,1) %>% 
    unique %>% unlist
  return(o)
}

#' Convert parameter name and index into Stan-style column
#' name.
#'
#' @param parameter name of parameter
#' @param ... indices to use (i=1:10, j=3:7).
#' @return character vector of column names.
#' @export
generate_stan_column_name <- function(parameter, ...) {
	if (length(list(...)) == 0) return(NULL)
	index_list <- expand.grid(list(...)) %>% apply(index_list,1,paste,collapse='.')
  column <- paste(parameter, index_list, sep='.')
	return(index_list)
}

#' Get list of column indexes of all parameters.
#'
#' @param cn Stan-format column names.
#' @return list of named vectors, one entry per parameter, 
#'         each vector element is the index of a column
#'         for the parameter.
#' @export
get_split_column_indexes <- function(cn) {
  parameters <- extract_parameter_names(cn)
  o <- list()
  for (name in parameters) {
    o[[name]] <- grepl(pattern=paste0('^', name, '\\.|^', name, '$'), x=cn, fixed=FALSE) %>% which
  }
  return(o)
}

#' Get list of column names of all parameters
#'
#' @param cn Stan-format column names.
#' @return list of named vector, one entry per parameter,
#'         each vector element is the name of a column for
#'         that parameter
#' @export
get_split_column_names <- function(cn) {
  parameter_column_index = get_split_column_indexes(cn)
  for (name in names(parameter_column_index)) {
    parameter_column_index[[name]] = cn[parameter_column_index[[name]]]
  }
  return(o)
}


#' Create a dimlist out of a character vector of Stan-style column
#' names.
#' @param x vector of column names for a given parameter.
#' @return an un-named vector of dimensions.
#' @export
generate_dims <- function(cn) {
	o <- strsplit(x=cn, split='\\.') %>% lapply(`[`,-1)
  if (is_ragged_list(o))
    stop("Parameter name has inconsistent dimensions.")
  if (is_empty_list(o)) {
    return(0)
  } else {
    o <- do.call(what=rbind, args=o) %>% apply(2,as.numeric) %>% 
      apply(2,function(x) max(x)-min(x)+1)
	  return(o)
  }
  stop("These are not the droids you are looking for.")
}


#' Use Stan .csv column names to calculate dimension attributes of each
#' parameter.
#' @param columns .csv column names with name.i.j.... format.
#' @return a named list with dim(parameter) for each element.
#' @export
generate_dimensions <- function(cn) {
	parameter_names <- extract_parameter_names(cn)
  split_columns <- get_split_column_names(cn)
	dimensions <- list()
	for ( name in parameter_names ) {
    dimensions[[name]] <- split_columns[[name]] %>% generate_dims
  }
	return(dimensions)
}













