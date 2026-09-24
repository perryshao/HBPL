function theta = trainBinRegression(X, trainGID, lambda, jointNum, modalityNum) %#ok<INUSD>
% TRAINBINREGRESSION  Fit the HBPL weight matrix by multi-class regression.
%
%   theta = TRAINBINREGRESSION(X, trainGID, lambda, jointNum, modalityNum)
%
%   Minimises the HBPL objective with nonlinear conjugate gradient (see MINIMIZE). The whole
%   training set is used as one batch.
%
%   INPUTS
%     X            D x N    Fisher-vector action representations, one per column
%     trainGID     N x 1    class labels, 1..C
%     lambda       1 x 3    [multi-task, hierarchical, proximal] weights
%     jointNum     scalar   number of body-parts (34 = 5+10+19 for UT-Kinect)
%     modalityNum  scalar   unused; kept for call-site compatibility
%
%   OUTPUT
%     theta        D x C    learned weight matrix W
%
%   OBJECTIVE USED.  This script calls COSTFUNCREGMULTPARTGP_V1, the squared
%   l_{4,1} form *without* the outer square root, whereas MSR-Action3D and
%   NTU RGB+D call _V2, which carries the outer l_2 coupling of Eq. (13).
%   The discrepancy is preserved exactly as it was run for the paper. If you
%   switch this line to _v2 you are no longer reproducing the published
%   UT-Kinect number and the ablation has to be re-run.
%
%   REPRODUCIBILITY.  Training samples are shuffled with RANDPERM, so runs
%   differ slightly. Call rng(seed) beforehand to pin a run.
%
%   SIDE EFFECT.  A checkpoint `initialTheta.mat` is written to the current
%   folder after every pass so a long run can be resumed.
%
%   See also COSTFUNCREGMULTPARTGP_V1, HBPLCOST, MINIMIZE, PREDICTBINREGRESSION.

numTrain = length(trainGID);
classNum = length(unique(trainGID));

% One-hot targets, N x C.
Y = zeros(numTrain, classNum);
for i = 1:classNum
    Y(trainGID == i, i) = 1;
end

D = size(X, 1);
N = size(X, 2);

% Shuffle once so the batch is not ordered by class.
shuffleIndx = randperm(N);
Y = Y(shuffleIndx, :);
X = X(:, shuffleIndx);

batchTimes = 1;                 % full batch: this dataset fits in memory
iterNum    = 10;
batchsize  = floor(N / batchTimes);

initialTheta     = zeros(D * classNum, 1);   % vec(W)
preTinitialTheta = zeros(D * classNum, 1);   % proximal target; inactive, lambda(3)=0

for iter = 1:iterNum
    for batchtimes = 1:batchTimes
        cols   = (batchtimes - 1) * batchsize + 1:batchtimes * batchsize;
        Xbatch = X(:, cols);
        Ybatch = Y(cols, :);

        fprintf('Iteration %d Batch times %d\n', iter, batchtimes);

        % 50 = max line searches per call. MINIMIZE takes the objective by name.
        initialTheta = minimize(initialTheta, 'costFuncRegMultPartGp_v1', 50, ...
                                Xbatch, Ybatch, lambda, classNum, jointNum, ...
                                preTinitialTheta);

        save initialTheta initialTheta;     % checkpoint
    end
end

theta = reshape(initialTheta, D, classNum);
