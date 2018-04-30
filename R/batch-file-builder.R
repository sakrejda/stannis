
#' Generate a comment.
#'
#' @return Comment string.
#' @export
comment <- function() '#'

#' Generate a bsub-compatible prefix.
#'
#' @return prefix for BSUB option.
#' @export
bsub_prefix <- function(c=comment) paste0(c(), 'BSUB')

#' Generate a pbs-compatible prefix.
#'
#' @return prefix for PBS option.
#' @export
pbs_prefix <- function(c=comment) paste0(c(), 'PBS')

#' Generate an option selection
#' 
#' @param prefix the function to generate the right prefix for
#'        the platform
#' @param name the name of the option to set
#' @param value the value to set the option to
#' @return string encoding the option.
#' @export
generate_option <- function(prefix, name, value) 
  paste0(prefix(), ' -', name, ' ', value)

#' generate a set of options based on arguments
#'
#' @param ostream where to write the string
#' @param args list of arguments to generate to stream
#' @param prefix function to generate prefix with
#' @return output stream path
#' @export
generate_options <- function(ostream, args, prefix=pbs_prefix) {
  for (name in names(args)) {
    o <- generate_option(prefix=prefix, name=name, value=args[[name]])
    cat(o, file=ostream, sep="\n", append=TRUE)
  }
  return(ostream)
}

## There used to be more, but now needs to be 
## taken from cmdstan-run.R





