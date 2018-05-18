
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


