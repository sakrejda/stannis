
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



