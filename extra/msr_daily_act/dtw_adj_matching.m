function [min_distance, d, g] = dtw_adj_matching(A, B,adjustment_window_size,jointGroup,descrip_flag)
switch descrip_flag
    case   {2, 3, 4}
        A = A(3:end-2,:);B = B(3:end-2,:);% because beginning and ending two features are zero
        % get length of speech patterns A and B
        I = size(A,1);
        J = size(B,1);
        d = zeros(I,J);
        % local distance matrix
        d = feature_dist_matching(A,B);
    case 1
        % Fourire descriptor distance matrix
        % get length of speech patterns A and B
        I = size(A,1);
        J = size(B,1);
        d = zeros(I,J);
        d = distance_matrix_fd(A,B);
%         min_distance = sum(sum(abs(A-B).^2));
%         g = min_distance;
%         return;
    case {5, 6}
        A = A(3:end-2,:);B = B(3:end-2,:);% because beginning and ending two features are zero
        % get length of speech patterns A and B
        I = size(A,1);
        J = size(B,1);
        d = zeros(I,J);
        % local distance matrix
        d = distance_matrix_norm2(A,B);  
    case {7, 8}
        % get length of speech patterns A and B
        I = size(A,1);
        J = size(B,1);
        d = zeros(I,J);
        % local distance matrix
        d = distance_matrix_norm1(A,B);
    case 10
        for i = 1:jointGroup
            dr1 = pdist2(A(:,(i-1)*7+1:(i-1)*7+4),B(:,(i-1)*7+1:(i-1)*7+4)); %norm2 distance of Sr
            Wgts = ones(1,4);
            sum_norm2 = @(XI,XJ,W)(sqrt(bsxfun(@plus,XI,XJ).^2 * W'));
            dr2 = pdist2(A(:,(i-1)*7+1:(i-1)*7+4),B(:,(i-1)*7+1:(i-1)*7+4), @(Xi,Xj) sum_norm2(Xi,Xj,Wgts));%||Sr+Sr||2
            dv = pdist2(A(:,(i-1)*7+5:(i-1)*7+7),B(:,(i-1)*7+5:(i-1)*7+7));%norm2 distance of Sv
            d(:,:,i) = min(dr1,dr2)+dv;
        end
        d = sum(d,3);
        
end

% global distance matrix
NaN_index = isnan(d);
d(NaN_index) = 0;
I = size(d,1);J = size(d,2);
d=double(d);
%% search optimal path using C for acceleratting the computation
[g,steps] = dtwpath(d,adjustment_window_size); %#ok<NASGU>
% time normalize global distance matrix
N=I+J;
D=g/N;
% remove additional inf padded row and column from global distance matrix
D=D(2:end,2:end);
% path=traceback_path(steps);
min_distance = D(end, end);






