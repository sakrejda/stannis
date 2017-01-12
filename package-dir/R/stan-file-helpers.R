
#' Get the lines of a Stan .csv file with the metadata
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return only the lines starting with a hash.
get_comment_lines <- function(lines) {
	lines <- lines[grepl(pattern='^#', x=lines)]
	lines <- trim_comment_char(lines, c='#')
	return(lines)
}

#' Get the lines of a Stan .csv file with the control parameters.
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return only the lines with the A=B format.
get_control_lines <- function(lines) {
  lines <- get_comment_lines(lines)
	lines <- lines[grepl(pattern='=', x=lines, fixed=TRUE)] %>% 
    lapply(trim_whitespace) %>% unlist %>% process_key_value(split='=')
	return(lines)
}

#' Get the line of a Stan .csv file with the inverse mass matrix
#' diagonal in it.
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return vector of values of diagonal.
get_imm_diagonal <- function(lines) {
  lines <- get_comment_lines(lines) %>% lapply(trim_whitespace)
	imm_diagonal_idx <- which(grepl(pattern='Diagonal elements of inverse mass matrix', x=lines)) + 1
 	imm_diagonal <- strsplit(x=lines[imm_diagonal_idx], split=',', fixed=TRUE)[[1]]
	imm_diagonal <- trim_whitespace(imm_diagonal) %>% as.numeric
	return(imm_diagonal)
}


#' Get the line of a Stan .csv file with the column names in it, starts
#' with "lp__".
#' @param lines lines from the Stan .csv file, need only enough to get 
#'        past the recorded meta-data.
#' @return vector of all column names, with whitespace trimmed.
get_column_names <- function(lines) {
  idx <- which(grepl(pattern='^lp__,', x=lines))
	column_names <- strsplit(x=lines[idx], split=',', fixed=TRUE)[[1]]
	column_names <- trim_whitespace(column_names)
	return(column_names)
}

#' Properly read a stan file, avoiding factors and comments, including
#' reading column names from a header.
#'
#' @param file An output file produced by CmdStan.
#' @return A data.frame.
read_stan_data <- function(file) {
  o <- read.table(file=file, header=TRUE, sep=',', stringsAsFactors=FALSE, comment.char='#')
  return(o)
}

#' Properly read a stan file, avoiding factors and comments, including
#' reading column names from a header.
#'
#' @param file An output file produced by CmdStan.
#' @return A data.frame.
read_stan_metadata <- function(file) {
  lines <- readLines(file=file)
  imm <- get_imm_diagonal(lines)
  control <- get_control_lines(lines)
  o <- list()
  return(o)
}
