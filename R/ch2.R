# Chapter 2

# Imports ---------------------------------------------------------------------

library(cmdstanr)
library(dplyr)
library(here)
library(ggplot2)

# Constants -------------------------------------------------------------------

ITERATIONS <- 2500

# Globe model: data -----------------------------------------------------------

data_globe <- list(w = 6, n = 9)

# Globe model: uniform prior --------------------------------------------------

# Create a path to the Stan file
code_globe_uniform_prior <- here("stan", "ch2-globe-uniform.stan")

# Create the model
model_globe_uniform_prior <- cmdstan_model(code_globe_uniform_prior)

# Fit the model
fit_globe_uniform_prior <- model_globe_uniform_prior$sample(
  data = data_globe,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_globe_uniform_prior <- fit_globe_uniform_prior$draws(format = "df")

# Globe model: normal prior ---------------------------------------------------

code_globe_normal_prior <- here("stan", "ch2-globe-normal.stan")

# Create the model
model_globe_normal_prior <- cmdstan_model(code_globe_normal_prior)

# Fit the model
fit_globe_normal_prior <- model_globe_normal_prior$sample(
  data = data_globe,
  seed = 123,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_globe_normal_prior <- fit_globe_normal_prior$draws(format = "df")

# Compare posteriors ----------------------------------------------------------

plot_data <- tibble(
  prior = c(rep("uniform", ITERATIONS * 4), rep("normal", ITERATIONS * 4)),
  p = c(posterior_globe_uniform_prior$p, posterior_globe_normal_prior$p))

plot <- ggplot(
  data = plot_data,
  mapping = aes(
    x = p,
    fill = prior)) +
  geom_histogram() +
  facet_wrap(~ prior)

plot