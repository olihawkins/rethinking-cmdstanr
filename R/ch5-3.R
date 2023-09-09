# Chapter 5.3

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

# Standardise data ------------------------------------------------------------

standardise <- \(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)

# Load data -------------------------------------------------------------------

hw <- read_csv(here("data", "howell-1.csv")) |> 
  mutate(sex = if_else(male == 1, 2, 1))

mk <- read_csv(here("data", "milk.csv")) |> 
  clean_names() |> 
  arrange(clade) |> 
  group_by(clade) |> mutate(clade_id = cur_group_id()) |> ungroup() |> 
  mutate(kcal_per_g_std = standardise(kcal_per_g))

# Height by sex data ----------------------------------------------------------

data_height_sex <- list(
  n = nrow(hw),
  k = 2,
  height = hw$height,
  sex = hw$sex)

# Height by sex model ---------------------------------------------------------

# Create a path to the Stan file
code_height_sex <- here("stan", "ch5-3-height-sex.stan")

# Create the model
model_height_sex <- cmdstan_model(code_height_sex)

# Fit the model
fit_height_sex <- model_height_sex$sample(
  data = data_height_sex,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_height_sex <- fit_height_sex$draws(format = "df")

# Get a summary from the posterior
summary_height_sex <- fit_height_sex$summary()

# Kcal by clade data ----------------------------------------------------------

data_kcal_clade <- list(
  n = nrow(mk),
  k = nrow(distinct(mk, clade_id)),
  kcal = mk$kcal_per_g_std,
  clade = mk$clade_id)

# Kcal by clade model ---------------------------------------------------------

# Create a path to the Stan file
code_kcal_clade <- here("stan", "ch5-3-kcal-clade.stan")

# Create the model
model_kcal_clade <- cmdstan_model(code_kcal_clade)

# Fit the model
fit_kcal_clade <- model_kcal_clade$sample(
  data = data_kcal_clade,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_kcal_clade <- fit_kcal_clade$draws(format = "df")

# Get a summary from the posterior
summary_kcal_clade <- fit_kcal_clade$summary()

# Get a summary from the posterior for just the clade categories
summary_kcal_clade_a <- fit_kcal_clade$summary("a")
