function [trainGID, testGID] = GeneFisherCodeJointPyramid(jointNum, ntotalbh, numClusters, trainGID, testGID, batchsize, pcaFlag)
% GENEFISHERCODEJOINTPYRAMID  Fisher-vector encoding with a temporal pyramid.
%
%   [trainGID, testGID] = GENEFISHERCODEJOINTPYRAMID(jointNum, ntotalbh, ...
%                             numClusters, trainGID, testGID, batchsize, pcaFlag)
%
%   Implements Section III-C of the TCSVT paper. A GMM with `numClusters`
%   components is fitted to HRRV descriptors sampled across the training set,
%   every action is then encoded as an improved Fisher vector per body-part,
%   sum-pooled over a temporal pyramid of `ntotalbh` scales, and the per-part
%   codes are concatenated into the hierarchical representation u of Eq. (8).
%
%   NTU RGB+D does not fit in memory, so the encoded matrix is written out in
%   chunks of `batchsize` columns: traindata1.mat, traindata2.mat, ... and
%   likewise testdata<k>.mat. Each file holds one variable named after itself,
%   which is what TRAINBINREGRESSION_SHUFFLEBATCH and PREDICTBINREGRESSION
%   expect. The destination comes from HBPLDATADIR, so no absolute path is
%   baked in; set HBPL_BATCH_DIR to place the chunks elsewhere.
%
%   INPUTS
%     jointNum     scalar  number of body-parts (68 for NTU)
%     ntotalbh     scalar  temporal pyramid depth; scales are 2.^(0:ntotalbh)
%     numClusters  scalar  GMM components (32 in the paper)
%     trainGID     N x 1   training labels, returned unchanged
%     testGID      M x 1   test labels, returned unchanged
%     batchsize    scalar  columns per chunk (256 in the paper)
%     pcaFlag      logical whiten descriptors with PCA before the GMM
%
%   OUTPUTS
%     trainGID, testGID    passed through, so the caller can keep one
%                          assignment even when shuffling is enabled
%
%   REQUIRES  vl_gmm and vl_fisher from VLFeat; run HBPLSETUP first.
%
%   SIDE EFFECT  writes modelForTest.mat (GMM parameters plus the PCA basis)
%   to the current folder; GENEFISHERCODEJOINTPYRAMIDFORTEST reloads it.
%
%   See also FV_POOLING_TS, RAND_SAMPLING_TS, HBPLDATADIR, HBPLSETUP.

dataFolder = hbplDataDir('batches');

% ------------------------------------------------- codebook (GMM) learning
S = load('RRV_DB');
DB_DESCRIPTORS = S.RRV_DB;
clear S

nsmp    = 50000;                     % local descriptors used to fit the GMM
pyramid = 2.^(0:ntotalbh);           % segments per temporal pyramid level

% Draw descriptors until nsmp non-zero ones have accumulated. All-zero rows
% occur for parts that do not move in a clip and would break the GMM fit.
currentX  = {};
lastNsmp  = 0;
while lastNsmp < nsmp
    chunk = rand_sampling_ts(DB_DESCRIPTORS, nsmp);
    chunk(:, ~any(chunk, 1)) = [];
    currentX{end + 1} = chunk;                    %#ok<AGROW>
    lastNsmp = lastNsmp + size(chunk, 2);
end
X = [currentX{:}];
clear currentX chunk

if pcaFlag
    [coeff, ~, latent] = pca(X');
    PcaM = coeff(:, cumsum(latent) / sum(latent) < 0.98);
    X    = PcaM' * X;
    X    = X ./ sqrt(repmat(latent(1:size(PcaM, 2)), 1, lastNsmp));   % PCA whitening
else
    PcaM = zeros(3, 3);
end

[means, covariances, priors] = vl_gmm(X, numClusters);
clear X

modelForTest = struct('covariances', covariances, 'means', means, ...
                      'priors', priors, 'PcaM', PcaM);
save modelForTest modelForTest;
clear modelForTest

% Fisher vector length: 2 * D * K, times the number of pyramid segments.
codeLength = size(covariances, 1) * size(covariances, 2) * 2 * sum(pyramid);

fvOpts = struct('jointNum', jointNum, 'codeLength', codeLength, ...
                'pcaFlag', pcaFlag, 'PcaM', PcaM, 'means', means, ...
                'covariances', covariances, 'priors', priors, ...
                'pyramid', pyramid);

disp('==================================================');
fprintf('Calculating the fisher vector...\n');
disp('==================================================');

encodeToChunks(DB_DESCRIPTORS, 'traindata', 'training', dataFolder, batchsize, fvOpts);
clear DB_DESCRIPTORS

S = load('RRV_SAMPLES');
SAMPLES_DESCRIPTORS = S.RRV_SAMPLES;
clear S
encodeToChunks(SAMPLES_DESCRIPTORS, 'testdata', 'testing', dataFolder, batchsize, fvOpts);
end

% --------------------------------------------------------------------------
function encodeToChunks(descriptors, prefix, label, dataFolder, batchsize, o)
% ENCODETOCHUNKS  Encode every action and write fixed-size chunks to disk.
%
%   The original spelled this loop out four times (train/test x full/partial
%   chunk) and assembled the variable names with eval. One loop with a
%   dynamic struct field does the same thing and is checkable.

nSamples   = size(descriptors, 2);
batchTimes = floor(nSamples / batchsize);

for k = 1:batchTimes + 1
    first = (k - 1) * batchsize + 1;
    last  = min(k * batchsize, nSamples);
    if first > last
        break                       % exact multiple: no trailing partial chunk
    end

    block = zeros(o.codeLength * o.jointNum, last - first + 1);
    for col = 1:(last - first + 1)
        idx = first + col - 1;
        fprintf('computing and pooling Fisher Vectors for %s data %d...\n', label, idx);
        block(:, col) = hbplFisherEncodeAction(descriptors{1, idx}, o);
    end

    % Each chunk file holds a single variable named like the file itself.
    name = sprintf('%s%d', prefix, k);
    payload.(name) = block;                                     %#ok<STRNU>
    save(fullfile(dataFolder, name), '-struct', 'payload', name, '-v7.3');
    clear payload block
end
end
