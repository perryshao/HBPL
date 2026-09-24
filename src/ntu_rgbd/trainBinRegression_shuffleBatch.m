function theta = trainBinRegression_shuffleBatch(trainGID, lambda, jointNum, modalityNum, batchsize) %#ok<INUSL>
% TRAINBINREGRESSION_SHUFFLEBATCH  Fit HBPL weights on NTU RGB+D by mini-batch SGD.
%
%   theta = TRAINBINREGRESSION_SHUFFLEBATCH(trainGID, lambda, jointNum, ...
%                                           modalityNum, batchsize)
%
%   NTU RGB+D has 56,880 samples, so the Fisher-vector matrix does not fit in
%   memory. GENEFISHERCODEJOINTPYRAMID therefore writes it out as numbered
%   chunks traindata1.mat, traindata2.mat, ... and this function streams them:
%   each epoch visits every chunk once, in a fresh random order, running a
%   single nonlinear conjugate gradient line search per chunk.
%
%   INPUTS
%     trainGID     N x 1    class labels, 1..C
%     lambda       1 x 3    [multi-task, hierarchical, proximal] weights
%     jointNum     scalar   number of body-parts (68 = 10+20+38 for NTU)
%     modalityNum  scalar   unused; kept for call-site compatibility
%     batchsize    scalar   samples per chunk, must match the value passed to
%                           GENEFISHERCODEJOINTPYRAMID (256 in the paper)
%
%   OUTPUT
%     theta        D x C    learned weight matrix W
%
%   The chunk folder is resolved by HBPLDATADIR, so no absolute path is baked
%   in. Set HBPL_BATCH_DIR if the chunks live outside the repository.
%
%   To reproduce the Table II ablations, swap the objective name below for
%   costFuncRegMultPartGp_v1_212 (l_{2,1}) or _v1_422 (l_{4,2}).
%
%   REPRODUCIBILITY.  Chunk order is randomised per epoch with RANDPERM.
%   Call rng(seed) beforehand to pin a run.
%
%   SIDE EFFECTS.  Writes initialTheta.mat and theta.mat (both -v7.3) to the
%   current folder.
%
%   See also COSTFUNCREGMULTPARTGP_V2, HBPLCOST, MINIMIZE, HBPLDATADIR.

dataFolder = hbplDataDir('batches');

numTrain = length(trainGID);
classNum = length(unique(trainGID));

% One-hot targets, N x C.
Y = zeros(numTrain, classNum);
for i = 1:classNum
    Y(trainGID == i, i) = 1;
end

% Chunks 1..batchTimes hold `batchsize` samples each; chunk batchTimes+1 holds
% the remainder.
batchTimes = floor(numTrain / batchsize);

D = size(loadBatch(dataFolder, 'traindata', 1), 1);

initialTheta     = zeros(D * classNum, 1);   % vec(W)
preTinitialTheta = zeros(D * classNum, 1);   % proximal target; inactive, lambda(3)=0

iterNum = 40;
for iter = 1:iterNum
    for batchtimes = randperm(batchTimes)
        Xbatch = loadBatch(dataFolder, 'traindata', batchtimes);
        rows   = (batchtimes - 1) * batchsize + 1:batchtimes * batchsize;
        fprintf('Iteration %d Batch %d\n', iter, batchtimes);

        % One line search per chunk: this is the SGD step of the paper.
        initialTheta = minimize(initialTheta, 'costFuncRegMultPartGp_v2', 1, ...
                                Xbatch, Y(rows, :), lambda, classNum, jointNum, ...
                                preTinitialTheta);
    end

    % The encoder writes a trailing chunk only when samples remain.
    if batchTimes * batchsize < numTrain
        last = batchTimes + 1;
        Xbatch = loadBatch(dataFolder, 'traindata', last);
        fprintf('Iteration %d Batch %d \n', iter, last);
        initialTheta = minimize(initialTheta, 'costFuncRegMultPartGp_v2', 1, ...
                                Xbatch, Y(batchTimes * batchsize + 1:end, :), lambda, ...
                                classNum, jointNum, preTinitialTheta);
    end
end

save initialTheta initialTheta -v7.3;
theta = reshape(initialTheta, D, classNum);
save theta theta -v7.3;
end

function M = loadBatch(folder, prefix, k)
% LOADBATCH  Read chunk <prefix><k>.mat, whose single variable is named the same.
%
%   The original code did this with eval(['load ' ...]) followed by
%   eval(['Xbatch= ' ...]). Loading into a struct is equivalent and lets
%   MATLAB (and any reader) see what is going on.

name = sprintf('%s%d', prefix, k);
S    = load(fullfile(folder, name));
if ~isfield(S, name)
    error('trainBinRegression_shuffleBatch:badChunk', ...
          'Expected %s.mat to contain a variable named "%s"; found: %s.', ...
          name, name, strjoin(fieldnames(S)', ', '));
end
M = S.(name);
end
