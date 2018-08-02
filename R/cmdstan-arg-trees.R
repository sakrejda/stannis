
#' Combine multiple arg-trees by merging matching sub-trees.
#' 
#' @param ... arbitrary number of lists.
#' @return single merged list
#' @export
merge_trees <- function(...) {
  args_in <- list(...)
  args_out <- args_in[[1]]
  args_remaining <- args_in[2:length(args_in)]
  for (arg in args_remaining) {
    for (name in names(arg)) {
      if (!(name %in% names(args_out))) {
        args_out[[name]] <- arg[[name]]
      } else {
        if (is.list(args_out[[name]]) && is.list(arg[[name]])) {
          args_out[[name]] <- merge_trees(args_out[[name]], arg[[name]])
        } else if (!is.list(args_out[[name]]) && !is.list(arg[[name]])) {
          args_out[[name]] <- arg[[name]]
        } else {
          stop("Mismatched argument types in list merge.")
        } 
      }
    }
  }
  return(args_out)
}

#' Prepare a single input tree by combining paths.
#'
#' @param args an arg-tree
#' @return an arg-tree
#' @export
prepare_inputs = function(args) {

  # Prepare model
  args[['model_path']] <- find_model(args)

  # Prepare data
  data_dir <- args[['data_dir']]
  if (!is.null(data_dir) && !is.null(args[['data']][['file']])) {
    args[['data']][['file']] <- file.path(data_dir, args[['data']][['file']])
  }

  # Prepare inits
  init_exists <- !is.null(args[['init']]) && !is.na(args[['init']])
  is_init_file <- init_exists && is.na(as.numeric(args[['init']]))
  init_dir <- args[['init_dir']]
  if (!is.null(init_dir) && init_exists && is_init_file) {
    args[['init']] <- file.path(init_dir, args[['init']])
  }
  if (is_init_file && !file.exists(args[['init']])) {
    msg <- paste0("Initial values file missing at: ", args[['init']])
    stop(msg)
  }
  args[['hash']] <- create_hash(all_args[[i]])
  return(args)
}

#' Load a Stannis run control list of arg-trees from 
#' a .yaml file
#'
#' Format description: the two top-level items are
#' 'defaults', and 'runs'.  The each item under those
#' is a Stannis arg-tree with CmdStan arguments.
#'
#' Arg-trees are loaded, each run arg-tree is merged with the
#' defaults, and a hash is added to each.
#' 
#' @param file a .yaml file with arg-tree structure
#'        and defaults.
#' @return list of arg-trees with hashes, not finalized.
#' @export
load_args <- function(file) {
  control <- yaml::yaml.load_file(file)
  defaults <- control[['defaults']]
  all_args <- list()
  for (i in 1:length(control[['runs']])) {
    args <- merge_trees(defaults, control[['runs']][[i]])
    args[['binary']] <- compile_model(args)
    args <- replicate_args(args)
    args <- prepare_inputs(args)
    all_args <- c(all_args, args)
  }
  return(all_args)
}


#' Finalize an argument tree object by merging components
#' that are not fully specified and creating output directories
#' as necessary.
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
  output_files <- c('terminal', 'error', 'file', 'diagnostic_file', 'control')

  if (is.null(args[['target_dir']]))
    args[['target_dir']] <- getwd()

  if (!dir.exists(args[['target_dir']]))
    dir.create(args[['target_dir']], recursive = TRUE)
  args[['fit_path']] <- file.path(args[['target_dir']], args[['hash']])
  if (!dir.exists(args[['fit_path']]))
    dir.create(args[['fit_path']], recursive = TRUE)
  if (!dir.exists(file.path(args[['fit_path']], 'data')))
    dir.create(file.path(args[['fit_path']], 'data'), recursive=TRUE)
  if (!dir.exists(file.path(args[['fit_path']], 'init')))
    dir.create(file.path(args[['fit_path']], 'init'), recursive=TRUE)

  for (output in output_files) {
    args[['output']][[output]] <- file.path(args[['fit_path']], args[['output']][[output]])
  }


  if (!is.null(args[['data']]) && !is.null(args[['data']][['file']])) {
    if (file.exists(args[['data']][['file']])) {
      file.copy(from = args[['data']][['file']], 
	        to = file.path(args[['fit_path']], basename(args[['data']][['file']])))
    } else {
      msg <- paste0("Data file missing at: ", args[['data']][['file']])
      stop(msg)
    }
  }

  init_exists <- !is.null(args[['init']]) && !is.na(args[['init']])
  is_init_file <- init_exists && is.na(as.numeric(args[['init']]))
  init_dir <- args[['init_dir']]
  if (is_init_file && !file.exists(args[['init']])) {
    msg <- paste0("Initial values file missing at: ", args[['init']])
    stop(msg)
  } else {
    file.copy(from = args[['init']],
	      to = file.path(args[['fit_path']], basename(args[['init']])))
  }
  yaml::write_yaml(args, file = file.path(args[['fit_path']], "finalized.yaml"))
  register_run(args)
  return(args)
}
