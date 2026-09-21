function [min_distance, d, g] = dtw_adj_comparison(A, B,flag,adjustment_window_size)

r = adjustment_window_size;
A = A(3:end-2,:);B = B(3:end-2,:);% because beginning and ending two features are zero
% get length of speech patterns A and B
I = size(A,1);
J = size(B,1);
d = zeros(I,J);
% local distance matrix
d = feature_dist_comparison_matrix(A,B,flag);
% global distance matrix
NaN_index = isnan(d);

d(NaN_index) = 0;
I = size(d,1);J = size(d,2);
d=double(d);
%% search optimal path using C for acceleratting the computation
[g, steps] = dtwpath(d,r); %#ok<NASGU>



% time normalize global distance matrix
N=I+J;
D=g/N;


% remove additional inf padded row and column from global distance matrix
D=D(2:end,2:end);

% path=traceback_path(steps);

min_distance = D(end, end);






