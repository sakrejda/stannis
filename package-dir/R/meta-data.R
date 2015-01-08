#' Reads a simple tag:value file format.
#' @param file source file.
#' @return named vector with values as values and tags as names.
get_paths <- function(file='file-data.txt') {
  paths <- strsplit(x=readLines(file), split=':')
  pat <- lapply(paths, `[`, 2)
  ths <- lapply(paths, `[`, 1)
  paths <- pat
  names(paths) <- ths
  return(paths)
}

#' Reads a simple "a" = "b" format, ignoring non-matching data.
#' @param file source file.
#' @return named list with 'a' for names and 'b' for values.
process_bash_array <- function(file='model-data.sh') {
  lines <- readLines(file)
  lines <- lines[grepl(x=lines, pattern='=', fixed=TRUE)]
  parts <- gregexpr(text=lines, pattern='"', fixed=TRUE)
  keys <- mapply(
    FUN=function(text, indexing) substr(text, indexing[1]+1, indexing[2]-1),
    text=lines, indexing=parts)
  values <- mapply(
    FUN=function(text, indexing) {
      if (length(indexing) == 4) {
        o <- substr(text, indexing[3]+1, indexing[4]-1)
      } else {
        start <- regexpr(pattern='=', text=text, fixed=TRUE) +1
        stop <- nchar(text)
        o <- as.numeric(substr(text, start, stop))
      }
    }
    ,text=lines, indexing=parts, SIMPLIFY=FALSE)
  names(values) <- keys
  return(values)
}

                                                                                                                            
#' Normalizes a path and splits it on '/'.
#' @param path non-normalized paths.
#' @return list of normalized and split path parts.
path_split <- function(path) {                                                                                                          
  path <- normalizePath(path)                                                                                                           
  path <- strsplit(path, '/', fixed=TRUE)                                                                                               
  return(path)                                                                                                                          
}                                                                                                                                       
                                                                                                                                        
#' Search through parents of a directory for a file.                                                                                                                                       
#' @param directory start point for the search
#' @param file file name to search for.
#' @return name of the file, if found.
find_file <- function(directory=NULL, file='context.sh') {                                                                
  if (is.null(directory)) {                                                                                                             
    directory <- getwd()                                                                                                                
  } else {                                                                                                                              
    file <- file.path(directory,file)                                                                                           
    if (file.exists(file)) {                                                                                                            
      return(file)                                                                                                  
    } else {                                                                                                                            
      new_directory <- path_split(directory)[[1]]                                                                                       
      nc <- length(new_directory)                                                                                                       
      if (nc < 3) stop("model-data.sh not found.")                                                                                      
      new_directory <- do.call(what=file.path, args=as.list(new_directory[1:(nc-1)]))                                                   
      return(find_file(new_directory, file))   
    }                                                                                                                                   
  }                                                                                                                                     
}                          

#' Find and process a model file.
#' @param directory start point for the (ascending) search.
#' @param file name to search for.
#' @return name list with parsed data from the file.
find_model_data <- function(directory, file) {
	path <- find_file(directory, file)
	return(process_bash_array(path))
}		


