

#' Parameters can be extracted as long-format in index and wide-format in
#' iteration.  Preferably you can take a parameter that has meaningful margins
#' plus one margin for chain, and one margin for iteration in array format 
#' and transform it so that it has long-format meanigful margins with index 
#' columns, and wide-format margin is left for iterations. At this stage you
#' need to decide if chains are merged or not.  If chains are _not_ merged
#' then chain becomes one of the indexes.
#'
#' There should be K indexes, each with J_k groupings, and M iterations
#' produced in a sample.
#'
#' This way dplyr/data.table/base indexing can be used to pick out and label
#' meaningful margins, and apply(1, FUN) can be used to apply a summary
#' function to the iterations.  A summary function might reduce the `iteration`
#' margin to 1 `estimate` column, or it can produce P summaries, each with a
#' label.











