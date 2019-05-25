#' Ways we run models:
#'   1. vary data
#'   2. vary sampling parameters
#'   3. vary initial values (random or not)
#'   4. vary seed
#'
#' The consequences are always:
#'   1. different run definitions 
#'   2. different output files
#'   3. different auxilliary files (files required to understand the
#'      estimation procedure but not necessarily required to run it
#'
#'
#'

make_sequence_generator = function(start = 0) {
  idx_ = start
  idg = function() {
    x = idx_
    idx_ <<- idx_ + 1
    return(x)
  }
  return(idg)
}

default_id_sequence = make_sequence_generator()
default_seed_sequence = make_sequence_generator()

make_dataset_sequence = function(paths = NULL) {
  if (is.null(paths))
    stop("Will not make a sequence without paths, use 'stas:::data()'.")
  p_ = paths
  idx_sequence = make_sequence_generator(start = 1)
  dsg = function() { 
    x = idx_sequence()
    if (x <= length(p_))
      return(p_[x])
    else 
      return(NULL)
  }
  return(dsg)
}



  



