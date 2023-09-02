// Chapter 5.1: Joint regression of two models, used to simulate counterfactual 
// plots. 
//
// In other regression examples from this chapter I made the variable names 
// generic to illustrate the applicability of the code to other data.
//
// In this case I have named the variables after the data they represent in the
// marriage dataset, because the inferences being made in this case depend upon
// a causal model that is consistent with that specific data, and may not make 
// sense in other contexts. For the same reasons I am not passing Stan the 
// parameters of prior distributions as data from within R. This makes the
// most importatnt code more readable too.
//
// Finally, in this example I use the generated quantities block to simulate
// the counterfactual data while fitting the posterior. In the book McElreath
// does the same thing after fitting the model 'sim'.
data {
  int<lower=1> n;               // number of observations
  vector[n] divorce;            // outcome (divorce)
  vector[n] age;                // predictor 1 (age)
  vector[n] marriage;           // predictor 2 (marraiage)
  int<lower=1> age_seq_len;     // number of steps in x sequence
  vector[age_seq_len] age_seq;  // sequence of values for x
}
parameters {
  
  // Multiple regression model of divorce by age and marriage rate
  real a;                                 // intercept in multiple model
  real b_age;                             // coefficient of age
  real b_marriage;                        // coefficient of marriage
  real<lower=0,upper=50> sigma;           // error in multiple model
 
  // Univariable regression of marriage rate by age
  real a_marriage;                        // intercept in univariable model
  real b_age_marriage;                    // coefficient of age
  real<lower=0,upper=50> sigma_marriage;  // error in univariable model
  
}
model {
  
  // Variables
  vector[n] mu;
  vector[n] mu_marriage;
  
  // Multiple regression model of divorce by age and marriage rate
  mu = a + b_age * age + b_marriage * marriage;     // linear model
  a ~ normal(0, 0.2);                               // prior for intercept
  b_age ~ normal(0, 0.5);                           // prior for coefficient of age
  b_marriage ~ normal(0, 0.5);                      // prior for coefficient of marriage
  sigma ~ exponential(1);                           // prior for error
  divorce ~ normal(mu, sigma);                      // likelihood
  
  // Univariable regression of marriage rate by age
  mu_marriage = a_marriage + b_age_marriage * age;  // linear model
  a_marriage ~ normal(0, 0.2);                      // prior for intercept
  b_age_marriage ~ normal(0, 0.5);                  // prior for coefficient
  sigma_marriage ~ exponential(1);                  // prior for error
  marriage ~ normal(mu_marriage, sigma_marriage);   // likelihood
}

generated quantities {
  
  // Create variables for simulated outcomes at each value of age sequence
  vector[age_seq_len] marriage_seq;
  vector[age_seq_len] divorce_seq;
  
  // Simulate marriage rate for a given age
  for (i in 1:age_seq_len) {
    marriage_seq[i] = normal_rng(
      a_marriage + b_age_marriage * age_seq[i], sigma_marriage);
  }
  
  // Simulate divorce rate for a given age and simulated marriage rate
  for (i in 1:age_seq_len) {
    divorce_seq[i] = normal_rng(
      a + b_age * age_seq[i] + b_marriage * marriage_seq[i], sigma);
  }
}
