# Chapter 4.3

# Imports ---------------------------------------------------------------------

library(cmdstanr)
library(dplyr)
library(ggplot2)
library(here)
library(readr)

# Constants -------------------------------------------------------------------

MU_MEAN <- 178
MU_SD <- 20
SIGMA_LOWER <- 0
SIGMA_UPPER <- 50
ITERATIONS <- 2500

# Plot prior distributions ----------------------------------------------------

# Plot prior distribution of mu
ggplot(
    data = tibble(
      mu = 100:250, 
      density = dnorm(100:250, MU_MEAN, MU_SD)),
    mapping = aes(
      x = mu, 
      y = density)) + 
  geom_line()

# Plot prior distribution of sigma
ggplot(
  data = tibble(
    sigma = -10:60, 
    density = dunif(-10:60, SIGMA_LOWER, SIGMA_UPPER)),
  mapping = aes(
    x = sigma, 
    y = density)) + 
  geom_line()

# Plot prior predictive simulation
ggplot(
    data = tibble(
        mu = rnorm(1e4, MU_MEAN, MU_SD),
        sigma = runif(1e4, SIGMA_LOWER, SIGMA_UPPER)) |>  
      mutate(height = rnorm(1e4, mu, sigma)),
    mapping = aes(x = height)) + 
  geom_density()

# Load data -------------------------------------------------------------------

hw <- read_csv(here("data", "howell-1.csv")) |> 
  filter(age >= 18)

# Height data -----------------------------------------------------------------
  
data_height <- list(
  n = nrow(hw),
  height = hw$height,
  mu_mean = MU_MEAN,
  mu_sd = MU_SD,
  sigma_lower = SIGMA_LOWER,
  sigma_upper = SIGMA_UPPER)

# Height intercept model ------------------------------------------------------

# Create a path to the Stan file
code_height_intercept <- here("stan", "ch4-3-height-intercept.stan")

# Create the model
model_height_intercept <- cmdstan_model(code_height_intercept)

# Fit the model
fit_height_intercept <- model_height_intercept$sample(
  data = data_height,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_height_intercept <- fit_height_intercept$draws(format = "df")

# Get variance-covariance matrix and decompose --------------------------------

var_cov_matrix <- posterior_height_intercept |> 
  as_tibble() |> 
  select(mu, sigma) |> 
  cov()

variances <- diag(var_cov_matrix)
cor_matrix <- cov2cor(var_cov_matrix)

var_cov_matrix
variances
cor_matrix

# Plot marginal posteriors ----------------------------------------------------

plot_posteriors_data <- tibble(
  parameter = c(
    rep("mu", ITERATIONS * 4), 
    rep("sigma", ITERATIONS * 4)),
  value = c(
    posterior_height_intercept$mu, 
    posterior_height_intercept$sigma))

plot_posteriors <- ggplot(
  data = plot_posteriors_data,
  mapping = aes(
    x = value,
    fill = parameter)) +
  geom_histogram() +
  facet_wrap(~ parameter, scales = "free_x")

plot_posteriors
