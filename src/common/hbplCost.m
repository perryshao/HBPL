function [f, df] = hbplCost(thetaVec, X, Y, lambda, C, numParts, partGroup, variant, priorThetaVec, groupCof)
% HBPLCOST  Objective and gradient for Hierarchical Body-Parts Learning.
%
%   [f, df] = HBPLCOST(thetaVec, X, Y, lambda, C, numParts, partGroup, variant)
%
%   Squared-error multi-class regression with a hierarchical mixed-norm
%   regularizer over body-parts, as in Eq. (13) of
%
%     Shao, Li, Guo, Zhou, Chen. "A Hierarchical Model for Human Action
%     Recognition from Body-Parts." IEEE TCSVT 29(10):2986-2998, 2019.
%
%   The objective is
%
%       f = ||X'W - Y||_F^2
%           + lambda(1) * sum_d ||W(d,:)||_2                  (multi-task l_{2,1})
%           + lambda(2) * R(W)                                (hierarchical mixed norm)
%           + lambda(3) * ||W - W_prior||_F^2                 (proximal term)
%
%   where R(W) depends on `variant` (see below). Body-parts are contiguous
%   blocks of D/numParts rows of W; `partGroup` gives how many parts belong
%   to each of the three layers, e.g. [5 10 19] for MSR-Action3D / UT-Kinect
%   and [10 20 38] for NTU RGB+D (two subjects, hence doubled).
%
%   INPUTS
%     thetaVec      D*C x 1   vec(W), column-major
%     X             D x N     feature matrix (one action sample per column)
%     Y             N x C     one-hot labels
%     lambda        1 x 3     [multi-task, hierarchical, proximal] weights
%     C             scalar    number of action classes
%     numParts      scalar    number of body-parts (= sum(partGroup))
%     partGroup     1 x 3     parts per layer [L1 L2 L3]
%     variant       string    which mixed norm to use, see table below
%     priorThetaVec D*C x 1   optional, defaults to 0 (proximal term target)
%     groupCof      1 x 3     optional per-layer weights, defaults to [1 1 1]
%
%   OUTPUTS
%     f             scalar    objective value
%     df            D*C x 1   gradient w.r.t. vec(W)
%
%   VARIANTS.  With A_l = the layer-l aggregate over its parts, the
%   regularizer R(W) = sum_c (outer aggregation over layers):
%
%     'l4_1_2'   A_l = sum_k ||w^{l,k}||_4     R = ( sum_l A_l^2 )^(1/2)
%                The method reported as HBPL-l_{4,1,2} in the paper.
%
%     'l4_1_sq'  A_l = sum_k ||w^{l,k}||_4     R = sum_l A_l^2
%     'l2_1_sq'  A_l = sum_k ||w^{l,k}||_2     R = sum_l A_l^2
%     'l4_2_sq'  A_l = sum_k ||w^{l,k}||_4^2   R = sum_l A_l
%
%   NOTE.  Only 'l4_1_2' carries the outer square root, i.e. the l_2 coupling
%   across layers of Eq. (13). The three '*_sq' variants are the squared
%   forms that were used for the ablation in Table II; they are kept verbatim
%   so published numbers reproduce exactly. Do not "fix" the asymmetry
%   without re-running the ablation.
%
%   NUMERICS.  epsilon below is written 10e-8 (i.e. 1e-7, not 1e-8) and is
%   added *after* the fractional power rather than inside it. Both are
%   preserved exactly as originally run; changing either shifts results.
%   The three '*_sq' variants also retain the historical gradient scaling:
%   their hierarchical contribution omits the factor 2 from differentiating
%   the squared objective. Re-run the ablation before changing this scaling.
%
%   See also MINIMIZE, TRAINBINREGRESSION, PREDICTBINREGRESSION.

if nargin < 9 || isempty(priorThetaVec)
    priorThetaVec = 0;
end
if nargin < 10 || isempty(groupCof)
    groupCof = [1 1 1];
end

D = size(X, 1);
J = D / numParts;              % rows (feature dimensions) per body-part
W = reshape(thetaVec, D, C);
if isscalar(priorThetaVec)
    % Wrappers use scalar zero when no proximal target is supplied.
    Wprior = repmat(priorThetaVec, D, C);
else
    Wprior = reshape(priorThetaVec, D, C);
end

% Row index range of the parts belonging to each layer.
layerEnd   = cumsum(partGroup);
layerStart = [1, layerEnd(1:end - 1) + 1];

% ---------------------------------------------------------------- objective
fitTerm = sum(sum((X' * W - Y).^2));

% Multi-task l_{2,1}: couples each feature dimension across all classes.
multiTaskTerm = sum(sqrt(sum(W.^2, 2)));

% Per-layer aggregate A_l, one value per class (1 x C).
layerAgg = zeros(3, C);
for l = 1:3
    acc = 0;
    for j = layerStart(l):layerEnd(l)
        rows = (j - 1) * J + 1:j * J;
        switch variant
            case {'l4_1_2', 'l4_1_sq'}
                acc = acc + sqrt(sqrt(sum(W(rows, :).^4, 1)));   % ||w||_4
            case 'l2_1_sq'
                acc = acc + sqrt(sum(W(rows, :).^2, 1));         % ||w||_2
            case 'l4_2_sq'
                acc = acc + sqrt(sum(W(rows, :).^4, 1));         % ||w||_4^2
            otherwise
                error('hbplCost:unknownVariant', 'Unknown variant "%s".', variant);
        end
    end
    layerAgg(l, :) = acc;
end

% Outer aggregation across the three layers.
switch variant
    case 'l4_2_sq'
        layerRow = groupCof * layerAgg;                 % sum_l A_l
    otherwise
        layerRow = groupCof * (layerAgg.^2);            % sum_l A_l^2
end

if strcmp(variant, 'l4_1_2')
    hierTerm = sum(sqrt(layerRow));                     % outer l_2 across layers
else
    hierTerm = sum(layerRow);
end

proxTerm = sum(sum((W - Wprior).^2));

f = fitTerm + lambda(1) * multiTaskTerm + lambda(2) * hierTerm + lambda(3) * proxTerm;

% ----------------------------------------------------------------- gradient
if nargout < 2
    return
end

grad = 2 * X * (X' * W - Y);
clear X                                  % the feature batch dominates memory

epsilon = 10e-8;                         % guards division by zero; see NUMERICS

gradMultiTask = repmat((sum(W.^2, 2) + epsilon).^(-1 / 2), 1, C) .* W;

gradHier = zeros(D, C);
for l = 1:3
    for j = layerStart(l):layerEnd(l)
        rows = (j - 1) * J + 1:j * J;
        Wp = W(rows, :);
        switch variant
            case 'l4_1_2'
                % A_l / sqrt(sum_l A_l^2) * d||w||_4/dw
                pre  = repmat(layerAgg(l, :), J, 1) .* repmat(1 ./ (sqrt(layerRow) + epsilon), J, 1);
                dpart = (Wp.^3) ./ repmat(sum(Wp.^4, 1).^(3 / 4) + epsilon, J, 1);
            case 'l4_1_sq'
                pre  = repmat(layerAgg(l, :), J, 1);
                dpart = (Wp.^3) ./ repmat(sum(Wp.^4, 1).^(3 / 4) + epsilon, J, 1);
            case 'l2_1_sq'
                pre  = repmat(layerAgg(l, :), J, 1);
                dpart = Wp ./ repmat(sum(Wp.^2, 1).^(1 / 2) + epsilon, J, 1);
            case 'l4_2_sq'
                pre  = repmat(sum(Wp.^4, 1).^(1 / 4), J, 1);      % = ||w||_4
                dpart = (Wp.^3) ./ repmat(sum(Wp.^4, 1).^(3 / 4) + epsilon, J, 1);
        end
        gradHier(rows, :) = groupCof(l) * pre .* dpart;
    end
end

gradProx = 2 * (W - Wprior);

grad = grad + lambda(1) * gradMultiTask + lambda(2) * gradHier + lambda(3) * gradProx;

df = reshape(grad, D * C, 1);
