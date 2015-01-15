#' Properly read a stan file, avoiding factors and comments, including
#' reading column names from a header.
#'
#' @param file An output file produced by CmdStan.
#' @return A matrix with samples or optima.

read_stan_file <- function(file) {
  samples_df <- read.table(file=file, header=TRUE, sep=',', stringsAsFactors=FALSE, comment.char='#')
  samples_mat <- as.matrix(samples_df)
  rownames(samples_mat) <- 1:nrow(samples_mat)
  return(samples_mat)
}

