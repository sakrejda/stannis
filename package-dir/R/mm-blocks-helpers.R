
default_formula <- function(covariate, intercept=FALSE) { 
	if (intercept) {
		formula <- paste0(" ~  1")
	} else {
		formula <- paste0(" ~ -1")
	} 
	extra <- paste(names(covariate), collapse=' + ')
	return(as.formula(paste(formula, extra, sep=' + ')))
}

weight_helper_factory <- function(scale) {
	scale;
	weight_helper <- function(covariate, knot) exp(-((covariate[[1]]-knot)/scale)^2)
	return(weight_helper)
}

circle_weight_helper_factory <- function(scale) {
	scale;
	circle_weight_helper <- function(covariate, knot) exp(-sq_circ_distance(covariate[[1]],knot)/scale^2)
	return(circle_weight_helper)
}

age_map <- function(covariate, knot) {
	covariate <- covariates[[1]]
	o <- vector(mode='numeric', length=length(covariate))
	if (knot == 1) {
		o <- ifelse(covariate==1, 1, o)
		return(o)
	}
	if (knot == 2) {
		return(o)
	}
	if (knot > 2) {
		o <- ifelse(covariate >= knot, as.numeric(covariate >= knot), o)
		return(o)
	}
	stop("Fail in covariate_map.")
}

age_x_season_map <- function(covariate, knot) {
	#o <- vector(mode='numeric', length=length(covariate))
	max_age <- 4
	a <- covariate[['age']]
	s <- covariate[['season']]
	if (knot == 1) {
		o <- ifelse(a==1 & s==2, 1, 0)
		return(o)
	}
	if (knot == 2) {
		o <- ifelse(a==1 & s==4, 1, 0)
		return(o)
	}
	if (knot >= 3) {
		knot_a <- knot %/% 3 + 2
		if (knot_a>=4) knot_a <- max_age
		a <- ifelse(a>=max_age,max_age,a)
		knot_s <- ifelse(knot %% 3==0,knot %%3+1, knot %%3+2)
		o <- ifelse (a==knot_a & s==knot_s,1,0)
		return(o)
	} 
	stop("Fail in covariate_map.")
}

matches_helper_factory <- function(name) {
	name;
	matches_helper <- function(covariate, knot) ifelse(covariate[[name]] == knot, 1, 0) 
	return(matches_helper)
}




