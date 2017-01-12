
#' Convert parameter name and index into Stan-style column
#' name.
#' @param parameter name of parameter
#' @param ... indices to use (i=1:10, j=3:7).
#' @return character vector of column names.
generate_stan_column_name <- function(parameter, ...) {
	if (length(list(...)) == 0) return(NULL)
	index_list <- expand.grid(list(...)) %>% apply(index_list,1,paste,collapse='.')
  column <- paste(parameter, index_list, sep='.')
	return(index_list)
}

#' Split column names by parameter.
#' @param x Stan-format column names.
#' @return list of Stan-format column names, with one 
#'         entry (vector) per parameter
split_columns_by_parameter <- function(x) {
  parameters <- extract_parameter_names(x)
  o <- list()
  for (name in parameters) {
    wh <- grepl(pattern=paste0('^', name, '\\.'), x=x, fixed=TRUE) %>% which
    o[[name]] <- x[wh]
  }
  return(o)
}


#' Get parameter name from Stan-format csv file. 
#' 
#' @param columns .csv column names with name.i.j.... format.
#' @return A vector of unique named parameters.  Should match parameters
#' named in the Stan model, plus internal (X__) parameters.
get_parameter_names <- function(lines) {
  parameter_names <- get_column_names(lines) %>% extract_parameter_names
	return(parameter_names)
}

#' Subset a vector of names to keep only sampler/internal parameters.
#' @param x vector of names
#' @return x, excluding names not ending in '__'.
internal_parameters <- function(x) {
	x <- x[grepl(pattern='__$', x=x)]
	return(x)
}

#' Subset a vector of names to keep only model parameters.
#' @param x vector of names
#' @return x, excluding names ending in '__'.
model_parameters <- function(x) {
	x <- x[!grepl(pattern='__$', x=x)]
	return(x)
}

#' Check whether list elements have different lenghts.
is_ragged_list <- function(x) lapply(x, length) %>% unique %>%
  length %>% `!=`(1) %>% isTRUE

#' Check whether list elements are all zero.
is_empty_list <- function(x) lapply(x, length) %>% unique %>%
  `==`(0) %>% all %>% isTRUE

#' Create a dimlist out of a character vector of Stan-style column
#' names.
#' @param x vector of column names for a given parameter.
#' @return an un-named vector of dimensions.
generate_dims <- function(x) {
	o <- strsplit(x=x, split='\\.') %>% lapply(`[`,-1)
  if (is_ragged_list(o))
    stop("Parameter name has inconsistent dimensions.")
  if (is_empty_list(o)) {
    return(0)
  } else {
    o <- data.table::rbindlist(o) %>% apply(2,as.numeric) %>% 
    apply(2,function(x) max(x)-min(x)+1)
	  return(o)
  }
  stop("These are not the droids you are looking for.")
}

#' Split Stan-style data from a .csv file by parameter.
#' @param x Stan-format .csv parameter data.
#' @return list of Stan-format parameter data, with one 
#'         entry (data.frame) per parameter
split_data_by_parameter <- function(data) {
  parameters <- colnames(data) %>% extract_parameter_names
  o <- list()
  for (name in parameters) {
    wh <- grepl(pattern=paste0('^', name, '\\.'), 
      x=colnames(data), fixed=TRUE) %>% which
    o[[name]] <- x[,wh]
  }
  return(o)
}

#' Create an array from a Stan-style data frame for a 
#' given parameter.
#' @param data data frame of the set of columns for a given
#'        parameter.
#' @return array of correct dimension for the given parameter
#'         indexed as in the Stan model.
generate_parameter_array <- function(data) {
	if (ncol(data) > 1) {
    column_names <- colnames(data)
    num_rows <- nrow(data)
		names <- extract_parameter_names(column_names)
		dim_list <- c(num_rows,as.list(generate_dims(column_names)))
		names(dim_list) <- c('iteration',letters[9:(9+length(dim_list)-2)])
		o <- array(data=data, dim=dim_list)
	} else {
		o <- array(data=data, dim=num_rows)
	}
	return(o)
}


#' Use Stan .csv column names to calculate dimension attributes of each
#' parameter.
#' @param columns .csv column names with name.i.j.... format.
#' @return a named list with dim(parameter) for each element.
#' 
generate_dimensions <- function(x) {
	parameter_names <- extract_parameter_names(x)
  split_columns <- split_columns_by_parameter(x)
	dimensions <- list()
	for ( name in parameter_names ) {
    dimensions[[name]] <- split_columns[[name]] %>% generate_dims
  }
	return(dimensions)
}













