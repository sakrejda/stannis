
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
  args_in <- list(...)
  cmd <- construct_cmdline(...) %>% strsplit('[ ]+') %>% `[[`(1)
  binary <- cmd[1]
  args <- cmd[2:length(cmd)]
  if ('output' %in% names(args_in)) {
    if ('terminal' %in% names(args_in[['output']])) {
      out <- args_in[['output']][['terminal']]
    } else {
      out <- ""
    }
    if ('error' %in% names(args_in[['output']])) {
      err <- args_in[['output']][['error']]
    } else {
      err <- ""
    }
  } else {
    out <- ""
    err <- ""
  }
  if (out == "" || err == "") 
    wait = TRUE
  else
    wait = FALSE
  system2(command=binary, args=args, 
    stdout=out, stderr=err, wait=wait)
}


process_stub <- function(args) {

  get_element <- function(x, name) {
    if (name %in% names(x))
      return(x[[name]])
    else
      stop(paste0("'", name, "' required to process stub."))
  }

  name <- get_element(args, 'name')
  id <- get_element(args, 'id')
  chain <- get_element(args, 'chain')
  model <- basename(get_element(args, 'binary'))
  get_element(args, 'data')
  data <- get_element(args[['data']], 'file')

  stub <- get_element(args, 'stub')
  stub <- gsub('\\[\\[NAME\\]\\]', name, stub)
  stub <- gsub('\\[\\[ID\\]\\]', id, stub)
  stub <- gsub('\\[\\[CHAIN\\]\\]', chain, stub)
  stub <- gsub('\\[\\[MODEL\\]\\]', model, stub)
  stub <- gsub('\\[\\[DATA\\]\\]', data, stub)
  return(stub)
}

merge_lists <- function(...) {
  args_in <- list(...)
  args_out <- args_in[[1]]
  args_remaining <- args_in[2:length(args_in)]
  for (arg in args_remaining) {
    for (name in names(arg)) {
      if (!(name %in% names(args_out))) {
        args_out[[name]] <- arg[[name]]
      } else {
        if (is.list(args_out[[name]]) && is.list(arg[[name]])) {
          args_out[[name]] <- merge_lists(args_out[[name]], arg[[name]])
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

load_yaml_args <- function(file, hash=NULL) {
  control <- yaml::yaml.load_file(file)
  defaults <- control[['defaults']]
  runs <- control[['runs']]
  cmds <- list()
  for (i in 1:length(runs)) {
    run <- runs[[i]][['name']]
    args <- merge_lists(defaults, runs[[i]])
    if (!is.null(hash) && 'output' %in% names(args) && 'dir' %in% names(args[['output']])) { 
      args[['output']][['dir']] = file.path(args[['output']][['dir']], hash)
    }
    args[['binary']] <- file.path(args[['binary_dir']], run)
    args[['id']] <- sample(10^6, 1)
    if (!('sample' %in% names(args)) ||
        !('num_chains' %in% names(args[['sample']])) || 
        isTRUE(args[['sample']][['num_chains']] < 1)) {
      args[['sample']][['num_chains']] <- 1
    } else {
      args[['sample']][['num_chains']] <- as.integer(args[['sample']][['num_chains']])
    }
    for (chain in 1:args[['sample']][['num_chains']]) { 
      args[['chain']] <- chain
      stub <- process_stub(args)
      output_names <- list(
        terminal = paste0(stub, '-terminal.txt'),
        error = paste0(stub, '-errors.txt'),
        file = paste0(stub, '-output.csv'),
        diagnostics = paste0(stub, '-diagnostics.csv'),
        control = paste0(stub, '-control.rds')
      )
      if ('output' %in% names(args) && 'dir' %in% names(args[['output']])) {
        output_names <- lapply(output_names, 
          function(x) file.path(args[['output']][['dir']], x))
      }
      for (name in names(output_names)) {
        args[['output']][[name]] <- output_names[[name]]
      }
      cmds[[paste(run, i, chain, sep=':')]] <- args 
    }
  }
  return(cmds)
}

run_yaml <- function(file, hash=NULL) {  
  args <- load_yaml_args(file, hash) 
  for (run in args) {
    saveRDS(object=args, file=run[['output']][['control']])
    o <- do.call(what=run_model_cmd, args=run)
  }
  return(args)
}

