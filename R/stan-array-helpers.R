
#' Extract array set from a Stan file set.
#'
#' @param set object created by `read_stan_set`
#' @return list of arrays, one per chain in set 
#' @export
create_array_set <- function(set) {
  if (!isTRUE(set[['merged']])) {
    for (i in 1:length(set[['data']])) {
      set[['data']][[i]] <- generate_parameter_arrays(set[['data']][[i]]) 
    }
  } else {
    set[['data']] <- generate_parameter_arrays(set[['data']])
  }
  set[['is_array']] <- TRUE
  return(set)
}

#' Extract a single parameter array from a Stan file set.
#'
#' @param set object created by `read_stan_set`
#' @return list of arrays, one per chain in set 
#' @export
extract_array <- function(set, parameter) {
  if (!isTRUE(set[['merged']])) {
    o <- list()
    for (i in seq_along(set[['data']])) {
      wh = colnames(set[['data']][[i]]) %>% get_split_column_indexes()
      sub_data <- set[['data']][[i]][,wh[[parameter]], drop=FALSE]
      o[[i]] <- generate_parameter_array(sub_data)
    }
  } else {
    wh = colnames(set[['data']]) %>% get_split_indexes()
    sub_data <- set[['data']][,wh[[parameter]], drop=FALSE]
    o <- generate_parameter_array(sub_data)
  }
  return(o)
}

#' Label parameter array 
#'
#' @param array, Stan-dimension (+1 for iteration) array of 
#'        parameter samples.  First dimension is the iteration.
#' @param labels, list, matching array dimensions, used to
#'        label array margins, one list element per dimension, 
#'        name is the dimension name, each entry is a vector
#'        with labels or each entry of the dimension index.
#' @export
label_array <- function(A, labels) { 
  if (!is.null(labels)) {
    dimnames(A) = labels
  } else {
    dimnames(A) = lapply(dim(A), function(x) 1:x)
  } 
  return(A)
}

#' Array to long-form
#'
#' @param array array of samples extracted from sample file set
#' @param labels list with a named elements for each array margin
#'        and each element lists the names for that margin.  The
#'        first list element must be for the iterations margin.
#' @return list with a component for a matrix of values (one group
#'         per row, one iteration per column), and a data.frame
#'         with string labels for each row.
#' @export
unroll_array <- function(A, labels = NULL) {
  A = label_array(A, labels = labels)
  n_dim <- dim(A) %>% length
  lf <- matrix(data = A, ncol = dim(A)[1], byrow=TRUE)
  dimnames(lf) <- list(group = 1:nrow(lf), iteration = 1:ncol(lf))
  labels = dimnames(A)[2:n_dim]
  grouping <- do.call(what = expand.grid, 
    args = c(labels, list(stringsAsFactors=FALSE)))
  return(list(values = lf, grouping = grouping))  ## FIXME: Future proper type.
}

#' Array to long-form, combined into one data frame.
#'
#' @param array array of samples extracted from sample file set
#' @param labels list with a named elements for each array margin
#'        and each element lists the names for that margin.
#' @return data frame with grouping variables and the associated
#'         values (iterations are in columns with numerical names.
#' @export
unroll_array_to_df <- function(A, labels = NULL) {
  lf <- unroll_array(A, labels)
  lf <- data.frame(lf[['grouping']], lf[['values']], check.names = FALSE, stringsAsFactors=FALSE)
  return(lf) 
}


