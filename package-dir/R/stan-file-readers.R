#' Properly read a stan file, avoiding factors and comments, including
#' reading column names from a header.
#'
#' @param file An output file produced by CmdStan.
#' @return A data.frame.
read_stan_data <- function(file) {
  o <- read.table(file=file, header=TRUE, sep=',', stringsAsFactors=FALSE, comment.char='#')
  return(o)
}

#' Properly read a stan file, avoiding factors and comments, including
#' reading column names from a header.
#'
#' @param file An output file produced by CmdStan.
#' @return A data.frame.
read_stan_metadata <- function(file) {
  lines <- readLines(file)
  control <- get_control_lines(lines)
  o <- list(
    stan_version = get_stan_version(control),
    model_name = get_model_name(control),
    method = get_method_name(control),
    algorithm = get_algorithm_name(control),
    engine = get_engine_name(control),
    save_warmup = get_save_warmup(control),
    num_warmup = get_num_warmup(control),
    thin = get_thin(control),
    num_draws = get_num_draws(control),
    adaptation_used = get_adaptation_used(control),
    gamma = get_gamma(control), 
    delta = get_delta(control), 
    kappa = get_kappa(control), 
    get_t0 = get_t0(control),
    get_init_buffer = get_init_buffer(control),
    get_term_buffer = get_term_buffer(control),
    get_window = get_window(control),
    get_max_depth = get_max_depth(control),
    get_metric = get_metric(control),
    get_initial_stepsize = get_initial_stepsize(control),
    get_chain_id = get_chain_id(control),
    get_data_file = get_data_file(control),
    get_init_file = get_init_file(control),
    get_output_file = get_output_file(control),
    get_diagnostic_file = get_diagnostic_file(control),
    get_refresh = get_refresh(control),
    inverse_mass_matrix = get_imm_diagonal(lines)
  )
  return(o)
}

#' Read Stan file
read_stan <- function(file) {
  o <- list(
    metadata <- read_stan_metadata(file)
    samples <- read_stan_data(file)
  )
  return(o)
}

read_stan_set <- function(root='.', pattern) {
  files <- dir(path=root, pattern=pattern, full.names=TRUE)
  o <- list()
  for (f in files) {
    o[[f]] <- read_stan(f)
  }
  names(o) <- sapply(o, function(x) x[['metadata']][['id']])
  return(o)
}
    
