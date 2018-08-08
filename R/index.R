
#' Find a full path to a file name, recursively
#'
#' @param root search everything below this directory
#' @param name file name to search for
#' @return full normalized path to file
#' @export
find_file <- function(root, name, complete = TRUE) {
  if (complete)
    name = paste0('^', name, '$')
  if (length(name) > 1)
    name = paste0(name, collapse = '|')
  path = dir(path = root, pattern = name, recursive=TRUE, full.names=TRUE)
  normalized_path = normalizePath(path)
  return(normalized_path)
}

#' Find entry at a path in a list
#' 
#' @param x the list
#' @param path (in-list) to the desired element
#' @return location of the name
#' @export
find_ = function(x, path = NULL) {
  if (length(path) == 1)
    return(x[[path]])
  else
    return(find_(x[[path[1]]], path[2:length(path)]))
}


#' Find entry at a path in a list
#' 
#' @param x the list
#' @param path (in-list) to the desired element
#' @return location of the name
#' @export
find = function(x, path) {
  path = strsplit(path, '/')[[1]]
  o = find_(x, path)
  return(o)
}

#' Pick the hash out of a path
#' 
#' @param path vector to search
#' @return hash
#' @export
find_hash = function(path) gsub(pattern =  '^.*([a-z0-9]{64}).*$', replacement = '\\1', x = path)
  
#' Find the components of a single run under a set of paths
#' 
#' @param root root path to search under
#' @param control name of the control files
#' @param output name of the output files
#' @param name of the diagnostics files
#' @return data frame indexing the file sets
#' @export
find_run_files = function(root, control = 'finalized.yaml', 
  output = 'output.csv', diagnostics = 'diagnostics.csv'
) {
  full_paths = dir(path = root, pattern = paste(control, output, diagnostics, sep = '|'), full.names = TRUE, recursive = TRUE)
  hash = vector(mode = 'character', length = length(full_paths))
  name = vector(mode = 'character', length = length(full_paths))
  path = vector(mode = 'character', length = length(full_paths))
  type = vector(mode = 'character', length = length(full_paths))
  for (i in seq_along(full_paths)) {
    hash[i] = find_hash(full_paths[i])
    name[i] = basename(full_paths[i])
    path[i] = dirname(full_paths[i])
    if (name[i] %in% control)
      type[i] = "control"
    else if (name[i] %in% output)
      type[i] = "output"
    else if (name[i] %in% diagnostics)
      type[i] = "diagnostics"
    else
      type[i] = "cruft"
  }
  return(data.frame(hash = hash, name = name, path = path, type = type))
}


