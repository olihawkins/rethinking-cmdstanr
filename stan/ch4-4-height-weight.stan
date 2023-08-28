// Chapter 4.4: Height as a function of weight
data {
  int<lower=1> n;
  vector[n] height;
  vector[n] weight;
  real weight_mean;
  real alpha_mean;
  real<lower=0> alpha_sd;
  real beta_mean;
  real<lower=0> beta_sd;
  real<lower=0> sigma_lower;
  real sigma_upper;
}
parameters {
  real alpha;
  real<lower=0> beta;
  real<lower=0,upper=50> sigma;
}
model {
  vector[n] mu;
  mu = alpha + beta * (weight - weight_mean); // linear model
  alpha ~ normal(alpha_mean, alpha_sd);       // intercept prior
  beta ~ lognormal(beta_mean, beta_sd);       // coefficient prior
  sigma ~ uniform(sigma_lower, sigma_upper);  // error prior
  height ~ normal(mu, sigma);                 // likelihood
}

