function [min_distance, d, g] = dtw_adj_fd(A, B, orientation1,orientation2,flag,adjustment_window_size)
% Minimal time normalized dtw distance between speech patterns A and B.

% References:
%
% [SakoeChiba1978] SAKOE, Hiroki; CHIBA, Seibi: Dynamic Programming
%     Algorithm Optimization for Spoken Word Recognition,
%     http://citeseer.ist.psu.edu/viewdoc/download?doi=10.1.1.114.3782&rep=rep1&type=pdf
%
% [Paliwal1982] PALIWAL, K.K. et al.: A Modification over Sakoe and Chiba's
%     Dynamic Time Warping Algorithm for Isolated Word Recognition,
%     http://maxwell.me.gu.edu.au/spl/publications/papers/sigpro82_kkp_dtw.pdf
%
% [Ellis2003] ELLIS, D.: Dynamic Time Warp (DTW) in Matlab,
%     http://www.ee.columbia.edu/~dpwe/resources/matlab/dtw/
win_r = adjustment_window_size;
orientation1 = orientation1(3:end-2,:);orientation2 = orientation2(3:end-2,:);
% get length of speech patterns A and B
I = size(orientation1,1);
J = size(orientation2,1);
d = zeros(I,J);
t = zeros(I,4);r = zeros(J,4);
% local distance matrix
d = feature_dist_orien_matrix(t,r,orientation1,orientation2,flag);% for fourier descriptor
% global distance matrix
NaN_index = isnan(d);
d(NaN_index) = 0;
% Fourire descriptor distance matrix
d_fd = repmat(norm(A-B),size(d,1),size(d,2));
factor = mean(mean(d))/norm(A-B);
% d = d+factor*d_fd;
% position_nan = find(NaN_index==1);
% num_nan = sum(nonzeros(NaN_index));
% I_nan = num_nan/J;
% keep original structure and path of dist matrix regardless of occlusion
% d(find(NaN_index(:,1)==1),:) = [];
I = size(d,1);J = size(d,2);
d=double(d);
%% search optimal path using C for acceleratting the computation
[g,steps] = dtwpath(d,win_r); %#ok<NASGU>
% time normalize global distance matrix
N=I+J;
D=g/N;
% remove additional inf padded row and column from global distance matrix
D=D(2:end,2:end);

% path=traceback_path(steps);
% d_ima = max(max(d))-d;
% imshow(d_ima,[min(min(d)) max(max(d))]); hold on;
% figure(1), plot(path(:,2),path(:,1),'.b-'),hold on;


min_distance = D(end, end);






