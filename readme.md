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
- [Divergent transitions - a primer](https://discourse.mc-stan.org/t/divergent-transitions-a-primer/17099)

### Bayesian R Packages

- [rethinking](https://github.com/rmcelreath/rethinking/)
- [cmdstanr](https://github.com/stan-dev/cmdstanr)
- [rstan](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started)
- [brms](https://paul-buerkner.github.io/brms/)

