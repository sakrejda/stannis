
construct_cmdline <- function(...) {
  args <- list(...)

  push_optimize <- function(...) stop("Optimization interface not implemented.")
  push_variational <- function(...) stop("VI interface not implemented.")
  push_diagnose <- function(...) stop("Diagnose interface not implemented.")
  
  if (!('binary') %in% names(args)) {
    stop("Arguments must include path to binary in 'binary'.")
  } else {
    binary <- args[['binary']]
  }

  if (!('method' %in% names(args)))
    args[['method']] <- 'sample'

  if (args[['method']] == 'sample') {
    cmd <- paste(binary, push_sample(args))
  } else if (args[['method']] == 'optimize') {
    cmd <- paste(binary, push_optimize(...))
  } else if (args[['method']] == 'variational') {
    cmd <- paste(binary, push_variational(...))
  } else if (args[['method']] == 'diagnose') {
    cmd <- paste(binary, push_diagnose(...))
  } else {
    msg <- paste0("Method '", args[['method']], "'",
      " is not an option in CmdStan.")
  }
  cmd <- paste(cmd, push_args(args, 'id'),
    push_data(args), push_args(args, 'init'),
    push_random(args), push_output(args))
  return(cmd)
}

run_model_cmd <- function(...) {
  args_in <- finalize_args(list(...))
  cmd <- construct_cmdline(...) %>% strsplit('[ ]+') %>% `[[`(1)
  binary <- cmd[1]
  args <- cmd[2:length(cmd)]
  out <- args_in[['output']][['terminal']]
  err <- args_in[['output']][['error']]
  if ('wait' %in% names(args_in) && args_in[['wait']] == TRUE) 
    wait = TRUE
  else
    wait = FALSE
  system2(command=binary, args=args, stdout=out, stderr=err, wait=wait)
}

finalize_args <- function(args) {
  if (!is.null(args[['target_dir']])) {
    output_prefix <- file.path(args[['target_dir']], args[['hash']], args[['chain']])
    for (output in names(args[['output']])) {
      args[['output']][[output]] <- file.path(output_prefix, args[['output']][[output]])
    }
  }
  if (!is.null(args[['data_dir']])) {
    data_prefix <- file.path(args[['data_dir']], args[['hash']], args[['chain']])
    args[['data']][['file']] <- file.path(data_prefix, args[['data']][['file']])
  }
  if (!is.null(args[['init_dir']])) {
    init_prefix <- file.path(args[['init_dir']], args[['hash']], args[['chain']])
    args[['init']] <- file.path(init_prefix, args[['init']])
  }
  return(args)
}

# return binary path
compile_model <- function(args) {}

create_hash <- function(args) {}

# expand chains, inits, or both
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

load_yaml_args <- function(file) {
  control <- yaml::yaml.load_file(file)
  defaults <- control[['defaults']]
  all_args <- list()
  for (i in 1:length(control[['runs']])) {
    args <- merge_lists(defaults, control[['runs']][[i]])
    args[['binary']] <- compile_model(args)
    args[['output']] <- list()
    args[['output']][['terminal']] = 'terminal.txt'
    args[['output']][['error']] = 'error.txt'
    args[['output']][['file']] = 'output.csv'
    args[['output']][['diagnostics']] = 'diagnostics.csv'
    args[['output']][['control']] = 'control.yaml'
    args <- flatten_args(args)
    all_args <- c(all_args, args)
  }
  for (i in 1:length(all_args)) {
    all_args[i][['hash']] <- create_hash(all_args[i])
  }
  return(all_args)
}

run_yaml <- function(file, target_dir, cores = getOption("cl.cores", 1)) {  
  args <- load_yaml_args(file) 
  cl <- parallel::makeCluster(cores)
  o <- parallel::clusterMap(cl, function(run) {
    do.call(what=run_model_cmd, args=c(run, list(wait=TRUE)))
  }, args, .scheduling = 'dynamic')
  return(args)
}

