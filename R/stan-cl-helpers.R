#' Get the Stan version from processed list.
#'
#' @param processed list from .csv
#' @return stan version string.
#' @export
get_stan_version <- function(cl) c(major=cl$stan_version_major, 
  minor=cl$stan_version_minor, patch=cl$stan_version_patch)

#' Model name from list.
#'
#' @param processed list from .csv
#' @return model name
#' @export
get_model_name <- function(cl) cl[['model']]

#' Sampling method name from processed list.
#'
#' @param processed list from .csv
#' @return method name
#' @export
get_method_name <- function(cl) cl[['method']]

#' Algorithm name from processed list.
#'
#' @param processed list from .csv
#' @return algorithm name
#' @export
get_algorithm_name <- function(cl) cl[['algorithm']]

#' Engine name from processed list.
#'
#' @param processed list from .csv
#' @return engine name
#' @export
get_engine_name <- function(cl) cl[['engine']]

#' Indicator whether to save warmup.
#'
#' @param processed list from .csv
#' @return indicator as TRUE/FALSE
#' @export
get_save_warmup <- function(cl) cl[['save_warmup']] %>% get_initial_number %>%
  as.numeric %>% as.logical

#' Number of warmup iterations.
#'
#' @param processed list from .csv
#' @return integer number of warmup iterations
#' @export 
get_num_warmup <- function(cl) {
  save <- get_save_warmup(cl)
  if (save) 
    o <- cl[['num_warmup']] %>% get_initial_number %>% as.numeric
  else 
    o <- 0
  return(o)
}

#' Thin by
#'
#' @param processed list from .csv
#' @return number of iterations to thin by
#' @export 
get_thin <- function(cl) cl[['thin']] %>% get_initial_number %>% as.numeric

#' Number of total iterations
#'
#' @param processed list from .csv
#' @return integer number of total iterations.
#' @export 
get_num_draws <- function(cl) {
  thin <- get_thin(cl)
  o <- cl[['num_samples']] %>% get_initial_number %>% as.numeric
  return((o %/% thin) + 1)
}

#' Whether adaptation is engaged
#'
#' @param processed list from .csv
#' @return TRUE if adaptation was used.
#' @export 
get_adaptation_used <- function(cl) cl[['engaged']] %>% get_initial_number %>% 
  as.numeric %>% as.logical %>% isTRUE()

#' Gamma adaptation parameter
#'
#' @param processed list from .csv
#' @return parameter value
#' @export 
get_gamma <- function(cl) cl[['gamma']] %>% get_initial_number %>% as.numeric

#' Delta adaptation parameter
#'
#' @param processed list from .csv
#' @return parameter value
#' @export 
get_delta <- function(cl) cl[['delta']] %>% get_initial_number %>% as.numeric

#' Kappa adaptation parameter
#'
#' @param processed list from .csv
#' @return parameter value
#' @export 
get_kappa <- function(cl) cl[['kappa']] %>% get_initial_number %>% as.numeric

#' t0 adaptation parameter
#'
#' @param processed list from .csv
#' @return parameter value
#' @export 
get_t0 <- function(cl) cl[['t0']] %>% get_initial_number %>% as.numeric

#' init_buffer adaptation parameter
#'
#' @param processed list from .csv
#' @return parameter value
#' @export 
get_init_buffer <- function(cl) cl[['init_buffer']] %>% get_initial_number %>% as.numeric

#' terminal buffer adaptation parameter
#'
#' @param processed list from .csv
#' @return parameter value
#' @export 
get_term_buffer <- function(cl) cl[['term_buffer']] %>% get_initial_number %>% as.numeric

#' adaptation window parameter
#'
#' @param processed list from .csv
#' @return parameter value
#' @export 
get_window <- function(cl) cl[['window']] %>% get_initial_number %>% as.numeric

#' max tree depth parameter
#'
#' @param processed list from .csv
#' @return parameter value
#' @export 
get_max_depth <- function(cl) cl[['max_depth']] %>% get_initial_number %>% as.numeric

#' metric used parameter.
#'
#' @param processed list from .csv
#' @return parameter value
#' @export 
get_metric <- function(cl) cl[['metric']] 

#' initial stepsize parameter
#'
#' @param processed list from .csv
#' @return parameter value
#' @export 
get_initial_stepsize <- function(cl) cl[['stepsize']] %>% get_initial_number %>% as.numeric

#' retrieve chain id
#'
#' @param processed list from .csv
#' @return parameter value
#' @export 
get_chain_id <- function(cl) cl[['id']] %>% get_initial_number %>% as.numeric

#' data file path
#'
#' @param processed list from .csv
#' @return path
#' @export 
get_data_file <- function(cl) cl[['file']]

#' init file path
#'
#' @param processed list from .csv
#' @return path
#' @export 
get_init_file <- function(cl) cl[['file']]


#' output file path
#'
#' @param processed list from .csv
#' @return path
#' @export 
get_output_file <- function(cl) {cl[['file']] <- NULL; return(cl[['file']])}

#' diagnostic file path
#'
#' @param processed list from .csv
#' @return path
#' @export 
get_diagnostic_file <- function(cl) cl[['diagnostic_file']]

#' output refresh parameter
#'
#' @param processed list from .csv
#' @return path
#' @export 
get_refresh <- function(cl) cl[['refresh']] %>% as.numeric


