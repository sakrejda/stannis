drop_types <- function(stan_args) {
	types_rex <- 'int|real|vector|matrix'
	return(gsub(pattern=types_rex, replacement='', x=stan_args))
}

drop_declarations <- function(lines) {
	types_rex <- 'int|real|vector|matrix'
	declare_rex <- paste0('[[:blank:]]*(', types_rex, ')[[:blank:]][[:ascii:]]+;')
	parsed <- regexpr(declare_rex, lines, perl=TRUE)
	is_declare <- (attr(x=parsed, which='capture.start')[,1] != -1)
	lines <- lines[!is_declare]
	return(lines)
}

modify_definition <- function(lines) {
	name_rex <- "([[:alnum:]]+|[^i][^f]) (?<f_name>[[:ascii:]]+)\\((?<f_args>[[:ascii:]]+)\\)[[:blank:]]*{"
	parsed <- regexpr(name_rex, lines, perl=TRUE)

	starts_name <- attr(x=parsed, which='capture.start')[,2]
	stops_name  <- attr(x=parsed, which='capture.length')[,2]+starts_name-1
	part_name <-ifelse(starts_name == -1, NA,
		substr(x=lines, start=starts_name, stop=stops_name))
	lacks_name <- starts_name == -1

	starts_args <- attr(x=parsed, which='capture.start')[,3]
	stops_args  <- attr(x=parsed, which='capture.length')[,3]+starts_args-1
	part_args <-ifelse(starts_args == -1, NA,
		substr(x=lines, start=starts_args, stop=stops_args))

	if_rex <- "[[:blank:]]*if[[:blank:]]*\\("
	parsed <- regexpr(if_rex, lines, perl=TRUE)
	is_if <- parsed != -1

	o <- ifelse(lacks_name | is_if, lines, 
		paste0(part_name, ' <- function(', drop_types(part_args), ') {'))
	return(o)
}


modify_return <- function (lines) {
	return_rex <- "(?<first>[[:ascii:]]*return) (?<last>[[:ascii:]]+);"
	parsed <- regexpr(return_rex, lines, perl = TRUE)

	starts_a <- attr(x=parsed, which='capture.start')[,1]
	stops_a  <- attr(x=parsed, which='capture.length')[,1]+starts_a-1
	part_a <-ifelse(starts_a == -1, NA,
		substr(x=lines, start=starts_a, stop=stops_a))

	starts_b <- attr(x=parsed, which='capture.start')[,2]
	stops_b  <- attr(x=parsed, which='capture.length')[,2]+starts_b-1
	part_b <- ifelse(starts_b == -1, NA,
		substr(x=lines, start=starts_b, stop=stops_b))
	
	o <- ifelse(starts_a == -1, lines, paste0(part_a, '(', part_b, ')'))
	return(o)
}

modify_stan_functions <- function(input, output=NULL) {
	lines <- readLines(input)
	o <- drop_declarations(lines) %>%  modify_definition %>% modify_return
	o <- paste0(o, collapse="\n")
	if (is.null(output)) 
		cat(o)
	else 
		writeLines(text=o, con=output)
}




