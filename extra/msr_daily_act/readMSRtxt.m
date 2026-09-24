% USAGE: drawskt(1,3,1,4,1,2) --- show actions 1,2,3 performed by subjects 1,2,3,4 with instances 1 and 2.
function [X Y Z] = readMSRtxt(skeleton_txt)

file = sprintf(skeleton_txt);
fp = fopen(file);
if fp > 0
    A = fscanf(fp, '%f');
    fclose(fp);
end
T = A(1);
trajectory = zeros(T * 40, 4);
begin_n = 3;
Incret_n = 0;
for t = 1:T
    if A(begin_n + Incret_n) == 40
        trajectory((t - 1) * 40 + 1:t * 40, :) = reshape(A(begin_n + Incret_n + 1:begin_n + Incret_n + 40 * 4), 4, 40)';
        Incret_n = Incret_n + 40 * 4 + 1;
    else
        trajectory((t - 1) * 40 + 1:t * 40, :) = NaN;
        Incret_n = Incret_n + 80 * 4 + 1;
    end
end

trajectory(isnan(trajectory)) = [];
trajectory = trajectory(1:2:end, :);
I = size(trajectory, 1) * size(trajectory, 2) / 4;
A = reshape(trajectory, 20, I / 20, 4);

X = A(:, :, 1);
Z = A(:, :, 2);
Y = A(:, :, 3) / 4;

%
% l=size(A,1)/4;
% A=reshape(A,4,l);
% A=A';
% A=reshape(A,20,l/20,4);
%
% X=A(:,:,1);
% Z=400-A(:,:,2);
% Y=A(:,:,3)/4;
