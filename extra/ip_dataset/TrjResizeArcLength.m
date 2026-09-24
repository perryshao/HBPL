% Interpolation and resize the trajectory into a new length (with respect to unit arc length)
% by skaegy
%% Input
% Trj: original trajectory n*3
% Num: the number of the resized frames

%% output
% ResizeTrj: Length*3

%%
function ResizeTrj = TrjResizeArcLength(Trj, Num)
if nargin < 1
    error('Need more input');
end

if size(Trj, 1) < size(Trj, 2)
    Trj = Trj';
end
n = length(Trj);
Interp_Trj1(:, 1) = interp1(1:n, Trj(:, 1), 1:0.1:n, 'spline');
Interp_Trj1(:, 2) = interp1(1:n, Trj(:, 2), 1:0.1:n, 'spline');
Interp_Trj1(:, 3) = interp1(1:n, Trj(:, 3), 1:0.1:n, 'spline');
Interp_Trj2(:, 1) = interp1(1:length(Interp_Trj1), Interp_Trj1(:, 1), 1:0.1:length(Interp_Trj1), 'spline');
Interp_Trj2(:, 2) = interp1(1:length(Interp_Trj1), Interp_Trj1(:, 2), 1:0.1:length(Interp_Trj1), 'spline');
Interp_Trj2(:, 3) = interp1(1:length(Interp_Trj1), Interp_Trj1(:, 3), 1:0.1:length(Interp_Trj1), 'spline');

[~, s] = TrjLength(Interp_Trj2);
Interp_Trj2 = Interp_Trj2 / (s + eps);
[s_seg, ~] = TrjLength(Interp_Trj2);

S_seg = repmat(s_seg, 1, Num);
Step = repmat([0:1 / (Num - 1):1], length(s_seg), 1);
clear s_seg
[~, min_idx] = min(abs(S_seg - Step));

ResizeTrj = Interp_Trj2(min_idx, :);
end
