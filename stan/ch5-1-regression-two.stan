// Chapter 5.1: Regression with two predictors
data {
  int<lower=1> n;        // number of observations
  vector[n] y;           // outcome (divorce)
  vector[n] x1;          // predictor 1
  vector[n] x2;          // predictor 2
  real a_mean;           // intercept mean
  real<lower=0> a_sd;    // intercept sd
  real bx1_mean;         // coefficient 1 mean
  real<lower=0> bx1_sd;  // coefficient 1 sd
  real bx2_mean;         // coefficient 2 mean
  real<lower=0> bx2_sd;  // coefficient 2 sd
  real sigma_rate;       // rate of prior for error
}
parameters {
  real<lower=0,upper=50> sigma;  // error
  real bx1;                      // coefficient 1
  real bx2;                      // coefficient 2
  real a;                        // intercept
}
model {
  vector[n] mu;
  mu = a + bx1 * x1 + bx2 * x2;     // linear model
  a ~ normal(a_mean, a_sd);         // prior for intercept
  bx1 ~ normal(bx1_mean, bx1_sd);   // prior for coefficient 1
  bx2 ~ normal(bx2_mean, bx2_sd);   // prior for coefficient 1
  sigma ~ exponential(sigma_rate);  // prior for error
  y ~ normal(mu, sigma);            // likelihood
}
