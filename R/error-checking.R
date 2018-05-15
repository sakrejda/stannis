
#' Return an NA or the value
#'
#' @param x a list element, could be NULL
#' @return NA or the item
not_null <- function(x) if (is.null(x)) return(NA) else return(x)

#' Check whether list elements have different lenghts.
#'
#' @param x item to check.
#' @return TRUE only if x is a ragged list.
#' @export
is_ragged_list <- function(x) lapply(x, length) %>% unique %>%
  length %>% `!=`(1) %>% isTRUE

#' Check whether list elements are all zero.
#'
#' @param x item to check
#' @return TRUE only if x is a list.
#' @export
is_empty_list <- function(x) lapply(x, length) %>% unique %>%
  `==`(0) %>% all %>% isTRUE


#' Throw error when copying fails.
#'
#' @param from source path
#' @param to destination path
#' @export
copy_failed = function(from, to) { 
  msg = "Copying failed: \n"
  for (i in 1:length(from)) {
    msg = paste0(msg, 
      "  from: ", from[i], "\n",
      "  to:   ", to[i], "\n")
  }
  stop(msg)
}

#' Check if a path exists and is a directory
#'
#' @param p path to check
#' @return TRUE iff conditions are met
is_directory <- function(p) {
  p = path.expand(p)
  o = isTRUE(file.info(p)$isdir)
  return(o)
}

