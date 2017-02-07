
comment <- function() '#'

bsub_prefix <- function(c=comment) paste0(c(), 'BSUB')
pbs_prefix <- function(c=comment) paste0(c(), 'PBS')

generate_option <- function(prefix, name, value) 
  paste0(prefix(), ' -', name, ' ', value)

generate_options <- function(ostream, args, prefix=pbs_prefix) {
  for (name in names(args)) {
    o <- generate_option(prefix=prefix, name=name, value=args[[name]])
    cat(o, file=ostream, sep="\n", append=TRUE)
  }
  return(ostream)
}

generate_cmdstan_run <- function(ostream, binary, args) {
  o <- cmdstan_run(binary=binary, args=args, run=FALSE)
  cat("\n")
  cat(o, file=ostream, sep="\n", append=TRUE)
  return(ostream)
}




