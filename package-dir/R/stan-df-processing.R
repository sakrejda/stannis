
#' Use Stan .csv column names to calculate dimension attributes of each
#' parameter.
#' @param columns .csv column names with name.i.j.... format.
#' @return a named list with dim(parameter) for each element.
#' 
generate_dimensions <- function(columns) {
	parameter_names <- extract_parameter_names(columns)
  split_columns <- split_columns_by_parameter(columns)
	dimensions <- list()
	for ( name in parameter_names ) {
    dimensions[[name]] <- split_columns[[name]] %>% generate_dims
  }
	return(dimensions)
}













