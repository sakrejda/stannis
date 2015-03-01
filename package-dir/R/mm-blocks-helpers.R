
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
	weight_helper <- function(covariate, knot) exp(-((covariate[,1]-knot)/scale)^2)
	return(weight_helper)
}

circle_weight_helper_factory <- function(scale) {
	scale;
	circle_weight_helper <- function(covariate, knot) exp(-sq_circ_distance(covariate[,1],knot)/scale^2)
	return(circle_weight_helper)
}

## Requires MV map_block?
donut_weight_helper_factory <- function(scale) {
	scale;
	donut_weight_helper <- function(covariate, knot) {
		w1 <- exp(-((covariate[,1]-knot[1])/scale[1])^2)
		w2 <- exp(-((covariate[,2]-knot[2])/scale[2])^2)
		w3 <- exp(-sq_circ_distance(covariate[,3],knot[3])/scale[3]^2)
		return(w1*w2*w3)
	}
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


age_x_season_helper_factory <- function(period, max_age) {
	period; max_age;
	age_x_season_helper <- function(covariate, knot) {
		a <- covariate[['age']]
		s <- covariate[['season']]
		o <- vector(mode='numeric', length=length(a))
		if (knot == 1) {
			o <- ifelse(a==0 & s==2,1,0)
			return(o)
		}
		if (knot == 2) {
			o <- ifelse(a==0 & s==4,1,0)
			return(o)
		}
		if (knot >= 3) {
			knot_a <- knot %/% 3 + 1
#			if (knot_a > max_age) knot_a <- max_age
			a <- ifelse(a >= max_age, max_age, a)
			knot_s <- ifelse(knot %% 3==0, knot %% 3 + 1, knot %% 3+2)
			o <- ifelse(a==knot_a & s==knot_s,1,0)
			return(o)
		}
	}
	return(age_x_season_helper)
}


matches_helper_factory <- function(name) {
	name;
	matches_helper <- function(covariate, knot) ifelse(covariate[[name]] == knot, 1, 0) 
	return(matches_helper)
}




