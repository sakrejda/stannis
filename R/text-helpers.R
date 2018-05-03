#' Trims whitespace from a string front and back.
#' @param s the string
#' @return s without leading and trailing whitespace.
#' @export
trim_whitespace <- function(s) {
	s <- gsub(pattern='^\\s*', replacement='', x=s)
	s <- gsub(pattern='\\s*$', replacement='', x=s)
	return(s)
}

#' Trims comment char from the front of a string.
#' @param s the string
#' @param c comment character
#' @return s without leading and trailing whitespace.
#' @export
trim_comment_char <- function(s, c='#') {
	s <- gsub(pattern=paste0('^\\s*', c, '\\s*'), replacement='', x=s)
	return(s)
}

#' Reads a simple tag:value file format.
#' @param file read all lines from here
#' @param split string to distinguish lhs from rhs
#' @return named vector with values as values and tags as names.
#' @export
read_key_value <- function(file, split='=') {
  data <- readLines(file) %>% unlist %>%
    process_key_value
  return(data)
}

#' Processes a strings data format (key[split]value)
#' @param x vector of strings to process
#' @param split string to distinguish lhs from rhs
#' @return named vector with values as values and tags as names.
#' @export
process_key_value <- function(x, split='=') {
  splits <- strsplit(x=x, split=split) 
  lhs <- lapply(splits, `[`, 1) %>% sapply(trim_whitespace)
  rhs <- lapply(splits, `[`, 2) %>% lapply(trim_whitespace)
  names(rhs) <- lhs
  return(rhs)
}
                                                                                                                            
#' Normalizes a path and splits it on a path separator, 
#' typically '/'.
#' @param path non-normalized paths.
#' @param separator the path separator, typically '/'
#' @return list of normalized and split path parts.
#' @export
path_split <- function(path, separator='/') {                                                                                                          
  path <- normalizePath(path)                                                                                                           
  path <- strsplit(path, separator, fixed=TRUE)                                                                                               
  return(path)                                                                                                                          
}                                                                                                                                       

#' Retrieve just file extension from a string
#'
#' @param s string
#' @param split what to split the extension with
#' @return extension 
#' @export
extension = function(s) strsplit(x = s, split = '\\.') %>% last() 

#' Subset a vector of names to keep only sampler/internal parameters.
#'
#' @param s vector of names
#' @return s, including names ending in '__'.
#' @export
internal_parameters <- function(s) s[grepl(pattern='__$', x=s)]

#' Subset a vector of names to keep only model parameters.
#'
#' @param s vector of names
#' @return s, excluding names ending in '__'.
#' @export
model_parameters <- function(s) s[!grepl(pattern='__$', x=s)]




#' Find number at the head of a string.
#'
#' @param s string
#' @return number only.
#' @export
get_initial_number <- function(s) {
  s <- gsub(pattern=' [^0-9]*', x=s, replacement='')
  return(s)
}

