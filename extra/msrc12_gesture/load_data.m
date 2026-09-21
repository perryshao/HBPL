function load_data(joints_no,shuffle_sort)
load MSRC12_Skeleton;
class_no = size(SmthTrj,1);
subject_no = size(SmthTrj,2);
joints_num = length(joints_no);
joints = zeros(1,joints_num);
TRAJDB = cell(2,[]);
TRAJSAMPLES = cell(2,[]);
for i = 1:joints_num
     joints(1,i) = str2double(joints_no{i});
end
for i = 1:class_no
    for j = 1:subject_no
        Traj_Data = SmthTrj{i,j};
        if i==6&&j==18
            continue;
        end
        for k = 1:joints_num
            fprintf('loading the samples %d-%d-%d\n',i,j,k)
            if ismember(j,shuffle_sort(1,:)) 
                for n = 1:length(Traj_Data(joints(1,k),:));
                    TRAJDB{2,end+1} = Traj_Data{joints(1,k),n};
                    TRAJDB{1,end} =[i,j,k];
                end
            else
                for n = 1:length(Traj_Data(joints(1,k),:));
                    TRAJSAMPLES{2,end+1} = Traj_Data{joints(1,k),n};
                    TRAJSAMPLES{1,end} =[i,j,k];
                end
            end
        end 
    end
end

save DB TRAJDB;
save SAMPLES TRAJSAMPLES;





