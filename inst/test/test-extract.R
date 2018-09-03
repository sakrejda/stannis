
library(stannis)
tag = "00000000-0000-0000-0000-000000000000"
o = stannis:::rewrite(source = 'output.csv', root = 'binary', tag = tag, comment = "Krump")
P = stannis:::get_parameter('binary', 'P')

m = rstan::read_stan_csv("output.csv")
P_ = rstan::extract(m, pars = c("P"), permuted=FALSE)

max_err = max(P[1001:1300,] - P_[,1,])



