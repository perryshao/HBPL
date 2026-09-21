function predictLabel = predictBinRegression(theta, testGID, batchsize)
%PREDICTBINREGRESSION  Classify NTU RGB+D test samples with the learned weights.
%
%   predictLabel = PREDICTBINREGRESSION(theta, testGID, batchsize)
%
%   Implements Eq. (14) of the TCSVT paper: each sample takes the class whose
%   weight vector gives the largest response, argmax_c <u_i, w_c>. Test
%   features are streamed from the numbered chunks testdata1.mat,
%   testdata2.mat, ... written by GENEFISHERCODEJOINTPYRAMID.
%
%   INPUTS
%     theta       D x C    weight matrix from TRAINBINREGRESSION_SHUFFLEBATCH
%     testGID     N x 1    test labels; only its length is used here
%     batchsize   scalar   samples per chunk, must match the training run
%
%   OUTPUT
%     predictLabel  N x 1  predicted class index per test sample
%
%   The chunk folder is resolved by HBPLDATADIR, so no absolute path is baked
%   in. Set HBPL_BATCH_DIR if the chunks live outside the repository.
%
%   See also TRAINBINREGRESSION_SHUFFLEBATCH, HBPLDATADIR.

dataFolder = hbplDataDir('batches');

N            = length(testGID);
batchTimes   = floor(N / batchsize);
predictLabel = zeros(N, 1);

for batchtimes = 1:batchTimes
    Xbatch = loadBatch(dataFolder, 'testdata', batchtimes);
    rows   = (batchtimes-1)*batchsize + 1 : batchtimes*batchsize;
    fprintf('Testing Batch times %d\n', batchtimes);
    [~, predictLabel(rows)] = max(Xbatch' * theta, [], 2);
end

% Trailing partial chunk. Guarded, so a test set smaller than one batch -- where
% the loop above never runs -- still works; the original indexed an undefined
% loop variable in that case.
if batchTimes*batchsize < N
    last   = batchTimes + 1;
    Xbatch = loadBatch(dataFolder, 'testdata', last);
    fprintf('Testing Batch times %d \n', last);
    [~, predictLabel(batchTimes*batchsize+1:end)] = max(Xbatch' * theta, [], 2);
end
end


function M = loadBatch(folder, prefix, k)
%LOADBATCH  Read chunk <prefix><k>.mat, whose single variable is named the same.
%
%   The original did this with eval(['load ' ...]) followed by
%   eval(['Xbatch= ' ...]). Loading into a struct is equivalent and lets
%   MATLAB -- and any reader -- see what is going on.

name = sprintf('%s%d', prefix, k);
S    = load(fullfile(folder, name));
if ~isfield(S, name)
    error('predictBinRegression:badChunk', ...
          'Expected %s.mat to contain a variable named "%s"; found: %s.', ...
          name, name, strjoin(fieldnames(S)', ', '));
end
M = S.(name);
end
