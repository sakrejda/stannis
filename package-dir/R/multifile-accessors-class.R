
#' A reference class allows access to output from multiple CmdStan .csv
#' files efficiently. We assume little, different files are : 1) allowed
#' to provide different parameters; 2) allowed to hold different number
#' of iterations; and 3) be generated from different techniques.  The
#' behavior is that when a named parameter is asked for, it will be put 
#' together in a single column from all files in which it is found.  The
#' source of the parameters can also be requested and it will be
#' provided for the most recent. 
#'
#' @field paths paths to .csv output from optimize and/or sample.
#' @field type vector indicating result type ("optimize" or "sample").
#' @field id vector indicating the try/chain number.
#' @field model_parameters names of model parameters (per-estimation)
#' @field internal_parameters names of internal parameters (per-estimation)
#' @field meta other data on output provided by parse_parameters function.
#' @field dimensions list (one entry per named parameter) listing dimensions of said parameter.
#' @field estimates list (one entry per estimate source) of matrices with sample/optim solution estimates.

stan_commander <- setRefClass(Class="stan_commander", contains='fbo',
	fields = list(
    
	),
	methods = list(
		initialize = function(paths) {
			"Loads data from files, and fill fields."
      callSuper(paths)
		},

	)
)
	


