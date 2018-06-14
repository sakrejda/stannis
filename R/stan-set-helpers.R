#' Wrapper for C++ function wrapper.
#'
#' @param file file name passed to C++ reader.
#' @return list with samples, indexing, etc...
#' @export
read_stan_csv = function(file) {
  file = normalizePath(file)
  os = stannis:::read_cmdstan_csv(file)
  os[['n_iterations']] = length(os[['parameters']][[1]])
  names(os[['parameters']]) = os[['p_names']]
  names(os[['index']]) = os[['p_names']]
  names(os[['dimensions']]) = os[['p_names']]
  names(os[['n_dim']]) = os[['p_names']]
  for (name in os[['p_names']]) {
    os[['parameters']][[name]] = array(
      data = os[['parameters']][[name]],
      dim = c(os[['n_iterations']], os[['dimensions']][[name]])
    )
  }    
  return(os)
}

#' Read a set of Stan files and their metadata
#'
#' @param root directory to read from
#' @param pattern pattern of filenames to read
#' @return a processed and merged list of files.
#' @export 
read_file_set = function(root='.', control = 'finalized.yaml', samples = 'output.csv', ...) {
  control_files = find_file(root, control, ...)
  if (length(control_files) == 0)
    control_files = NULL
  csv_files = find_file(root, samples, ...)
  if (length(csv_files) == 0)
    stop(paste0("No files matching the pattern were found at root: ", root, "\n"))
  attempt = try({
    n_chains = length(csv_files)
    metadata = lapply(control_files, yaml::yaml.load_file)
    csv_data = lapply(csv_files, read_stan_csv)
    grouping = list()
    for ( i in 1:n_chains) {
      n_iterations = metadata[[i]][['sample']][['num_warmup']] + metadata[[i]][['sample']][['num_samples']]
      grouping[[i]] = data.frame(
        iteration = 1:n_iterations,
        chain = i, 
        warmup = (1:n_iterations) <= metadata[[i]][['num_warmup']],
        post_warmup = (1:n_iterations) > metadata[[i]][['num_warmup']]
      )
    }
    return(list(metadata=metadata, n_chains = n_chains, 
                header_data = data[c('n_col', 'n_parameters', 'p_names', 'n_dim',
                                     'dimensions', 'index')],
                data = data[['parameters']],
                grouping = grouping))
  })
  return(list())
}


#' Trim warmup
#'
#' @param set object created by `read_stan_set`
#' @return same object but with warmup iterations removed.
#' @export
trim_warmup = function(set) {
  for (i in seq_along(set[['data']])) {
    idx = set[['grouping']][[i]][['post-warmup']]
    data = set[['data']][[i]]
    ndim = dim(data) %>% length
    if (ndim < 2) 
      data = data[idx]
    else 
      data = apply(data, 2:length(dim(data)), function(x, idx) x[idx])
    set[['data']][[i]] = data    
    set[['grouping']][[i]] = set[['grouping']][[i]][idx,]
  }
  return(set)
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
    data = do.call(abind::abind, c(set[['data']], list(along=-1),
      list(dimnames = dimnames(set[['data']][[1]])))),
    grouping = do.call(rbind, set[['grouping']])
  )
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




