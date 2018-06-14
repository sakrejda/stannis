
#' create a pseudo-'secret', salted with project_id
#'
#' @param args arg-tree object (list).
#' @return hash 
#' @export
create_hash <- function(args) {
  project_id_hash = get_id(args) %>% openssl::sha256()
  model_path = find_model(args)
  model_hash = openssl::sha256(x=file(model_path))
  if (is.null(args[['data']]) || is.null(args[['data']][['file']]))
    data_hash = ''
  else {
    data_file = args[['data']][['file']]
    if (!is.null(args[['data_dir']])) {
      data_file = file.path(args[['data_dir']], data_file)
    }
    if (file.exists(data_file)) {
      data_hash = openssl::sha256(x=file(data_file))
    } else {
      msg <- paste0("Data file missing: ", data_file)
      stop(msg)
    }
  }
  if (!is.null(args[['init']]) && !is.na(args[['init']]) && 
      is.na(as.numeric(args[['init']]))
  ) {
    init_file = args[['init']]
    if (!is.null(args[['init_dir']])) {
      init_file = file.path(args[['init_dir']], init_file)
    }
    if (file.exists(init_file)) {
      init_hash = openssl::sha256(x=file(args[['init']]))
    } else {
      msg <- paste0("Init file missing: ", init_file)
      stop(msg)
    }
  } else 
    init_hash = ''
  if (is.null(args[['hash_salt']]))
    hash_salt <- ""
  else
    hash_salt <- args[['hash_salt']]
  full_hash = openssl::sha256(x = paste(project_id_hash, model_hash,
    data_hash, init_hash, hash_salt, sep = ':'))
  return(full_hash)
}

