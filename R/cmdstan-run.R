
#' Create a flat string of CmdStan arguments based on a 
#' sub-tree of an arg-tree.
#'
#' @param ... arguments to run CmdStan with.
#' @return string of arguments to CmdStan.
#' @export
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

#' Run a CmdStan model based on a single arg-tree.
#' 
#' @param ... sub-tree of arg-tree split into arguments. 
#' @return NULL, run as a system command.
#' @export
run_model_cmd <- function(...) {
  args_in <- finalize_args(list(...))
  cmd <- do.call(what = construct_cmdline, args = args_in) %>% 
    strsplit('[ ]+') %>% `[[`(1)
  binary <- cmd[1]
  args <- cmd[2:length(cmd)]
  out <- args_in[['output']][['terminal']]
  err <- args_in[['output']][['error']]
  if ('wait' %in% names(args_in) && args_in[['wait']] == TRUE) 
    wait = TRUE
  else
    wait = FALSE
  system2(command=binary, args=args, stdout=out, stderr=err, wait=wait)
  args_in[['command']] <- cmd
  return(args_in)
}

#' Run a set of CmdStan runs based on a set of arg-trees
#' in a .yaml file.
#'
#' @param file .yaml file with instructions
#' @param cores number of cores to use for the run
#' @export
run_cmdstan <- function(file, cores = getOption("cl.cores", 1)) {  
  args <- load_yaml_args(file) 
  if (is.null(cores) || is.na(cores) || cores == 1) {
    for (i in 1:length(args)) {
      args[[i]] <- do.call(what = run_model_cmd, args = args[[i]])
    }
  } else {    
    cl <- parallel::makeCluster(cores)
    args <- parallel::clusterMap(cl, function(run) {
      do.call(what=run_model_cmd, args=c(run, list(wait=TRUE)))
    }, args, .scheduling = 'dynamic')
  }
  return(args)
}

