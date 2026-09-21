function [SC_DES,SCSAMPLES_DES] = relative_sc_bat(joints_no,marker)

load([marker '.mat']);
ROOTDB = TRAJDB;% HEAD curve as root trajectory here
samples=size(ROOTDB,2);
SC_DES = cell(1,samples);
m_num = length(joints_no);
%% initial shape context computation
mean_dist_global=[]; % use [] to estimate scale from the data
nbins_theta=12;
nbins_alpha=12;
nbins_r=5;
ndum1=0;
eps_dum=0.15;
r_inner=1/8;
r_outer=2;
%% sc computation
for i=1:samples
    fprintf ('get the relative descriptor %d/%d...\n',i,samples);
    root_curve = ROOTDB{2,i};lengths = size(root_curve,1);
    relative_curve = zeros(lengths,3*m_num);
    for j=1:m_num
        load([joints_no{1,j} '.mat']);
        child_curve=TRAJDB{2,i}; % LWRA curve
        relative_curve(:,j*3-2:j*3) = child_curve - root_curve;
    end
    for k=1:lengths
        sc_trajectory = reshape(relative_curve(k,:),3,m_num);
        nsamp1 = m_num;
        % outliers on each iteration
        out_vec_1 = zeros(1,nsamp1);
        % compute shape contexts for (transformed) model
        [BH_theta,BH_alpha,mean_dist_1]=sc3d_compute(sc_trajectory,zeros(1,nsamp1),mean_dist_global,nbins_theta,nbins_alpha,nbins_r,r_inner,r_outer,out_vec_1);
        SC_DES{1,i}(end+1:end+9,:)=[BH_theta BH_alpha];
    end
end

load([marker 'samples.mat']);
ROOTSAMPLES=TRAJSAMPLES;
samples=size(ROOTSAMPLES,2);
SCSAMPLES_DES = cell(1,samples);

for i=1:samples
    fprintf ('get the samples relative descriptor %d/%d...\n',i,samples);
    root_curve = ROOTSAMPLES{2,i};lengths = size(root_curve,1);
    relative_curve = zeros(lengths,3*m_num);
    for j=1:m_num
        load([joints_no{1,j} 'samples.mat']);
        child_curve=TRAJSAMPLES{2,i}; % LWRA curve
        relative_curve(:,j*3-2:j*3) = child_curve - root_curve;
    end
    for k=1:lengths
        sc_trajectory = reshape(relative_curve(k,:),3,m_num);
        nsamp1 = m_num;
        % outliers on each iteration
        out_vec_1 = zeros(1,nsamp1);
        % compute shape contexts for (transformed) model
        [BH_theta,BH_alpha,mean_dist_1]=sc3d_compute(sc_trajectory,zeros(1,nsamp1),mean_dist_global,nbins_theta,nbins_alpha,nbins_r,r_inner,r_outer,out_vec_1);
        SCSAMPLES_DES{1,i}(end+1:end+9,:)=[BH_theta BH_alpha];
    end
end
clear TRAJDB ROOTDB TRAJSAMPLES ROOTSAMPLES;
