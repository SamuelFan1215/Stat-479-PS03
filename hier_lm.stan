data {
    int<lower=1> N; // number of total observations
    int<lower=1> J; // number of groups, J = 6
    int<lower=1> K; // number of columns in X (number of predictors)
    int<lower=1, upper=J> id[N]; // group indices
    matrix[N,K] X; // the predictor matrix
    vector[N] y; // the response matrix
    int<lower = 0> n_grid; // length of posterior prediction grid
    vector[n_grid] dance_grid; // predictor 1 grid
    vector[n_grid] valence_grid; // predictor 2 grid
    // input priors: 
}

parameters {
  vector[K] gamma; // coefficient of predictors (mean of beta)
  vector<lower=0>[K] tau; // sd of predictors (sd of beta)
  vector[K] beta_raw[J]; // standardized coefficient
  real<lower=0> sigma; // sd of response
}

transformed parameters {
  vector[K] beta[J]; // matrix of group-level regression coefficients
  for(j in 1:J) {
    beta[j] = gamma + tau .* beta_raw[j]; 
  }
}
model {
  vector[N] mu; // X times beta
  // priors
  gamma ~ normal(32, 1.5); // mean of regression coefficient
  tau ~ cauchy(0.75, 0.05); // want tau to be small for accuracy
  sigma ~ normal(23, 1); // sd of response
  for(j in 1:J){
   beta_raw[j] ~ normal(0, 1); // implies beta~normal(gamma, tau)
  }
  for(n in 1:N){
    mu[n] = X[n] * beta[id[n]]; // compute the linear predictor using relevant group-level regression coefficients
  }
  // likelihood
  y ~ normal(mu, sigma);
}

generated quantities{
  vector[n_grid] post_line;
  
  for(i in 1:n_grid){
    post_line[i] = beta[1,1] * dance_grid[i] + beta[1,2] * mean(X[,2]);
  }
}

