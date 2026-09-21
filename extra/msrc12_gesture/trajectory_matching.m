function [distance_matrix_interg,recog_ratio_interg,distance_table_interg]=trajectory_matching(marker,level,descrip_flag,occlu_ratio)
% copyfile('mat/*.*','../HDM05EvaluatingCode/','f');
if occlu_ratio == 0
    occlu_flag = 0;   
else
    occlu_flag = 1;
end
fileprefix = '.mat';
matfilename = [marker fileprefix];
if exist(matfilename,'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
samples_r = size(TRAJDB,2);
for i=1:samples_r   
       directory_loca=find(TRAJDB{1,i}=='/');
       TRAJDB{1,i}=TRAJDB{1,i}(1:directory_loca(2));
end
dataGID = grp2idx(TRAJDB(1,:)');

% samples_r = size(TRAJDB,2);
% for i=1:samples_r
%     directory_loca=find(TRAJDB{1,i}=='/');
%     TEMP(i,:)=TRAJDB{1,i}(directory_loca(2)+5:directory_loca(2)+6);
% end
% subjectID_DB = TEMP;

EXPERIMENT_NUM = 30;
for experiment_num = 1:EXPERIMENT_NUM
    
    % select trajectories randomly
    i=1;
    original_trajectory = cell(1,12);
    noise_trajectory = cell(1,12);
    while i<13,
        indx = find(dataGID==i);
        indx = indx((randperm(length(indx),1)));
        original_trajectory{i} = TRAJDB{2,indx};
        i=i+1;
    end
    trainGID = (1:12)';testGID = (1:12)';
    
    % load TRAJDB;
    theta_x = 30;tx = 200;% in degree
    theta_y = 0; ty = 100;
    theta_z = 45;tz = 0;
    s = 0.5 ; %scale factor
    for i=1:12
        marker_xyz = original_trajectory{i};
        %     [marker_xyz max_limit min_original] = normalization(marker_xyz);
        
        mindim = min([max(marker_xyz(:,1))-min(marker_xyz(:,1))...
            max(marker_xyz(:,2))-min(marker_xyz(:,2))...
            max(marker_xyz(:,3))-min(marker_xyz(:,3))]);
        maxdim = max([max(marker_xyz(:,1))-min(marker_xyz(:,1))...
            max(marker_xyz(:,2))-min(marker_xyz(:,2))...
            max(marker_xyz(:,3))-min(marker_xyz(:,3))]);
%         noise_f(i) = sqrt(mindim)/sqrt(maxdim);
        
        if mindim <1
            signal_p = mindim^2;
        else
            signal_p = sqrt(mindim);
        end
        marker_xyz(:,1) = marker_xyz(:,1)+(level*randn(1,size(marker_xyz,1))*sqrt(mindim))';
        marker_xyz(:,2) = marker_xyz(:,2)+(level*randn(1,size(marker_xyz,1))*sqrt(mindim))';
        marker_xyz(:,3) = marker_xyz(:,3)+(level*randn(1,size(marker_xyz,1))*sqrt(mindim))';
        
%         scatter3(x, y, z, 12, t, 'filled');
%         Y = awgn(marker_xyz,level);
%         Y = verse_normalization(Y,max_limit,min_original);
%         noise_trajectory{i} = Y;

        marker_xyz(:,end+1) = 1;% qici matrix
        marker_xyz = marker_xyz';
        marker_xyz = makehgtform('xrotate',(theta_x*pi)/180)*marker_xyz;
        marker_xyz = makehgtform('yrotate',(theta_y*pi)/180)*marker_xyz;
        marker_xyz = makehgtform('zrotate',(theta_z*pi)/180)*marker_xyz;
        marker_xyz = makehgtform('xrotate',(theta_x*pi)/180)*marker_xyz;
        marker_xyz = makehgtform('yrotate',(theta_y*pi)/180)*marker_xyz;
        marker_xyz = makehgtform('zrotate',(theta_z*pi)/180)*marker_xyz;
        marker_xyz = makehgtform('translate',tx,ty,tz)*marker_xyz;
        marker_xyz = makehgtform('scale',s)*marker_xyz;
        marker_xyz = marker_xyz';
        marker_xyz(:,end) = [];
        
        noise_trajectory{i} = marker_xyz;
        % cut the trajectory with occlu_ratio occlusion
        if occlu_flag == 1
            length_trajectory = size(noise_trajectory{i},1);
            occlu_indx = fix(length_trajectory*rand*(1-occlu_ratio))+1;
            noise_trajectory{i}(occlu_indx:occlu_indx+fix(length_trajectory*occlu_ratio),:) = NaN;
        end
        
    end
    
    samples = length(original_trajectory);
    TRAJDB_DES = cell(1,samples);
    for i=1:samples
        marker_xyz = double(original_trajectory{i});
        fprintf ('%d of %d %dth descriptor...\n',i,samples,descrip_flag);
        switch descrip_flag
            case 1
                fd = fft(marker_xyz);
                fd = fd./repmat(max(fd),size(fd,1),1);
                marker_des = fd(2:30,:);
            case 2
                marker_des=descriptor_comp(marker_xyz);
            case 3
%                 marker_des = integral_invariant(marker_xyz,8,0.05);
                marker_des = integral_invariant_kn(marker_xyz,8,20);
                marker_des = 0.5-marker_des;
            case 4
                marker_des = integral_invariant_ms(marker_xyz,8,0.3);
                marker_des = 0.5-marker_des;
            case 5
                marker_des = integral_invariant_dist(marker_xyz,20);
            otherwise
                disp('error input descrip_flag')
        end
        
        TRAJDB_DES{1,i} = marker_des;
    end
    
    samples = length(noise_trajectory);
    TRAJSAMPLES_DES = cell(1,samples);
    for i=1:samples
        marker_xyz = double(noise_trajectory{i});
        fprintf ('%d of %d %dth samples descriptor...\n',i,samples,descrip_flag);
        switch descrip_flag
            case 1
                fd = fft(marker_xyz);
                fd = fd./repmat(max(fd),size(fd,1),1);
                marker_des = fd(2:30,:);
            case 2
                marker_des=descriptor_comp(marker_xyz);
                [marker_des,~] = remove_stapoint(marker_des);
            case 3
%                 marker_des = integral_invariant(marker_xyz,20,0.05);
                marker_des = integral_invariant_kn(marker_xyz,20,20);
                marker_des = 0.5-marker_des;
            case 4
                marker_des = integral_invariant_ms(marker_xyz,20,0.3);
                marker_des = 0.5-marker_des;
            case 5
                marker_des = integral_invariant_dist(marker_xyz,20);
            otherwise
                disp('error input descrip_flag')
        end
        TRAJSAMPLES_DES{1,i} = marker_des;
    end
    
    samples_r=size(TRAJDB_DES,2);
    samples_t=size(TRAJSAMPLES_DES,2);
    dtw_distance = zeros(samples_t,samples_r);
    for i=1:samples_t
        for j=1:samples_r
            fprintf ('the %d/%d--%d recognition for %dth descriptor...%2.2f%%\n',i,j,samples_r*samples_t,descrip_flag,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
            %         dtw_distance(i,j)=dtw_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1);
            [dtw_distance(i,j), ~, ~]=dtw_adj_matching(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},100,descrip_flag);
        end
    end
    [V I] = min(dtw_distance,[],2); % sum up the recognition accurate ratio
    I'
    for i = 1:16
        for j = 1:16
            confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j));
        end
    end
    recog_ratio_interg(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:));
    confusion_matrix_interg{1,experiment_num} = confusion_matrix;
    distance_matrix_interg{1,experiment_num} = dtw_distance;
end


% save TRAJDB original_trajectory;save TRAJSAMPLES noise_trajectory;
% for i = 1:16
%     plot3d(original_trajectory{i});
%     xlabel('X','FontWeight','bold');ylabel('Y','FontWeight','bold');zlabel('Z','FontWeight','bold');
%     saveas(gcf,num2str(i),'png')
% end
% for i = 1:16
%     plot3d(noise_trajectory{i});
%     xlabel('X','FontWeight','bold');ylabel('Y','FontWeight','bold');zlabel('Z','FontWeight','bold');
%     saveas(gcf,strcat(num2str(i),'samples'),'png')
% end
% 
% %% plot the dtw illustration
% plot3d(original_trajectory{1});hold on, plot3d(noise_trajectory{1}); hold on;
% for i = 1:size(path,1)
%     plot3([original_trajectory{1}(path(i,1),1) noise_trajectory{1}(path(i,2),1)],...
%          [original_trajectory{1}(path(i,1),2) noise_trajectory{1}(path(i,2),2)],...
%          [original_trajectory{1}(path(i,1),3) noise_trajectory{1}(path(i,2),3)]), hold on;
% end
%% plot distance matrix
m = length(distance_matrix_interg);
n = size(distance_matrix_interg{1,1},1);
confusion_sum = zeros(n,n);
for i=1:n
%     name_class{i}=['class_' num2str(i)];
    name_class{i}=num2str(i);
end
for i = 1:m
    if ~isempty(distance_matrix_interg{1,i})
        distance_matrix_interg{1,i} = distance_matrix_interg{1,i}./repmat(sum(distance_matrix_interg{1,i},2),1,n);
        distance_matrix_interg{1,i} = distance_matrix_interg{1,i}*100;
        confusion_sum = confusion_sum + distance_matrix_interg{1,i}; 
    else
        i = i-1;
        break;
    end
end
distance_table_interg = confusion_sum/i;
figure(1),draw_cm(distance_table_interg,name_class,n);
% saveas(gcf,strcat('dtw_distance_matching_',...
%     num2str(level)),'fig');
%% for occlusion 
saveas(gcf,strcat('dtw_distance_matching_',...
    num2str(level),'_occlusion_',num2str(occlu_ratio),'_descrip_',num2str(descrip_flag)),'fig');


