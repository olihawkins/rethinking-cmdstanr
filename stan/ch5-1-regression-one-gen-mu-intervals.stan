// Chapter 5.1: Regression with one predictor, using the generated quantities
// block to generate mu for a set of intervals using the linear model.
data {
  int<lower=1> n;                 // number of observations
  vector[n] y;                    // outcome (divorce)
  vector[n] x;                    // predictor
  real a_mean;                    // intercept mean
  real<lower=0> a_sd;             // intercept sd
  real bx_mean;                   // coefficient mean
  real<lower=0> bx_sd;            // coefficient sd
  real sigma_rate;                // rate of prior for error
  int<lower=1> n_intervals;       // number of intervals
  vector[n_intervals] intervals;  // intervals
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
  y ~ normal(mu, sigma);            // likelihood
}
generated quantities {
  vector[n_intervals] mu_intervals;
  for (i in 1:n_intervals) mu_intervals[i] = a + bx * intervals[i];
}
