function gene_descriptor_fd_samples(marker)
if nargin<=2
    TRAJSAMPLES_DES = cell (1,[]);
    fileprefix='samples.mat';
    matfilename=[marker fileprefix];
    if exist(matfilename,'file')
        load(matfilename);
    else
        fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
    end
    fileextend='samples_DES.mat';
    matfilename=[marker fileextend];
   %% read joint 3D data with matrix format and get the descritor
    samples=size(TRAJSAMPLES,2);
%     TRAJSAMPLES = normalization_basewhole_samples(marker,joints_no);
    for i=1:samples
        marker_xyz=double(TRAJSAMPLES{2,i});
        fprintf ('%d of %d samples integral descriptor...\n',i,samples);
%         marker_xyz = interpolation(marker_xyz,size(marker_xyz,1)*2,0);
%         index = ismember(marker_xyz,TRAJSAMPLES{2,i});
        fd = fft(marker_xyz);
        fd = fd./repmat(max(fd),size(fd,1),1);
        marker_des = fd(2:30,:);
%         marker_des = marker_des(or(or(index(:,1),index(:,2)),index(:,3)),:);
        TRAJSAMPLES_DES{1,end+1}=marker_des;
    end
    save(matfilename, 'TRAJSAMPLES_DES'); 
else
    TSDSAMPLES_DES = cell (2,[]);
    if exist('tsdsamples.mat','file')
        load tsdsamples;
    else
        fprintf ('Error, there are not existing database, lack of load_tsd_samples() funcition');
    end
    samples=size(TSDSAMPLES,2);
    for i=1:samples
        right_xyz=double(TSDSAMPLES{2,i});% right hand xyz postion
        left_xyz= double(TSDSAMPLES{3,i}); % letf hand xyz postion
        right_xyz=remove_stapoint(right_xyz);
        right_des=descriptor_comp(right_xyz);
        left_xyz=remove_stapoint(left_xyz);
        left_des=descriptor_comp(left_xyz); 
        TSDSAMPLES_DES{1,end+1}=left_des;
        TSDSAMPLES_DES{2,end}=right_des;
    end
    save('tsdsamples_des','TSDSAMPLES_DES');
end
clear all;
