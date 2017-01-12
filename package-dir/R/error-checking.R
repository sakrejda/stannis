#' Check whether list elements have different lenghts.
is_ragged_list <- function(x) lapply(x, length) %>% unique %>%
  length %>% `!=`(1) %>% isTRUE

#' Check whether list elements are all zero.
is_empty_list <- function(x) lapply(x, length) %>% unique %>%
  `==`(0) %>% all %>% isTRUE




