copy_failed = function(from, to) { 
  msg = "Copying failed: \n"
  for (i in 1:length(from)) {
    msg = paste0(msg, 
      "  from: ", from[i], "\n",
      "  to:   ", to[i], "\n")
  }
  stop(msg)
}

last = function(x) sapply(x, function(z) z[length(z)])
extension = function(s) strsplit(x = s, split = '\\.') %>% last() 

run_data_shim = function(run) {
  requirements = run[['requirements']]
  transformations = run[['transformations']]
  if (is.null(requirements)) 
    required_data = TRUE
  else
    required_data = readRDS(
      file = dir(path = run[['sources']], pattern = basename(run[['requirements']]), full.names=TRUE)[1])
  transformations = readRDS(
    file = dir(path = run[['sources']], pattern = basename(run[['transformations']]), full.names=TRUE)[1])
  input_file = dir(path = run[['sources']], pattern = basename(run[['dependency']]), full.names=TRUE)[1]
  oldman::data_shim(requirements = required_data, transformations = transformations,
    input_file = input_file, output_file = file.path(run[['target_dir']], run[['product']]))
  return(TRUE)
}

run_isolated_script = function(run, e = new.env(parent = parent.env(.GlobalEnv))) {
  name = run[['name']]
  id = run[['id']]
  sources = run[['sources']]
  deps = run[['dependencies']]
  script = dir(path = sources, pattern = run[['script']], full.names=TRUE)[1] %>% path.expand
  isolation_dir = tempfile(pattern = paste0(name, "-", id, "-"))
  if (!dir.exists(isolation_dir)) {
    dir.create(path = isolation_dir, showWarnings = TRUE, recursive = TRUE)
  }
  target_dir = run[['target_dir']]
  dep_paths = list() 
  dep_links = list()
  for (d in deps) {
    dep_paths[[d]] = dir(path = sources, pattern = d, full.names=TRUE)[1]
    dep_links[[d]] = file.path(isolation_dir, d)
    did_copy = file.copy(from = dep_paths[[d]], to = dep_links[[d]], overwrite=TRUE)
    if (any(!did_copy)) 
      copy_failed(dep_paths[[d]][!did_copy], dep_links[[d]][!did_copy])
  }
  cwd = getwd()
  target_dir = path.expand(target_dir)
  if (substr(target_dir, 1, 1) != "/") {
    target_dir = file.path(cwd, target_dir)
  }
  assign(x = "target_dir", value = target_dir, envir = e)
  tryCatch(expr = {
    setwd(isolation_dir)
    if (extension(script) == "R") {
      source(file = script, local = e)
    } else if (extension(script) == "sh") {
      system(command = script, wait = TRUE)
    }
    setwd(cwd)
  }, error = function(e) {setwd(cwd); stop(e)}, 
     finally = function(e) {setwd(cwd)})
  all_files = dir(isolation_dir, full.names=TRUE)
  for (f in all_files) {
    bn = basename(f)
    file.copy(from = f, to = file.path(target_dir, bn))
  }
  return(e) 
}

run_data_yaml = function(file, hash=NULL, cores = getOption("cl.cores", 1)) {
  control = yaml::yaml.load_file(file)
  defaults = control[['defaults']]
  runs = control[['runs']]
  for ( i in 1:length(runs)) {
    run_name = runs[[i]][['name']]
    sources = runs[[i]][['source_dir']]
    ## FIXME: could merge defaults in here for each runs[[i]]
    if (runs[[i]][['type']] == 'data-shim') {
      run_data_shim(runs[[i]]) 
    }
    if (runs[[i]][['type']] == 'script') {
      run_isolated_script(runs[[i]])
    } 
  }

}







