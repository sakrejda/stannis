#' Basic method to return one CmdStan argument.
#'
#' @param name name of the parameter to add.
#' @param value value the parameter takes.
#' @return combined string argument.
#' @export
push_arg = function(name, value) paste0(name, "=", value)

#' Basic method to pull out arguments by name
#' from a list.
#'
#' @param args (potentially nested) list containing arguments.
#' @param names vector of named arguments to pull out.
#' @return turn vector of arguments as strings
#' @export
push_simple = function(args, names) {
  args_out = ""
  for (name in names) {
    if (name %in% names(args)) {
      args_out = paste(args_out, push_arg(name, args[[name]]))
    }
  }
  return(args_out)
}
 
#' Add a data argument.
#'
#' @param args argument list
#' @return argument string.
#' @export
push_data = function(args) {
  if (!('data' %in% names(args)))
    return("")
  args = args[['data']]
  stub = paste("data", push_simple(args, 'file'))
  return(stub)
}

#' Add a random init seed argument
#'
#' @param args argument list
#' @return argument string
#' @export
push_random = function(args) {
  if (!('random' %in% names(args)))
    return("")
  args = args[['random']]
  stub = paste("random", push_simple(args, 'seed'))
  return(stub)
}

#' Add output arguments.
#'
#' @param args argument list
#' @return argument string
#' @export
push_output = function(args) {
  if (!('output' %in% names(args))) 
    return("")
  args = args[['output']]
  stub = paste("output", push_simple(args,
    c('file', 'diagnostic_file', 'refresh')))
  return(stub)
}

#' add nuts sampler sub-arguments.
#'
#' @param args argument list
#' @return argument string
#' @export
push_nuts = function(args) {
  if (!("nuts" %in% names(args))) 
    return("")
  args = args[['nuts']]
  stub = push_simple(args, 'max_depth')
  return(stub)
}

#' add static HMC sub-arguments.
#'
#' @param args argument list
#' @return argument string
#' @export
push_static = function(args) {
  if (!("static" %in% names(args)))
    return("")
  args = args[['static']]
  stub = push_simple(args, 'int_time')
  return(stub)
}

#' Add HMC engine sub-arguments
#'
#' @param args argument list
#' @return argument string
#' @export
push_engine = function(args) {
  if (!("engine" %in% names(args)))
    return("")
  stub = paste0("engine=", args[['engine']]) 
  if (args[['engine']] == 'nuts')
    stub = paste(stub, push_nuts(args))
  else if (args[['engine']] == 'static')
    stub = paste(stub, push_static(args))
  else
    stop(paste0("Engine ',", args[['engine']], 
      "', is not an engine for HMC in Stan."))
  return(stub)
}

#' Add HMC metric sub-arguments.
#'
#' @param args argument list
#' @return argument string
#' @export
push_metric = function(args) {
  if (!('metric' %in% names(args)))
    return("")
  metrics = c('unit_e', 'diag_e', 'dense_e')
  if (args[['metric']] %in% metrics)
    stub = push_simple(args, 'metric')
  else {
    msg = paste0("HMC metric '", args[['metric']], "' ",
		  "is not an option in CmdStan.")
  }
  return(stub)
}

#' Add HMC algorithm sub-arguments
#'
#' @param args argument list
#' @return argument string
#' @export
push_hmc = function(args) {
  if (!("hmc" %in% names(args)))
    return("")
  args = args[['hmc']]
  stub = paste(
    push_engine(args),
    push_metric(args), 
    push_simple(args, c('metric_file', 'stepsize', 'stepsize_jitter')))
  return(stub)
}

#' Add fixed_param non-sampler arguments.
#'
#' @param args argument list
#' @return argument string
#' @export
push_fixed = function(args) {
  return("")
}

#' Add algorithm sub-arguments.
#'
#' @param args argument list
#' @return argument string
#' @export
push_algorithm = function(args) {
  if (!("algorithm" %in% names(args))) 
    return("")
  stub = paste0("algorithm=", args[['algorithm']])
  if (args[['algorithm']] == 'hmc')
    stub = paste(stub, push_hmc(args))
  else if (args[['algorithm']] == 'fixed')
    stub = paste(stub, push_fixed(args))
  else { 
    msg = paste0("Sampling algorithm '", args[['algorithm']], "' ",
		  "is not an option in CmdStan.")
    stop(msg)
  }
  return(stub)
}

#' Add sampler adaptation sub-arguments.
#'
#' @param args argument list
#' @return argument string
#' @export
push_adapt = function(args) {
  if (!('adapt' %in% names(args)))
    return("")
  args = args[['adapt']]
  stub = paste("adapt", push_simple(args,
        c('engaged', 'gamma', 'delta', 'kappa', 't0', 
          'init_buffer', 'term_buffer', 'window')))
  return(stub)
}

#' Add sampler sub-arguments
#'
#' @param args argument list
#' @return argument string
#' @export
push_sample = function(args) {
  if (!('sample' %in% names(args)))
    return("")
  args = args[['sample']]
  stub = paste(
    push_simple(args, c('num_samples', 'num_warmup', 'save_warmup', 'thin')),
    push_adapt(args), push_algorithm(args))
  return(stub)
}

push_optimize = function(...) stop("Optimization interface not implemented.")
push_variational = function(...) stop("VI interface not implemented.")
push_diagnose = function(...) stop("Diagnose interface not implemented.")
  
push_method = function(args) {
  stub = paste0("method=", args[['method']])
  if (args[['method']] == 'sample') {
    stub = paste(stub, push_sample(args[['sample']]))
  } else if (args[['method']] == 'optimize') {
    stub = paste(stub, push_optimize(args[['optimize']]))
  } else if (args[['method']] == 'variational') {
    stub = paste(stub, push_variational(args[['variational']]))
  } else if (args[['method']] == 'diagnose') {
    stub = paste(stub, push_diagnose(args[['diagnose']]))
  } else {
    msg = paste0("Method '", args[['method']], "'",
      " is not an option in CmdStan.")
    stop(msg)
  }
  return(stub)
}


#' Create a flat string of CmdStan arguments based on a 
#' sub-tree of an arg-tree.
#'
#' @param ... arguments to run CmdStan with.
#' @return string of arguments to CmdStan.
#' @export
construct_cmdline = function(...) {
  args = list(...)

  if (!('binary' %in% names(args))) {
    stop("Arguments must include path to binary in 'binary'.")
  } else {
    binary = args[['binary']]
  }

  if (!('method' %in% names(args)))
    args[['method']] = 'sample'

  cmd = paste(binary, push_method(args), 
    push_simple(args, 'id'),
    push_data(args), 
    push_simple(args, 'init'),
    push_random(args), 
    push_output(args))
  return(cmd)
}
