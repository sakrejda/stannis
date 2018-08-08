#' Wrapper for C++ function wrapper.
#'
#' @param file file name passed to C++ reader.
#' @return list with samples, indexing, etc...
#' @export
read_stan_csv = function(file) {
  file = normalizePath(file)
  os = stannis:::read_cmdstan_csv(file)
  os[['index']] = NULL
  os[['n_col']] = NULL
  os[['n_iterations']] = length(os[['parameters']][[1]])
  d = lapply(os[['dimensions']], function(x) if (length(x) == 0) 1 else x)
  names(d) = os[['p_names']]
  names(os[['parameters']]) = os[['p_names']]
  for (name in os[['p_names']]) {
    dim(os[['parameters']][[name]]) <- c(os[['n_iterations']], d[[name]])
  }
  os[['dimensions']] = NULL
  return(os)
}

#' Process sampling file

#' Process diagnostics
#'
#' @param x `read_stan_csv` output of diagnostic .csv file.
process_diagnostics = function(x) {
  fix_diagnostic_names <- function(s) mapply(substr, x=s, stop=nchar(s), MoreArgs=list(start=3))

  o = list()
  n_algorithm_parameters = 7
  n_sampler_parameters = (x[['n_parameters']] - n_algorithm_parameters) / 3
  if (n_sampler_parameters != trunc(n_sampler_parameters))
    stop("This is not a diagnostic file.")

  algorithm_start = 1
  algorithm_stop = algorithm_start + n_algorithm_parameters - 1
  position_start = algorithm_stop + 1
  position_stop = position_start + n_sampler_parameters - 1
  momentum_start = position_stop + 1
  momentum_stop = momentum_start + n_sampler_parameters - 1
  gradient_start = momentum_stop + 1
  gradient_stop = gradient_start + n_sampler_parameters - 1
  algorithm_names <- x[['p_names']][algorithm_start:algorithm_stop]
  parameter_names <- x[['p_names']][position_start:position_stop]

  o[['algorithm']] <- x[['parameters']][algorithm_start:algorithm_stop]
  o[['position']] <- x[['parameters']][position_start:position_stop]
  names(o[['position']]) <- parameter_names 
  o[['momentum']] <- x[['parameters']][momentum_start:momentum_stop]
  names(o[['momentum']]) <- parameter_names 
  o[['gradient']] <- x[['parameters']][gradient_start:gradient_stop]
  names(o[['gradient']]) <- parameter_names
  return(o)
}


#' Read a set of Stan files and their metadata
#'
#' @param search directories to read from
#' @param pattern pattern of filenames to read
#' @return a processed and merged list of files.
#' @export 
read_file_set = function(root='.', hashes = NULL, control = 'finalized.yaml', 
  samples = 'output.csv', diagnostics = 'diagnostics.csv', ...
) {
  if (is.null(hashes)) 
    stop("Must indicate which hashes to include in a comparable run.")
  index = data.frame(hash = hashes)
  control_files = find_file(root, control, ...)


  metadata = lapply(control_files, yaml::yaml.load_file)
  if (length(control_files) == 0)
    control_files = NULL
  csv_files = find_file(root, samples, ...)
  n_chains = length(csv_files)
  if (length(csv_files) == 0)
    stop(paste0("Sampling matching the pattern were not found at root: ", root, "\n"))

  grouping = list()
  for ( i in 1:n_chains) {
    n_iterations = metadata[[i]][['sample']][['num_warmup']] + 
      metadata[[i]][['sample']][['num_samples']]
      n_warmup = metadata[[i]][['sample']][['num_warmup']]
      grouping[[i]] = data.frame(
        iteration = 1:n_iterations, chain = i, 
        warmup = (1:n_iterations) <= n_warmup,
        post_warmup = (1:n_iterations) > n_warmup
      )
    }
    csv_data = lapply(csv_files, read_stan_csv)
    header_data = lapply(csv_data, function(x) x[c(
      'n_col', 'n_parameters', 'p_names', 'n_dim', 
      'dimensions', 'index', 'timing', 'step_size', 'mass_matrix')])
  sampling <- list(metadata=metadata, n_chains = n_chains, 
                header_data = header_data,
                data = lapply(csv_data, `[[`, 'parameters'),
                grouping = grouping)

  diagnostic_files = find_file(root, diagnostics, ...)
  if (length(diagnostic_files) != length(sampling[['header_data']]))
    stop(paste0("Diagnostic files (for each sampling file) matching",
		"the pattern were not found at root: ", root, "\n"))
  sampling[['diagnostics']] = try({
    n_chains = length(diagnostic_files)
    diagnostic_data = lapply(diagnostic_files, read_stan_csv) %>%
      lapply(process_diagnostics) 
    for (name in c('algorithm', 'position', 'momentum', 'gradient')) {
      diagnostic_data[[name]] <- lapply(diagnostic_data, `[[`, name)
    }
    diagnostic_data
  })
  return(sampling)
}


#' Trim warmup
#'
#' @param set object created by `read_stan_set`
#' @return same object but with warmup iterations removed.
#' @export
trim_warmup = function(set) {
  for (i in seq_along(set[['data']])) {
    idx = set[['grouping']][[i]][['post_warmup']]
    for (p in names(set[['data']][[i]])) {
      data = set[['data']][[i]][[p]]
      ndim = dim(data) %>% length
      if (ndim < 2) 
        data = data[idx]
      else 
        data = apply(data, 2:ndim, function(x, idx) x[idx], idx=idx)
      set[['data']][[i]][[p]] = data    
    }
    set[['grouping']][[i]] = set[['grouping']][[i]][idx,]
  }
  return(set)
}

#' Get names of parameters in set
#'
#' @param set object created by read_file_set
#' @return names of parameters in set
#' @export
get_parameter_names = function(set) {
  matchy_names = sapply(set[['data']], names) %>%
    apply(1, function(x) length(unique(x)) == 1) %>%
    all
  return(names(set[['data']][[1]]))
}

#' Merge chains
#'
#' @param set object created by `read_stan_set`
#' @return set object with only one merged chain.
#' @export
merge_chains = function(set) {
  data = set[['data']]
  o = list(
    n_chains = set[['n_chains']],
    metadata = set[['metadata']],
    data = list(),
    grouping = do.call(rbind, set[['grouping']])
  )
  d = list()
  parameters = get_parameter_names(set) 
  for (p in parameters) {
    d[[p]] = list()
    for (i in 1:length(set[['data']])) {
      d[[p]][[i]] = set[['data']][[i]][[p]] 
    }
    o[['data']][[p]] = do.call(abind::abind, c(d[[p]], list(along=1),
      list(dimnames = dimnames(set[['data']][[1]][[p]]))))
  }
  o[['merged']] = TRUE
  return(o)
}

#' Scatter set
#' 
#' @param set set to write out.
#' @param target target directory to write to.
#' @return target directory 
#' @export
scatter = function(set, target) {
  saveRDS(set[['metadata']], file = file.path(target, 'metadata.rds'))
  if (set[['merged']]) {
    parameter_names = names(set[['data']])
    for (parameter in parameter_names) {
      saveRDS(set[['data']][[parameter]], file = file.path(target, 
        paste0('parameter-', parameter, '.rds')))
    }
  } else { 
    for (i in 1:length(set[['data']])) { 
      parameter_names = names(set[['data']][[i]])
      for (parameter in parameter_names) {
        saveRDS(set[['data']][[i]][[parameter]], file = file.path(target, 
          paste0('parameter-', parameter, '-chain-', i, '.rds')))
      }
    }
  }
  return(target)
}




