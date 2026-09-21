function d=feature_dist_comparison_matrix(t,r,flag)
weight_o=0.2;weight_rd=0.8;
m = size(t,1);
n = size(r,1);
dim = size(t,2);
% dim = 4;
det_k = zeros(m,n);det_t = zeros(m,n);S_k = zeros(m,n);S_t = zeros(m,n);
for i=1:m
    
    %%   differential invariants computation
    det_diff = repmat(t(i,:),n,1)-r;
    %     det_k(i,:) = sqrt(sum(det_diff(:,1:dim).^2,2))'; % for norm-2
    det_k(i,:) = sum(abs(det_diff(:,1:dim/2)),2)'; % for norm-1
    det_t(i,:) = sum(abs(det_diff(:,dim/2+1:end)),2)'; % for norm-1
    if flag == 1
        %         S_k(i,:) = sum(abs([repmat(t(i,:),n,1) r]),2)';
        S_k(i,:) = sum(abs([repmat(t(i,1:dim/2),n,1) r(:,1:dim/2)]),2)';
        S_t(i,:) = sum(abs([repmat(t(i,dim/2+1:end),n,1) r(:,dim/2+1:end)]),2)';
    end

          
end
d=(det_k./S_k).*(det_t./S_t);




