
#' Take last element of a vector.
#'
#' @param x a vector or list
#' @return last element of x
#' @export
last = function(x) sapply(x, function(z) z[length(z)])

