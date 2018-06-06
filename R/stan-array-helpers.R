
#' Extract array set from a Stan file set.
#'
#' @param set object created by `read_stan_set`
#' @return list of arrays, one per chain in set 
#' @export
create_array_set = function(set) {
  if (!isTRUE(set[['merged']])) {
    for (i in 1:length(set[['data']])) {
      set[['data']][[i]] = generate_parameter_arrays(set[['data']][[i]]) 
    }
  } else {
    set[['data']] = generate_parameter_arrays(set[['data']])
  }
  set[['is_array']] = TRUE
  return(set)
}

#' Extract a single parameter array from a Stan file set.
#'
#' @param set object created by `read_stan_set`
#' @return list of arrays, one per chain in set 
#' @export
extract_array = function(set, parameter) {
  if (!isTRUE(set[['merged']])) {
    o = list()
    for (i in seq_along(set[['data']])) {
      wh = colnames(set[['data']][[i]]) %>% get_split_column_indexes()
      sub_data = set[['data']][[i]][,wh[[parameter]], drop=FALSE]
      o[[i]] = generate_parameter_array(sub_data)
    }
  } else {
    wh = colnames(set[['data']]) %>% get_split_indexes()
    sub_data = set[['data']][,wh[[parameter]], drop=FALSE]
    o = generate_parameter_array(sub_data)
  }
  return(o)
}

#' Create margin labels following a pattern
#'
#' @param A array to create labels for (or matrix).
#' @return list of margin labels
#' @export
name_margins = function(A) {
  n_dim = dim(A) %>% length()
  l = list()
  groups = paste0("group_", 1:(n_dim - 1))
  for (i in 1:length(groups)) {
    group = groups[i]
    l[[group]] = as.character(1:(dim(A)[i + 1]))
  }
  return(l)
}

#' Create labelled samples.
#'
#' @param array array of samples extracted from sample file set
#' @param labels list with a named elements for each array margin
#'        and each element is a data frame of groupings to join with
#'        that margin's index. 
#' @return list with a component for a matrix of values (one group
#'         per row, one iteration per column), and a data.frame
#'         with string labels for each row.
#' @export
label = function(A, labels = NULL) {
  n_dim = dim(A) %>% length
  margins = name_margins(A)
  lf = matrix(data = A, ncol = dim(A)[1], byrow=TRUE)
  dimnames(lf) = list(group = 1:nrow(lf), iteration = 1:ncol(lf))
  grouping = do.call(what = expand.grid, 
    args = c(margins, list(stringsAsFactors=FALSE)))
  if (!is.null(labels)) {
    for (group in names(grouping)) {
      grouping = dplyr::left_join(grouping, labels[[group]], by = group)
    }
  }
  return(list(values = lf, grouping = grouping))  ## FIXME: Future proper type.
}

#' Summarize iterations to estimates!
#'
#' @param x list from with named elements 'values' and 'grouping'.  The 'values' 
#'          element is a matrix (n-groups by n-iterations) with sampled
#'          parameter values.  The 'grouping' element is a data.frame with 
#'          n-groups rows and one column per index.
#' @param f function to use to aggregate (applied row-wise)
summarize = function(x, f, ...) {
  x[['values']] <- apply(x, 1, f, ...)
  return(x)
}

#' Standard summary function.
#'
#' @param x per-iteration parameter values.
#' @return 
std_estimates <- function(x) {
  x = c(lb = quantile(x, probs=0.025), estimate = mean(x), ub = quantile(x, probs=0.975))
  attr(x, 'summaries') <- c('2.5%', 'mean', '97.5%')
  return(x)
}


