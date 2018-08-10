
#' Return a closure with a log file set
#'
#' @param log_file where to write log to
#' @return closure, callable in various ways with strings.
#' @export
logger <- function(log_file = tempfile()) { 
  log_file <- log_file
  log_f <- function(...) cat(paste0(..., collapse=", "), file = log_file, sep = "\n", append = TRUE)
#  of = file(log_file, open = "wt")
#  sink(type = 'message', file = of)
  cat(paste0("Starting at: ", Sys.time(), "\n"), file = log_file)
  return(log_f)
}


#' Retrieve a job with defaults integrated.
#'
#' @param instructions, loaded from .yaml file (list)
#' @param i pull out i'th job
#' @param logger used to log output
#' @return job
#' @export
get_job <- function(instructions, i, logger) {
  job <- instructions[['defaults']] %>% purrr::list_merge(instructions[['runs']][[i]])
  logger("Job name: ", job[[1]][['name']])
  return(job[[1]])
}

#' Retrieve the script to run on.
#'
#' @param job job to get script from
#' @param logger used to log output
#' @return path to job script
#' @export
get_script <- function(job, logger) {
  script_file = paste0(job[['name']], ".R")
  script_path = find_file(job[['source_dir']], script_file)
  if (length(script_path) == 0) 
    logger("Script not found: ", script_file)
  else
    logger("Script path: ", script_path)
  return(script_path)
}

#' Returns the expected output files from a job:
#'
#' @param job a job
#' @param logger, a logger
#' @return character vector of expected object names
#' @export
get_expected_files <- function(job, logger) { 
  expect_file <- sapply(job[['outputs']], function(x) x[['file']])
  return(expect_file)
}

#' Return the expected outputs from a job:
#'
#' @param job a job
#' @param logger, a logger
#' @return character vector of expected object names
#' @export
get_expectations <- function(job, logger) { 
  expect_file <- sapply(job[['outputs']], function(x) x[['file']])
  expect_name <- gsub('\\.[a-zA-Z0-9]+$', '', expect_file)
  expect <- gsub('-', '_', expect_name)
  return(expect)
}


#' Get file extension from path
#'
#' @param s path
#' @return extension
#' @export
get_ext <- function(s) {
  split <- strsplit(x=s, split='\\.')[[1]]
  ls <- length(split)
  return(split[ls])
}

#' Save output
#'
#' @param job job description
#' @param output list of output objects
#' @param logger logger to write log to...
#' @return NULL
#' @export
save_output <- function(job, output, logger) {
  target_dir <- job[['target_dir']]
  dir.create(path = target_dir, showWarnings = FALSE, recursive = TRUE)
  output_files <- sapply(job[['outputs']], function(x) x[['file']])
  output_names <- get_expectations(job, logger)
  for (i in 1:length(output_names)) {
    output_path <- file.path(target_dir, output_files[i])
    if (file.exists(output_path))
      next
    logger("Output extension: ", get_ext(output_path))
    if (get_ext(output_path) == 'rds') {
      saveRDS(output[[output_names[i]]], output_path)
    } else if (get_ext(output_path) == 'rdump') {
      rstan::stan_rdump(list = ls(output[[output_names[i]]]),
        file = output_path, envir = output[[output_names[i]]])
    } else logger("Output type not known for object: ", output_names[i])
  }
  return(NULL)
}

#' Run files based on scripts... take N+1...
#' 
#' @param file .yaml file with instructions, see example
#' @param log_file where to write text log to.
#' @return log_file where logs were written.
#' @export
scripted <- function(file, log_file = tempfile(), debug=FALSE) {
  instructions <- yaml::yaml.load_file(file)
  n_instructions <- length(instructions[['runs']])
  log <- logger(log_file)
  log("\n\nThere are ", n_instructions, " jobs.")

  for (i in 1:n_instructions) {
    log("Instruction ", i)
    job <- get_job(instructions, i, log)

    log(paste("Search for dependencies in: ", job[['source_dir']]))
    script_path = get_script(job, log)

    log("Loading script.", script_path)
    source(script_path, echo = debug)

    log("Does the output target exist?")
    target_dir <- job[['target_dir']]
    if (!dir.exists(target_dir)) {
      log("Target directory does not exist, creating: ", target_dir)
      if (file.exists(target_dir) && file.info(target_dir)$isdir) {
        log("Target directory path has a file.  Aborting.")
        stop("Target directory path has a file. Aborting.")
      } else {
        dir.create(target_dir, recursive=TRUE)
      }
    }
      

    log("Get expected files.")
    expected_files <- get_expected_files(job, log)
    expectations_met <- file.exists(file.path(job[['target_dir']], expected_files))
    if (all(expectations_met)) {
      log("All outputs are present, skipping job.")
      next
    } else {
      missing_expectations <- expected_files[!expectations_met]
      for (f in missing_expectations) {
        log("Need to produce ", f)
      }
    }

    o <- NULL
    log("Calling script-level main function.")
    o <- main(job)

    if (!is.null(o)) {
      log("Objects in return are: ")
      log(names(o))
    } else {
      log("No objects found in return.")
    }

    expected_objects <- get_expectations(job, log)
    log("Expected objects are: ")
    log(expected_objects)
    if (all(expected_objects %in% names(o))) {
      log("All output found.")
    } else {
      log("Some expected output is missing.")
      missing_output <- expected_objects[!(expected_objects %in% names(o))]
      for (missing in missing_output) {
        log("Object named ", missing, " was not found.")
      }
    }

    log("Saving output.")
    log("Target directory is: ", job[['target_dir']])
    save_output(job, o, log) 
    log("Finished saving output.")
  }
  return(log_file)
}



