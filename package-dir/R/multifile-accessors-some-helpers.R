
process_index_list <- function(...) {
	if (length(list(...)) == 0) return(NULL)
	index_list <- expand.grid(list(...))
	index_list <- apply(index_list,1,paste,collapse='.')
	return(index_list)
}

named_columns_to_parameter_names <- function(colname) {
	o <- strsplit(x=colname, split='\\.') %>% lapply(`[`,1) %>% unique %>% `[[`(1)
	return(o)
}

named_columns_to_dim_list <- function(colname) {
	o <- strsplit(x=colname, split='\\.') %>% lapply(`[`,-1)
	o <- do.call(what=rbind, args=o) %>% apply(2,as.numeric) %>% apply(2,function(x) max(x)-min(x)+1)
	return(o)
}



named_columns_to_arrays <- function(data) {
	if (ncol(data) > 1) {
		names <- named_columns_to_parameter_names(colnames(data))
		dim_list <- c(nrow(data),as.list(named_columns_to_dim_list(colnames(data))))
		names(dim_list) <- c('iteration',letters[9:(9+length(dim_list)-2)])
		o <- array(data=data, dim=dim_list)
	} else {
		o <- array(data=data, dim=length(data))
	}
	return(o)
}

