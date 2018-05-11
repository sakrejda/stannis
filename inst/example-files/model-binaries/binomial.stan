data {
  int n_obs;
  int N;
  int y[n_obs];
}

transformed data {
  for (i in 1:n_obs) {
    if (y[i] > N)
      reject("Can't win if you don't try.");
  }
}

parameters {
  real<lower=0, upper=1> theta;
}

model {
  y ~ binomial(N, theta);
}







