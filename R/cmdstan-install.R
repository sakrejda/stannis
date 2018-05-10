#' Get CmdStan from github.com/stan-dev/cmdstan
#' 
#' @param config_file .yaml file listing where to get
#'        CmdStan from.
#' @return config object
get_cmdstan = function(config_file) {
  config = yaml::yaml.load_file(input = config_file)
  if (!require(git2r)) {
    stop("Package `git2r` is required to use this functionality.")
  }
  git2r::clone(url = config[['cmdstan_repository']],
    local_path = config[['cmdstan_dir']],
    branch = config[['cmdstan_branch']], checkout = TRUE)
  ##### STILL DO SUBMODULE UPDATE
  return(config)
}

#' Build `stanc` in the cmdstan directory.
#'
#' @param config_file .yaml file listing how to install CmdStan.
#' @return config object of install.
build_cmdstan = function(config_file) {
  config = yaml::yaml.load_file(input = config_file)
  target_dir = config[['stannis_dir']]
  system2(command = config[['cmdstan_cmd']], 
    args = c(config[['cmdstan_options']], "stanc"), 
    stdout = file.path(config[['stannis_dir']], "cmdstan-build.log"),
    stderr = file.path(config[['stannis_dir']], "cmdstan-build.err"),
    wait = FALSE)
  return(config)
}


#' Download CmdStan from github.com/stan-dev/cmdstan and build it in a
#' local directory. 
#'
#' @param target_dir directory to install/build CmdStan in.
#' @return path to .yaml file listing config details.
#' @export
install_cmdstan = function(target_dir = NULL) {
  if (!require(rappdirs)) {
    stop("Package 'rappdirs' is required to use this functionality.")
  }
  if (is.null(target_dir)) {
    target_dir = file.path(rappdirs::user_data_dir(), 'stannis') %>%
      path.expand()
  }
  if (!dir.exists(target_dir))
    dir.create(target_dir, showWarnings=TRUE, recursive=TRUE)
  config_dir = file.path(rappdirs::user_config_dir(), 'stannis') %>%
    path.expand()
  if (!dir.exists(config_dir))
    dir.create(config_dir, showWarnings=TRUE, recursive=TRUE)
  config = list(
    stannis_dir = rappdirs::user_data_dir(),
    config_dir = file.path(config_dir),
    cmdstan_dir = file.path(target_dir, 'cmdstan'),
    cmdstan_repository = "https://github.com/stan-dev/cmdstan",
    cmdstan_branch = "develop",
    cmdstan_cmd = "make",
    cmdstan_options = c(paste("-j", parallel::detectCores(), 
      paste("-C", file.path(target_dir, 'cmdstan'))))
  )
  config_file = file.path(config_dir, "stannis.yaml")
  yaml::write_yaml(x = config, file = config_file)
  get_cmdstan(config_file)
  build_cmdstan(config_file)
  return(config_file)
}


