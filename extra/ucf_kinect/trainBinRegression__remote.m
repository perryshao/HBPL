function theta = trainBinRegression(X, trainGID, lambda, jointNum, modalityNum)

% Labels and training data
numTrain = length(trainGID);
classNum = length(unique(trainGID));
Y = zeros(numTrain, classNum);
for i = 1:classNum
    Y(trainGID == i, i) = 1;
end

%% =========== Regularized Multiple Binary Logistic Regression ============

% due to memory limitation, we train the regression model with a set of batch training.
D = size(X, 1);
N = size(X, 2);
J = D / jointNum;
ntotalbh = 3;
partGroup = [15 0 0];
% partGroup = [5 10 14];
partNum = length(partGroup);
% nBases1 = 1024;nBases2 = 1024; %nBases3 = 128;
numClusters1 = 32; numClusters2 = 32; DimFeat1 = 4; DimFeat2 = 3;  % for fisher vector
M(1:modalityNum) = numClusters1 * 2 * (DimFeat1 + DimFeat2) * sum(2.^(0:ntotalbh)); % for single modality
% shuffle the training data before minibatch training
shuffleIndx = randperm(N);
Y = Y(shuffleIndx, :);
X = X(:, shuffleIndx);
batchTimes = 1;
iterNum = 10;
batchsize = floor(N / batchTimes);
preTheta = cell(1, partNum);
for m = 1:partNum
    preTheta{m} = zeros(J * classNum * partGroup(m), 1);
end
initialTheta = zeros(D * classNum, 1); % vec(W)
preTinitialTheta = zeros(D * classNum, 1);
%% pretrain
% mX = X;
% tempPreTheta = [];
% PartGroupDim(1:modalityNum+1) = [0 nBases1*sum(2.^(0:ntotalbh))*jointNum D];% if dimensions of each modality is not equal
% % re-arrange the X in modality
% for j = 1:jointNum
%             tempIndexM = 0;
%             for m = 1:modalityNum
%                 mX(ModalityDim(m)+(j-1)*M(m)+1:ModalityDim(m)+j*M(m),:) = X((j-1)*J+tempIndexM+1:(j-1)*J+tempIndexM+M(m),:);
%                 tempIndexM = tempIndexM+M(m);
%             end
% end
%  for m = 1:modalityNum
%      for iter = 1:iterNum
%          for batchtimes = 1:batchTimes
%              Xbatch = mX(ModalityDim(m)+1:ModalityDim(m+1),(batchtimes-1)*batchsize+1:batchtimes*batchsize);
%              Ybatch = Y((batchtimes-1)*batchsize+1:batchtimes*batchsize,:);
%              fprintf('Modality %d Iteration %d Batch times %d\n',m, iter, batchtimes)
%              [preTheta{m}, ~, ~] = minimize(preTheta{m}, 'costFunctionRegPretrain', 50, Xbatch, Ybatch, lambda,classNum,jointNum);
%          end
%      end
%      tempPreTheta = [tempPreTheta;preTheta{m}];
% end
% mInitialTheta = tempPreTheta;
% save mInitialTheta mInitialTheta;
% clear tempPreTheta preTheta;
% % re-arrange the initialTheta in modality
% for j = 1:jointNum
%             tempIndexM = 0;
%             for m = 1:modalityNum
%                 preTinitialTheta((j-1)*J+tempIndexM+1:(j-1)*J+tempIndexM+M(m),:) = mInitialTheta(ModalityDim(m)+(j-1)*M(m)+1:ModalityDim(m)+j*M(m),:);
%                 tempIndexM = tempIndexM+M(m);
%             end
% end
% clear mInitialTheta;
% save preTinitialTheta preTinitialTheta
%% pretrain each layer
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
for iter = 1:iterNum
    for batchtimes = 1:batchTimes
        Xbatch = X(:, (batchtimes - 1) * batchsize + 1:batchtimes * batchsize);
        Ybatch = Y((batchtimes - 1) * batchsize + 1:batchtimes * batchsize, :);
        fprintf('Iteration %d Batch times %d\n', iter, batchtimes)
        % for multiple modality
        %         [initialTheta, J, c] = minimize(initialTheta, 'costFunctionReg', 50, Xbatch, Ybatch, lambda,classNum,jointNum, modalityNum,preTinitialTheta);
        % for single modality
        %         [initialTheta, J, c] = minimize(initialTheta, 'costFuncRegMultPart', 50, Xbatch, Ybatch, lambda,classNum,jointNum,preTinitialTheta);
        [initialTheta, J, c] = minimize(initialTheta, 'costFuncRegMultPartGp', 50, Xbatch, Ybatch, lambda, classNum, jointNum, preTinitialTheta);
        save initialTheta initialTheta;
        save iternum iter;
    end
    %     Xbatch = X(:,batchtimes*batchsize+1:end);
    %     Ybatch = Y(batchtimes*batchsize+1:end,:);
    %     fprintf('Iteration %d Batch times %d \n',iter,batchtimes+1)
    %     [initialTheta, J, c] = minimize(initialTheta, 'costFuncRegMex', 50, Xbatch, Ybatch, lambda,classNum,jointNum, modalityNum, preTheta);
end

% save initialTheta;
% preTheta = initialTheta;
% lambda = [0.5 0.5 0.5];
% [theta, J, c] = minimize(initialTheta, 'costFuncRegMex', 50, X, Y, lambda,classNum,jointNum, modulaNum, preTheta);

theta = initialTheta;
theta = reshape(theta, D, classNum);
