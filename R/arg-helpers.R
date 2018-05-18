

#' Finalize an argument tree object by merging components
#' that are not fully specified.
#'
#' @param args arg-tree object (list).
#' @return same tree, ready to pass to 'construct_cmdline'
#'         and 'run_model_cmd'
#' @export
finalize_args <- function(args) {
  if (is.null(args[['output']]))
    args[['output']] <- list()
  args[['output']][['terminal']] = 'terminal.txt'
  args[['output']][['error']] = 'error.txt'
  args[['output']][['file']] = 'output.csv'
  args[['output']][['diagnostic_file']] = 'diagnostics.csv'
  args[['output']][['control']] = 'control.yaml'
  output_files <- c('terminal', 'error', 'file', 'diagnostics', 'control')

  if (is.null(args[['target_dir']]))
    args[['target_dir']] <- "fits"

  if (!dir.exists(args[['target_dir']]))
    dir.create(args[['target_dir']], recursive = TRUE)
  args[['fit_prefix']] <- file.path(args[['target_dir']], 
    paste0("fit-", args[['hash']]))
  if (!dir.exists(args[['fit_prefix']]))
    dir.create(args[['fit_prefix']], recursive = TRUE)
  if (!dir.exists(file.path(args[['fit_prefix']], 'data')))
    dir.create(file.path(args[['fit_prefix']], 'data'), recursive=TRUE)
  if (!dir.exists(file.path(args[['fit_prefix']], 'init')))
    dir.create(file.path(args[['fit_prefix']], 'init'), recursive=TRUE)

  putative_prefix = file.path(args[['fit_prefix']], 
    paste0("chain-", args[['sample']][['chain']]))
  while (dir.exists(putative_prefix)) {
    args[['sample']][['chain']] <- args[['sample']][['chain']] + 1
    putative_prefix = file.path(args[['fit_prefix']], 
      paste0("chain-", args[['sample']][['chain']]))
  }
  dir.create(putative_prefix)

  args[['output_prefix']] <- putative_prefix
  for (output in output_files) {
    args[['output']][[output]] <- file.path(args[['output_prefix']], 
      args[['output']][[output]])
  }

  data_prefix <- args[['data_dir']]
  if (!is.null(data_prefix) && !is.null(args[['data']][['file']])) {
    args[['data']][['file']] <- file.path(data_prefix, args[['data']][['file']])
  }
  if (!is.null(args[['data']]) && !is.null(args[['data']][['file']])) {
    if (!file.exists(args[['data']][['file']])) {
      msg <- paste0("Data file missing at: ", args[['data']][['file']])
      stop(msg)
    } else {
      file.copy(args[['data']][['file']], args[['fit_prefix']], overwrite=TRUE)
    }
  }

  init_exists <- !is.null(args[['init']]) && !is.na(args[['init']])
  is_init_file <- init_exists && is.na(as.numeric(args[['init']]))
  init_prefix <- args[['init_dir']]
  if (!is.null(init_prefix) && init_exists && is_init_file) {
    args[['init']] <- file.path(init_prefix, args[['init']])
  }
  if (is_init_file && !file.exists(args[['init']])) {
    msg <- paste0("Initial values file missing at: ", args[['init']])
    stop(msg)
  } else {
    file.copy(args[['init']], args[['fit_prefix']], overwrite=TRUE)
  }
  yaml::write_yaml(args, file = file.path(args[['output_prefix']], "finalized.yaml"))
  register_run(args)
  return(args)
}

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
        "searched in: ", search_path,
        "pattern: ", part_file_path)
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

#' create a pseudo-'secret', salted with project_id
#'
#' @param args arg-tree object (list).
#' @return hash 
#' @export
create_hash <- function(args) {
  project_id_hash = get_id(args) %>% openssl::sha256()
  model_path = find_model(args)
  model_hash = openssl::sha256(x=file(model_path))
  if (is.null(args[['data']]) || is.null(args[['data']][['file']]))
    data_hash = ''
  else {
    data_file = args[['data']][['file']]
    if (!is.null(args[['data_dir']])) {
      data_file = file.path(args[['data_dir']], data_file)
    }
    if (file.exists(data_file)) {
      data_hash = openssl::sha256(x=file(data_file))
    } else {
      msg <- paste0("Data file missing: ", data_file)
      stop(msg)
    }
  }
  if (!is.null(args[['init']]) && !is.na(args[['init']]) && 
      is.na(as.numeric(args[['init']]))
  ) {
    init_file = args[['init']]
    if (!is.null(args[['init_dir']])) {
      init_file = file.path(args[['init_dir']], init_file)
    }
    if (file.exists(init_file)) {
      init_hash = openssl::sha256(x=file(args[['init']]))
    } else {
      msg <- paste0("Init file missing: ", init_file)
      stop(msg)
    }
  } else 
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
  if (is.null(args[['init']]) || length(args[['init']]) == 0) {
    n_inits <- 1
  } else {
    n_inits <- length(args[['init']])
  }
  if (is.null(args[['sample']]) || is.null(args[['sample']][['num_chains']])) {
    n_chains <- 1
  } else {
    n_chains <- args[['sample']][['num_chains']]
  }
  n_total <- n_inits * n_chains
  if (is.null(args[['sample']])) 
    args[['sample']] <- list()
  for (chain in 1:n_total) {
    arg_append <- args
    arg_append[['sample']][['chain']] <- chain
    if (!is.null(args[['init']]))
      arg_append[['init']] <- args[['init']][(chain - 1) %% n_inits + 1]
    args_out[[length(args_out) + 1]] <- c(arg_append)
  }
  return(args_out)
}


