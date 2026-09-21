function comparison_samples(level)
index=[13 20 40 53 74 86 104 119 140 151 164];
RANK = '26' ;RKNE = '24';LANK = '33';LKNE = '31';
LELB = '18';LWRA = '20';RELB = '11';RWRA = '13';
STRN = '2';HEAD = '6';
load ([HEAD '.mat']);
for i = 1:11
    original_trajectory{i} = TRAJDB{2,index(i)};
end

gamma =0.5;
testGID = [1:11]';trainGID = [1:11]';
for i=1:11
    marker_xyz = original_trajectory{i};
%     [marker_xyz max_limit min_original] = normalization(marker_xyz);
   
    mindim = min([max(marker_xyz(:,1))-min(marker_xyz(:,1))...
                 max(marker_xyz(:,2))-min(marker_xyz(:,2))...
                 max(marker_xyz(:,3))-min(marker_xyz(:,3))]);
    maxdim = max([max(marker_xyz(:,1))-min(marker_xyz(:,1))...
                 max(marker_xyz(:,2))-min(marker_xyz(:,2))...
                 max(marker_xyz(:,3))-min(marker_xyz(:,3))]);
    noise_f(i) = sqrt(mindim)/sqrt(maxdim);
%     noise_inten = level*(size(marker_xyz,1)/500).^2;
    
    if mindim < 1
        signal_p = mindim^2;
    else
        signal_p = sqrt(mindim);
    end
    marker_xyz(:,1) = marker_xyz(:,1)+(level*randn(1,size(marker_xyz,1))*signal_p)';
    marker_xyz(:,2) = marker_xyz(:,2)+(level*randn(1,size(marker_xyz,1))*signal_p)';
    marker_xyz(:,3) = marker_xyz(:,3)+(level*randn(1,size(marker_xyz,1))*signal_p)';
%     scatter3(x, y, z, 12, t, 'filled');
%     Y = awgn(marker_xyz,level);
%     Y = verse_normalization(Y,max_limit,min_original);
%     noise_trajectory{i} = Y;
    noise_trajectory{i} = marker_xyz;
end

samples = length(original_trajectory);
for i=1:samples
    marker_xyz = double(original_trajectory{i});
    fprintf ('%d of %d integral descriptor...\n',i,samples);
    marker_des = integral_invariant(marker_xyz,10,0.05);
    marker_des = 0.5-marker_des;
    TRAJDB_DES{1,i} = marker_des;
end

samples = length(noise_trajectory);
for i=1:samples
    marker_xyz = double(noise_trajectory{i});
    fprintf ('%d of %d integral descriptor...\n',i,samples);
    marker_des = integral_invariant(marker_xyz,level*1000*noise_f(i)+10,0.05);
    marker_des = 0.5-marker_des;
    TRAJSAMPLES_DES{1,i} = marker_des;
end

samples_r=size(TRAJDB_DES,2);
samples_t=size(TRAJSAMPLES_DES,2);
dtw_distance = zeros(samples_t,samples_r);
for i=1:samples_t
    for j=1:samples_r
        fprintf ('the %d/%d--%d recognition for integral descriptor...%2.2f%%\n',i,j,samples_r*samples_t,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
        %         dtw_distance(i,j)=dtw_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1);
        [dtw_distance(i,j), ~, ~]=dtw_adj_comparison(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},1,50); 
    end
end
dtw_distance = exp(-gamma*dtw_distance); %% tranform to Likelihood of dtw distance -- Perry 28/05/2013
dtw_distance = dtw_distance./repmat(sum(dtw_distance,2),1, samples_r);%% softmax of dtw distance -- Perry 28/05/2013
[V I] = max(dtw_distance,[],2); % sum up the recognition accurate ratio
I'
for i = 1:11
    for j = 1:11
        confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j));
    end
end
recog_ratio_interg = trace(confusion_matrix)/sum(confusion_matrix(:))