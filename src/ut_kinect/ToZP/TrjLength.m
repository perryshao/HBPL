% Calculate the length of the trajectory 2d or 3d
% by skaegy
%% Input
% trajectory

%% output
% s: trajectory length

%%
function [s_norm, s_all] = TrjLength(trajectory)
% if nargin<1
%     error('Need more input');
% end

if size(trajectory, 1) < size(trajectory, 2)
    trajectory = trajectory';
end
s_part = [0; sqrt(sum(diff(trajectory).^2, 2))];
s_norm = cumsum(s_part) / sum(s_part);
s_all = sum(s_part);
end
