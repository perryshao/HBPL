function gene_descriptor_fd(marker)
if nargin == 1
    TRAJDB_DES = cell (1,[]);
    fileprefix = '.mat';
    matfilename = [marker fileprefix];
    if exist(matfilename,'file')
        load(matfilename);
    else
        fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
    end
    fileextend = '_DES.mat';
    matfilename = [marker fileextend];
   %% read joint 3D data with matrix format and get the descritor
    samples = size(TRAJDB,2);
%     TRAJDB = normalization_basewhole(marker,joints_no);
    for i=1:samples
        marker_xyz = double(TRAJDB{2,i});
%        [marker_xyz,stapoint_index] = remove_stapoint(marker_xyz); % cannot eliminate the static points
        fprintf ('%d of %d integral descriptor...\n',i,samples);
        
%         marker_xyz = interpolation(marker_xyz,size(marker_xyz,1)*2,0);
%         index = ismember(marker_xyz,TRAJDB{2,i});
        fd = fft(marker_xyz);
        fd = fd./repmat(max(fd),size(fd,1),1);
        marker_des = fd(2:30,:);
%         marker_des = marker_des(or(or(index(:,1),index(:,2)),index(:,3)),:);
        TRAJDB_DES{1,end+1} = marker_des;
    end
    save(matfilename, 'TRAJDB_DES'); 
else
    TSDDB_DES = cell (2,[]);
    if exist('tsddb.mat','file')
        load tsddb;
    else
        fprintf ('Error, there are not existing database, lack of load_tsd() funcition');
    end
    samples = size(TSDDB,2);
    for i = 1:samples
        right_xyz = double(TSDDB{2,i});% right hand xyz postion
        left_xyz = double(TSDDB{3,i}); % letf hand xyz postion
        right_xyz = remove_stapoint(right_xyz);
        right_des = descriptor_comp(right_xyz);
        left_xyz = remove_stapoint(left_xyz);
        left_des = descriptor_comp(left_xyz); 
        TSDDB_DES{1,end+1} = left_des;
        TSDDB_DES{2,end} = right_des;
    end
    save('tsddb_des','TSDDB_DES');
end
clear all;

