function I = svm_hmm_classifier(traindata,trainGID,testdata,testGID)
O = 42;          %Number of coefficients in a vector
nex = length(traindata);        %Number of sequences
Q = 20;          %Number of states
class_num = length(unique(trainGID));

for i = 1:class_num
    data = traindata(trainGID == i);
    
    % initial guess of parameters
    prior0 = normalise(rand(Q,1));
    transmat0 = mk_stochastic(rand(Q,Q));
    
    
    [LL{i}, prior{i}, transmat{i},prob_states{i},svmmodel{i}] = ...
        svm_hmm_em(data, prior0, transmat0, 'max_iter', 100);
    LL{i}
    
    loglik{i} = svmhmm_logprob(data, prior{i}, transmat{i},svmmodel{i},prob_states{i})
end

%% get the loglik with test data
nex = length(testdata); 
class_num =length(unique(testGID));
test_loglik = zeros(nex,class_num);

for i = 1:nex
    for j = 1:class_num
        data = testdata{i};
        fprintf ('the %d samples/%d class--hmm recognition for integral descriptor...%2.2f%%\n',i,j,(class_num*(i-1)+j)*100/(nex*class_num));
        test_loglik(i,j) = svmhmm_logprob(data, prior{j}, transmat{j},svmmodel{j},prob_states{j});
    end
end
[~,I]=max(test_loglik,[],2); % sum up the recognition accurate ratio

for i = 1:class_num
    for j = 1:class_num
        confusion_matrix(i,j) = length(find(testGID == i & I == j));
    end
end
recog_ratio_interg{1,1} = trace(confusion_matrix)/sum(confusion_matrix(:))
confusion_matrix_interg{1,1} = confusion_matrix;
