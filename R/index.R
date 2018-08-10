
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
  for (i in seq_along(full_paths)) 
    hash[i] = find_hash(dirname(full_paths[i]))
  hash = unique(hash)
  o = list()
  for (h in hash) {
    o[[h]] = list()
    o[[h]][['hash']] = h
    is_hash = find_hash(dirname(full_paths)) == h 
    is_control = grepl(pattern = control, x = basename(full_paths)) & is_hash
    is_output = grepl(pattern = output, x = basename(full_paths)) & is_hash
    is_diagnostics = grepl(pattern = diagnostics, x = basename(full_paths)) & is_hash
    if (any(is_control))
      o[[h]][['control']] = basename(full_paths)[is_control]
    else
      o[[h]][['control']] = NA
    if (any(is_output))
      o[[h]][['output']] = basename(full_paths)[is_output]
    else
      o[[h]][['output']] = NA
    if (any(is_diagnostics))
      o[[h]][['diagnostics']] = basename(full_paths)[is_diagnostics]
    else
      o[[h]][['diagnostics']] = NA
    o[[h]] = do.call(data.frame, o[[h]])
  }
  o = do.call(rbind, o)
  rownames(o) = as.character(1:nrow(o))
  return(o)
}

#' Find and remove run directories with no output file.
#' 
#' @param root root path to search under
#' @return hashes of removed directories
#' @export
remove_failed_runs = function(root, ...) {
  runs = find_run_files(root, ...)
  failed_runs = runs[['hash']][is.na(runs[['output']])]
  failed_paths = file.path(root, failed_runs)
  if (length(failed_runs) != 0) {
    files = dir(path = failed_paths, full.names=TRUE)
    file.remove(files)
    file.remove(failed_paths, recursive = TRUE)
  }
  return(failed_runs)
}


