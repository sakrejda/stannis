full_eval = function(l) {
  if (is.language(l))
    return(full_eval(eval(l)))
  for (i in seq_along(l))
    if (is.language(l[[i]]))
      l[[i]] = full_eval(l[[i]])
  return(l)
}

id = function(x = 0) return(x)

random = function(seed = stas:::seed()) {
  return(list(seed = seed))
}

seed = function(x = NULL) {
  if (is.null(x)) 
    x = sample(10^4, 1)
  return(x)
}

output = function(file = 'output.csv', diagnostic_file = 'diagnostics.csv') {
  o = list(file = file, diagnostic_file = diagnostic_file)
  return(o)
}

adapt = function(engaged = TRUE, gamma = .05, delta = 0.8, kappa = 0.75, 
                 t0 = 10, init_buffer = 75, term_buffer = 50, window = 25
) {
  o = as.list(full_eval(formals(adapt)))
  if (!missing(engaged))
    o[['engaged']] = engaged
  if (!missing(gamma))
    o[['gamma']] = gamma
  if (!missing(delta))
    o[['delta']] = delta
  if (!missing(kappa))
    o[['kappa']] = kappa
  if (!missing(t0))
    o[['t0']] = t0
  if (!missing(init_buffer))
    o[['init_buffer']] = init_buffer
  if (!missing(term_buffer))
    o[['term_buffer']] = term_buffer
  if (!missing(window))
    o[['window']] = window
  return(o)
}

static = function(int_time = 2 * pi) {
  return(int_time)
}

nuts = function(max_depth = 10) {
  o = list(max_depth = 10)
  return(o)
}

hmc = function(int_time = stas:::nuts(), metric = 'diagonal', stepsize = 1, stepsize_jitter = 0) {
  o = full_eval(formals(hmc))
  if (!missing(int_time))
    o[['int_time']] = int_time
  if (!missing(metric))
    o[['metric']] = metric
  if (!missing(stepsize))
    o[['stepsize']] = stepsize
  if (!missing(stepsize_jitter))
    o[['stepsize_jitter']] = stepsize_jitter
  o[['algorithm']] = 'hmc'
  return(o)
}

sampling = function(num_samples = 1000, num_warmup = 1000, save_warmup = FALSE,
                  thin = 1, adapt = stas:::adapt(), algorithm = stas:::hmc()) {
  o = as.list(full_eval(formals(sampling)))
  if (!missing(num_samples))
    o[['num_samples']] = num_samples
  if (!missing(num_warmup))
    o[['num_warmup']] = num_warmup
  if (!missing(save_warmup))
    o[['save_warmup']] = save_warmup
  if (!missing(thin))
    o[['thin']] = thin
  if (!missing(adapt))
    o[['adapt']] = adapt
  if (!missing(algorithm))
    o[['algorithm']] = algorithm
  o[['method']] = "sampling"
  return(o)
}

stan_binary = function(...) {
  if (length(list(...)) == 0)
    return('default_binary')
  else 
    return(as.vector(list(...)))
}

sample = function(binary = stas:::stan_binary(), id = stas:::id(), 
                  data = 'data.rdump', init = 'init.rdump',
                  random = stas:::random(), output = stas:::output(),
                  num_samples = NULL,
                  num_warmup = NULL,
                  save_warmup = NULL,
                  thin = NULL,
                  adapt = NULL,
                  algorithm = NULL
) {
  s = sampling()
  if (!is.null(num_samples))
    s$num_samples = num_samples
  if (!is.null(num_warmup))
    s$num_warmup = num_warmup
  if (!is.null(save_warmup))
    s$save_warmup = save_warmup
  if (!is.null(thin))
    s$thin = thin
  if (!is.null(adapt))
    s$adapt = adapt
  if (!is.null(algorithm))
    s$algorithm = algorithm
  o = list(eval(binary), eval(id), s, data, init, eval(output))
  o = as.list(full_eval(o))
  return(o)
}

run = function(binary, method = stas:::sampling(), id = stas:::id(), 
               data = 'data.rdump', init = 'init.rdump',
               random = stas:::random(), output = stas:::output()
) {
  

}

push_arg = function(args, name, value) paste(args, paste0(name, "=", value))

push_method = function(x) {
  
}

cmdstan_cmdline = function(x) {
  options = push_arg("", 'method', attr(x[['method']], 'type'))
  if (attr(x[['method']], 'type') == 'sampling') {
    options = push_arg(options, 'thin', x[['method']][['sampling']][['thin']])
    options = push_arg(options, 'adapt', x[['method']][['sampling']][['num_warmup']])
    options = push_arg(options, 'algorithm', x[['method']][['sampling']][['num_warmup']])
       
    
}




