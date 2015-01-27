#' Trims whitespace from a string front and back.
#' @param s the string
#' @return s without leading and trailing whitespace.
trim_whitespace <- function(s) {
	s <- gsub(pattern='^\\s*', replacement='', x=s)
	s <- gsub(pattern='\\s*$', replacement='', x=s)
	return(s)
}

#' Grab the lines of a Stan .csv file with the metadata
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return only the lines starting with a hash.
grab_comment_lines <- function(lines) {
	comment_lines <- lines[grepl(pattern='^#', x=lines)]
	comment_lines <- gsub(pattern='^#', replacement='', x=comment_lines)
	return(comment_lines)
}

#' Grab the lines of a Stan .csv file with the control parameters.
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return only the lines with the A=B format.
grab_control_lines <- function(lines) {
	eq_lines <- lines[grepl(pattern='=', x=lines, fixed=TRUE)]
	eq_lines <- strsplit(x=eq_lines, split='=', fixed=TRUE)
	eq_lines <- lapply(eq_lines, trim_whitespace)
  names(eq_lines) <- sapply(eq_lines,`[`,1)
	eq_lines <- sapply(eq_lines, `[`, 2, USE.NAMES=TRUE)
	return(eq_lines)
}

#' Grab the line of a Stan .csv file with the inverse mass matrix
#' diagonal in it.
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return vector of values of diagonal.
grab_imm_diagonal <- function(lines) {
	imm_diagonal_idx <- which(grepl(pattern='Diagonal elements of inverse mass matrix', x=lines)) + 1
 	imm_diagonal <- strsplit(x=lines[imm_diagonal_idx], split=',', fixed=TRUE)[[1]]
	imm_diagonal <- trim_whitespace(imm_diagonal) %>% as.numeric
	return(imm_diagonal)
}


#' Grab the line of a Stan .csv file with the column names in it, starts
#' with "lp__".
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return vector of all parameter names, with whitespace trimmed.
grab_parameter_vector <- function(lines) {
  parameter_names_idx <- which(grepl(pattern='^lp__,', x=lines))
	parameter_names <- strsplit(x=lines[parameter_names_idx], split=',', fixed=TRUE)[[1]]
	parameter_names <- trim_whitespace(parameter_names)
	return(parameter_names)
}

#' Use Stan .csv column named parameter from the Stan model.
#' 
#' @param columns .csv column names with name.i.j.... format.
#' @return A vector of unique named parameters.  Should match parameters
#' named in the Stan model, plus internal (xxx__) parameters.
grab_parameter_names <- function(columns) {
	model_parameters <- strsplit(x=columns, split='.', fixed=TRUE)
	model_parameter_names <- unique(sapply(model_parameters, `[`, 1))
	return(model_parameter_names)
}

#' Use Stan .csv column names to calculate dimension attributes of each
#' parameter.
#' @param columns .csv column names with name.i.j.... format.
#' @return a named list with dim(parameter) for each element.
#' 
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

#' Takes names from Stan .csv files and produces an object with parsed
#' info from comments as well as parameter/transformed parameter names,
#' a matched R object class, and object dimensions.
#' 
#' @param file A vector of length 1, containing the file name of a Stan .csv output file.
#' @return A list with metadata on the Stan run recorded in the file.
#' @examples
#' parameters <- parse_parameters(file='/tmp/stan.csv')
#'
#'
#'
parse_parameters <- function(file=NULL) {
	if (is.null(file) | (length(file) != 1)) 
		stop("File must be a length-1 character vector.") # Too strict?
	
	lines <- readLines(file, n=5*10^3)
	comment_lines <- grab_comment_lines(lines)
	eq_lines <- grab_control_lines(comment_lines)
	if (
		grepl(x=eq_lines['method'], pattern='sample', fixed=TRUE) && 
		any(grepl(x=lines, pattern='mass matrix', fixed=TRUE))
	) {
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














