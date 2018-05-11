
#' Combine two lists by merging matching sub-trees.
#' 
#' @param ... arbitrary number of lists.
#' @return single merged list
#' @export
merge_lists <- function(...) {
  args_in <- list(...)
  args_out <- args_in[[1]]
  args_remaining <- args_in[2:length(args_in)]
  for (arg in args_remaining) {
    for (name in names(arg)) {
      if (!(name %in% names(args_out))) {
        args_out[[name]] <- arg[[name]]
      } else {
        if (is.list(args_out[[name]]) && is.list(arg[[name]])) {
          args_out[[name]] <- merge_lists(args_out[[name]], arg[[name]])
        } else if (!is.list(args_out[[name]]) && !is.list(arg[[name]])) {
          args_out[[name]] <- arg[[name]]
        } else {
          stop("Mismatched argument types in list merge.")
        } 
      }
    }
  }
  return(args_out)
}

#' Load a list of arg-trees from a .yaml file
#' 
#' @param file a .yaml file with arg-tree structure
#'        and defaults.
#' @param list of arg-trees with hashes, not finalized.
#' @export
load_yaml_args <- function(file) {
  control <- yaml::yaml.load_file(file)
  defaults <- control[['defaults']]
  all_args <- list()
  for (i in 1:length(control[['runs']])) {
    args <- merge_lists(defaults, control[['runs']][[i]])
    args[['binary']] <- compile_model(args)
    args <- flatten_args(args)
    all_args <- c(all_args, args)
  }
  for (i in 1:length(all_args)) {
    all_args[[i]][['hash']] <- create_hash(all_args[[i]])
  }
  return(all_args)
}


