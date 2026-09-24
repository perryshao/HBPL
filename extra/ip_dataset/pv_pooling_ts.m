function [beta] = pv_pooling_ts(feaSet, pyramid)
% ================================================
%
% Usage:
% Compute the linear spatial pyramid feature
%
% Inputss:
% feaSet        local feature array extracted from the
%               temporal sequences, column-wise
% pyramid       -defines structure of pyramid
%
% Output:
% beta          -multiscale max pooling feature
%
% Written by Jianchao Yang @ NEC Research Lab America (Cupertino)
% Mentor: Kai Yu
% July 2008
%
% Revised May. 2010
% ===============================================

dSize = size(feaSet, 1);
nSmp = size(feaSet, 2);

% compute the local feature for each local feature
pv_codes = feaSet;

% spatial levels
pLevels = length(pyramid);
% total spatial bins
tBins = sum(pyramid);

beta = zeros(dSize, tBins);
bId = 0;

for iter1 = 1:pLevels,
    Unit = nSmp / pyramid(iter1);
    % find to which spatial bin each local descriptor belongs
    idxBin = ceil((1:nSmp) / Unit);

    for iter2 = 1:pyramid(iter1),
        bId = bId + 1;
        sidxBin = find(idxBin == iter2);
        if isempty(sidxBin),
            continue;
        end

        % average pooling for occlusion
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        RefeatSet = feaSet(:, sidxBin);
        RefeatSet(:, isnan(RefeatSet(end, :))) = []; % for occlusion
        if isempty(RefeatSet)
            beta(:, bId) = zeros(dSize, 1);
        else
            %              beta(:, bId) = max(RefeatSet,[],2); % max pooling
            %             beta(:, bId) = mean(RefeatSet,2); % average pooling
            beta(:, bId) = sum(RefeatSet, 2); % sum pooling
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % average pooling
        %         beta(:, bId) = vl_fisher(feaSet(:,sidxBin), means, covariances, priors,normalizeF);
        % max pooling
        %         beta(:, bId) = max(fv_codes(:,sidxBin),[],2);
    end
end

if bId ~= tBins,
    error('Index number error!');
end

beta = beta(:);
% beta = beta./sqrt(sum(beta.^2));
beta = beta ./ sum(beta);
% beta(isnan(beta)) = 0;% avoid NaN
