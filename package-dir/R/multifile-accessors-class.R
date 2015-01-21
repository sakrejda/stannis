
#' A reference class allows access to output from multiple CmdStan .csv
#' files efficiently.
#'
#' @field paths paths to .csv output from optimize and/or sample.
#' @field type vector indicating result type ("optimize" or "sample").
#' @field id vector indicating the try/chain number.
#' @field model_parameters names of model parameters (per-estimation)
#' @field internal_parameters names of internal parameters (per-estimation)
#' @field meta other data on output provided by parse_parameters function.
#' @field dimensions list (one entry per named parameter) listing dimensions of said parameter.
#' @field estimates list (one entry per estimate source) of matrices with sample/optim solution estimates.

stan_commander <- setRefClass(Class="stan_commander",
	fields = list(
		paths = "character",
		hashes = "character",
		type = "character",
		ids = "character",
		model_parameters = "list",
		internal_parameters = "list",
		meta = "list",
		dimensions = "list",
		estimates = "list",
		hashes__ = "character",
		current_type__ = "character",
		source_type = function(type=NULL) {
			if (is.null(type)) return(current_type__)
			if (type %in% c('optimize','sample')) 
				current_type__ <<- type
			else
				stop("You're not my type.")
		},
		current_id__ = "character",
		source_id = function(id=NULL) {
			if (is.null(id)) return(current_id__)
			if (id %in% ids)
				current_id__ <<- id
			else
				stop("Where's your id!")
		}
	),
	methods = list(
		initialize = function(paths) {
			"Loads data from files, and fill fields."
			paths <<- paths
			hashes <<- vector(mode='character', length=length(paths))
			check_hashes()
		},
		do_hashes = function() {
			"Calculates current hashes of files in 'paths' field."
			new_hashes <- mapply(FUN=digest, file=paths, MoreArgs=list(algo='sha256', length=10^3))
			return(new_hashes)
		},
		stale_hashes = function() {
			"Test if the current exposed hashes ('hashes') are out of sync with current files."
			hashes__ <<- do_hashes()
			if(all(hashes == hashes__))
				return(FALSE)
			else 
				return(TRUE)
		},
		check_hashes = function() {
			"If hashes are stale, refresh the object and update hashes."
			if (stale_hashes()) {
				refresh()
				hashes <<- hashes__
			}
		},
		refresh = function() {
			"Reload object data from files."
			do_meta()
			type <<- sapply(meta, `[[`, 'type')
			ids <<- sapply(meta, `[[`, 'try')
			parameters <- lapply(meta, `[[`, 'parameter_names')  ## Local 
			model_parameters <<- lapply(parameters, function(x) x[!grepl(pattern='__$', x=x)])
			internal_parameters <<- lapply(parameters, function(x) x[grepl(pattern='__$', x=x)])
			dims <- sapply(meta, `[[`, 'dimensions')   ## Local
			dimensions <<- lapply(dims, function(d) d[names(d) %in% model_parameters[[1]]])
			current_type__ <<- 'sample'
			current_id__ <<- '1';
			do_reload()
		},
		do_meta = function() {
			"Parse file comments/header."
			meta <<- lapply(paths, parse_parameters)
		},
		do_reload = function() {
			"Parse file estimates."
			estimates <<- lapply(paths, read_stan_file)	
		},
		make_names = function(name, ...) {
			"Paste together parameter name with indexes to generate csv column name."
			indexes <- process_index_list(...)
			if (!is.null(indexes)) {
				name <- paste(name, indexes, sep='.')
			} 
			return(name)
		},
		check_dimensions = function(name, args) {
			"Check if 'args' are reasonable dimensions for 'name' parameter."
			id <- as.numeric(current_id__)
			local_dims <- dimensions[[id]][[name]]
			if (length(args) != 0) {
				if (length(args) != length(local_dims)) 
					stop(paste0("Wrong dimensionality for parameter '", name, "'."))
				for ( i in seq_along(args)) {
					if ( (args[i] < 1) || (args[i] > local_dims[i])) 
						stop(paste0("Index ", i, " out of bounds."))
				}
			} else if (local_dims != 0) {
					stop(paste0("Wrong dimensionality for parameter '", name, "'."))
			}
		},
		get_parameter = function(x, ...) {
			"Implementation for the subset operator '['... used directly or via an S4 method."
			check_hashes()
			#dots <- list(...)
			#indexes <- unlist(dots)
			column_names <- make_names(x, ...)
			#check_dimensions(x, dots)
			type_mask <- type %in% current_type__
			o <- lapply(estimates[type_mask], `[`, , j=column_names, drop=FALSE)
			o <- do.call(what=rbind, args=o)
			return(o)
		},
		get_array = function(x, ...) {
			"Implementation for the subset operator '[', returning an array."
			o <- get_parameter(x, ...)
			o <- named_columns_to_arrays(o)
			return(o)
		}
	)
)
	


