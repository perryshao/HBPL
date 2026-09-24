function [f, df] = costFuncRegMultPartGp_v2(initialTheta, X, Y, lambda, C, jointNum, preTinitialTheta)
% COSTFUNCREGMULTPARTGP_V2  HBPL objective/gradient -- l_{4,1,2}, Eq. (13) of the paper
%
%   Thin wrapper kept for backward compatibility: MINIMIZE receives this
%   function *by name* as a string, and its parameter list is already full
%   (6 extra arguments), so the layer sizes cannot be passed through and are
%   fixed here instead.
%
%   Layer sizes for this dataset: partGroup = [5 10 19]
%   (parts in layer 1, 2, 3; see Table I of the TCSVT paper).
%
%   All of the mathematics lives in HBPLCOST -- see there for the objective,
%   the gradient, and the numerical caveats.
%
%   See also HBPLCOST, MINIMIZE.

if nargin < 7
    preTinitialTheta = 0;
end

partGroup = [5 10 19];

[f, df] = hbplCost(initialTheta, X, Y, lambda, C, jointNum, partGroup, 'l4_1_2', preTinitialTheta);
