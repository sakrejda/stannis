
library(stannis)
tag = "00000000-0000-0000-0000-000000000000"

system.time({
  o = stannis::rewrite_stan_csv(source = 'output.csv', root = 'binary', tag = tag, comment = "Krump")
  P = stannis::get_parameter('binary', 'P')
})

system.time({
  m = rstan::read_stan_csv("output.csv")
  P_ = rstan::extract(m, pars = c("P"), permuted=FALSE)
})

max_err = max(P[1001:1300,] - P_[,1,])



run = stannis::read_run('.', uuid = NULL)


library(stannis)
P = stannis::get_parameter('./sample', 'P')
P_ = stannis::get_parameter('./sample', 'P', mmap=TRUE)
str(P)
str(P_)

