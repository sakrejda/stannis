#' Substitute tags for the referenced file content. 
#' 
#' @param model full path to model file with tags in it.  Must be specified.
#' @param search path to search for chunks to be inserted when tags
#'        are replaced. If not specified search is restricted to model
#'        directory.
#' @param output full path to file that model will be 
#'        written into. If not specified it is derived from the
#'        model path by replacing the extension with .stan
substitutions <- function(model = NULL, search = NULL, output = NULL) {
  if (is.null(model)) 
    stop("Argument 'model' can not be left unspecified or NULL.")
  if (is.null(search))
    search <- dirname(model)
  tag_find <- function(f) f[grepl(pattern='// \\[\\[.*\\]\\]', x=f) %>% which]
  tag_pull <- function(text)  gsub(pattern='// \\[\\[(.*)\\]\\]', replacement = '\\1', x=text)
  tag_file <- function(tag) {
    files <- gsub(pattern='::', replacement='-', x=tag) %>% paste('chunk', sep='.')
    names(files) <- tag
    return(files)
  }
  find_file <- function(search, name) {
    search <- strsplit(search, split=',', fixed=TRUE) %>% unlist
    clean_search <- gsub(pattern='[ \t]', replacement='', x=search)
    candidates <- sapply(clean_search, dir, pattern=name, full.names=TRUE)
    return(candidates[1])
  }
  
  model <- readLines(model)
  tags <- tag_find(model) 
  tag_names <- tag_pull(tags)
  chunk_files <- tag_file(tag_names)
  
  model_text <- paste(model, collapse="\n")
  for (tag in seq_along(tags)) {
    chunk_file <- find_file(search, chunk_files[tag])
    chunk <- readLines(chunk_file) %>% paste(collapse="\n")
    model_text <- gsub(pattern=tags[tag], replacement=paste("\n", chunk, "\n", sep=""), x=model_text, fixed=TRUE)
  }
  
  if (is.null(output)) {
    output_file = gsub(pattern='\\.[^\\.]*$', replacement='.stan', x=model)
  } else {
    output_file =output
  }
  writeLines(model_text, con=output_file)
}  

