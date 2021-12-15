data {
    int<lower=1> N; // number of total observations
    int<lower=1> J; // number of groups, J = 6
    int<lower=1> K; // number of columns in X (number of predictors)
    int<lower=1, upper=J> id[N]; // group indices
    matrix[N, K] X; // the predictor matrix
    vector[N] y; // the response matrix
    int<lower = 0> n_grid; // length of posterior prediction grid
    vector[n_grid] dance_grid; // predictor 1 grid
    vector[n_grid] valence_grid; // predictor 2 grid
}

parameters {
  vector[K] beta[J];
  real<lower=0> sigma; // variance of response
}

model {
  vector[N] mu; // X times beta
  sigma ~ normal(23, 1); // response's sd 
  beta[,1] ~ normal(75, 0.5);
  beta[,2] ~ normal(6.2, 0.6);
  for(n in 1:N){
    mu[n] = X[n] * beta[id[n]]; // compute the linear predictor using relevant group-level regression coefficients
  }
  // likelihood
  y ~ normal(mu, sigma);
}

generated quantities{
  matrix[n_grid, J] post_matrix;
  
  for(i in 1:n_grid){
    for (k in 1:6) {
      post_matrix[i, k] = beta[k,1] * dance_grid[i] + beta[k,2] * mean(X[,2]); // fix valence at mean and look at danceability
    }
  }
}


