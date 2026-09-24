function model = trainHMM(data, M, Q, cov_type, cov_prior)
O = size(data{1}, 1); % Number of coefficients in a vector
% initial guess of parameters
prior0 = normalise(rand(Q, 1));
transmat0 = mk_stochastic(rand(Q, Q));

[mu0, Sigma0] = mixgauss_init(Q * M, data, cov_type);
mu0 = reshape(mu0, [O Q M]);
Sigma0 = reshape(Sigma0, [O O Q M]);
mixmat0 = mk_stochastic(rand(Q, M));

[~, prior, transmat, mu, Sigma, mixmat] = ...
    mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 100, 'cov_type', cov_type, 'cov_prior', cov_prior);

loglik = mhmm_logprob(data, prior, transmat, mu, Sigma, mixmat);
model = structure(prior, transmat, mu, Sigma, mixmat, loglik);
