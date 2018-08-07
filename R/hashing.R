
#' create a pseudo-'secret', salted with project_id
#' 
#' This is a hash of the:
#'   1) project id
#'   2) model file contents
#'   3) model binary contents
#'   4) data file contents (if any)
#'   5) init file contents (if any)
#'   6) arbitrary hash salt
#'   7) prepared but not finalized arg tree 
#'
#' @param args arg-tree object (list).
#' @return hash 
#' @export
create_hash <- function(args) {
  project_id_hash = get_id(args) %>% openssl::sha256()
  model_path = find_model(args)
  model_hash = openssl::sha256(x=file(model_path))
  binary_hash = openssl::sha256(x=file(args[['binary']]))
  args[['binary']] <- NULL ## otherwise hashed already 
  if (is.null(args[['data']]) || is.null(args[['data']][['file']]))
    data_hash = ''
  else {
    data_file = args[['data']][['file']]
    if (file.exists(data_file)) {
      data_hash = openssl::sha256(x=file(data_file))
      args[['data']][['file']] <- NULL ## otherwise hashed already
    } else {
      msg <- paste0("Data file missing: ", data_file)
      stop(msg)
    }
  }
  if (!is.null(args[['init']]) && !is.na(args[['init']]) && 
      is.na(as.numeric(args[['init']]))
  ) {
    init_file = args[['init']]
    if (file.exists(init_file)) {
      init_hash = openssl::sha256(x=file(init_file))
      args[['init']] <- NULL ## otherwise hashed already
    } else {
      msg <- paste0("Init file missing: ", init_file)
      stop(msg)
    }
  } else {
    init_hash = ''
  }

  args[['target_dir']] <- NULL
  args[['data_dir']] <- NULL
  args[['model_dir']] <- NULL
  args[['binary_dir']] <- NULL
  args[['model_path']] <- NULL
  arg_hash = args %>% unlist %>% openssl::sha256() %>% 
    paste(collapse = ":")  ## includes hash_salt

  full_hash = openssl::sha256(x = paste(project_id_hash, 
    model_hash, binary_hash,
    data_hash, init_hash, arg_hash, sep = ':'))
  if (length(full_hash) != 1) 
    stop("Hash should be a length-1 character vector.")
  return(full_hash)
}

#' List all hashes under a target directory
#'
#' @param target_dir directory to search for hashes
#' @return character vector of hashes
#' @export
index_hashes = function(target_dir) dir(path = target_dir,
  pattern = '^([a-z0-9]{64})$', full.names = FALSE, recursive = FALSE)




