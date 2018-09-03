

#' Turn any vector of strings into a UUID
#'
#' @param s vector of strings
#' @return UUID
#' @export
as_uuid = function(s) {
  .Call('hash_to_uuid', PACKAGE = 'stannis', s)
}

#' Rewrite a Stan .csv output file.
#' 
#' @param source path to Stan format .csv file
#' @param root where to rewrite to
#' @param tag uuid that gets embedded in binary output
#' @param comment freeform text embedded in binary output
#' @return TRUE if fully rewritten
#' @export
rewrite_stan_csv = function(source, root, tag, comment) {
  .Call('rewrite_stan_csv', PACKAGE = 'stannis', source, root, tag, comment)
}

#' Read the parameter dimensions of the binary rewrite
#'
#' @param root where the rewrite is rooted.
#' @return named list of parameter dimensions
#' @export
get_dimensions = function(root) {
  dim_path = file.path(root, 'dimensions.bin')
  name_path = file.path(root, 'names.bin')
  dims = .Call('get_dimensions', PACKAGE = 'stannis', dim_path, name_path) 
  return(dims)
}

#' Read a specific parameter from the binary rewrite
#' 
#' @param root where the rewrite is rooted
#' @return array of parameter samples
#' @export
get_parameter = function(root, name) {
  if (!dir.exists(root) || length(root) != 1) 
    stop("argument 'root' must be a path to a single directory.")
  if (!is.character(name) || length(name) != 1)
    stop("argument 'name' must be a length-1 character vector.")
  parameter = .Call('get_parameter', PACKAGE = 'stannis', root, name) 
  parameter = array(data = parameter[['data']], dim = parameter[['dims']])
  return(parameter)
}

