full_eval = function(l) {
  if (is.language(l)) {
    return(full_eval(eval(l)))
  } else if (is.list(l)) {
    l = lapply(l, function(ll) full_eval(eval(ll)))
    l[sapply(l, is.null)] = NULL
  }
  return(l)
}

id = function(x = 1) return(x)

random = function(seed = stas:::seed()) {
  o = list('random', seed = seed)
  return(o)
}

seed = function(x = NULL) {
  if (is.null(x)) 
    x = base:::sample(10^4, 1)
  return(x)
}

data = function(file = NULL) {
  if (is.null(file))
    return(NULL)
  o = list('data', file = normalizePath(file))
  return(o)
}

init = function(radius = 2, file = NULL) {
  if (is.null(file)) {
    return(list(init = radius))
  } else {
    return(list(init = file))
  }
}

output = function(file = 'output.csv', diagnostic_file = 'diagnostics.csv') {
  o = list('output', file = file, diagnostic_file = diagnostic_file)
  return(o)
}

adapt = function(engaged = TRUE, gamma = .05, delta = 0.8, kappa = 0.75, 
                 t0 = 10, init_buffer = 75, term_buffer = 50, window = 25
) {
  o = as.list(full_eval(formals(adapt)))
  o = c(list('adapt', o))
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
  o = list(engine = 'static', int_time = int_time)
  return(o)
}

nuts = function(max_depth = 10) {
  o = list(engine = 'nuts', max_depth = max_depth)
  return(o)
}

hmc = function(
  engine = stas:::nuts(), 
  metric = 'diag_e', 
  stepsize = 1, 
  stepsize_jitter = 0
) {
  o = full_eval(formals(hmc))
  o = c(list(algorithm = 'hmc'), o)
  if (!missing(engine))
    o[['engine']] = engine
  if (!missing(metric))
    o[['metric']] = metric
  if (!missing(stepsize))
    o[['stepsize']] = stepsize
  if (!missing(stepsize_jitter))
    o[['stepsize_jitter']] = stepsize_jitter
  return(o)
}

sampling = function(
  algorithm = stas:::hmc(), 
  num_samples = 1000, 
  num_warmup = 1000, 
  save_warmup = FALSE,
  thin = 1, 
  adapt = stas:::adapt()
) {
  o = as.list(full_eval(formals(sampling)))
  o = c(list(method = 'sample'), o)
  if (!missing(algorithm))
    o[['algorithm']] = algorithm
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
  return(o)
}

stan_binary = function(...) {
  if (length(list(...)) == 0) {
    o = 'default_binary'
  } else { 
    o = as.vector(list(...))
  }
  return(o)
}

sample = function(binary = stas:::stan_binary(), id = stas:::id(), 
                  data = stas:::data(), init =  NULL,
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
  if (!missing(data) && is.character(data))
    data = stas:::data(file = data)
  if (!missing(init) && is.na(as.numeric(init)))
    init = stas:::init(file = init)
  o = list(eval(binary), id = eval(id), s)
  o[['data']] = eval(data)
  o[['init']] = init
  o[['output']] = eval(output)
  o = as.list(full_eval(o))
  o[[1]] = gsub('^[ ]*', '', o[[1]]) 
  return(o)
}

configure_run = function(binary = stas:::stan_binary(), 
               method = stas:::sampling(), id = stas:::id(), 
               data = stas:::data(), init = stas:::init(),
               random = stas:::random(), output = stas:::output()
) {
  o = as.list(full_eval(formals(run)))
  if (!missing(binary))
    o[['binary']] = binary
  if (!missing(method))
    o[['method']] = method
  if (!missing(id))
    o[['id']] = id
  if (!missing(data))
    o[['data']] = stas:::data(file = data) 
  if (!missing(init)) {
    if (is.list(init)) {
      o[['init']] = init
    } else if (!is.na(as.numeric(init))) {
      o[['init']] = stas:::init(radius = as.numeric(init))
    } else if (file.exists(init)) {
      o[['init']] = stas:::init(file = init)
    } else {
      stop("'init' values is not numeric and is not an existing file.")
    }
  }
  if (!missing(random))
    o[['random']] = random
  if (!missing(output))
    o[['output']] = output
  names(o)[1] = ""
  return(o)
}

stringify_binary = function(x) x[[1]]

stringify_impl = function(x) {
  cmd = ""
  for (i in 1:length(x)) {
    if (is.logical(x[[i]])) {
      if (x[[i]]) {
        x[[i]] = 1
      } else {
        x[[i]] = 0
      }
    }
    if (is.list(x[[i]])) {
      x[[i]] = stringify_impl(x[[i]])
      cmd = paste(cmd, x[[i]])
    } else {
      if (!is.null(names(x)) && names(x)[i] != "") {
        cmd = paste(cmd, paste(names(x)[i], x[i], sep = '='))
      } else {
        cmd = paste(cmd, x[i])
      }
    }
  }
  return(cmd)
}

stringify_arguments = function(x) {
  cmd = stringify_impl(x)
  if (substr(cmd, 1, 1) == " ")
    cmd = substr(cmd, 2, nchar(cmd))
  cmd = gsub('^[^ ]*[ ]', '', cmd)
  return(cmd)
}



