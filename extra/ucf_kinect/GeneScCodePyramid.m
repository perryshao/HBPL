function [traindata, testdata, sum_ScSPM_time] = GeneScCodePyramid(TSSMDB_HOG, TSSMSAMPLES_HOG, ntotalbh, pcaFlag)

%% collect the visual words

samples_r = size(TSSMDB_HOG, 2);
samples_t = size(TSSMSAMPLES_HOG, 2);

% dictionary training for sparse coding
nBases = 1024;
nsmp = 10000;
beta = 1e-5;                        % a small regularization for stablizing sparse coding
num_iters = 50;

% feature pooling parameters
pyramid = 2.^(0:ntotalbh);                % spatial block number on each level of the pyramid
gamma = 0.15;
% knn = 200;
knn = 0;                          % find the k-nearest neighbors for approximate sparse coding
% if set 0, use the standard sparse coding
jointCodeLength = nBases * sum(pyramid);
%% learning sparse coding dictionary
currentTime = 0;
lastNsmp = 0;
% to avoid all(0) feature vector
while lastNsmp < nsmp
    currentTime = currentTime + 1;
    % randomly selecting local training features
    currentX{currentTime} = rand_sampling_ts(TSSMDB_HOG, nsmp);
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
    X = [X currentX{currentTime}];
end
clear currentX emptyIndx;

% do pca on X first;
if pcaFlag
    [coeff, ~, latent, ~, ~] = pca(X');
    PcaM = coeff(:, cumsum(latent) / sum(latent) < 0.99);
    X = PcaM' * X;
end

nsmp = size(X, 2); % remeausre the nsmp after sampling
batch_size = floor(nsmp / 1); % batch size when learning sparse codes

[B, S, stat] = reg_sparse_coding(X, nBases, eye(nBases), beta, gamma, num_iters, batch_size);
clear X;

%% calculate the sparse coding feature

disp('==================================================');
fprintf('Calculating the sparse coding feature...\n');
fprintf('Regularization parameter: %f\n', gamma);
disp('==================================================');

traindata = zeros(jointCodeLength, samples_r);
for iter1 = 1:samples_r,
    fprintf ('computing and pooling sparce codes for training data %d...\n', iter1);
    feats = TSSMDB_HOG{1, iter1};
    if pcaFlag
        feats = feats * PcaM; % dimension reduction of pca;
    end
    if knn,
        traindata(:, iter1) = sc_approx_pooling_ts(feats', B, pyramid, gamma, knn);
    else
        traindata(:, iter1) = sc_pooling_ts(feats', B, pyramid, gamma);
    end
end
save traindata traindata; clear traindata;
clear TSSMDB_HOG;
testdata = zeros(jointCodeLength, samples_t);
tic;
for iter2 = 1:samples_t,
    fprintf ('computing and pooling sparce codes for test data %d...\n', iter2);
    feats = TSSMSAMPLES_HOG{1, iter2};
    if pcaFlag
        feats = feats * PcaM; % dimension reduction of pca;
    end
    if knn,
        testdata(:, iter2) = sc_approx_pooling_ts(feats', B, pyramid, gamma, knn);
    else
        testdata(:, iter2) = sc_pooling_ts(feats', B, pyramid, gamma);
    end
end
sum_ScSPM_time = toc;
load traindata.mat;
