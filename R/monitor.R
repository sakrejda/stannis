
#' Monitor runs in a given root directory
#'
#' @param root directory to search for runs under.
#' @param ... other arguments passed to find_run_files
#' @return data.frame with hash, path, and file names of output files
#'         with S3 class c("mcmc.monitor", "data.frame" to simplify
#'         printing.
#' @export
monitor = function(root = '.', split_complete = TRUE, ...) {
  rf = find_run_files(root, ...)
  fs = dir(path = file.path(root, rf$hash), 
    pattern = 'terminal.txt', full.names = TRUE)
  so = order(file.info(fs)$ctime)
  completion = mapply(FUN = function(f, h) {
    ls = readLines(f)
    ls = ls[grepl('^Iteration:', ls)]; 
    lsl = length(ls); 
    if (length(lsl) == 0) 
      return(list(hash = h, complete = -1, n_done = 0, n_iterations = NA))
    n_iterations = gsub('(.*) ([0-9]+)( / )([0-9]+) (.*)', '\\4', ls[1]) %>% as.numeric; 
    n_done = gsub('(.*) ([0-9]+)( / )([0-9]+) (.*)', '\\2', ls[lsl]) %>% as.numeric 
    if (n_done == n_iterations)
      return(list(hash = h, complete = 1, n_done = n_done, n_iterations = n_iterations))
    else
      return(list(hash = h, complete = 0, n_done = n_done, n_iterations = n_iterations))  
  }, f = fs, h = find_hash(fs), SIMPLIFY = FALSE, USE.NAMES = FALSE)
  completion = do.call(rbind, sapply(completion, data.frame, simplify = FALSE))[so,]
  class(completion) <- c("mcmc.monitor", "data.frame")
  return(completion)
}

#' Print output of stannis::monitor
#'
#' @param completion data from 'monitor' on the completion of runs.
#' @return NULL
#' @export
print.mcmc.monitor = function(completion) {
  w = options("width")[['width']] - 2
  s_done = trunc(completion[,'n_done'] / completion[,'n_iterations'] * w)
  s_todo = w - s_done
  done = sapply(s_done, rep, x='*', simplify = FALSE) %>% sapply(paste0, collapse = '')
  todo = sapply(s_todo, rep, x='-', simplify = FALSE) %>% sapply(paste0, collapse = '')
  msg = paste0("[", done, todo, "]\n")
  for (i in seq_along(msg)) {
    cat(paste("Hash:", completion[['hash']][i], "\n"))
    cat(msg[i])
    cat("\n")
  }
  return(NULL)
}



