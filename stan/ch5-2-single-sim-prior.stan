// Chapter 5.2: Regression with one predictor. This version includes a flag to 
// generate either the prior or posterior which works by conditionally
// evaluating the likelihood. Based on an approach developed by Jim Savage.
// https://khakieconomics.github.io/2017/04/30/An-easy-way-to-simulate-fake-data-in-stan.html
data {
  int<lower=1> n;                        // number of observations
  vector[n] y;                           // outcome (divorce)
  vector[n] x;                           // predictor
  real a_mean;                           // intercept mean
  real<lower=0> a_sd;                    // intercept sd
  real bx_mean;                          // coefficient mean
  real<lower=0> bx_sd;                   // coefficient sd
  real sigma_rate;                       // rate of prior for error
  int<lower=0, upper=1> run_estimation;  // a switch to evaluate the likelihood
  
}
parameters {
  real<lower=0,upper=50> sigma;  // error
  real bx;                       // coefficient
  real a;                        // intercept
}
model {
  vector[n] mu;
  mu = a + bx * x;                  // linear model
  a ~ normal(a_mean, a_sd);         // prior for intercept
  bx ~ normal(bx_mean, bx_sd);      // prior for coefficient
  sigma ~ exponential(sigma_rate);  // prior for error
  if (run_estimation == 1) {
    y ~ normal(mu, sigma);          // likelihood
  }
}
