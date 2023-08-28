# rethinking-cmdstanr

This is an R project for reproducing and exploring the model fitting and analysis code shown in Richard McElreath's book *Statistical Rethinking* using CmdStanR and the tidyverse.

## Setting up the R environment from scratch

This shows how to set up an R environment from scratch so that it is easy to restore. The current version of `renv` appears to have issues working with third party package repositories, which is how `cmdstanr` is normally installed. The easiest solution for now is to install `cmdstanr` from its GitHub repo, as `renv::install` seems to be able to track GitHub packages without any issues.

Create a bare R environment.

```r
renv::init(bare = TRUE)
```

Install tidyverse packages.

```r
renv::install("dplyr")
renv::install("ggplot2")
renv::install("purrr")
renv::install("readr")
renv::install("tidyr")
renv::install("here")
```

Install `cmdstanr`.

```r
renv::install("stan-dev/cmdstanr")
```

Install `rethinking`.

```r
renv::install("rmcelreath/rethinking")
```

Snapshot the library.

```
renv::snapshot()
```

## Restoring the R environment from the lockfile

Activate the environment.

```r
renv::activate()
```

Restore the environment.

```r
renv::restore()
```

## How this project is organised

### Code files

For each section in the book that explores a particular analysis, there is an R script in the `R` directory and Stan model definitions in the `stan` directory. The textbook uses a hierarchical numbering system for sections, and the code files are numbered with smallest encompassing section number that covers the relevant material. Models are given meaningful but short names that summarise their goal.

### Stan model definitions

There are more Stan model definitions in this project than there are models that appear in the book. For some examples in the book, the same model is defined in several different ways in Stan. This is so that I can explore different aspects of Stan. 

In some cases I have defined the same model in two or more ways that are equivalent, but that either offer different interfaces to the R code, or that may fit differently given how MCMC works. 

In other cases I am using Stan to generate additional output that I need in the analysis. In the first half of his book, McElreath uses his own implementation of quadratic approximation to fit Bayesian models and to sample and simulate from the posterior distribution. Stan can do this sampling and simulation for you, so rather than trying to emulate the book's handling of posterior samples in R, it sometimes makes more sense to use these feature of Stan. Where a model has been augmented to generate additional data for use in the analysis, the model name has a suffix that contains `gen`.

## Links

### Statistical Rethinking

- [Statistical Rethinking](https://github.com/rmcelreath/stat_rethinking_2022)
- [Statistical Rethinking 2 with Stan and R](https://vincentarelbundock.github.io/rethinking2/)
- [Statistical Rethinking with brms, ggplot2, and the tidyverse](https://bookdown.org/ajkurz/Statistical_Rethinking_recoded/)

### CmdStanR

- [CmdStanR Overview](https://mc-stan.org/cmdstanr/)
- [Getting Started with CmdStanR](https://mc-stan.org/cmdstanr/articles/cmdstanr.html)
- [How does CmdStanR work?](https://mc-stan.org/cmdstanr/articles/cmdstanr-internals.html)
- [CmdStan User's Guide](https://mc-stan.org/docs/cmdstan-guide/index.html)
- [Understanding basics of Bayesian statistics and modelling](https://discourse.mc-stan.org/t/understanding-basics-of-bayesian-statistics-and-modelling/17243)

### Stan
- [Correct order of statements in the model block](https://discourse.mc-stan.org/t/correct-ordering-of-lines-in-the-model-block/661/3)
- [Divergent transitions - a primer](https://discourse.mc-stan.org/t/divergent-transitions-a-primer/17099)
- [An easy way to simulate fake data from your Stan model](https://khakieconomics.github.io/2017/04/30/An-easy-way-to-simulate-fake-data-in-stan.html)

### Bayesian R Packages

- [rethinking](https://github.com/rmcelreath/rethinking/)
- [cmdstanr](https://github.com/stan-dev/cmdstanr)
- [rstan](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started)
- [brms](https://paul-buerkner.github.io/brms/)

