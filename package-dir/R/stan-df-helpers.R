
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

#' Generate one properly sized array for each Stan parameter
#' in a given Stan-format data frame.
generate_parrameter_arrays <- function(data) {
  data <- split_data_by_parameter(data)
  for (d in data)
    d <- generate_parameter_array(data)
  return(d)
}








