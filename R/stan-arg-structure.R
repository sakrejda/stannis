

Arg <- R6::R6Class("Arg")

ValueArg <- R6::R6Class("ValueArg", inherit=Arg,
  public = list(
    initialize = function(value=NULL) {
      if (is_valid_value(value))
        private$value = as.integer(value)
      else 
        invalid_arg(value)
    }
  )
)

CategoricalArg <- R6::R6Class("CategoricalArg", inherit=Arg)

MethodArg <- R6::R6Class("MethodArg", inherit=CategoricalArg,
  public = list(
    initialize = function(value=NULL) {
      if (is.null(value)) 
        value <- 'sample'
      private$valid_values = c('sample', 'optimize', 'variational', 'diagnose')
      if (value %in% private$valid_values)
        private$value <- value
      else 
        invalid_arg(value)
  ),
  private = list(
    value = 'character',
    valid_values = 'character'
  )
)

MethodSampleArg <- R6::R6Class("MethodSampleArg", inherit=MethodArg,
  public = list(
    initialize = function(args=NULL) {
      valid_sub_args = c('NumSamplesArg', 'NumWarmupArg',
        'SaveWarmupArg', 'ThinArg', 'AdaptArg', 'AlgorithmArg')
      super$initialize('sample')
      sub_args <- list()
      for (arg in args) 
        add(arg)
    }
  ),
  private = list(
    sub_args = 'list',
    valid_sub_args = 'list',
    add = function(arg) {
      arg_class <- class(arg) 
      if (arg_class %in% valid_sub_args) {
        private$sub_args <- c(sub_args, list(arg))
      } else {
        invalid_arg(arg)
      }
      return(NULL)
    }
  )
)

PositiveIntegerArg <- R6::R6Class("PositiveIntegerArg", inherit=ValueArg,
  public = list(
    initialize = function(value=NULL) {
      if (is.null(value))
        value <- self$default()
      if (is_valid_value(value))
        private$value = as.integer(value)
      else 
        invalid_arg(value)
    }
  ),
  private = list(
    is_valid_value = function(value) {
      pass <- is.numeric(value) &&
        is.integer(as.integer(value)) &&
        (value >= 0)
      return(isTRUE(pass))
    }
  )
)

NumSamplesArg <- R6::R6Class("NumSamplesArg", inherit=PositiveIntegerArg,
  public = list(
    default = function() 1000
  )
)

NumWarmupArg <- R6::R6Class("NumWarmupArg", inherit=PositiveIntegerArg,
  public = list(
    default = function() 1000
  )
)

BoolArg <- R6::R6Class("BoolArg", inherit=CategoricalArg,
  public = list(
    initialize = function(value=NULL) {
      if (is.null(value)) 
        value <- TRUE
      private$valid_values = c(TRUE, FALSE)
      if (value %in% private$valid_values)
        private$value <- value
      else 
        invalid_arg(value)
    }
  ),
  private = list(
    value = 'character',
    valid_values = 'character'
  )
)

SaveWarmupArg <- R6::R6Class("SaveWarmupArg", inherit=BoolArg)

ThinArg <- R6::R6Class("ThinArg", inherit=PositiveIntegerArg,
  public = list(
    default = function() 1
  )
)


HMCAdaptArg <- R6::R6Class("HMCAdaptArg", inherit=CategoricalArg,
  public = list(
    initialize = function(args=NULL) {
      valid_sub_args = c('AdaptEngagedArg', 'AdaptGammaArg',
      'AdaptDeltaArg', )
      sub_args <- list()
      for (arg in args) 
        add(arg)
    }
  ),
  private = list(
    sub_args = 'list',
    valid_sub_args = 'list',
    add = function(arg) {
      arg_class <- class(arg) 
      if (arg_class %in% valid_sub_args) {
        private$sub_args <- c(sub_args, list(arg))
      } else {
        invalid_arg(arg)
      }
      return(NULL)
    }
  )
)
