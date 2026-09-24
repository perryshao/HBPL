function [f, df] = costFuncRegMultPartGp_v1_212(initialTheta, X, Y, lambda, C, jointNum, preTinitialTheta)
% COSTFUNCREGMULTPARTGP_V1_212  HBPL objective/gradient -- l_{2,1} ablation, Table II
%
%   Thin wrapper kept for backward compatibility: MINIMIZE receives this
%   function *by name* as a string, and its parameter list is already full
%   (6 extra arguments), so the layer sizes cannot be passed through and are
%   fixed here instead.
%
%   Layer sizes for this dataset: partGroup = [10 20 38]
%   (parts in layer 1, 2, 3; see Table I of the TCSVT paper).
%
%   All of the mathematics lives in HBPLCOST -- see there for the objective,
%   the gradient, and the numerical caveats.
%
%   See also HBPLCOST, MINIMIZE.

if nargin < 7
    preTinitialTheta = 0;
end

partGroup = [10 20 38];

[f, df] = hbplCost(initialTheta, X, Y, lambda, C, jointNum, partGroup, 'l2_1_sq', preTinitialTheta);
