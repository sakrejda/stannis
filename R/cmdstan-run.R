
cmdstan_data_dir <- function() {
  if (require(rappdirs))
    o <- file.path(rappdirs::user_data_dir(), "cmdstan-resources")
  else 
    o <- tempdir()
  return(o)
}


cmdstan_build <- function(model=NULL, cmdstan='~/packages/cmdstan', resources=cmdstan_data_dir()) {
  if(!dir.exists(resources))
    dir.create(resources)
  model <- normalizePath(model) 
  model_dir <- dirname(model)
  model_name <- model %>% basename %>% substr(x=., start=1, stop=nchar(.)-5)
  resources <- normalizePath(resources)
  cmd <- paste0("make -C ", cmdstan, " ", model)
  system(cmd)
  file.copy(from=file.path(model_dir, model_name), to=resources)
  target_file <- file.path(resources, model_name)
  return(target_file)
}
  
cmdstan_default_args <- function() {
  s <- "sample"
  return(s)
}

cmdstan_run <- function(binary=NULL, args=cmdstan_default_args(), run=TRUE) {
  if (is.null(binary)) {
    stop("Model binary not specified. Not running.")
  } else {
    cmd <- paste(binary, args)   
  }
  if (isTRUE(run))
    system(cmd)
  return(cmd)
}
  

