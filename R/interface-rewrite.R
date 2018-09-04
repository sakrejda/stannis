#' Rewrite a Stan .csv output file.
#' 
#' @param source path to Stan format .csv file
#' @param root where to rewrite to
#' @param tag uuid that gets embedded in binary output
#' @param comment freeform text embedded in binary output
#' @return TRUE if fully rewritten
#' @export
rewrite_stan_csv = function(source, root, tag, comment) {
  .Call('rewrite_stan_csv', PACKAGE = 'stannis', source, root, tag, comment)
}

