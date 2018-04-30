
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
  old_hash = openssl::sha256(x = file(target_model_path))
  binary_path = file.path(binary_dir, args[['model_name']]) %>% normalizePath()
  if (new_hash == old_hash)
    return(binary_path)
  file.copy(from = model_path, to = binary_dir, overwrite = TRUE)
  system2(command = "make", 
    args = paste("-C", args[['cmdstan_dir']], binary_path),
    stdout = file.path(binary_dir, "compilation-output.txt"),
    stderr = file.path(binary_dir, "compilation-errors.txt"),
    wait = TRUE)
  if (file.exists(binary_path)) {
    return(binary_path)                           
  } else {
    stop("CmdStan failed to create binary.")
  }
}



