# Chapter 5.2

# Imports ---------------------------------------------------------------------

library(cmdstanr)
library(dplyr)
library(ggplot2)
library(here)
library(janitor)
library(posterior)
library(purrr)
library(readr)
library(tidyr)

# Constants -------------------------------------------------------------------

ITERATIONS <- 2500

# Load data -------------------------------------------------------------------

mk <- read_csv(here("data", "milk.csv")) |> 
  clean_names()

# Standardise data ------------------------------------------------------------

standardise <- \(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)

mk <- mk |> 
  mutate(
    kcal_per_g_std = standardise(kcal_per_g),
    neocortex_perc_std = standardise(neocortex_perc),
    mass_std = standardise(mass)) |> 
  drop_na()

# Kcal by neocortex data ------------------------------------------------------

data_kcal_neocortex <- list(
  n = nrow(mk),
  y = mk$kcal_per_g_std,
  x = mk$neocortex_perc_std,
  a_mean = 0,
  a_sd = 0.2,
  bx_mean = 0,
  bx_sd = 0.5,
  sigma_rate = 1,
  run_estimation = 1)

# Kcal by neocortex model -----------------------------------------------------

# Create a path to the Stan file
code_kcal_neocortex <- here("stan", "ch5-2-single-sim-prior.stan")

# Create the model
model_kcal_neocortex <- cmdstan_model(code_kcal_neocortex)

# Fit the model
fit_kcal_neocortex <- model_kcal_neocortex$sample(
  data = data_kcal_neocortex,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_kcal_neocortex <- fit_kcal_neocortex$draws(format = "df")

# Get a summary from the posterior
summary_kcal_neocortex <- fit_kcal_neocortex$summary()

# Plot sample from posterior over data ----------------------------------------

posterior_sample <- posterior_kcal_neocortex |> sample_n(50)

plot_kcal_neocortex_posterior <- ggplot(
  data = mk, 
  mapping = aes(
    x = kcal_per_g_std, 
    y = neocortex_perc_std)) + 
  geom_point() + 
  geom_abline(
    intercept = posterior_sample$a,
    slope = posterior_sample$bx,
    alpha = 0.2) +
  scale_x_continuous(limits = c(-2.1, 2.1)) +
  scale_y_continuous(limits = c(-2.1, 2.1))