
#' Read the record table:
#'
#' @param file file holding record table.
#' @return record table as data.frame
#' @export 
read_record_table <- function(file) read.csv(file, header=TRUE)

#' Write the record table:
#'
#' @param x record table as data.frame
#' @param file to write record table to
#' @export 
write_record_table <- function(x, file) write.csv(x, file, row.names=FALSE)

#' Record basic info on a run that indexes the registry
#'
#' @param args arg-tree object (list)
#' @return data.frame of the record table
#' @export
record_table <- function(args) {
  hash <- args[['hash']]
  replicate <- args[['replicate']]
  record <- data.frame(
    project_id = args[['project_id']], 
    model_name = args[['model_name']],
    method = not_null(args[['method']]),
    data_file = not_null(args[['data']][['file']]),
    replicate = not_null(args[['replicate']])
  )
  record_table_file <- file.path(args[['target_dir']], 'record_table.csv')
  if (file.exists(record_table_file)) {
    record_table <- read_record_table(record_table_file)
    record_table <- rbind(record_table, record)
  } else {
    record_table <- record
  }
  write_record_table(record_table, record_table_file)
  return(record_table)
}

#' Record that a run is being started
#'
#' @param args arg-tree object (list)
#' @return NULL
#' @export
register_run <- function(args) {
  hash <- args[['hash']]
  replicate <- args[['replicate']]
  registry_file <- file.path(args[['target_dir']], 'registry.yaml')
  if (file.exists(registry_file))
    registry <- yaml::yaml.load_file(input = registry_file)
  else
    registry <- list()
  if (is.null(registry[[hash]]))
    registry[[hash]] <- list()
  registry[[hash]][[as.character(replicate)]] <- args
  record_table(args)
  yaml::write_yaml(x = registry, file = registry_file)
  return(NULL)  
}



