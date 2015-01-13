#' Get names of model parameters contained in stan_commander object.
#' 
#' @param x stan_commander object.
#' @return unique parameters contained in the object.
setMethod(
	f=getGeneric("names"),
	signature = signature(x="stan_commander"),
	definition = function(x) {
		noms <- with(data=x, expr={
			id <- as.numeric(current_id__)
			model_parameters[[id]]
		})
		return(noms)
	}
)

setMethod(
  f=getGeneric("dim"),
	signature=signature(x="stan_commander"),
	definition = function(x) {
		id <- as.numeric(current_id__)
		return(x[['dimensions']][[id]])
	}
)
	
#' Accessor to get a vector of samples for a parameter.
#' 
setMethod(
	f="[",
	signature = signature(x='stan_commander', i='character'),
	definition = function(x, i, ...) {
		o <- do.call(what=x$get_parameter, args=list(i, ...))
		return(o)
	}
)


#setMethod(
#	f="[<-",
#	signature = signature(x='block_distribution', i='character',j='character'),
#	definition = function(x, i, j, value) {
#		x$write(x=value, from=i, to=j)
#	return(x)
#}
#)
#



