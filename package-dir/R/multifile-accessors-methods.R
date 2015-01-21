#' Get names of model parameters contained in stan_commander object.
#' 
#' @param x stan_commander object.
#' @return unique parameters contained in the object.
setMethod(
	f="names",
	signature = signature(x="stan_commander"),
	definition = function(x) {
		noms <- with(data=x, expr={
			id <- as.numeric(current_id__)
			model_parameters[[id]]
		})
		return(noms)
	}
)

#' Accessor to get dimensions of parameter for the currently chosen id/type.
#' @param x stan_commander object.
setMethod(
  f="dim",
	signature=signature(x="stan_commander"),
	definition = function(x) {
		id <- as.numeric(current_id__)
		return(x[['dimensions']][[id]])
	}
)
	
#' Accessor to get a vector of samples for a parameter.
#' 
#' @param x stan_commander object
#' @param i name of the parameter
#' @param j first index, if any.
#' @param ... additional indexing, if any.
#' @param drop currently ignored.
#' @details Does some checking, then delegates to a stan_commander member
setMethod(
	f="[",
	signature = signature(x='stan_commander', i='character', j="ANY", drop="ANY"),
	definition = function(x, i, j=NULL, ..., drop=FALSE) {
		if (!(i %in% names(output))) {
			msg <- paste0("Name '", i, "' is not a parameter in object '", as.character(substitute(x)), "'.\n")
			stop(msg)
		}
		if (missing(j) || is.null(j)) {
			o <- do.call(what=x$get_parameter, args=list(i, ...))
		} else {
			o <- do.call(what=x$get_parameter, args=list(i, j, ...))
		}
		return(o)
	}
)


