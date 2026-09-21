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
% position_nan = find(NaN_index==1);
% num_nan = sum(nonzeros(NaN_index));
% I_nan = num_nan/J;
% keep original structure and path of dist matrix regardless of occlusion
% d(find(NaN_index(:,1)==1),:) = [];
d(NaN_index) = 0;
I = size(d,1);J = size(d,2);
d=double(d);
%% search optimal path using C for acceleratting the computation
[g steps] = dtwpath(d,r); %#ok<NASGU>
%% search optimal path using matlab
% g = zeros(I+1,J+1);
% g(:,:) = inf;
% g(1,1) = 2*d(1,1); % initial condition, see (19) in [SakoeChiba1978]
% s = J/I; % slope from (0,0) to (I,J)
% steps = zeros(I,J); % steps to take in order to reach D(i,j)
% 
% for i = 2:I+1;
%     for j = 2:J+1;
%         if (abs(i-(j/s)) > r)
%             % we're outside the adjustment window
%             continue;
%         end
% 
%         % local distance matrix is smaller than g, translate coordinates
%         i_l = i-1;
%         j_l = j-1;
% 
%         % calculate global distances
%         % (see DP-equation (20) from [SakoeChiba1978] for reference)
%         [distance, step] =  min([g(i,   j-1) +   d(i_l, j_l)...
%                                  g(i-1, j-1) + 2*d(i_l, j_l)...
%                                  g(i-1, j)   +   d(i_l, j_l)]);
% %         distance =  min([g(i,   j-1) +   d(i_l, j_l)...
% %                          g(i-1, j-1) + 2*d(i_l, j_l)...
% %                          g(i-1, j)   +   d(i_l, j_l)]);
%         g(i,j) = distance;
%         steps(i-1,j-1) = step;
%     end
% end


% time normalize global distance matrix
N=I+J;
D=g/N;


% remove additional inf padded row and column from global distance matrix
D=D(2:end,2:end);

% path=traceback_path(steps);

min_distance = D(end, end);






