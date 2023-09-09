// Chapter 5.3: Regression with a categorical predictor: kcal by clade
data {
  int<lower=1> n;               // number of observations
  int<lower=1> k;               // number of categories
  vector[n] kcal;               // outcome
  array[n] int<lower=1> clade;  // predictor
}
parameters {
  vector[k] a;                   // intercepts
  real<lower=0,upper=50> sigma;  // error
}
model {
  vector[n] mu;
  mu = a[clade];
  a ~ normal(0, 0.5);          // prior for intercepts
  sigma ~ exponential(1);      // prior for error
  kcal ~ normal(mu, sigma);    // likelihood
}
