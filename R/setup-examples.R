
#' Set up a set of file to run examples.
#'
#' @param target_dir directory to set up in.
#' @return TRUE iff successful
#' @export
setup_runs <- function(target_dir) { 
  target_dir <- normalizePath(target_dir)
  if (!is_directory(target_dir) && file.exists(target_dir)) {
    msg <- paste("Target directory is a file: ", target_dir)
    stop(msg)
  } 
  if (!file.exists(target_dir)) {
    dir.create(target_dir, TRUE, TRUE)
  }
  data_dir <- file.path(target_dir, 'data')
  dir.create(data_dir)
  model_dir <- file.path(target_dir, 'models')
  dir.create(model_dir)
  init_dir <- file.path(target_dir, 'init')
  dir.create(init_dir)
  
  examples_dir <- system.file('example-files', package = 'stannis')
  file.copy(from = file.path(examples_dir, "data"), 
            to = data_dir, overwrite=TRUE, recursive = TRUE)
  file.copy(from = file.path(examples_dir, "models"), 
            to = model_dir, overwrite=TRUE, recursive = TRUE)
  file.copy(from = file.path(examples_dir, 'fits.yaml'), 
            to = target_dir)
  return(TRUE)
}



