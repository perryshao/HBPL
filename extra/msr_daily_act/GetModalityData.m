function collectedData = GetModalityData(data, jointNum, modalityNum, ntotalbh)

% X = DxN matrix, J and M is the partition parameters over joints and feature modalities
D = size(data, 1); N = size(data, 2);
J = D / jointNum;
% nBases1 = 1024;nBases2 = 1024;%nBases3 = 128; % for sparse coding
numClusters1 = 32; numClusters2 = 32; DimFeat1 = 4; DimFeat2 = 3; % for fisher vector
% M(1:modalityNum) = ones(1,2).*(J/modalityNum); % if dimensions of each modality are equal.
% M(1:modalityNum) = [nBases1*sum(2.^(0:ntotalbh)) nBases2*sum(2.^(0:ntotalbh))];% if dimensions of each modality is not equal
M(1:modalityNum) = [numClusters1 * 2 * DimFeat1 * sum(2.^(0:ntotalbh)) numClusters2 * 2 * DimFeat2 * sum(2.^(0:ntotalbh))]; % if dimensions of each modality is not equal

% two modalities
% ModalityDim(1) = 0;
% ModalityDim(2) = D/modalityNum; % if dimensions of each modality are equal.

% ModalityDim(1:modalityNum) = [0 nBases1*sum(2.^(0:ntotalbh))*jointNum];% if dimensions of each modality is not equal for sparse coding
ModalityDim(1:modalityNum) = [0 numClusters1 * 2 * DimFeat1 * sum(2.^(0:ntotalbh)) * jointNum]; % if dimensions of each modality is not equal for fisher vector

collectedData = data;
for j = 1:jointNum
    tempIndexM = 0;
    for m = 1:modalityNum
        collectedData((j - 1) * J + tempIndexM + 1:(j - 1) * J + tempIndexM + M(m), :) = data(ModalityDim(m) + (j - 1) * M(m) + 1:ModalityDim(m) + j * M(m), :);
        tempIndexM = tempIndexM + M(m);
    end
end
