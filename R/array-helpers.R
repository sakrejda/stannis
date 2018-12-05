

#' Normalize an array's labels.
#'
#' @param A array to create labels for (or matrix).
#' @return array with consitent dimnames.
#' @export
normalize_margin_names = function(A) {
  dims = dim(A) 
  n_dim = length(dims)
  dnl = dimnames(A)
  if (is.null(dnl))
    dnl = vector(mode = "list", length = n_dim)

  dn = names(dnl)
  if (is.null(dn))
    dn = vector(mode = 'character', length = n_dim)
  for (i in 1:n_dim) {
    missing_name_i = (dn[i] == "")
    if (missing_name_i) {
      dn[i] = paste("group", i, sep = "_")
    }
  }
  names(dnl) = dn

  for (i in 1:n_dim) {
    missing_j_names = is.null(dnl[[i]])
    if (missing_j_names)
      dnl[[i]] = as.character(1:dims[i])
  }
  dimnames(A) = dnl
  return(A)
}

#' Replace array dimensionality by explicit long-format data labels.
#' 
#' @param A array to process
#' @param ... further args passed to "data.frame"
#' @return data frame with all array data in long format.
#' @export
flatten_array = function(A, ...) {
  A = normalize_margin_names(A)
  labels = do.call(what = expand.grid, args = c(dimnames(A), list(stringsAsFactors = FALSE)))
  dim(A) = NULL
  A = data.frame(labels, value = A, stringsAsFactors = FALSE)
  return(A)
}

#' Take a numeric sequence and force it to sort properly as a character
#' sequence by padding to length.
#'
#' @param x numeric sequence
#' @return sequence of strings padded out to the same length
#' @export
padded_sequence = function(x) {
  wd = nchar(x)
  mw = max(wd)
  pw = paste0(sapply(wd, function(w, mw) paste(rep("0", mw - w), collapse = ""), mw = mw), x)
  return(pw)
}



#' Summarize iterations to estimates!
#'
#' @param x list from with named elements 'values' and 'grouping'.  The 'values' 
#'          element is a matrix (n-groups by n-iterations) with sampled
#'          parameter values.  The 'grouping' element is a data.frame with 
#'          n-groups rows and one column per index.
#' @param f function to use to aggregate (applied row-wise)
#' @return data frame (further merging of estimates is dissalowed due to
#'         "transform then summarize" pattern.
#' @export
summarize = function(x, f, ...) {
  x[['values']] <- apply(x[['values']], 1, f, ...) %>% t
  x <- data.frame(x[['grouping']], x[['values']], check.names=FALSE)
  return(x)
}

#' Standard summary function.
#'
#' @param x per-iteration parameter values.
#' @return per-estimate summary.
#' @export 
std_estimates <- function(x) {
  x = c(quantile(x, probs=0.025), mean(x), quantile(x, probs=0.975))
  names(x) <- c('lb', 'estimate', 'ub')
  attr(x, 'summaries') <- c('2.5%', 'mean', '97.5%')
  return(x)
}


