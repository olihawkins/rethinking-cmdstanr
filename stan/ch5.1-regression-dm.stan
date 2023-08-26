// Chapter 5.1: Regression using design matrix approach 
data {
  int<lower=1> n;     // number of observations
  int<lower=1> K;     // number of regressors (including constant)
  vector[n] divorce;  // outcome
  matrix[n, K] X;     // regressors
}
parameters {
  real<lower=0,upper=50> sigma;  // scale
  vector[K] b;                   // coefficients (including constant)
}
transformed parameters {
  vector[n] mu;  // location
  mu = X * b;    // linear transformation
}
model {
  divorce ~ normal(mu, sigma);  // likelihood
  sigma ~ exponential(1);       // prior for scale
  b[1] ~ normal(0, 0.2);        // prior for intercept
  for (i in 2:K) {              // priors for coefficients
    b[i] ~ normal(0, 0.5);
  }
}