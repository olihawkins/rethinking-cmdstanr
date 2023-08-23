// Chapter 2: Globe model with normal prior
data {
  int w;
  int n;
}
parameters {
  real<lower=0,upper=1> p;
}
model {
  w ~ binomial(n, p);
  p ~ normal(0.5, 0.2);
}
