#' Takes names from Stan .csv files and produces an object with parsed
#' info from comments as well as parameter/transformed parameter names,
#' a matched R object class, and object dimensions.
#' 
#' @param A vector of length 1, containing the file name of a Stan .csv output file.
#' @examples
#' parameters <- parse_parameters(file='/tmp/stan.csv')
#'
#'
#'

trim_whitespace <- function(s) {
	s <- gsub(pattern='^\\s*', replacement='', x=s)
	s <- gsub(pattern='\\s*$', replacement='', x=s)
	return(s)
}

grab_comment_lines <- function(lines) {
	comment_lines <- lines[grepl(pattern='^#', x=lines)]
	comment_lines <- gsub(pattern='^#', replacement='', x=comment_lines)
	return(comment_lines)
}

grab_control_lines <- function(lines) {
	eq_lines <- lines[grepl(pattern='=', x=lines, fixed=TRUE)]
	eq_lines <- strsplit(x=eq_lines, split='=', fixed=TRUE)
	eq_lines <- lapply(eq_lines, trim_whitespace)
  names(eq_lines) <- sapply(eq_lines,`[`,1)
	eq_lines <- sapply(eq_lines, `[`, 2, USE.NAMES=TRUE)
	return(eq_lines)
}

grab_imm_diagonal <- function(lines) {
	imm_diagonal_idx <- which(grepl(pattern='Diagonal elements of inverse mass matrix', x=lines)) + 1
 	imm_diagonal <- strsplit(x=lines[imm_diagonal_idx], split=',', fixed=TRUE)[[1]]
	imm_diagonal <- trim_whitespace(imm_diagonal) %>% as.numeric
	return(imm_diagonal)
}

grab_parameter_vector <- function(lines) {
  parameter_names_idx <- which(grepl(pattern='^lp__,', x=lines))
	parameter_names <- strsplit(x=lines[parameter_names_idx], split=',', fixed=TRUE)[[1]]
	parameter_names <- trim_whitespace(parameter_names)
	return(parameter_names)
}

grab_parameter_names <- function(columns) {
	model_parameters <- strsplit(x=columns, split='.', fixed=TRUE)
	model_parameter_names <- unique(sapply(model_parameters, `[`, 1))
	return(model_parameter_names)
}

generate_dimensions <- function(columns) {
	model_parameter_names <- grab_parameter_names(columns)
	model_parameters <- strsplit(x=columns, split='.', fixed=TRUE)
	dimensions <- list()
	for ( name in model_parameter_names ) {
		index_block <- model_parameters[name == sapply(model_parameters, `[`, 1)]
		n_dim <- unique(sapply(index_block,length)-1)
		if (length(n_dim) != 1) stop("Mixing parameters in aggregation.")
		if (n_dim != 0) {  # Need to calculate indexing.
			index_block <- sapply(index_block, `[`, 2:(n_dim+1)) %>% as.numeric
			index_block <- matrix(data=unlist(index_block), ncol=n_dim, byrow=TRUE)
			dimensions[[name]] <- apply(X=index_block,2,max)
		} else {
			dimensions[[name]] <- 0
		}
	}
	return(dimensions)
}

internal_parameters <- function(x) {
	x <- x[grepl(pattern='__$', x=x)]
	return(x)
}

model_parameters <- function(x) {
	x <- x[!grepl(pattern='__$', x=x)]
	return(x)
}

parse_parameters <- function(file=NULL) {
	if (is.null(file) | (length(file) != 1)) 
		stop("File must be a length-1 character vector.") # Too strict?
	
	lines <- readLines(file, n=5*10^3)
	comment_lines <- grab_comment_lines(lines)
	eq_lines <- grab_control_lines(comment_lines)
	if (grepl(x=eq_lines['run_arguments'], pattern='sample', fixed=TRUE)) {
		imm_diagonal <- grab_imm_diagonal(comment_lines)
		type <- 'sample'
	} else {
		imm_diagonal <- NULL
		type <- 'optimize'
	}
	csv_column_names <- grab_parameter_vector(lines[1:100])
	dimensions <- generate_dimensions(csv_column_names)

	o <- list(
		run_arguments = eq_lines,
		inverse_mass_matrix_diagonal = imm_diagonal,
		csv_column_names = csv_column_names,
		internal_parameter_columns = internal_parameters(csv_column_names),
		model_parameter_columns = model_parameters(csv_column_names),
		parameter_names = names(dimensions),
		dimensions = dimensions,
		type = type,
		try = eq_lines['id']
	)
	return(o)
}














