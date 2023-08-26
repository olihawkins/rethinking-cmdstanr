data {
  int<lower=1> n;       // number of observations
  vector[n] y;          // outcome (divorce)
  vector[n] x;          // predictor (median_age_marriage or divorce)
  real a_mean;          // intercept mean
  real<lower=0> a_sd;   // intercept sd
  real bx_mean;         // coefficient mean
  real<lower=0> bx_sd;  // coefficient sd
  real sigma_rate;      // rate of prior for error
}
parameters {
  real<lower=0,upper=50> sigma;  // error
  real bx;                       // coefficient
  real a;                        // intercept
}
model {
  vector[n] mu;
  mu = a + bx * x;                  // linear model
  y ~ normal(mu, sigma);            // likelihood: probability of data
  a ~ normal(a_mean, a_sd);         // prior for intercept
  bx ~ normal(bx_mean, bx_sd);      // prior for coefficient
  sigma ~ exponential(sigma_rate);  // prior for error
}
