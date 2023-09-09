// Chapter 5.3: Regression with a categorical predictor: height by sex
data {
  int<lower=1> n;             // number of observations
  int<lower=1> k;             // number of categories
  vector[n] height;           // outcome
  array[n] int<lower=1> sex;  // predictor
}
parameters {
  vector[k] a;                   // intercepts
  real<lower=0,upper=50> sigma;  // error
}
model {
  vector[n] mu;
  mu = a[sex];
  a ~ normal(170, 20);         // prior for intercepts
  sigma ~ uniform(0, 50);      // prior for error
  height ~ normal(mu, sigma);  // likelihood
}
generated quantities{
  real contrast;
  contrast = a[1] - a[2];
}
