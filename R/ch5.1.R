# Chapter 5.1

# Imports ---------------------------------------------------------------------

library(cmdstanr)
library(dplyr)
library(ggplot2)
library(here)
library(purrr)
library(readr)
library(tidyr)

# Constants -------------------------------------------------------------------

ITERATIONS <- 2500

# Load data -------------------------------------------------------------------

wd <- read_csv(here("data", "waffle-divorce.csv"))

# Standardise data ------------------------------------------------------------

standardise <- \(x) (x - mean(x)) / sd(x)

wd <- wd |> 
  mutate(
    median_age_marriage_std = standardise(median_age_marriage),
    marriage_rate_std = standardise(marriage_rate),
    divorce_rate_std = standardise(divorce_rate))

# Divorce by age data ---------------------------------------------------------

data_divorce_age <- list(
  n = nrow(wd),
  y = wd$divorce_rate_std,
  x = wd$median_age_marriage_std,
  a_mean = 0,
  a_sd = 0.2,
  bx_mean = 0,
  bx_sd = 0.5,
  sigma_rate = 1)

# Divorce by age model --------------------------------------------------------

# Create a path to the Stan file
code_divorce_age <- here("stan", "ch5.1-regression-one.stan")

# Create the model
model_divorce_age <- cmdstan_model(code_divorce_age)

# Fit the model
fit_divorce_age <- model_divorce_age$sample(
  data = data_divorce_age,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_divorce_age <- fit_divorce_age$draws(format = "df")

# Get a summary from the posterior
summary_divorce_age <- fit_divorce_age$summary()

# Divorce by marriage rate data -----------------------------------------------

data_divorce_marriage <- list(
  n = nrow(wd),
  y = wd$divorce_rate_std,
  x = wd$marriage_rate_std,
  a_mean = 0,
  a_sd = 0.2,
  bx_mean = 0,
  bx_sd = 0.5,
  sigma_rate = 1)

# Divorce by marriage rate model ----------------------------------------------

# Create a path to the Stan file
code_divorce_marriage <- here("stan", "ch5.1-regression-one.stan")

# Create the model
model_divorce_marriage <- cmdstan_model(code_divorce_marriage)

# Fit the model
fit_divorce_marriage <- model_divorce_marriage$sample(
  data = data_divorce_marriage,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_divorce_marriage <- fit_divorce_marriage$draws(format = "df")

# Get a summary from the posterior
summary_divorce_marriage <- fit_divorce_marriage$summary()

# Multiple regression of divorce data -----------------------------------------

data_divorce_multiple <- list(
  n = nrow(wd),
  y = wd$divorce_rate_std,
  x1 = wd$marriage_rate_std,
  x2 = wd$median_age_marriage_std,
  a_mean = 0,
  a_sd = 0.2,
  bx1_mean = 0,
  bx1_sd = 0.5,
  bx2_mean = 0,
  bx2_sd = 0.5,
  sigma_rate = 1)

# Multiple regression of divorce model ----------------------------------------

# Create a path to the Stan file
code_divorce_multiple <- here("stan", "ch5.1-regression-two.stan")

# Create the model
model_divorce_multiple <- cmdstan_model(code_divorce_multiple)

# Fit the model
fit_divorce_multiple <- model_divorce_multiple$sample(
  data = data_divorce_multiple,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_divorce_multiple <- fit_divorce_multiple$draws(format = "df")

# Get a summary from the posterior
summary_divorce_multiple <- fit_divorce_multiple$summary()

# Multiple regression of divorce data using design matrix ---------------------

X <- wd |> 
  mutate(intercept = 1) |>
  select(
    intercept, 
    marriage_rate_std, 
    median_age_marriage_std) |> 
  as.matrix()

data_divorce_multiple_dm <- list(
  n = nrow(wd),
  k = ncol(X),
  y = wd$divorce_rate_std,
  X = X,
  a_mean = 0,
  a_sd = 0.2,
  b_mean = 0,
  b_sd = 0.5,
  sigma_rate = 1)

# Multiple regression of divorce model using design matrix --------------------

# Create a path to the Stan file
code_divorce_multiple_dm <- here("stan", "ch5.1-regression-dm.stan")

# Create the model
model_divorce_multiple_dm <- cmdstan_model(code_divorce_multiple_dm)

# Fit the model
fit_divorce_multiple_dm <- model_divorce_multiple_dm$sample(
  data = data_divorce_multiple_dm,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_divorce_multiple_dm <- fit_divorce_multiple_dm$draws(format = "df")

# Get a summary from the posterior
summary_divorce_multiple_dm <- fit_divorce_multiple_dm$summary()
