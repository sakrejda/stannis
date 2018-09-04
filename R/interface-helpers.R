

#' Turn any vector of strings into a UUID
#'
#' @param s vector of strings
#' @return UUID
#' @export
uuid = function(s = NULL) {
  if (is.null(s))
    id = .Call('uuid', PACKAGE = 'stannis')
  else 
    id = .Call('hash_to_uuid', PACKAGE = 'stannis', s)
  return(id)
}

