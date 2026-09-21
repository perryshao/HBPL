function norm_lik = test_data_prob(data,model,H_k)
nex = length(data); class_num = size(model,1);
N = size(model,2); %features
test_loglik = cell(1,nex);
lik = cell(1,nex);
if nargin < 3,
    H_k = 1:N;
end
%% test models for whold feature vector
% for k= 1: nex
%     test_data = data{k};
%     for i =1:class_num 
%         fprintf ('the %dth data/%dth class--test samples %2.2f%%\n',k,i,(class_num*(k-1)+i)*100/(nex*class_num));
%         if ~isempty(model{i})
%             prior = model{i}.prior;transmat = model{i}.transmat;mu = model{i}.mu;
%             Sigma = model{i}.Sigma;mixmat = model{i}.mixmat;
%             test_loglik{k}(i) = mhmm_logprob(test_data,prior, transmat, mu, Sigma, mixmat);
%         else
%             test_loglik{k}(i) = 0;
%         end
%     end
%     % avoid the probability density from becoming infinite
%     if max(test_loglik{k}) > 700
%         test_loglik{k} = test_loglik{k} - (max(test_loglik{k}) - 700);
%     elseif min(test_loglik{k}) < -700 &&...
%             (max(test_loglik{k}) - min(test_loglik{k})) < 1400
%         test_loglik{k} = test_loglik{k}- (min(test_loglik{k}) + 700);
%     end
%     lik{k} = exp(test_loglik{k});
% end
% norm_lik = lik;
% for k = 1:nex
%     norm_lik{k} = normalise(lik{k})';
% end
%% test models for each feature vector
for k= 1: nex
    for j = H_k
        fprintf ('the %dth data/%dth features--test samples %2.2f%%\n',k,j,(length(H_k)*(k-1)+j)*100/(nex*length(H_k)));
        for i =1:class_num
            if j == 1
                test_data = data{k}(1:4,2:end-2);
            else
                test_data = data{k}(((j-2)*4+4+1):((j-1)*4+4),2:end-2);
            end
            if ~isempty(model{i,j})
                prior = model{i,j}.prior;transmat = model{i,j}.transmat;mu = model{i,j}.mu;
                Sigma = model{i,j}.Sigma;mixmat = model{i,j}.mixmat;
                test_loglik{k}(i,j) = mhmm_logprob(test_data,prior, transmat, mu, Sigma, mixmat);
            else
                test_loglik{k}(i,j) = 0;
            end
        end
        % avoid the probability density from becoming infinite
        if max(test_loglik{k}(:,j)) > 700
            test_loglik{k}(:,j) = test_loglik{k}(:,j) - (max(test_loglik{k}(:,j)) - 700);
        elseif min(test_loglik{k}(:,j)) < -700 &&...
                (max(test_loglik{k}(:,j)) - min(test_loglik{k}(:,j))) < 1400
            test_loglik{k}(:,j) = test_loglik{k}(:,j) - (min(test_loglik{k}(:,j)) + 700);
        end
        lik{k}(:,j) = exp(test_loglik{k}(:,j));
    end
end
norm_lik = lik;
for k = 1:nex
    norm_lik{k} = mk_stochastic(lik{k}')';
end
%% backup of test models for each feature vector
% for k= 1: nex
%     for j = H_k
%         fprintf ('the %dth data/%dth features--test samples %2.2f%%\n',k,j,(length(H_k)*(k-1)+j)*100/(nex*length(H_k)));
%         for i =1:class_num
%             if j == 1
%                 test_data = data{k}(1:10,2:end-2);
%             else
%                 test_data = data{k}(((j-2)*4+10+1):((j-1)*4+10),2:end-2);
%             end
%             if ~isempty(model{i,j})
%                 prior = model{i,j}.prior;transmat = model{i,j}.transmat;mu = model{i,j}.mu;
%                 Sigma = model{i,j}.Sigma;mixmat = model{i,j}.mixmat;
%                 test_loglik{k}(i,j) = mhmm_logprob(test_data,prior, transmat, mu, Sigma, mixmat);
%             else
%                 test_loglik{k}(i,j) = 0;
%             end
%         end
%         % avoid the probability density from becoming infinite
%         if max(test_loglik{k}(:,j)) > 700
%             test_loglik{k}(:,j) = test_loglik{k}(:,j) - (max(test_loglik{k}(:,j)) - 700);
%         elseif min(test_loglik{k}(:,j)) < -700 &&...
%                 (max(test_loglik{k}(:,j)) - min(test_loglik{k}(:,j))) < 1400
%             test_loglik{k}(:,j) = test_loglik{k}(:,j) - (min(test_loglik{k}(:,j)) + 700);
%         end
%         lik{k}(:,j) = exp(test_loglik{k}(:,j));
%     end
% end
% norm_lik = lik;
% for k = 1:nex
%     norm_lik{k} = mk_stochastic(lik{k}')';
% end