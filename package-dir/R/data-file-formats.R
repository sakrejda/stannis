get_paths <- function(file='file-data.txt') {
  paths <- strsplit(x=readLines(file), split=':')
  pat <- lapply(paths, `[`, 2)
  ths <- lapply(paths, `[`, 1)
  paths <- pat
  names(paths) <- ths
  return(paths)
}

process_bash_array <- function(file='model-data.sh') {
  lines <- readLines(file)
  lines <- lines[grepl(x=lines, pattern='=', fixed=TRUE)]
  parts <- gregexpr(text=lines, pattern='"', fixed=TRUE)
  keys <- mapply(
    FUN=function(text, indexing) substr(text, indexing[1]+1, indexing[2]-1),
    text=lines, indexing=parts)
  values <- mapply(
    FUN=function(text, indexing) {
      if (length(indexing) == 4) {
        o <- substr(text, indexing[3]+1, indexing[4]-1)
      } else {
        start <- regexpr(pattern='=', text=text, fixed=TRUE) +1
        stop <- nchar(text)
        o <- as.numeric(substr(text, start, stop))
      }
    }
    ,text=lines, indexing=parts, SIMPLIFY=FALSE)
  names(values) <- keys
  return(values)
}



