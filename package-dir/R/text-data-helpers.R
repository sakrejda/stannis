#' Reads a simple tag:value file format.
#' @param file read all lines from here
#' @param split string to distinguish lhs from rhs
#' @return named vector with values as values and tags as names.
read_key_value <- function(file, split='=') {
  splits <- strsplit(x=readLines(file), split=split)
  data <- process_key_value(splits)
  return(data)
}

#' Processes a strings data format (key[split]value)
#' @param x vector of strings to process
#' @param split string to distinguish lhs from rhs
#' @return named vector with values as values and tags as names.
process_key_value <- function(x, split) {
  lhs <- lapply(splits, `[`, 1)
  rhs <- lapply(splits, `[`, 2)
  names(rhs) <- lhs
  return(rhs)
}
                                                                                                                            
#' Normalizes a path and splits it on a path separator, 
#' typically '/'.
#' @param path non-normalized paths.
#' @param separator the path separator, typically '/'
#' @return list of normalized and split path parts.
path_split <- function(path, separator='/') {                                                                                                          
  path <- normalizePath(path)                                                                                                           
  path <- strsplit(path, separator, fixed=TRUE)                                                                                               
  return(path)                                                                                                                          
}                                                                                                                                       
                                                                                                                                        

