

#' Based on an argument tree ('args' object) find a model
#' and return the path. If the model file (.stan file) is not
#' found, check for the presence of a partial model file (.model file)
#' and splice it with components from args[['model_dir']]
#'
#' @param args arg-tree object (list).
#' @return path to object's model file.
#' @export
find_model <- function(args) {
  search_path = args[['model_dir']]
  full_file_pattern = paste0('^', args[['model_name']], '\\.stan$')
  part_file_pattern = paste0('^', args[['model_name']], '\\.model$')
  full_file_path = dir(path = search_path, pattern = full_file_pattern, full.names=TRUE)
  if (length(full_file_path) == 0) {
    part_file_path = dir(path = search_path, pattern = part_file_pattern, full.names=TRUE)
    if (length(part_file_path) == 0) {
      msg <- paste0("Model not found. \n", 
        "searched in: ", paste0(search_path, collapse=", "), "\n",
        "pattern: ", paste0(part_file_path, collapse=", "))
      stop(msg)
    } 
    full_file_path = substitutions(model = part_file_path, search = search_path,
      output = file.path(tempdir(), paste0(args[['model_name']], '.stan')))
  }
  return(normalizePath(full_file_path))
}

#' return project id from an argument tree ('args' object).
#'
#' @param args arg-tree object (list).
#' @return project id.
#' @export
get_id <- function(args) return(args[['project_id']])

#' return binary dir for this project from an argument 
#' tree ('args' object).  If the binary_dir is missing, 
#' create an R-session-specific tempdir.
#'
#' @param args arg-tree object (list).
#' @return project binary dir
#' @export
get_binary_dir <- function(args) {
  binary_dir <- normalizePath(args[['binary_dir']])
  if (is.null(binary_dir))
    binary_dir <- file.path(tempdir(), "binaries")
  if (!dir.exists(binary_dir)) 
    dir.create(binary_dir, showWarnings=TRUE, recursive=TRUE,
      mode = "0770")
  return(binary_dir)
}


#' Replicate arg-tree and add replicate tag.
#'
#' @param args agr-tree object (list).
#' @return list of arg-trees, separated s.t. each arg-tree
#'         is for one replicate
#' @export
replicate_args <- function(args) {
  n_replicates <- args[['replicates']]
  args = replicate(n = n_replicates, expr = args, simplify = FALSE)
  for (r in 1:n_replicates) {
    args[[r]][['replicate']] <- r
  }
  return(args)
}


