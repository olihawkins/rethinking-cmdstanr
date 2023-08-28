// Chapter 2.4: Globe model with uniform prior
data {
  int w;
  int n;
}
parameters {
  real<lower=0,upper=1> p;
}
model {
  w ~ binomial(n, p);
  p ~ uniform(0, 1);
}
