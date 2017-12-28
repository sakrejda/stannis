
push_arg <- function(name, value) paste0(name, "=", value)

push_args <- function(args, names) {
  args_out <- ""
  for (name in names) {
    if (name %in% names(args)) {
      args_out <- paste(args_out, push_arg(name, value))
    }
  }
  return(args_out)
}

push_engine <- function(args) {
  if (!('engine' %in% names(args)))
    return("")
  stub <- paste0("engine=", args[['engine']])
  if (args[['engine']] == 'static') {
    stub <- paste(stub, push_args(args, 'int_time'))
  } else if (args[['engine']] == 'nuts') {
    stub <- paste(stub, push_args(args, 'max_depth'))
  } else {
    msg <- paste("Engine '", args[['engine']], "' is not",
      " a recognized engine.")
  }
  return(stub)
}
  
push_metric <- function(args) {
  if (!('metric' %in% names(args)))
    return("")
  stub <- paste0("metric=", args[['metric']])
  if(args[['metric']] == 'unit_e') {
    stub <- paste(stub, push_args(args, 'unit_e'))
  } else if(args[['metric']] == 'diag_e') {
    stub <- paste(stub, push_args(args, 'diag_e'))
  } else if (args[['metric']] == 'dense_e') {
    stub <- paste(stub, push_args(args, 'dense_e'))
  } else {
    msg <- paste0("Metric '", args[['metric']], "' is not",
      " a recognized metric.")
    stop(msg)
  }
  return(stub)
}

push_data <- function(args) {
  stub <- paste("data", push_args(args, 'file'))
  return(stub)
}

push_seed <- function(args) {
  stub <- paste("random", push_args(args, 'seed'))
  return(stub)
}

push_output <- function(args) {
  stub <- paste("output", push_args(args,
    c('file', 'diagnostic_file', 'refresh')))
  return(stub)
}

push_adapt <- function(args) {
  adapt_args <- c('engaged', 'gamma', 'delta', 'kappa', 't0', 
          'init_buffer', 'term_buffer', 'window')
  if (!any(names(args) %in% adapt_args)) 
    return("")
  stub <- paste("adapt", push_args(args,
        c('engaged', 'gamma', 'delta', 'kappa', 't0', 
          'init_buffer', 'term_buffer', 'window')))
  return(stub)
}

sample_cmdline <- function(...) {
  args <- list(...)
  if (!('binary') %in% names(args)) {
    stop("Arguments must include path to binary in 'binary'.")
  } else {
    binary <- args[['binary']]
  }
  stub <- paste(binary, 
    "method=sample", push_args(args, 
      c('num_samples', 'num_warmup', 'save_warmup', 'thin')),
      push_adapt(args), 
      "algorithm=hmc"
  )
  stub <- paste(stub, push_engine(args), push_metric(args),
    push_args(args, c('metric_file', 'stepsize', 'stepsize_jitter')))
  return(stub) 
} 


run <- function(...) {
  args <- list(...)

  optimize_cmdline <- function(...) stop("Optimization interface not implemented.")
  variational_cmdline <- function(...) stop("VI interface not implemented.")
  diagnose_cmdline <- function(...) stop("Diagnose interface not implemented.")
  
  if (!('method' %in% names(args)))
    args[['method']] <- 'sample'

  if (args[['method']] == 'sample') {
    cmd <- sample_cmdline(...)
  } else if (args[['method']] == 'optimize') {
    cmd <- optimize_cmdline(...)
  } else if (args[['method']] == 'variational') {
    cmd <- variational_cmdline(...)
  } else if (args[['method']] == 'diagnose') {
    cmd <- diagnose_cmdline(...)
  } else {
    msg <- paste0("Method '", args[['method']], "'",
      " is not an option in CmdStan.")
  }
  cmd <- paste(cmd, push_args(args, 'id'),
    push_data(args), push_args(args, 'init'),
    push_seed(args), push_output(args))
  paths <- run_cmdline(cmd)
  return(paths)
}
