
process_index_list <- function(...) {
	if (length(list(...)) == 0) return(NULL)
	index_list <- expand.grid(list(...))
	index_list <- apply(index_list,1,paste,collapse='.')
	return(index_list)
}



