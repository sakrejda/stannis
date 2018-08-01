
#' Check if two hashes match.
#'
#' @param a, an openssl::sha256 hash
#' @param b, an openssl::sha256 hash
#' @return TRUE only if they are equal
#' @export
hash_match <- function(a, b) {
  if (is.null(a) || is.null(b))
    return(FALSE)
  cmp <- a == b
  return(isTRUE(all(cmp)))
}

#' Find CmdStan installation
#'
#' @param args argument list, with possible hints..
#' @return CmdStan directory
#' @export
find_cmdstan <- function(args) {
  if (!is.null(args[['cmdstan_dir']]))
    cmdstan_dir = args[['cmdstan_dir']]
  else {
    cmdstan_dir = file.path(rappdirs::user_data_dir(), 'stannis', 'cmdstan') %>%
      path.expand()
    if (!dir.exists(cmdstan_dir))
      install_cmdstan()
  }
  return(cmdstan_dir)
}

#' Return binary path to a compiled model, don't recompile if
#' the stashed model is the same as the to-be-compiled model
#' according to a hash (just return the path).
#' 
#' @param args an argument tree
#' @return path to the binary of the compiled model.
compile_model <- function(args) {
  binary_dir <- get_binary_dir(args)
  model_path = find_model(args)
  new_hash = openssl::sha256(x = file(model_path))
  target_model_path = file.path(binary_dir, paste0(args[['model_name']], '.stan'))
  if (file.exists(target_model_path)) {
    old_hash = openssl::sha256(x = file(target_model_path))
  } else {
    old_hash = ""
  }
  binary_path = file.path(binary_dir, args[['model_name']]) %>% normalizePath()
  if (hash_match(new_hash, old_hash) && file.exists(binary_path))
    return(binary_path)
  file.copy(from = model_path, to = binary_dir, overwrite = TRUE)
  cmdstan_dir = find_cmdstan(args)
  system2(command = "make", 
    args = paste("-C", cmdstan_dir, binary_path),
    stdout = file.path(binary_dir, "compilation-output.txt"),
    stderr = file.path(binary_dir, "compilation-errors.txt"),
    wait = TRUE)
  if (file.exists(binary_path)) {
    return(binary_path)                           
  } else {
    stop("CmdStan failed to create binary.")
  }
}



