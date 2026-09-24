function theta = trainBinRegression_norm1(X, trainGID, lambda, jointNum, modalityNum)

% Labels and training data
numTrain = length(trainGID);
classNum = length(unique(trainGID));
Y = zeros(numTrain, classNum);
for i = 1:classNum
    Y(trainGID == i, i) = 1;
end

%% =========== Regularized Multiple Binary Logistic Regression ============

% % Set Options
% options = optimset('GradObj', 'on', 'MaxIter', 400);
% preTheta = 0;
% D = size(X,1);
% initialTheta = zeros(D, classNum);
% % Optimize
% [theta, J, exit_flag] = ...
%     fminunc(@(t)(costFunctionReg(t, X, Y, lambda, classNum,jointNum, modulaNum,preTheta)), initialTheta, options);

% due to memory limitation, we train the regression model with a set of batch training.
D = size(X, 1);
N = size(X, 2);
J = D / jointNum;
ntotalbh = 3;
% partGroup = [20 0 0];
partGroup = [5 10 19];
partNum = length(partGroup);
numClusters1 = 32; numClusters2 = 32; DimFeat1 = 4; DimFeat2 = 3;  % for fisher vector
M(1:modalityNum) = numClusters1 * 2 * (DimFeat1 + DimFeat2) * sum(2.^(0:ntotalbh)); % for single modality
% shuffle the training data before minibatch training
shuffleIndx = randperm(N);
Y = Y(shuffleIndx, :);
X = X(:, shuffleIndx);
batchTimes = 1;
iterNum = 40;
batchsize = floor(N / batchTimes);
preTheta = cell(1, partNum);
for m = 1:partNum
    preTheta{m} = zeros(J * classNum * partGroup(m), 1);
end
initialTheta = zeros(D, classNum); % vec(W)
%% pretrain
% partGroup = [0 5 10 19];
% preTrainTheta = zeros(D,classNum);
% for  g = 2:length(partGroup)
%     for iter = 1:iterNum
%         partIndx = sum(partGroup(1:g-1))*J+1:sum(partGroup(1:g))*J;
%         Xbatch = X(partIndx,:);
%         Ybatch = Y;
%         fprintf('PartGroup %d Iteration %d\n',g-1, iter)
%         [preTinitialTheta((partIndx(1)-1)*classNum+1:partIndx(end)*classNum,:), ~, ~] = minimize(preTinitialTheta((partIndx(1)-1)*classNum+1:partIndx(end)*classNum,:),...
%                                                                                                                                       'costFuncRegMultPartGpPretr', 50, Xbatch, Ybatch, lambda,classNum,partGroup(g));
%     end
%         preTrainTheta(partIndx,:) = reshape(preTinitialTheta((partIndx(1)-1)*classNum+1:partIndx(end)*classNum,:), length(partIndx), classNum);
% end
%
% preTinitialTheta = reshape(preTrainTheta, D*classNum,1);
% clear preTrainTheta;
% save preTinitialTheta preTinitialTheta

%% refine the training
% load preTinitialTheta;
% initialTheta = preTinitialTheta;
reltol = 1e-3;
quiet = false;
eta = 1e-3;
pcgmaxi = 5000;
% rel_tol = 0.01;     % relative target duality gap

for iter = 1:iterNum
    for batchtimes = 1:batchTimes
        Xbatch = X(:, (batchtimes - 1) * batchsize + 1:batchtimes * batchsize);
        Ybatch = Y((batchtimes - 1) * batchsize + 1:batchtimes * batchsize, :);
        fprintf('Iteration %d Batch times %d\n', iter, batchtimes)
        % for multiple modality
        %         [initialTheta, J, c] = minimize(initialTheta, 'costFunctionReg', 50, Xbatch, Ybatch, lambda,classNum,jointNum, modalityNum,preTinitialTheta);
        % for single modality
        %         [initialTheta, J, c] = minimize(initialTheta, 'costFuncRegMultPart', 50, Xbatch, Ybatch, lambda,classNum,jointNum,preTinitialTheta);
        initialTheta = l1_ls_multiclass(Xbatch', Ybatch, lambda(2), reltol, quiet, eta, pcgmaxi, initialTheta);
        save initialTheta initialTheta;
    end
end
theta = initialTheta;
