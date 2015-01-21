
process_index_list <- function(...) {
	if (length(list(...)) == 0) return(NULL)
	index_list <- expand.grid(list(...))
	index_list <- apply(index_list,1,paste,collapse='.')
	return(index_list)
}

named_columns_to_parameter_names <- function(colname) {
	o <- strpslit(x=colname, split='\\.') %>% lapply(`[`,1) %>% unique
	return(o)
}

## This needs to consider multiple names within one (?)
named_columns_to_dim_list <- function(colname) {
	o <- strsplit(x=colname, split='\\.') %>% lapply(`[`,-1)
	o <- do.call(what=rbind, args=o) %>% apply(2,as.numeric) %>% apply(2,function(x) max(x)-min(x)+1)
	return(o)
}



named_columns_to_arrays <- function(data) {
	names <- named_columns_to_parameter_names(names(data))
	dim_list <- named_columns_to_dim_list(names(data))

}

