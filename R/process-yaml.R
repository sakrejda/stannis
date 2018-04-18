
process_stub <- function(args) {

  get_element <- function(x, name) {
    name_parts <- strsplit(name, "/", fixed=TRUE)[[1]]
    if (length(name_parts) == 1 && name %in% names(x)) {
      return(x[[name]])
    } else if (length(name_parts) > 1 && name %in% names(x)) {
      return(get_element(x[[name_parts[1]]], paste(name_parts[2:length(name_parts)], collapse="/")))
    } else {
      stop(paste0("'", name, "' required to process stub."))
    }
  }

  stub <- get_element(args, 'stub')
  stub_idx <- gregexpr(pattern = '\\[\\[([A-Z/]{1,100})\\]\\]', text=stub)[[1]]
  n_stubs <- length(stub_idx)
  stub_starts <- c(stub_idx) + 2 
  stub_stops <- c(stub_starts + attr(stub_idx, 'match.length')) - 5
  stub_parts <- substr(rep(stub, n_stubs), stub_starts, stub_stops)

  for (i in 1:n_stubs) {
    part_pattern <- paste0('\\[\\[', stub_parts[i], '\\]\\]')
    part_value <- get_element(args, tolower(stub_parts[i]))
    stub <- gsub(part_pattern, part_value, stub)
  }

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


