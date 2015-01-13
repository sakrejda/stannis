	
## Below works if j is just one number... now generalize... :/
setMethod(
	f="[",
	signature = signature(x='stan_commander', i='character', j="numeric"),
	definition = function(x, i, j) {
		o <- do.call(what=x$get_parameter, args=list(i, j))
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



