// Stan model for mortality rates using just one category

data {
  // Define variables in data
  // Number of observations (an integer)
  int<lower=0> N;
  // Number of beta parameters
  int<lower=0> p;

  // Number of years to estimate for 
  int<lower=0> nYears;
  
  
  // Covariates
  int <lower=0, upper=1> intercept[N];
  int <lower=0, upper=1> sex_woman[N];
  int <lower=0, upper=1> age_old[N];
  real year[N];

  // number of patients
  real<lower=0> nPat[N];
  // sum of person time
  real<lower=0> pTime[N];

  // Count outcome
  int<lower=0> y[N];
  // the dead that are not in PAR
  int<lower=0> y_miss[N];
}

parameters {
  // Define parameters to estimate
  real<lower=-10,upper=10> beta[5];
  // offset
  real<lower=-20,upper=20> alpha[5];
}

transformed parameters  {
  // linear predictor, this must be a log rate and hence
  // be less than zero
  real <upper=0>lp[N];
  // expected value of deaths for the observed part
  real <lower=0> mu[N];
  real <lower=0> Nmiss[N];
  real <lower=0> mu_missing[N];
  
  //real <lower=0,upper=1> prev[N];
  for (i in 1:N) {
    lp[i] = beta[1] + beta[2]*sex_woman[i] + beta[3]*age_old[i] +
      beta[4]*year[i]+beta[5]*year[i]*year[i];
    // Mean
    mu[i] = exp(lp[i])*pTime[i];
    Nmiss[i] = exp(alpha[1] + alpha[2]*sex_woman[i] + alpha[3]*age_old[i]+
		   alpha[4]*year[i]+alpha[5]*year[i]*year[i]);
    
    mu_missing[i]=exp(lp[i])*Nmiss[i];
  }
}

model {
  // hard coded priors, not so nice...
  alpha[1]~normal(8,5);
  alpha[2]~normal(0,2);
  alpha[3]~normal(0,2);
  alpha[4]~normal(0,2);
  alpha[5]~normal(0,2);
  beta[1]~normal(-4.4,2);
  beta[2]~normal(0,2);
  beta[3]~normal(0,2);
  beta[4]~normal(0,2);
  beta[5]~normal(0,2);

  
  y ~ poisson(mu);
  y_miss~poisson(mu_missing);
}

generated quantities {
  real totalN[nYears];
  real totalNM[nYears];
  real totalNW[nYears];
  real totalNOld[nYears];
  real totalNYoung[nYears];
  real missYoungWomen[nYears];
  real missYoungMen[nYears];
  real missOldWomen[nYears];
  real missOldMen[nYears];
  real totalMiss[nYears];
  // total pop
  for (i in 1:nYears){
    totalN[i]=0;
    for (j in 1:4){
      totalN[i]+=Nmiss[j+4*(i-1)]+nPat[j+4*(i-1)];
      //totalN[i]+=Nmiss+nPat[j+4*(i-1)];
    }
  }
  for (i in 1:nYears){
    totalNM[i]=0;
    totalNW[i]=0;
    for (j in 1:2){
      totalNM[i]+=Nmiss[j+4*(i-1)]+nPat[j+4*(i-1)];
    }
    for (j in 3:4){
      totalNW[i]+=Nmiss[j+4*(i-1)]+nPat[j+4*(i-1)];
    }
  }
  for (i in 1:nYears){
    totalNOld[i]=0;
    totalNYoung[i]=0;
    for (j in 1:4){
      if (j==1 || j==3)
	totalNYoung[i]+=Nmiss[j+4*(i-1)]+nPat[j+4*(i-1)];
      if (j==2 || j==4)
	totalNOld[i]+=Nmiss[j+4*(i-1)]+nPat[j+4*(i-1)];
    }
  }
  for (i in 1:nYears){
    totalMiss[i]=0;
    for (j in 1:4){
      totalMiss[i]+=Nmiss[j+4*(i-1)];
    }
  }
  for (i in 1:nYears){
    missYoungMen[i]=Nmiss[1+4*(i-1)];
    missYoungWomen[i]=Nmiss[3+4*(i-1)];
    missOldMen[i]=Nmiss[2+4*(i-1)];
    missOldWomen[i]=Nmiss[4+4*(i-1)];
  }
}
