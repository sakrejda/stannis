#' Basic method to return one CmdStan argument.
#' @param name name of the parameter to add.
#' @param value value the parameter takes.
push_arg <- function(name, value) paste0(name, "=", value)

#' Basic method to pull out arguments by name
#' from a list
#' @param args (potentially nested) list containing arguments.
#' @param names vector of named arguments to pull out.
push_args <- function(args, names) {
  args_out <- ""
  for (name in names) {
    if (name %in% names(args)) {
      args_out <- paste(args_out, push_arg(name, args[[name]]))
    }
  }
  return(args_out)
}
 

push_data <- function(args) {
  if (!('data' %in% names(args)))
    return("")
  else 
    args <- args[['data']]
  if ('dir' %in% names(args)) {
    args[['file']] = file.path(args[['dir']], args[['file']])
  }
  stub <- paste("data", push_args(args, 'file'))
  return(stub)
}

push_random <- function(args) {
  if (!('random' %in% names(args)))
    return("")
  else 
    args <- args[['random']]
  stub <- paste("random", push_args(args, 'seed'))
  return(stub)
}

push_output <- function(args) {
  if (!('output' %in% names(args))) 
    return("")
  else 
    args <- args[['output']]
  stub <- paste("output", push_args(args,
    c('file', 'diagnostic_file', 'refresh')))
  return(stub)
}

push_nuts <- function(args) {
  if (!("nuts" %in% names(args))) 
    return("")
  stub <- push_args(args, 'max_depth')
  return(stub)
}

push_static <- function(args) {
  if (!("static" %in% names(args)))
    return("")
  stub <- push_args(args, 'int_time')
  return(stub)
}

push_engine <- function(args) {
  if (!("engine" %in% names(args)))
    return("")

  if (args[['engine']] == 'nuts')
    stub <- push_nuts(args)
  else if (args[['engine']] == 'static')
    stub <- push_static(args)
  else
    stop(paste0("Engine ',", args[['engine']], 
      "', is not an engine for HMC in Stan."))
  return(stub)
}

push_metric <- function(args) {
  if (!('metric' %in% names(args)))
    return("")
  else
    return(push_args(args, 'metric'))
}

push_hmc <- function(args) {
  if (!("hmc" %in% names(args)))
    return("")
 
  args <- args[['hmc']]
  stub <- paste("algorithm=hmc", push_engine(args),
    push_metric(args), push_args(args, c(
      'metric_file', 'stepsize', 'stepsize_jitter')))
  return(stub)
}

push_fixed <- function(args) {
  return("algorithm=fixed_param")
}

push_algorithm <- function(args) {
  if (!("algorithm" %in% names(args))) {
    return("")
  } else {
    if (args[['algorithm']] == 'hmc')
      stub <- push_hmc(args)
    else if (args[['algorithm']] == 'fixed')
      stub <- push_fixed(args)
  }
  return(stub)
}

push_adapt <- function(args) {
  if (!('adapt' %in% names(args)))
    return("")
  else
    args <- args[['adapt']]
  stub <- paste("adapt", push_args(args,
        c('engaged', 'gamma', 'delta', 'kappa', 't0', 
          'init_buffer', 'term_buffer', 'window')))
  return(stub)
}

push_sample <- function(args) {
  if (!('sample' %in% names(args)))
    return("method=sample")
  else
    args <- args[['sample']]
  stub <- paste("method=sample", push_args(args,
    c('num_samples', 'num_warmup', 'save_warmup', 'thin')),
    push_adapt(args), push_algorithm(args))
  return(stub)
}
