// Chapter 4: Height model with intercept only
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
  height ~ normal(mu, sigma);
  mu ~ normal(mu_mean, mu_sd);
  sigma ~ uniform(sigma_lower, sigma_upper);
}
