#' Read a set of Stan files and their metadata
#'
#' @param root directory to read from
#' @param pattern pattern of filenames to read
#' @return a processed and merged list of files.
#' @export 
read_file_set <- function(root='.', pattern) {
  files <- dir(path=root, pattern=pattern, full.names=TRUE, recursive=TRUE)
  n_chains <- length(files)
  metadata <- lapply(files, read_stan_metadata)
  ids <- sapply(metadata, `[[`, 'chain_id')
  data <- lapply(files, function(f) {
    d <- read_stan_data(f)
    d[['iteration']] <- 1:nrow(d)
    return(d)
  })
  grouping <- list()
  for ( i in seq_along(ids)) {
    grouping[[i]] <- data.frame(iteration = 1:nrow(data[[i]]))
    grouping[[i]][['chain']] <- rep(i, nrow(data[[i]]))
    grouping[[i]][['warmup']] <- 
      data[[i]][['iteration']] <= metadata[[i]][['num_warmup']]
    grouping[[i]][['post-warmup']] <- 
      data[[i]][['iteration']] > metadata[[i]][['num_warmup']]
  }
  return(list(metadata=metadata, n_chains = n_chains, data=data,
              grouping = grouping))
}


#' Trim warmup
#'
#' @param set object created by `read_stan_set`
#' @return same object but with warmup iterations removed.
#' @export
trim_warmup <- function(set) {
  for (i in seq_along(set[['data']])) {
    idx <- set[['grouping']][[i]][['post-warmup']]
    set[['data']][[i]] <- set[['data']][[i]][idx,]
    set[['grouping']][[i]] <- set[['grouping']][[i]][idx,]
  }
  return(set)
}

#' Merge chains
#'
#' @param set object created by `read_stan_set`
#' @return set object with only one merged chain.
#' @export
merge_chains <- function(set) {
  if (isTRUE(set[['is_array']])) {
    stop("Merging only supported on non-array sets.")
  }
  samples = set[['data']]
  cn = names(samples[[1]])
  for (c in 1:length(samples)) 
    if (any(cn != names(samples[[c]])))
      stop("Column names do not match within set. Not merging.")
  o <- list(
    n_chains = set[['n_chains']],
    metadata = set[['metadata']],
    data = do.call(rbind, set[['data']]),
    grouping = do.call(rbind, set[['grouping']])
  )
  o[['merged']] <- TRUE
  colnames(o$data) = cn
  return(o)
}

#' Scatter set
#' 
#' @param set set to write out.
#' @param target target directory to write to.
#' @return target directory 
#' @export
scatter <- function(set, target) {
  saveRDS(set[['metadata']], file = file.path(target, 'metadata.rds'))
  if (set[['merged']]) {
    if (is.data.frame(set[['data']]))
      saveRDS(set[['data']], file = file.path(target, paste0('samples-df.rds')))
    else {
      parameter_names = names(set[['data']])
      for (parameter in parameter_names) {
        saveRDS(set[['data']][[parameter]], file = file.path(target, 
          paste0('parameter-', parameter, '.rds')))
      }
    }
  } else { 
    for (i in 1:length(set[['data']])) { 
      if (is.data.frame(set[['data']][[i]])) {
        saveRDS(set[['data']][[i]], file = file.path(target, paste0('samples-chain-', i, '-df.rds')))
      } else {
        parameter_names = names(set[['data']][[i]])
        for (parameter in parameter_names) {
          saveRDS(set[['data']][[i]][[parameter]], file = file.path(target, 
            paste0('parameter-', parameter, '-chain-', i, '.rds')))
        }
      }
    }
  }
  return(target)
}




