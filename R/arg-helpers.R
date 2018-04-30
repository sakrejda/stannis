

#' Finalize an argument tree object by merging components
#' that are not fully specified.
#'
#' @param args arg-tree object (list).
#' @return same tree, ready to pass to 'construct_cmdline'
#'         and 'run_model_cmd'
#' @export
finalize_args <- function(args) {
  args[['output']] <- list()
  args[['output']][['terminal']] = 'terminal.txt'
  args[['output']][['error']] = 'error.txt'
  args[['output']][['file']] = 'output.csv'
  args[['output']][['diagnostics']] = 'diagnostics.csv'
  args[['output']][['control']] = 'control.yaml'

  if (!is.null(args[['target_dir']])) {
    output_prefix <- file.path(args[['target_dir']], args[['hash']], args[['chain']])
    for (output in names(args[['output']])) {
      args[['output']][[output]] <- file.path(output_prefix, args[['output']][[output]])
    }
  }
  data_prefix <- args[['data_dir']]
  if (!is.null(data_prefix)) {
    args[['data']][['file']] <- file.path(data_prefix, args[['data']][['file']])
  }
  init_prefix <- args[['init_dir']]
  if (!is.null(init_prefix)) {
    args[['init']] <- file.path(init_prefix, args[['init']])
  }
  return(args)
}

#' Based on an argument tree ('args' object) find a model
#' and return the path.
#'
#' @param args arg-tree object (list).
#' @return path to object's model file.
#' @export
find_model <- function(args) {
  search_path = args[['model_path']]
  file_pattern = paste0('^', args[['model_name']], '\\.stan$')
  path = dir(path = search_path, pattern = file_pattern, full.names=TRUE)
  if (length(path) == 1)
    return(normalizePath(path))
  else {
    msg <- paste0("Model not found. \n", 
      "searched in: ", search_path,
      "pattern: ", file_pattern)
    stop(msg)
  }
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
  binary_dir <- args[['binary_dir']]
  if (is.null(binary_dir))
    binary_dir <- file.path(tempdir(), "binaries")
  return(binary_dir)
}

#' create a pseudo-'secret', salted with project_id
#'
#' @param args arg-tree object (list).
#' @return hash 
#' @export
create_hash <- function(args) {
  project_id_hash = get_id(args) %>% openssl::sha256()
  model_path = find_model(args)
  model_hash = openssl::sha256(x=file(model_path))
  data_hash = openssl::sha256(x=file(args[['data']][['file']]))
  if (!is.null(args[['init']]))
    init_hash = openssl::sha256(x=file(args[['init']]))
  else 
    init_hash = ''
  full_hash = openssl::sha256(x = paste(project_id_hash, model_hash,
    data_hash, init_hash, sep = ':'))
  return(full_hash)
}

#' expand chains, inits, or both
#'
#' @param args agr-tree object (list).
#' @return list of arg-trees, separated s.t. each arg-tree
#'         is for one chain and one init file.
#' @export
flatten_args <- function(args) {
  args_out <- list()
  for (arg in args) {
    n_inits <- length(arg[['init']])
    n_chains <- arg[['sample']][['n_chains']]
    n_total <- n_inits * n_chains
    for (chain in 1:n_total) {
      arg_append <- arg
      arg_append[['sample']][['chain']] <- chain
      arg_append[['init']] <- arg[['init']][(c - 1) %% n_inits + 1]
      args_out <- c(args_out, arg_append)
    }
  }
  return(args_out)
}


