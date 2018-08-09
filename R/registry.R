

#' Load a registry (or initialize if necessary).
#' 
#' @param path path where to load the registry from
#' @return the registry object
#' @export
load_registry = function(path = 'registry.yaml') {
  if (file.exists(path))
    registry = yaml::yaml.load_file(input = path)
  else
    registry = list()
  return(registry)
}
  
#' Save a registry
#'
#' @param registry a registry object
#' @param path the path to save the registry to (.yaml)
#' @return path where the reigstry was saved
#' @export
save_registry = function(registry, path = 'registry.yaml') {
  yaml::write_yaml(x = registry, file = path)
  return(path)
}

#' Check that a key exists in the registry 
#'
#' @param registry a registry object
#' @param hash the key (hash) to check
#' @return logical (TRUE/FALSE)
#' @export
check_key = function(registry, key) isTRUE(!is.null(registry[[key]]))

#' Remove a record from the registry
#'
#' @param registry a registry object
#' @param hash the key (hash) to remove
#' @return NULL
#' @export
remove_key = function(registry, hash) registry[[key]] = NULL

#' Add a key to a registry, with its arg-tree
#' 
#' @param registry the registry to add to
#' @param args the art-tree to add
#' @return the registry with the added key
#' @export
insert_in = function(args, registry) {
  hash = args[['hash']]
  exists = check_key(registry, hash)
  if (exists) {
    matches = isTRUE(registry[[hash]][[hash]] == hash)
    if (!matches) {
      msg = paste0("Registry has an in consistent entry, '",
		   hash, "', can not insert there.")
      stop(msg)
    }
  }
  registry[[hash]] = args
  return(registry)
}

#' Record that a run is being started
#'
#' @param args arg-tree object (list)
#' @return NULL
#' @export
register_run = function(path, args) {
  registry_file = file.path(args[['target_dir']], 'registry.yaml')
  registry = load_registry(registry_file)
  insert_in(args, registry)
  save_registry(registry, registry_file)
  return(registry_file)  
}

#' Build a registry 
#' @param root root of the tree of Stannis runs (where to find hash dirs)
#' @param name name of the registry file (w/o extension)
#' @param target optional directory where to place the registry
#' @return path to the new registry
#' @export
build_registry = function(root, name = 'registry', target = NULL) {
  if (is.null(target)) 
    registry_path = file.path(root, paste0(name, '.yaml'))
  else 
    registry_path = file.path(target, paste0(name, '.yaml'))
  hashes = index_hashes(root)
  registry = load_registry(registry_path)
  for (hash in hashes) {
    registry = file.path(root, hash, 'finalized.yaml') %>%
      yaml::yaml.load_file() %>%
      insert_in(registry)
  }
  save_registry(registry, registry_path)
  return(registry_path)
}

