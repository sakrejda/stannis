
#' Run a CmdStan model based on a single arg-tree.
#' 
#' @param ... sub-tree of arg-tree split into arguments. 
#' @return NULL, run as a system command.
#' @export
run_model_cmd <- function(...) {
  args_in <- finalize_args(list(...))
  cmd <- do.call(what = construct_cmdline, args = args_in) %>% 
    strsplit('[ ]+') %>% `[[`(1)
  args_in[['command']] <- cmd
  binary <- cmd[1]
  args <- cmd[2:length(cmd)]
  out <- args_in[['output']][['terminal']]
  err <- args_in[['output']][['error']]
  if (isTRUE(args_in[['wait']]))
    wait = TRUE
  else
    wait = FALSE
  if (isTRUE(args_in[['existing_output']]))
    return(args_in)
  else
    system2(command=binary, args=args, stdout=out, stderr=err, wait=wait)
  return(args_in)
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




