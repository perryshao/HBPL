function [traindata, testdata, sum_FvSPM_time] = GeneFisherCodeJointPyramid(DB_DESCRIPTORS, SAMPLES_DESCRIPTORS, jointNum, ntotalbh, numClusters, pcaFlag)

%% collect the visual words
samples_r = size(DB_DESCRIPTORS, 2);
samples_t = size(SAMPLES_DESCRIPTORS, 2);

% parameters for GMM learning
nsmp = 10000;

% feature pooling parameters
pyramid = 2.^(0:ntotalbh);                % spatial block number on each level of the pyramid

%% learning sparse coding dictionary
currentTime = 0;
lastNsmp = 0;
% to avoid all(0) feature vector
while lastNsmp < nsmp
    currentTime = currentTime + 1;
    % randomly selecting local training features
    currentX{currentTime} = rand_sampling_ts(DB_DESCRIPTORS, nsmp);
    currentNsmp = size(currentX{currentTime}, 2); % remeausre the nsmp after sampling
    emptyIndx = zeros(1, currentNsmp);
    for i = 1:currentNsmp
        if ~any(currentX{currentTime}(:, i))
            emptyIndx(i) = i;
        end
    end
    emptyIndx(emptyIndx == 0) = [];
    currentX{currentTime}(:, emptyIndx) = [];
    lastNsmp = lastNsmp + size(currentX{currentTime}, 2); % remeausre the nsmp after sampling
end
X = [];
for i = 1:currentTime
    % X = [X currentX{currentTime}]; %big debug found by perry on 1/6/16
    X = [X currentX{i}];
end
clear currentX emptyIndx;

% X = rand_sampling_ts(DB_DESCRIPTORS, nsmp);

% do pca on X first;
if pcaFlag
    [coeff, ~, latent, ~, ~] = pca(X');
    PcaM = coeff(:, cumsum(latent) / sum(latent) < 0.99);
    X = PcaM' * X;
    X = X ./ sqrt(repmat(latent(1:size(PcaM, 2)), 1, lastNsmp)); % whiten the pca
else
    PcaM = zeros(3, 3);
end

% VLFeat 0.9.20 writes the fifth output slot even when fewer are requested.
% Request every output to avoid an out-of-bounds write in its legacy MEX gateway.
[means, covariances, priors, ~, ~] = vl_gmm(X, numClusters);
clear X;

%% save key parameters for fisher vector encoding.
modelForTest.covariances = covariances;
modelForTest.means = means;
modelForTest.priors = priors;
modelForTest.PcaM = PcaM;
save modelForTest modelForTest;
clear modelForTest;
Length_fisherV = size(covariances, 1) * size(covariances, 2) * 2;
jointCodeLength = Length_fisherV * sum(pyramid);
% jointCodeLength = Length_fisherV;
%% calculate the sparse coding feature

disp('==================================================');
fprintf('Calculating the fisher vector...\n');
disp('==================================================');

traindata = zeros(jointCodeLength * jointNum, samples_r);
for iter1 = 1:samples_r,
    fprintf ('computing and pooling Fisher Vectors for training data %d...\n', iter1);
    featsLength = size(DB_DESCRIPTORS{1, iter1}, 1);
    frameLength = floor(featsLength / jointNum);
    for m = 1:jointNum
        feats = DB_DESCRIPTORS{1, iter1}((m - 1) * frameLength + 1:m * frameLength, :);
        if pcaFlag
            feats = feats * PcaM; % dimension reduction of pca;
            %             feats= feats./sqrt(repmat(latent(1:size(PcaM,2)),1,frameLength))'; % whiten the pca
        end
        %         traindata((m-1)*jointCodeLength+1:m*jointCodeLength, iter1) = vl_fisher(feats', means, covariances, priors,'Improved');
        traindata((m - 1) * jointCodeLength + 1:m * jointCodeLength, iter1) = fv_pooling_ts(feats', means, covariances, priors, 'Improved', pyramid);
    end
end
save traindata traindata; clear traindata;
clear DB_DESCRIPTORS;
testdata = zeros(jointCodeLength * jointNum, samples_t);
tic;
for iter2 = 1:samples_t,
    fprintf ('computing and pooling Fisher Vectors for test data %d...\n', iter2);
    featsLength = size(SAMPLES_DESCRIPTORS{1, iter2}, 1);
    frameLength = floor(featsLength / jointNum);
    for n = 1:jointNum
        feats = SAMPLES_DESCRIPTORS{1, iter2}((n - 1) * frameLength + 1:n * frameLength, :);
        if pcaFlag
            feats = feats * PcaM; % dimension reduction of pca;
            %             feats= feats./sqrt(repmat(latent(1:size(PcaM,2)),1,frameLength))'; % whiten the pca
        end
        %         testdata((n-1)*jointCodeLength+1:n*jointCodeLength, iter2) = vl_fisher(feats', means, covariances, priors,'Improved');
        testdata((n - 1) * jointCodeLength + 1:n * jointCodeLength, iter2) = fv_pooling_ts(feats', means, covariances, priors, 'Improved', pyramid);
    end
end
sum_FvSPM_time = toc;
load traindata.mat;
