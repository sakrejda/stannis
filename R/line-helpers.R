
#' Get the lines of a Stan .csv file with the metadata
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return only the lines starting with a hash.
#' @export
get_comment_lines <- function(lines) {
	lines <- lines[grepl(pattern='^#', x=lines)]
	lines <- trim_comment_char(lines, c='#')
	return(lines)
}

#' Get the lines of a Stan .csv file with the control parameters.
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return only the lines with the A=B format.
#' @export
get_control_lines <- function(lines) {
  lines <- get_comment_lines(lines)
	lines <- lines[grepl(pattern='=', x=lines, fixed=TRUE)] %>% 
    lapply(trim_whitespace) %>% unlist %>% process_key_value(split='=')
#  lines <- gsub(pattern='(Default)', replacement='', x=lines, fixed=TRUE)
	return(lines)
}

#' Get the line of a Stan .csv file with the inverse mass matrix
#' diagonal in it.
#'
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return vector of values of diagonal.
#' @export
get_imm_diagonal <- function(lines) {
  lines <- get_comment_lines(lines) %>% lapply(trim_whitespace)
  is_imm_bool <- grepl(pattern='Diagonal elements of inverse mass matrix', x=lines)
  if (any(isTRUE(is_imm_bool))) {
    imm_diagonal_idx <- which(is_imm_bool) + 1
 	  imm_diagonal <- strsplit(x=lines[imm_diagonal_idx], split=',', fixed=TRUE)[[1]]
  	imm_diagonal <- trim_whitespace(imm_diagonal) %>% as.numeric
  } else {
    imm_diagonal <- NULL
  }
	return(imm_diagonal)
}


#' Get the line of a Stan .csv file with the column names in it, starts
#' with "lp__".
#'
#' @param lines lines from the Stan .csv file, need only enough to get 
#'        past the recorded meta-data.
#' @return vector of all column names, with whitespace trimmed.
get_column_names <- function(lines) {
  idx <- which(grepl(pattern='^lp__,', x=lines))
	column_names <- strsplit(x=lines[idx], split=',', fixed=TRUE)[[1]]
	column_names <- trim_whitespace(column_names)
	return(column_names)
}

#' Total run time 
#'
#' @param CmdStan output as vector of lines
#' @return total time to run model
#' @export
get_total_time <- function(lines) {
  lines <- get_comment_lines(lines) %>%
    `[`(grepl(pattern = '(Total)', x = .))
  l <- regexpr(pattern="[0-9][0-9\\.]*", text=lines) %>%
    attr('match.length')
  total_time <- substr(lines, 1, l) %>% as.numeric
  if (length(total_time) > 0) 
    return(total_time)
  else 
    return(NA)
}


