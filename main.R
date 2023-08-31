## main script to estimate problem drug users from administrative data
## this project was comissioned by the Swedish SOU - Narkotikautredningen (S 2022:01)

## A Ledberg 2023 06 21

## The code is an adaptation of the method of:
## Jones et al 2020,
## Estimating the prevalence of problem drug use from drug-related mortality data.
## Addiction, 115: 2393– 2404. https://doi.org/10.1111/add.15111.

## There are two different models, one with an interaction between year and age group, and the other without. 

require(rstan)

options(mc.cores = parallel::detectCores())



## start by loading the data
mdat <- readRDS("sou_data.rds")
nyears <- length(unique(mdat$year))

## this file contains the number of persons who were in the
## official Swedish health care registry (patientregistret) by
## sex (KON), age group (agegr) and year. The variable
## "n"     total number of persons with a care occation in the given year
## "st"    total person time spent after the care occastion but within the year
## "d"     number of these person who died during the follow-up
## "totd"  total number of drug related deaths during the year
## "dmiss" difference between totd and d


## next use glm to get a model matrix 
fit1 <- glm(d~1+as.factor(KON)+as.factor(agegr)+year+offset(log(st)),data = mdat,family = "poisson")

## put the data in a Stan-friendly format 
mmat <- as.data.frame(model.matrix(fit1))
mmat$pTime <- (mdat$st)
names(mmat) <- c("intercept", "sex_woman","age_old","year","offset")

standat   <- as.list(mmat)
standat$y <- mdat$d
standat$y_miss <- mdat$dmiss
standat$nPat <- mdat$n
standat$N <- nrow(mmat)
standat$p <- ncol(mmat) - 1
standat$nYears <- nyears
standat$pTime <- mdat$st
standat$year <- (standat$year-mean(standat$year))/sd(standat$year)

## for a model without interactions run the below
## to set inital values for the fitting
initfun <- function() {
    dum <- vector(length = 5)
    dum[1] <- -4
    dum[2:5] <- rnorm(4,0,.5)
    dum2 <- vector(length = 5)
    dum2[1] <- 4
    dum2[2:5] <- rnorm(4,0,.5)
    list(beta = dum,alpha = dum2)
} 


fitStan <- stan(file = "estimate_pdu.stan", data = standat,
                chains = 4, iter = 10000, warmup = 5000, thin = 10,init = initfun)

##################################################################
## for a model with interaction between age groups and years run the below
initfun <- function() {
    dum <- vector(length = 6)
    dum[1] <- -4
    dum[2:6] <- rnorm(5,0,.5)
    dum2 <- vector(length = 6)
    dum2[1] <- 4
    dum2[2:6] <- rnorm(5,0,.5)
    list(beta = dum,alpha = dum2)
} 

fitStan <- stan(file = "estimate_pdu_interaction.stan", data = standat,
                 chains = 4, iter = 10000, warmup = 5000, thin = 10,init = initfun)


######################################################################
## call the plotting routine make_fig_estimates
ylist <- unique(mdat$year)
source("make_figure.R")

