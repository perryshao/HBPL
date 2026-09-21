function theta = trainBinRegression(X, trainGID, lambda, jointNum, modalityNum) %#ok<INUSD>
%TRAINBINREGRESSION  Fit the HBPL weight matrix by multi-class regression.
%
%   theta = TRAINBINREGRESSION(X, trainGID, lambda, jointNum, modalityNum)
%
%   Minimises Eq. (13) of the TCSVT paper with L-BFGS (see MINIMIZE), using
%   the hierarchical mixed norm supplied by COSTFUNCREGMULTPARTGP_V2. The
%   whole training set is used as one batch; NTU RGB+D is too large for that
%   and uses TRAINBINREGRESSION_SHUFFLEBATCH instead.
%
%   INPUTS
%     X            D x N    Fisher-vector action representations, one per column
%     trainGID     N x 1    class labels, 1..C
%     lambda       1 x 3    [multi-task, hierarchical, proximal] weights
%     jointNum     scalar   number of body-parts (34 = 5+10+19 for MSR-Action3D)
%     modalityNum  scalar   unused; kept so the call sites of the original
%                           multi-modality experiments still work
%
%   OUTPUT
%     theta        D x C    learned weight matrix W
%
%   To reproduce the Table II ablations, swap the objective name below for
%   costFuncRegMultPartGp_v1_212 (l_{2,1}) or _v1_422 (l_{4,2}).
%
%   REPRODUCIBILITY.  Training samples are shuffled with RANDPERM, so runs
%   differ slightly. Call rng(seed) beforehand to pin a run.
%
%   SIDE EFFECT.  A checkpoint `initialTheta.mat` is written to the current
%   folder after every pass so a long run can be resumed.
%
%   See also COSTFUNCREGMULTPARTGP_V2, HBPLCOST, MINIMIZE, PREDICTBINREGRESSION.

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

initialTheta     = zeros(D*classNum, 1);   % vec(W)
preTinitialTheta = zeros(D*classNum, 1);   % proximal target; inactive, lambda(3)=0

for iter = 1:iterNum
    for batchtimes = 1:batchTimes
        cols   = (batchtimes-1)*batchsize + 1 : batchtimes*batchsize;
        Xbatch = X(:, cols);
        Ybatch = Y(cols, :);

        fprintf('Iteration %d Batch times %d\n', iter, batchtimes);

        % 50 = max line searches per call. MINIMIZE takes the objective by name.
        initialTheta = minimize(initialTheta, 'costFuncRegMultPartGp_v2', 50, ...
                                Xbatch, Ybatch, lambda, classNum, jointNum, ...
                                preTinitialTheta);

        save initialTheta initialTheta;     % checkpoint
    end
end

theta = reshape(initialTheta, D, classNum);
