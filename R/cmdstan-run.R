
#' Run a CmdStan model based on a single arg-tree.
#' 
#' @param ... sub-tree of arg-tree split into arguments. 
#' @return NULL, run as a system command.
#' @export
run_model_cmd <- function(...) {
  args <- finalize_args(list(...))
  if (!args[['run']]) {
    return(args)
  }
  register_run(path = args[['target_dir']], args)
  cmd = args[['command']] %>% strsplit('[ ]+') %>% `[[`(1)
  cmd_binary <- cmd[1]
  cmd_args <- cmd[2:length(cmd)]
  cmd_out <- args[['output']][['terminal']]
  cmd_err <- args[['output']][['error']]
  if (isTRUE(args[['wait']]))
    wait = TRUE
  else
    wait = FALSE
  system2(command=cmd_binary, args=cmd_args, stdout=cmd_out, stderr=cmd_err, wait=wait)
  return(args)
}

#' Run a set of CmdStan runs based on a set of arg-trees
#' in a .yaml file.
#'
#' @param file .yaml file with instructions
#' @param cores number of cores to use for the run
#' @export
run_cmdstan <- function(file, cores = getOption("cl.cores", 1)) {  
  args <- load_args(file) 
  if (is.null(cores) || is.na(cores) || cores == 1) {
    for (i in 1:length(args)) {
      args[[i]] <- do.call(what = run_model_cmd, 
        args = c(args[[i]], list(wait = TRUE)))
    }
  } else {    
    cl <- parallel::makeCluster(cores)
    args <- parallel::clusterMap(cl, function(run) {
      do.call(what=run_model_cmd, args=c(run, list(wait=TRUE)))
    }, args, .scheduling = 'dynamic')
  }
  return(args)
}




