function [traindata,testdata,sum_ScSPM_time] = GeneScCodeJointPyramid(TSSMDB_HOG,TSSMSAMPLES_HOG,jointNum, ntotalbh,nBases,pcaFlag)

%% collect the visual words

samples_r = size(TSSMDB_HOG,2);
samples_t = size(TSSMSAMPLES_HOG,2);


% dictionary training for sparse coding
% nBases =128;
nsmp = 10000;
beta = 1e-5;                        % a small regularization for stablizing sparse coding 
num_iters = 50;


% feature pooling parameters
pyramid = 2.^(0:ntotalbh);                % spatial block number on each level of the pyramid
gamma = 0.15;
% knn = 200;
knn = 0;                          % find the k-nearest neighbors for approximate sparse coding
                                  % if set 0, use the standard sparse coding
jointCodeLength = nBases*sum(pyramid);
%% learning sparse coding dictionary
currentTime = 0;
lastNsmp = 0;
% to avoid all(0) feature vector
while lastNsmp < nsmp
    currentTime = currentTime+1;
    % randomly seleting local training features
    currentX{currentTime} = rand_sampling_ts(TSSMDB_HOG, nsmp);
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
    X = [X currentX{i}];
end
clear currentX emptyIndx;

% do pca on X first;
if pcaFlag
    [coeff, ~, latent, ~, ~] = pca(X');
    PcaM=coeff(:,cumsum(latent)/sum(latent)<0.99);
    X = PcaM'*X;
    X= X./sqrt(repmat(latent(1:size(PcaM,2)),1,lastNsmp)); % whiten the pca
end

nsmp = size(X,2); % remeausre the nsmp after sampling
batch_size = floor(nsmp/1); % batch size when learning sparse codes

% check if there exist a mat file for bases
if exist('Results\reg_sc_b1024_no.mat','file')
    load Results\reg_sc_b1024_no.mat
    clear X;
else
    [B, S, stat] = reg_sparse_coding(X, nBases, eye(nBases), beta, gamma, num_iters,batch_size);
    clear X;
end

%  [B, S, stat] = reg_sparse_coding(X, nBases, eye(nBases), beta, gamma, num_iters,batch_size);
%  clear X;

%% calculate the sparse coding feature

disp('==================================================');
fprintf('Calculating the sparse coding feature...\n');
fprintf('Regularization parameter: %f\n', gamma);
disp('==================================================');

traindata = zeros(jointCodeLength*jointNum,samples_r);
for iter1 = 1:samples_r, 
    fprintf ('computing and pooling sparce codes for training data %d...\n',iter1);
    featsLength = size(TSSMDB_HOG{1,iter1},1);
    frameLength = floor(featsLength/jointNum);
    for m = 1:jointNum
        feats = TSSMDB_HOG{1,iter1}((m-1)*frameLength+1:m*frameLength,:);
        if pcaFlag
            feats = feats*PcaM;% dimension reduction of pca;
%             feats= feats./sqrt(repmat(latent(1:size(PcaM,2)),1,frameLength))'; % whiten the pca
        end
        if knn,
            traindata((m-1)*jointCodeLength+1:m*jointCodeLength, iter1) = sc_approx_pooling_ts(feats', B, pyramid, gamma, knn);
        else
            traindata((m-1)*jointCodeLength+1:m*jointCodeLength, iter1) = sc_pooling_ts(feats', B, pyramid, gamma);
        end
    end
end
save traindata traindata;clear traindata;
clear TSSMDB_HOG;
testdata = zeros(jointCodeLength*jointNum,samples_t);
tic;
for iter2 = 1:samples_t, 
    fprintf ('computing and pooling sparce codes for test data %d...\n',iter2);
    featsLength = size(TSSMSAMPLES_HOG{1,iter2},1);
    frameLength = floor(featsLength/jointNum);
    for n = 1:jointNum
        feats = TSSMSAMPLES_HOG{1,iter2}((n-1)*frameLength+1:n*frameLength,:);
        if pcaFlag
            feats = feats*PcaM;% dimension reduction of pca;
%             feats= feats./sqrt(repmat(latent(1:size(PcaM,2)),1,frameLength))'; % whiten the pca
        end
        if knn,
            testdata((n-1)*jointCodeLength+1:n*jointCodeLength, iter2) = sc_approx_pooling_ts(feats', B, pyramid, gamma, knn);
        else
            testdata((n-1)*jointCodeLength+1:n*jointCodeLength, iter2) = sc_pooling_ts(feats', B, pyramid, gamma);
        end
    end
end
sum_ScSPM_time = toc;
load traindata.mat;



