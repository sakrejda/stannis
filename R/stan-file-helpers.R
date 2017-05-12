
#' Get the lines of a Stan .csv file with the metadata
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return only the lines starting with a hash.
get_comment_lines <- function(lines) {
	lines <- lines[grepl(pattern='^#', x=lines)]
	lines <- trim_comment_char(lines, c='#')
	return(lines)
}

#' Get the lines of a Stan .csv file with the control parameters.
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return only the lines with the A=B format.
get_control_lines <- function(lines) {
  lines <- get_comment_lines(lines)
	lines <- lines[grepl(pattern='=', x=lines, fixed=TRUE)] %>% 
    lapply(trim_whitespace) %>% unlist %>% process_key_value(split='=')
#  lines <- gsub(pattern='(Default)', replacement='', x=lines, fixed=TRUE)
	return(lines)
}

get_initial_number <- function(s) {
  s <- gsub(pattern=' [^0-9]*', x=s, replacement='')
  return(s)
}

get_stan_version <- function(cl) c(major=cl$stan_version_major, 
  minor=cl$stan_version_minor, patch=cl$stan_version_patch)

get_model_name <- function(cl) cl[['model']]
get_method_name <- function(cl) cl[['method']]
get_algorithm_name <- function(cl) cl[['algorithm']]
get_engine_name <- function(cl) cl[['engine']]
get_save_warmup <- function(cl) cl[['save_warmup']] %>% get_initial_number %>%
  as.numeric %>% as.logical
get_num_warmup <- function(cl) {
  save <- get_save_warmup(cl)
  if (save) 
    o <- cl[['num_warmup']] %>% get_initial_number %>% as.numeric
  else 
    o <- 0
  return(o)
}
get_thin <- function(cl) cl[['thin']] %>% get_initial_number %>% as.numeric
get_num_draws <- function(cl) {
  thin <- get_thin(cl)
  o <- cl[['num_samples']] %>% get_initial_number %>% as.numeric
  return((o %/% thin) + 1)
}
get_adaptation_used <- function(cl) cl[['engaged']] %>% get_initial_number %>% 
  as.numeric %>% as.logical
get_gamma <- function(cl) cl[['gamma']] %>% get_initial_number %>% as.numeric
get_delta <- function(cl) cl[['delta']] %>% get_initial_number %>% as.numeric
get_kappa <- function(cl) cl[['kappa']] %>% get_initial_number %>% as.numeric
get_t0 <- function(cl) cl[['t0']] %>% get_initial_number %>% as.numeric
get_init_buffer <- function(cl) cl[['init_buffer']] %>% get_initial_number %>% as.numeric
get_term_buffer <- function(cl) cl[['term_buffer']] %>% get_initial_number %>% as.numeric
get_window <- function(cl) cl[['window']] %>% get_initial_number %>% as.numeric
get_max_depth <- function(cl) cl[['max_depth']] %>% get_initial_number %>% as.numeric
get_metric <- function(cl) cl[['metric']] 
get_initial_stepsize <- function(cl) cl[['stepsize']] %>% get_initial_number %>% as.numeric
get_chain_id <- function(cl) cl[['id']] %>% get_initial_number %>% as.numeric
get_data_file <- function(cl) cl[['file']]
get_init_file <- function(cl) cl[['file']]
get_output_file <- function(cl) {cl[['file']] <- NULL; return(cl[['file']])}
get_diagnostic_file <- function(cl) cl[['diagnostic_file']]
get_refresh <- function(cl) cl[['refresh']] %>% as.numeric

#' Get the line of a Stan .csv file with the inverse mass matrix
#' diagonal in it.
#' @param lines lines from the Stan .csv file, need only enough to get past the recorded meta-data.
#' @return vector of values of diagonal.
get_imm_diagonal <- function(lines) {
  lines <- get_comment_lines(lines) %>% lapply(trim_whitespace)
  is_imm_bool <- grepl(pattern='Diagonal elements of inverse mass matrix', x=lines)
  if (any(isTRUE(is_imm_bool))) {
    imm_diagonal_idx <- which(is_imm_bool) + 1
 	  imm_diagonal <- strsplit(x=lines[imm_diagonal_idx], split=',', fixed=TRUE)[[1]]
  	imm_diagonal <- trim_whitespace(imm_diagonal) %>% as.numeric
  } else {
    imm_diagonal <- NULL
  }
	return(imm_diagonal)
}


#' Get the line of a Stan .csv file with the column names in it, starts
#' with "lp__".
#' @param lines lines from the Stan .csv file, need only enough to get 
#'        past the recorded meta-data.
#' @return vector of all column names, with whitespace trimmed.
get_column_names <- function(lines) {
  idx <- which(grepl(pattern='^lp__,', x=lines))
	column_names <- strsplit(x=lines[idx], split=',', fixed=TRUE)[[1]]
	column_names <- trim_whitespace(column_names)
	return(column_names)
}


get_total_time <- function(lines) {
  lines <- get_comment_lines(lines) %>%
    `[`(grepl(pattern = '(Total)', x = .))
  l <- regexpr(pattern="[0-9][0-9\\.]*", text=lines) %>%
    attr('match.length')
  total_time <- substr(lines, 1, l) %>% as.numeric
  if (length(total_time) > 0) 
    return(total_time)
  else 
    return(NA)
}



