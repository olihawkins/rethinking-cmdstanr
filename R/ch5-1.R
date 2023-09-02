# Chapter 5.1

# Imports ---------------------------------------------------------------------

library(cmdstanr)
library(dplyr)
library(ggplot2)
library(here)
library(posterior)
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
code_divorce_age <- here("stan", "ch5-1-single.stan")

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
code_divorce_marriage <- here("stan", "ch5-1-single.stan")

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
  x1 = wd$median_age_marriage_std,
  x2 = wd$marriage_rate_std,
  a_mean = 0,
  a_sd = 0.2,
  bx1_mean = 0,
  bx1_sd = 0.5,
  bx2_mean = 0,
  bx2_sd = 0.5,
  sigma_rate = 1)

# Multiple regression of divorce model ----------------------------------------

# Create a path to the Stan file
code_divorce_multiple <- here("stan", "ch5-1-multiple.stan")

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
    median_age_marriage_std,
    marriage_rate_std) |> 
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
code_divorce_multiple_dm <- here("stan", "ch5-1-multiple-dm.stan")

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

# Marriage rate by age data ---------------------------------------------------

data_marriage_age <- list(
  n = nrow(wd),
  y = wd$marriage_rate_std,
  x = wd$median_age_marriage_std,
  a_mean = 0,
  a_sd = 0.2,
  bx_mean = 0,
  bx_sd = 0.5,
  sigma_rate = 1)

# Marriage rate by age model --------------------------------------------------

# Create a path to the Stan file
# This version generates a distribution of mu for each observation
code_marriage_age <- here(
  "stan", "ch5-1-single-gen-mu-obs.stan")

# Create the model
model_marriage_age <- cmdstan_model(code_marriage_age)

# Fit the model
fit_marriage_age <- model_marriage_age$sample(
  data = data_marriage_age,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_marriage_age <- fit_marriage_age$draws(format = "df")

# Get a summary from the posterior
summary_marriage_age <- fit_marriage_age$summary()

# Plot marriage rate by age ---------------------------------------------------

plot_marriage_age_data <- wd |> select(
  state_abbr,
  median_age_marriage_std,
  marriage_rate_std)

intercept <- summary_marriage_age |> 
  filter(variable == "a") |> 
  pluck("mean")

slope <- summary_marriage_age |> 
  filter(variable == "bx") |> 
  pluck("mean")

plot_marriage_age <- ggplot(
  data = plot_marriage_age_data,
  mapping = aes(
    x = median_age_marriage_std,
    y = marriage_rate_std,
    label = state_abbr)) +
  geom_point() +
  geom_text(
    nudge_y = 0.15,
    check_overlap = TRUE) + 
  geom_abline(
    intercept = intercept,
    slope = slope)

# Divorce rate by marriage rate residuals data --------------------------------

mar_rate_mu <- summary_marriage_age$mean[5:54]
mar_rate_residual <- wd$marriage_rate_std - mar_rate_mu
x_seq <- seq(-2, 2, length.out = 50)

data_div_mar_rate_residuals <- list(
  n = nrow(wd),
  y = wd$divorce_rate_std,
  x = mar_rate_residual,
  a_mean = 0,
  a_sd = 0.2,
  bx_mean = 0,
  bx_sd = 0.5,
  sigma_rate = 1,
  x_seq_len = length(x_seq),
  x_seq = x_seq)

# Divorce rate by marriage rate residuals model -------------------------------

# Create a path to the Stan file
code_div_mar_rate_residuals <- here(
  "stan", "ch5-1-single-gen-mu-seq.stan")

# Create the model
model_div_mar_rate_residuals <- cmdstan_model(code_div_mar_rate_residuals)

# Fit the model
fit_div_mar_rate_residuals <- model_div_mar_rate_residuals$sample(
  data = data_div_mar_rate_residuals,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_div_mar_rate_residuals <- 
  fit_div_mar_rate_residuals$draws(format = "df")

# Get a summary from the posterior
summary_div_mar_rate_residuals <- 
  fit_div_mar_rate_residuals$summary()

summary_div_mar_rate_residuals <- 
  fit_div_mar_rate_residuals$summary(
    variables = fit_div_mar_rate_residuals$variable,
    default_summary_measures()[1:4],
    quantiles = ~ quantile2(., probs = c(0.055, 0.945)))

# Plot divorce rate by marriage rate residuals --------------------------------

plot_div_mar_rate_residuals_data <- tibble(
  state_abbr = wd$state_abbr,
  mar_rate_residual = mar_rate_residual,
  divorce_rate_std = wd$divorce_rate_std)

plot_div_mar_rate_residuals_area_data <- tibble(
  x_seq = x_seq,
  parameter_lower = summary_div_mar_rate_residuals$q5.5[5:54],
  parameter_upper = summary_div_mar_rate_residuals$q94.5[5:54])

intercept <- summary_div_mar_rate_residuals |> 
  filter(variable == "a") |> 
  pluck("mean")

slope <- summary_div_mar_rate_residuals |> 
  filter(variable == "bx") |> 
  pluck("mean")

plot_div_mar_rate_residuals <- ggplot() +
  geom_ribbon(
    data = plot_div_mar_rate_residuals_area_data,
    mapping = aes(
      x = x_seq,
      ymin = parameter_lower, 
      ymax = parameter_upper),
    alpha = 0.3) +
  geom_point(
    data = plot_div_mar_rate_residuals_data,
    mapping = aes(
      x = mar_rate_residual,
      y = divorce_rate_std),
    shape = 1,
    color = "blue",
    size = 2) +
  geom_text(
    data = plot_div_mar_rate_residuals_data,
    mapping = aes(
      x = mar_rate_residual,
      y = divorce_rate_std,
      label = state_abbr),
    nudge_y = 0.15,
    check_overlap = TRUE) + 
  geom_abline(
    intercept = intercept,
    slope = slope) +
  geom_vline(
    xintercept = 0,
    linetype = 2) +
  scale_x_continuous(
    expand = c(0, 0),
    limits = c(-2, 2),
    breaks = seq(-2, 2, 0.5)) +
  labs(
    x = "Marriage rate residuals",
    y = "Divorce rate (std)")

# Joint regression of divorce data --------------------------------------------

age_seq <- seq(-2, 2, length.out = 50)

data_divorce_joint <- list(
  n = nrow(wd),
  divorce = wd$divorce_rate_std,
  age = wd$median_age_marriage_std,
  marriage = wd$marriage_rate_std,
  age_seq_len = length(age_seq),
  age_seq = age_seq)

# Joint regression of divorce -------------------------------------------------

# Create a path to the Stan file
code_divorce_joint <- here(
  "stan", "ch5-1-amd-gen-sim-seq.stan")

# Create the model
model_divorce_joint <- cmdstan_model(code_divorce_joint)

# Fit the model
fit_divorce_joint <- model_divorce_joint$sample(
  data = data_divorce_joint,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_divorce_joint <- fit_divorce_joint$draws(format = "df")

# Get a summary from the posterior
summary_divorce_joint <- fit_divorce_joint$summary()

summary_divorce_joint <- 
  fit_divorce_joint$summary(
    variables = fit_divorce_joint $variable,
    default_summary_measures()[1:4],
    quantiles = ~ quantile2(., probs = c(0.055, 0.945)))

# Plot simulated counterfactual for joint model of divorce --------------------

plot_divorce_counteractual_data <- tibble(
  age = age_seq,
  divorce_mean = summary_divorce_joint$mean[59:108],
  divorce_lower = summary_divorce_joint$q5.5[59:108],
  divorce_upper = summary_divorce_joint$q94.5[59:108])

plot_divorce_counteractual <- ggplot(
    data = plot_divorce_counteractual_data,
    mapping = aes(
      x = age,
      y = divorce_mean,
      ymin = divorce_lower, 
      ymax = divorce_upper)) +
  geom_ribbon(alpha = 0.3) +
  geom_line() +
  scale_x_continuous(
    expand = c(0, 0),
    limits = c(-2, 2),
    breaks = seq(-2, 2, 0.5)) +
  labs(
    x = "Manipulated A",
    y = "Counterfactual D")

# Plot simulated counterfactual for effect of age on marriage -----------------

plot_marriage_counteractual_data <- tibble(
  age = age_seq,
  marriage_mean = summary_divorce_joint$mean[9:58],
  marriage_lower = summary_divorce_joint$q5.5[9:58],
  marriage_upper = summary_divorce_joint$q94.5[9:58])

plot_marriage_counteractual <- ggplot(
  data = plot_marriage_counteractual_data,
  mapping = aes(
    x = age,
    y = marriage_mean,
    ymin = marriage_lower, 
    ymax = marriage_upper)) +
  geom_ribbon(alpha = 0.3) +
  geom_line() +
  scale_x_continuous(
    expand = c(0, 0),
    limits = c(-2, 2),
    breaks = seq(-2, 2, 0.5)) +
  labs(
    x = "Manipulated A",
    y = "Counterfactual M")

