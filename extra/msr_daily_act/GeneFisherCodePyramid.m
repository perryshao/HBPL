function [traindata,testdata,sum_FvSPM_time] = GeneFisherCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,pcaFlag)

%% collect the visual words

samples_r = size(PairDistFeats_DB,2);
samples_t = size(PairDistFeats_SAMPLES,2);


% parameters for GMM learning
nsmp = 10000;
numClusters = 100;


% feature pooling parameters
pyramid = 2.^(0:ntotalbh);                % spatial block number on each level of the pyramid

%% learning sparse coding dictionary
currentTime = 0;
lastNsmp = 0;
% to avoid all(0) feature vector
while lastNsmp < nsmp
    currentTime = currentTime+1;
    % randomly seleting local training features
    currentX{currentTime} = rand_sampling_ts(PairDistFeats_DB, nsmp);
    currentNsmp = size(currentX{currentTime},2); % remeausre the nsmp after sampling
    emptyIndx = zeros(1,currentNsmp);
    for i = 1:currentNsmp
        if ~any(currentX{currentTime}(:,i))
            emptyIndx(i) = i;
        end
    end
    emptyIndx(emptyIndx==0) =[];
    currentX{currentTime}(:,emptyIndx) =[];
    lastNsmp =lastNsmp + size(currentX{currentTime},2); % remeausre the nsmp after sampling
end
X = [];
for i = 1:currentTime
    X = [X currentX{currentTime}];
end
clear currentX emptyIndx;

% X = rand_sampling_ts(PairDistFeats_DB, nsmp);

% do pca on X first;
if pcaFlag
    [coeff, ~, latent, ~, ~] = pca(X');
    PcaM=coeff(:,cumsum(latent)/sum(latent)<0.98);
    X = PcaM'*X;
end
nsmp = size(X,2); % remeausre the nsmp after sampling

[means, covariances, priors] = vl_gmm(X, numClusters);
clear X;

Length_fisherV = size(covariances,1)*size(covariances,2)*2;
jointCodeLength = Length_fisherV*sum(pyramid);
% jointCodeLength = Length_fisherV;
%% calculate the sparse coding feature

disp('==================================================');
fprintf('Calculating the fisher vector...\n');
disp('==================================================');

traindata = zeros(jointCodeLength,samples_r);
for iter1 = 1:samples_r, 
    fprintf ('computing and pooling Fisher Vectors for training data %d...\n',iter1);
     feats = PairDistFeats_DB{1,iter1};
    if pcaFlag
        feats = feats*PcaM;% dimension reduction of pca;
    end
%     traindata(:, iter1) = vl_fisher(feats', means, covariances, priors,'Improved');
    traindata(:, iter1) = fv_pooling_ts(feats', means, covariances, priors,'Improved',pyramid);
end
save traindata traindata;clear traindata;
clear PairDistFeats_DB;
testdata = zeros(jointCodeLength,samples_t);

tic;
for iter2 = 1:samples_t, 
    fprintf ('computing and pooling Fisher Vectors for test data %d...\n',iter2);
    feats = PairDistFeats_SAMPLES{1,iter2};
    if pcaFlag
        feats = feats*PcaM;% dimension reduction of pca;
    end
%     testdata(:, iter2) = vl_fisher(feats', means, covariances, priors,'Improved');
    testdata(:, iter2) = fv_pooling_ts(feats', means, covariances, priors,'Improved',pyramid);
end
sum_FvSPM_time = toc;
load traindata.mat;



