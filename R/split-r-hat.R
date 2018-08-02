
#' rstan's split-r-hat implementation in R
#'
#' Compute the split rhat for the diagnostics of converging; 
#' see the C++ code of split_potential_scale_reduction in chains.cpp.  
#' 
#' Note: 
#'   The R function wrapping the C++ implementation is defined 
#'   in chains.R with name rstan_splitrhat2_cpp 
#' 
#' @param  sims a 2-d array _without_ warmup samples (# iter * # chains) 
#' @return a single split-r-hat value.
split_rhat_rfun <- function(sims) {
  if (is.vector(sims)) dim(sims) <- c(length(sims), 1)
  chains <- ncol(sims)
  n_samples <- nrow(sims)
  half_n <- floor(n_samples / 2)
  idx_2nd <- n_samples - half_n + 1
  
  split_chain_mean <- numeric(chains * 2)
  split_chain_var <- numeric(chains * 2)
  
  for (i in 1:chains) {
    split_chain_mean[i] <- mean(sims[1:half_n, i])
    split_chain_var[i] <- var(sims[1:half_n, i])
    split_chain_mean[chains + i] <- mean(sims[idx_2nd:n_samples, i])
    split_chain_var[chains + i] <- var(sims[idx_2nd:n_samples, i])
  } 
  var_between <- half_n * var(split_chain_mean)
  var_within <- mean(split_chain_var) 
  sqrt((var_between/var_within + half_n -1)/half_n)
} 


#' Calculate a per-parameter summary
#'
#' Works on a single parameter from a set of chains.
#' 
#' @param set the chains to operate on
#' @return array of f(values) for each entry of the parameter.
#' @export
calculate_reduction <- function(chains, f) {
  samples = do.call(what=abind::abind, args = c(chains, along=-1)) 
  n_dim = length(dim(samples))
  if (n_dim == 2) 
    r_hat = f(t(samples))
  else
    r_hat = apply(samples, 3:n_dim, function(x) f(t(x)))
  return(r_hat)
}

#' Calculate Potential Scale Reduction Factor (PSRF)
#'
#' Works on an entire set of parameters.
#'
#' @param set the chains to operate on.
#' @return list of PSRF arrays (one per parameter)
#' @export 
calculate_set_psrf <- function(set) {
  parameters <- names(set$data[[1]])
  sampler_parameters = c('stepsize__', 'treedepth__', 'n_leapfrog__', 'divergent__', 'iteration')
  parameters <- parameters[!(parameters %in% sampler_parameters)]
  o <- list()
  for (parameter in parameters) {
    chains = lapply(set[['data']], `[[`, parameter)
    o[[parameter]] <- calculate_parameter_reduction(chains, split_rhat_rfun)
  }
  return(o)
}

#' Get the worst R-hat values per parameter.
#' 
#' @param list of r-hat values, per-parameter
#' @return tail of sorted list of r-hat values, per-parameter
#' @export
worst_psrf <- function(x) lapply(x, function(x) tail(sort(x)))



