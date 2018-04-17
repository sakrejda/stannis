
process_stub <- function(args) {

  get_element <- function(x, name) {
    if (name %in% names(x))
      return(x[[name]])
    else
      stop(paste0("'", name, "' required to process stub."))
  }

  name <- get_element(args, 'name')
  id <- get_element(args, 'id')
  chain <- get_element(args, 'chain')
  model <- basename(get_element(args, 'binary'))
  get_element(args, 'data')
  data <- get_element(args[['data']], 'file')

  stub <- get_element(args, 'stub')
  stub <- gsub('\\[\\[NAME\\]\\]', name, stub)
  stub <- gsub('\\[\\[ID\\]\\]', id, stub)
  stub <- gsub('\\[\\[CHAIN\\]\\]', chain, stub)
  stub <- gsub('\\[\\[MODEL\\]\\]', model, stub)
  stub <- gsub('\\[\\[DATA\\]\\]', data, stub)
  return(stub)
}

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


