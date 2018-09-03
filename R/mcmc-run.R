
#' Read a single Stannis run, rewrite to binary format, and return 
#' dimensions and paths to outptu.
#' 
#' @param root where the run directories are rooted
#' @param uuid UUID for this run.
#' @param control_file what the .yaml with run settings is called
#' @param sample_file what the sample output file is called
#' @param diagnostic_file file name for diagnostic output
#' @return list with run description
#' @export
read_run = function(root='.', uuid = NULL, control_file = 'finalized.yaml', 
  sample_file = 'output.csv', diagnostic_file = 'diagnostics.csv'
) {
  if (!is.null(uuid)) 
    run_root = file.path(root, uuid)
  else
    run_root = root
   
  sample_file_path = file.path(run_root, sample_file)
  if (!file.exists(sample_file_path))
    stop("Sample file is missing.")

  diagnostic_file_path = file.path(run_root, diagnostic_file)
  if (!file.exists(diagnostic_file_path))
    stop("Diagnostic file is missing.")

  control_file_path = file.path(run_root, control_file)
  if (!file.exists(control_file_path))
    stop("Control file is missing.")

  sample_root = file.path(run_root, 'sample')
  diagnostic_root = file.path(run_root, 'diagnostic')

  stannis::rewrite_stan_csv(source = sample_file_path, 
    root = sample_root,
    tag = uuid, comment = Sys.time())
  stannis::rewrite_stan_csv(source = diagnostic_file_path, 
    root = diagnostic_root,
    tag = uuid, comment = Sys.time())
  metadata = yaml::yaml.load_file(control_file_path)
  sample_dimensions = stannis::get_dimensions(
    file.path(sample_root, 'dimensions.bin'),
    file.path(sample_root, 'names.bin')
  )
  diagnostic_dimensions = stannis::get_dimensions(
    file.path(diagnostic_root, 'dimensions.bin'),
    file.path(diagnostic_root, 'names.bin')
  )
 
  return(list(
    run_root = run_root,
    sample_root = sample_root,
    sample_dimensions = sample_dimensions,
    diagnostic_root = diagnostic_root,
    diagnostic_dimensions = diagnostic_dimensions,
    metadata = metadata
  ))
} 



