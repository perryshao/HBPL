function [testdata, sum_FvSPM_time] = GeneFisherCodeJointPyramidForTest(RRV_SAMPLES, jointNum, ntotalbh, batchsize, pcaFlag, modelFile)
% GENEFISHERCODEJOINTPYRAMIDFORTEST  Encode test clips with an already-fitted GMM.
%
%   [testdata, sum_FvSPM_time] = GENEFISHERCODEJOINTPYRAMIDFORTEST( ...
%       RRV_SAMPLES, jointNum, ntotalbh, batchsize, pcaFlag, modelFile)
%
%   Same Fisher-vector encoding as GENEFISHERCODEJOINTPYRAMID, but it reuses
%   the GMM and PCA basis learned during training instead of re-fitting them.
%   Used by the noise and occlusion robustness experiments, where only the
%   test clips change.
%
%   INPUTS
%     RRV_SAMPLES  1 x M cell   HRRV descriptors of the perturbed test clips
%     jointNum     scalar       number of body-parts (68 for NTU)
%     ntotalbh     scalar       temporal pyramid depth
%     batchsize    scalar       columns per chunk; must match training
%     pcaFlag      logical      apply the stored PCA basis
%     modelFile    char         optional; which trained model to load,
%                               default 'modelForTest10'
%
%   OUTPUTS
%     testdata          the last chunk encoded, kept for the callers that
%                       inspect it; the full set is on disk as testdata<k>.mat
%     sum_FvSPM_time    seconds spent in Fisher encoding and pooling
%
%   MODEL FILE NAMING.  The suffix records which layers of the hierarchy the
%   model was trained on, by part count (Table III of the paper). For NTU
%   RGB+D, whose layers hold 10 / 20 / 38 parts:
%
%       modelForTest        all three layers, HBPL(L1+L2+L3)
%       modelForTest10      layer 1 only,     HBPL(L1)
%       modelForTest10+38   layers 1 and 3,   HBPL(L1+L3)
%
%   The default stays 'modelForTest10' because that is what the committed
%   robustness runs used. Pass modelFile explicitly for any other ablation.
%
%   See also GENEFISHERCODEJOINTPYRAMID, HBPLFISHERENCODEACTION, HBPLDATADIR.

if nargin < 6 || isempty(modelFile)
    modelFile = 'modelForTest10';
end

dataFolder = hbplDataDir('batches');
pyramid    = 2.^(0:ntotalbh);

S = load(modelFile);
modelForTest = S.modelForTest;
clear S

o = struct('jointNum', jointNum, ...
           'codeLength', size(modelForTest.covariances, 1) * ...
           size(modelForTest.covariances, 2) * 2 * sum(pyramid), ...
           'pcaFlag', pcaFlag, ...
           'PcaM', modelForTest.PcaM, ...
           'means', modelForTest.means, ...
           'covariances', modelForTest.covariances, ...
           'priors', modelForTest.priors, ...
           'pyramid', pyramid);

disp('==================================================');
fprintf('Calculating the fisher vector...\n');
disp('==================================================');

nSamples   = size(RRV_SAMPLES, 2);
batchTimes = floor(nSamples / batchsize);
testdata   = [];

tic;
for k = 1:batchTimes + 1
    first = (k - 1) * batchsize + 1;
    last  = min(k * batchsize, nSamples);
    if first > last
        break                       % exact multiple: no trailing partial chunk
    end

    testdata = zeros(o.codeLength * o.jointNum, last - first + 1);
    for col = 1:(last - first + 1)
        idx = first + col - 1;
        fprintf('computing and pooling Fisher Vectors for testing data %d...\n', idx);
        testdata(:, col) = hbplFisherEncodeAction(RRV_SAMPLES{1, idx}, o);
    end

    % Each chunk file holds a single variable named like the file itself.
    name = sprintf('testdata%d', k);
    payload.(name) = testdata;                                  %#ok<STRNU>
    save(fullfile(dataFolder, name), '-struct', 'payload', name, '-v7.3');
    clear payload
end
sum_FvSPM_time = toc;
