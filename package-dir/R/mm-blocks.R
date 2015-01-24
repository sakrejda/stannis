

#' A reference base class for classes which construct parts of a model
#' matrix.  Each part is a set of columns referring to one effect.
#' The goal is to focus on construction of model matrices, delegate when
#' possible to model.matrix, and avoid dealing with 'formula'-style
#' interfaces or additional issues (constraints, model types, etc...)
#'
#' @field effect_name__ A character string with the overall name of the
#' effect.
#' @field input_check__ A function for validating covariate values.
#' @field X__ Matrix holding the block in question.
model_block <- setRefClass(Class="model_block",
	fields = list(
		effect_name__ = "character",
		input_check__ = "function",
		covariate__ = "list",
		drops__ = "function",
		X__ = "matrix",
		X = function(x=NULL) {
			if (!is.null(x)) stop("Can not assign directly.")
			return(X__)
		},
		K = function(x=NULL) {
			if (!is.null(x)) stop("Can not assign directly.")
			return(ncol(X__))
		},
		N = function(x=NULL) {
			if (!is.null(x)) stop("Can not assign directly.")
			return(nrow(X__))
		}
	),
	methods=list(
		initialize = function(name, covariate=list(), validation=NULL, drops=NULL) {
		"Initialize the base class with a name and validation function."
			effect_name__ <<- name
			covariate__ <<- covariate
			if (is.null(validation)) {
				input_check__ <<- function(x) rep(TRUE,x)
			} else {
				input_check__ <<- validation
			}
			if (is.null(drops)) {
				drops__ <<- function(x) return(x)
			} else {
				drops__ <<- drops
			}
		},
		make_block = function() {
		"For the base class this is a placeholder which throws an error.  
		 In all other subclasses this function arranges the covariates into the
		 class-specific model matrix.  The name of the model"
			stop("Undefined 'make_block'.")
		}
	)
)

#' A reference class for constructing the (simple!) model matrix for a
#' covariate based on a model formula (default is additive of all
#' covariates.
#' 
#' @field formula The R-style formula used to describe the linear covariate
#' relationship.  Typically lacking an intercept in models made of
#' multiple blocks.
covariate_block <- setRefClass(Class="covariate_block", contains="model_block",
	fields = list(
		formula__ = "formula"
	),
	methods = list(
		initialize = function(name, covariate, formula=NULL, validation=NULL) {
			"Builds on initialization for base class, but only by calling method to construct the block."
			callSuper(name, covariate, validation)
			if (!is.null(formula)) {
				formula__<<- formula
			} else {
				formula__ <<- default_formula(covariate) 
			}
			make_block(); X;
		},
		make_block = function() {
			"Construct model matrix, delegate to model.matrix."
			X__ <<- model.matrix(formula__,
				model.frame(formula__, data=drops__(covariate__), na.action=function(x) x))

		}
	)
)

#' A reference class for constructing the (simple!) model matrix for a
#' factor, this preduces a parameterization assuming some other
#' intercept.
#' 
offset_block <- setRefClass(Class="offset_block", contains="covariate_block",
	fields = list(
	),
	methods = list(
		initialize = function(name, covariate, formula=NULL, validation=NULL) {
			"Builds on initialization for base class, but only by calling method to construct the block."
			if (is.null(formula)) {
				callSuper(name, covariate, formula=default_formula(covariate, intercept=TRUE), validation)
			} else {
				callSuper(name, covariate, formula, validation)
			}
			make_block(); X;
		},
		make_block = function() {
			"Construct model matrix, delegate to model.matrix."
			callSuper()
			X__ <<- X__[,2:ncol(X__)]
		}
	)
)

#' A reference class for constructing the model matrix for either a
#' spline (when a distance/weight function is passed as the helper) or
#' an arbitrary factor mapping (when the mapping function is passed as
#' the weight_helper).  In either case, the 'covariate' can be a list
#' s.t. weight_helper can access multiple covariates.
#' 
#' 
map_block <- setRefClass(Class="map_block", contains="model_block",
	fields = list(
		reference_points__ = "matrix",
		weight_helper__ = "function"
	),
	methods = list(
		initialize = function(name, covariate, reference_points,  weight_helper=default_weight_helper,
													validation=NULL
		) {
			"Builds on initialization for base class, but only by calling method to construct the block."
			callSuper(name, covariate, validation)
			reference_points__ <<- reference_points
			weight_helper__ <<- weight_helper
			make_block(); X;
		},
		make_block = function() {
			"Construct model matrix, delegate to helper function, passing covariates and knot points."
			cov <- drops__(covariate__)
			temp_block <- apply(reference_points__, 1, function(x) weight_helper__(covariate=cov, knot=x))
			colnames(temp_block) <- paste0(effect_name__,"_p_",1:nrow(reference_points__),"_")
			X__ <<- temp_block
		}
	)
)

discrete_map_block <- setRefClass(Class="discrete_map_block", contains="model_block",
	fields = list(
		reference_points__ = "character",
		weight_helper__ = "function"
	),
	methods = list(
		initialize = function(name, covariate, reference_points,  weight_helper=default_weight_helper,
													validation=NULL
		) {
			"Builds on initialization for base class, but only by calling method to construct the block."
			callSuper(name, covariate, validation)
			reference_points__ <<- reference_points
			weight_helper__ <<- weight_helper
			make_block(); X;
		},
		make_block = function() {
			"Construct model matrix, delegate to helper function, passing covariates and knot points."
			cov <- drops__(covariate__)
			temp_block <- sapply(reference_points__, function(x) weight_helper__(covariate=cov, knot=x))
			colnames(temp_block) <- paste0(effect_name__,"_p_",reference_points__,"_")
			X__ <<- temp_block
		}
	)
)
