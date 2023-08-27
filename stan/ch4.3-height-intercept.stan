// Chapter 4.3: Height model with intercept only
data {
  int<lower=1> n;
  vector[n] height;
  real mu_mean;
  real<lower=0> mu_sd;
  real<lower=0> sigma_lower;
  real sigma_upper;
}
parameters {
  real mu;
  real<lower=0,upper=50> sigma;
}
model {
  mu ~ normal(mu_mean, mu_sd);                // mu prior
  sigma ~ uniform(sigma_lower, sigma_upper);  // sigma prior
  height ~ normal(mu, sigma);                 // likelihood
}
