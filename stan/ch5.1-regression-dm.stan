// Chapter 5.1: Regression using design matrix approach 
data {
  int<lower=1> n;      // number of observations
  int<lower=1> k;      // number of regressors (including constant)
  vector[n] y;         // outcome
  matrix[n, k] X;      // regressors
  real a_mean;         // intercept mean
  real<lower=0> a_sd;  // intercept sd
  real b_mean;         // coefficient mean
  real<lower=0> b_sd;  // coefficient sd
  real sigma_rate;     // rate of prior for error
}
parameters {
  real<lower=0,upper=50> sigma;  // scale
  vector[k] b;                   // coefficients (including constant)
}
model {
  vector[n] mu;                  // location
  mu = X * b;                    // linear model
  y ~ normal(mu, sigma);         // likelihood
  sigma ~ exponential(1);        // prior for error
  b[1] ~ normal(a_mean, a_sd);   // prior for intercept
  for (i in 2:k) {               // priors for coefficients
    b[i] ~ normal(b_mean, b_sd);
  }
}
