
% Demo 1: Visualize a sequence.
%
% Author: Sebastian Nowozin <Sebastian.Nowozin@microsoft.com>

disp(['Visualizing sequence P1_1_9A_p28']);
[X,Y,tagset]=load_file('data\P1_1_1A_p28');
T=size(X,1);	% Length of sequence in frames
h=axes;
for ti=1:T
	skel_vis(X,ti,h);
	drawnow;
	pause(1/20);
% 	cla;
end
% Animate sequence

frame_id = find(Y(:,8)==1);
seg_num = length(frame_id);
X_segment = cell(1,seg_num);
X_segment{1} = X(1:frame_id(1)-1,:);
for ind = 2:seg_num
    X_segment{ind} = X(frame_id(ind-1):frame_id(ind)-1,:);
end

T = size(X_segment{1},1);
for ti=1:T
	skel_vis(X_segment{1},ti,h);
	drawnow;
	pause(1/30);
    cla;
end
T = size(X_segment{2},1);
for ti=1:T
	skel_vis(X_segment{2},ti,h);
	drawnow;
	pause(1/30);
    cla;
end


%% visualize the segmented motion

a = load('splitData/act01/P03_02_01_p02_r05.txt');
a = load(TRAJSAMPLES{1,169});
h=axes;
T = size(a,1);
for ti=1:T
skel_vis(a,ti,h);
drawnow;
pause(1/30);
cla;
end


% load('1.mat')
% TRAJDB(:,indx(2801:2806)) = [];
% save 1.mat TRAJDB
% 
% load('6.mat')
% TRAJDB(:,indx(2801:2806)) = [];
% save 6.mat TRAJDB
% 
% load('8.mat')
% TRAJDB(:,indx(2801:2806)) = [];
% save 8.mat TRAJDB
% 
% load('10.mat')
% TRAJDB(:,indx(2801:2806)) = [];
% save 10.mat TRAJDB
% 
% load('12.mat')
% TRAJDB(:,indx(2801:2806)) = [];
% save 12.mat TRAJDB
% 
% load('14.mat')
% TRAJDB(:,indx(2801:2806)) = [];
% save 14.mat TRAJDB
% 
% load('15.mat')
% TRAJDB(:,indx(2801:2806)) = [];
% save 15.mat TRAJDB
% 
% load('18.mat')
% TRAJDB(:,indx(2801:2806)) = [];
% save 18.mat TRAJDB
% 
% 
% load('19.mat')
% TRAJDB(:,indx(2801:2806)) = [];
% save 19.mat TRAJDB
% 
% load('12samples_DES.mat')
% TRAJSAMPLES_DES(:,indx(2833:2844)) = [];
% save 12samples_DES.mat TRAJSAMPLES_DES
load ([joints_no{1,1} '.mat']);load ([joints_no{1,1} 'samples.mat']);
[trainGID,testGID]=construct_ID(TRAJDB,TRAJSAMPLES);
m_num = length(joints_no);
for i = 1:m_num
    load([joints_no{1,i} '.mat']);
    temp_TRAJDB = cell(2,360);
    for j = 1:12
        indx = find(trainGID==j);
        if i == 1
            index{j} = indx((randperm(length(indx),30)));
        end
        temp_TRAJDB(:,(j-1)*30+1:j*30) = TRAJDB(:,index{j});
    end
    TRAJDB=temp_TRAJDB;
    save([joints_no{1,i} '.mat'],'TRAJDB');
end
for i = 1:m_num
    load([joints_no{1,i} 'samples.mat']);
    temp_TRAJSAMPLES = cell(2,360);
    for j = 1:12
        indx = find(trainGID==j);
        if i == 1
            index{j} = indx((randperm(length(indx),30)));
        end
        temp_TRAJSAMPLES(:,(j-1)*30+1:j*30) = TRAJSAMPLES(:,index{j});
    end
    TRAJSAMPLES=temp_TRAJSAMPLES;
    save([joints_no{1,i} 'samples.mat'],'TRAJSAMPLES');
end



% 
% load('19.mat')
% temp_TRAJDB = cell(2,360);
% for i = 1:12
%     temp_TRAJDB(:,(i-1)*30+1:i*30) = TRAJDB(:,index{i});
% end
% TRAJDB=temp_TRAJDB;
% save 19.mat TRAJDB
% %%
% load('1samples.mat')
% temp_TRAJSAMPLES = cell(2,360);
% for i = 1:12
%     indx = find(testGID==i);
%     indexsam{i} = indx((randperm(length(indx),30)));
%     temp_TRAJSAMPLES(:,(i-1)*30+1:i*30) = TRAJSAMPLES(:,indexsam{i});
% end
% TRAJSAMPLES=temp_TRAJSAMPLES;
% save 1samples.mat TRAJSAMPLES
% 
% load('12samples.mat')
% temp_TRAJSAMPLES = cell(2,360);
% for i = 1:12
%     temp_TRAJSAMPLES(:,(i-1)*30+1:i*30) = TRAJSAMPLES(:,indexsam{i});
% end
% TRAJSAMPLES=temp_TRAJSAMPLES;
% save 12samples.mat TRAJSAMPLES
% 
% %%
% load('12samples_DES.mat')
% temp_TRAJSAMPLES_DES = cell(1,360);
% for i = 1:12
%     temp_TRAJSAMPLES_DES(:,(i-1)*30+1:i*30) = TRAJSAMPLES_DES(:,indexsam{i});
% end
% TRAJSAMPLES_DES=temp_TRAJSAMPLES_DES;
% save 12samples_DES.mat TRAJSAMPLES_DES
% 
% load('12_DES.mat')
% temp_TRAJDB_DES = cell(1,360);
% for i = 1:12
%     temp_TRAJDB_DES(:,(i-1)*30+1:i*30) = TRAJDB_DES(:,index{i});
% end
% TRAJDB_DES=temp_TRAJDB_DES;
% save 12_DES.mat TRAJDB_DES








