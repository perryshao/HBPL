function [testdata,sum_FvSPM_time] = GeneFisherCodeJointPyramidForTest(TSSMSAMPLES_HOG,jointNum, ntotalbh,pcaFlag,cvtime)

%% collect the visual words

samples_t = size(TSSMSAMPLES_HOG,2);

% feature pooling parameters
pyramid = 2.^(0:ntotalbh);                % spatial block number on each level of the pyramid

%%load trained parameters of PCA and GMM
% load modelForTest;
% covariances = modelForTest{cvtime}.covariances;
% means = modelForTest{cvtime}.means;
% priors = modelForTest{cvtime}.priors;
% PcaM = modelForTest{cvtime}.PcaM;

load CSmodelForTest10;
covariances = modelForTest.covariances;
means = modelForTest.means;
priors = modelForTest.priors;
PcaM = modelForTest.PcaM;

Length_fisherV = size(covariances,1)*size(covariances,2)*2;
jointCodeLength = Length_fisherV*sum(pyramid);
% jointCodeLength = Length_fisherV;
%% calculate the sparse coding feature

disp('==================================================');
fprintf('Calculating the fisher vector...\n');
disp('==================================================');
testdata = zeros(jointCodeLength*jointNum,samples_t);
tic;
for iter2 = 1:samples_t, 
    fprintf ('computing and pooling Fisher Vectors for test data %d...\n',iter2);
    featsLength = size(TSSMSAMPLES_HOG{1,iter2},1);
    frameLength = floor(featsLength/jointNum);
    for n = 1:jointNum
        feats = TSSMSAMPLES_HOG{1,iter2}((n-1)*frameLength+1:n*frameLength,:);
%         feats(isnan(feats(:,end)),:) = [];% for occlusion 
        if pcaFlag
            feats = feats*PcaM;% dimension reduction of pca;
%             feats= feats./sqrt(repmat(latent(1:size(PcaM,2)),1,frameLength))'; % whiten the pca
        end
%         testdata((n-1)*jointCodeLength+1:n*jointCodeLength, iter2) = vl_fisher(feats', means, covariances, priors,'Improved');
       testdata((n-1)*jointCodeLength+1:n*jointCodeLength, iter2) = fv_pooling_ts(feats', means, covariances, priors,'Improved',pyramid);
    end
end
sum_FvSPM_time = toc;



