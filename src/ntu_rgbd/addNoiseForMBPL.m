function addNoiseForMBPL(marker,level,occlu_flag,occlu_ratio)
%% detect whether there are existing required mat files for C3D data
fileprefix='.mat';
%% process the samples data
fileprefix='samples.mat';
matfilename=[marker fileprefix];
if exist(matfilename,'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d_samples() funcition');
end
%% read required length of joint 3D data with matrix format and filter it
samples=size(TRAJSAMPLES_CV,2);
for i=1:samples
    marker_xyz = TRAJSAMPLES_CV{2,i};
    mindim = min([max(marker_xyz(:,1))-min(marker_xyz(:,1))...
        max(marker_xyz(:,2))-min(marker_xyz(:,2))...
        max(marker_xyz(:,3))-min(marker_xyz(:,3))]);
    maxdim = max([max(marker_xyz(:,1))-min(marker_xyz(:,1))...
        max(marker_xyz(:,2))-min(marker_xyz(:,2))...
        max(marker_xyz(:,3))-min(marker_xyz(:,3))]);
    noise_f(i) = sqrt(mindim)/sqrt(maxdim);
    
    marker_xyz(:,1) = marker_xyz(:,1)+(level*randn(1,size(marker_xyz,1))*sqrt(mindim))';
    marker_xyz(:,2) = marker_xyz(:,2)+(level*randn(1,size(marker_xyz,1))*sqrt(mindim))';
    marker_xyz(:,3) = marker_xyz(:,3)+(level*randn(1,size(marker_xyz,1))*sqrt(mindim))';
    
    %         Noise_tens = randn(size(marker_xyz,1),size(marker_xyz,2));
    %         sigma=(10^(-SNR/20))*(norm(marker_xyz,'fro')/norm(Noise_tens,'fro'));
    %         marker_xyz = marker_xyz + sigma*Noise_tens;  
    noise_trajectory = marker_xyz;
    % cut the trajectory with occlu_ratio occlusion
    if occlu_flag == 1
        length_trajectory = size(noise_trajectory,1);
        occlu_indx = fix(length_trajectory*rand*(1-occlu_ratio))+1;
%         noise_trajectory(occlu_indx:occlu_indx+fix(length_trajectory*occlu_ratio),:) = [];
        noise_trajectory(occlu_indx:occlu_indx+fix(length_trajectory*occlu_ratio),:) = NaN;
    end
    
    TRAJSAMPLES_CV{2,i} = noise_trajectory;
end
save(matfilename,'TRAJSAMPLES_CV');
end