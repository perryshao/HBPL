function d = feature_dist_integral_matrix(t, r)
m = size(t, 1);
n = size(r, 1);
for i = 1:m
    %%   differential invariants computation
    det_diff = repmat(t(i, :), n, 1) - r;
    det_k(i, :) = sqrt(sum(det_diff(:, 1:2).^2, 2))'; %#ok<AGROW>
end
S_m = sum(t(:, 1:2).^2, 2);
S_n = sum(r(:, 1:2).^2, 2);
% d=det_k.*det_t.*(1+weight*det_h)./(sqrt(S_m)*sqrt(S_n'));
% discard the gloabal parameter in multiple trajectories recognition -- perry 28/02/13
d = det_k ./ (sqrt(S_m) * sqrt(S_n'));
