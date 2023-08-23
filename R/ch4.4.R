# Chapter 4.4

# Imports ---------------------------------------------------------------------

library(cmdstanr)
library(dplyr)
library(ggplot2)
library(here)
library(purrr)
library(readr)
library(tidyr)

# Constants -------------------------------------------------------------------

ALPHA_MEAN <- 178
ALPHA_SD <- 20
BETA_MEAN <- 0
BETA_SD <- 1
SIGMA_LOWER <- 0
SIGMA_UPPER <- 50
ITERATIONS <- 2500

# Load data -------------------------------------------------------------------

df <- here("data", "howell-1.csv") |> 
  read_delim(delim = ";") |> 
  filter(age >= 18)

# Plot relationship between weight and height ---------------------------------

plot_wh <- ggplot(
  data = df,
  mapping = aes(
    x = weight,
    y = height)) +
  geom_point()

# Plot prior predictive distribution ------------------------------------------

plot_prior_predictive_distribution <- function(priors) {
  ggplot(
      data = priors,
      mapping = aes(
        x = weight,
        y = height,
        group = n)) +
    geom_line(alpha = 0.15) +
    geom_hline(
      yintercept = c(0, 272), 
      linewidth = 0.3,
      linetype = 2)
}

n_lines <- 100

initial_priors <- tibble(
    n = 1:n_lines,
    alpha = rnorm(n_lines, 178, 20),
    beta = rnorm(n_lines, 0, 10)) |> 
  expand_grid(weight = range(df$weight)) |> 
  mutate(height = alpha + beta * (weight - mean(df$weight)))

plot_initial_priors <- plot_prior_predictive_distribution(initial_priors)

revised_priors <- tibble(
  n = 1:n_lines,
  alpha = rnorm(n_lines, 178, 20),
  beta = rlnorm(n_lines, 0, 1)) |> 
  expand_grid(weight = range(df$weight)) |> 
  mutate(height = alpha + beta * (weight - mean(df$weight)))

plot_revised_priors <- plot_prior_predictive_distribution(revised_priors)

# Height data -----------------------------------------------------------------

data_height <- list(
  n = nrow(df),
  height = df$height,
  weight = df$weight,
  weight_mean = mean(df$weight),
  alpha_mean = ALPHA_MEAN,
  alpha_sd = ALPHA_SD,
  beta_mean = BETA_MEAN,
  beta_sd = BETA_SD,
  sigma_lower = SIGMA_LOWER,
  sigma_upper = SIGMA_UPPER)

# Height for weight model -----------------------------------------------------

# Create a path to the Stan file
code_height_weight <- here("stan", "ch4.4-height-weight.stan")

# Create the model
model_height_weight <- cmdstan_model(code_height_weight)

# Fit the model
fit_height_weight <- model_height_weight$sample(
  data = data_height,
  seed = 2001,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = ITERATIONS,
  iter_sampling = ITERATIONS,
  refresh = 500)

# Draw samples from the posterior
posterior_height_weight <- fit_height_weight$draws(format = "df")

# Get variance-covariance matrix and decompose --------------------------------

var_cov_matrix <- posterior_height_weight |> 
  as_tibble() |> 
  select(alpha, beta, sigma) |> 
  cov()

variances <- diag(var_cov_matrix)
cor_matrix <- cov2cor(var_cov_matrix)

var_cov_matrix
variances
cor_matrix

# Plot marginal posteriors ----------------------------------------------------

plot_posteriors_data <- tibble(
  parameter = c(
    rep("alpha", ITERATIONS * 4), 
    rep("beta", ITERATIONS * 4), 
    rep("sigma", ITERATIONS * 4)),
  value = c(
    posterior_height_weight$alpha, 
    posterior_height_weight$beta,
    posterior_height_weight$sigma))

plot_posteriors <- ggplot(
  data = plot_posteriors_data,
  mapping = aes(
    x = value,
    fill = parameter)) +
  geom_histogram() +
  facet_wrap(~ parameter, scales = "free_x")

plot_posteriors

# Plot posterior predictive ---------------------------------------------------

weight_seq <- 25:70
weight_mean <- mean(df$weight)
post <- posterior_height_weight
samples_per_posterior_row <- 10
color = "#52038a"

plot_posterior_prediction_data <- map(weight_seq, function(weight) {
  post_mean <- mean(post$alpha) + mean(post$beta) * (weight - weight_mean)
  parameter_dist <- post$alpha + post$beta * (weight - weight_mean)
  observation_dist <- rnorm(
    n = samples_per_posterior_row * nrow(post),
    mean = post$alpha + post$beta * (weight - weight_mean),
    sd = post$sigma)
  tibble(
    weight = weight,
    post_mean = post_mean,
    parameter_lower = quantile(parameter_dist, 0.025),
    parameter_upper = quantile(parameter_dist, 0.975),
    observation_lower = quantile(observation_dist, 0.025),
    observation_upper = quantile(observation_dist, 0.975))
}) |> list_rbind() 

plot_posterior_prediction <- ggplot(
    data = plot_posterior_prediction_data,
    mapping = aes(x = weight)) +
  geom_ribbon(
    mapping = aes(
      ymin = observation_lower, 
      ymax = observation_upper),
    fill = color,
    alpha = 0.2) +
  geom_ribbon(
    mapping = aes(
      ymin = parameter_lower, 
      ymax = parameter_upper),
    fill = color,
    alpha = 0.4) +
  geom_line(
    mapping = aes(y = post_mean),
    color = color) +
  geom_point(
    data = df,
    mapping = aes(
      x = df$weight,
      y = df$height),
    color = color,
    shape = 1) +
  labs(
    x = "weight",
    y = "height")
  
plot_posterior_prediction
