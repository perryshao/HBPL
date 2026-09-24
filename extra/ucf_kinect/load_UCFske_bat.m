function load_UCFske_bat(joints_no, BAT_FOLDER)
file_ext = '.ske';
fileprefix = '.mat';
db_i = 0; samples_i = 0; class_i = 0;
joints_no = reshape(joints_no, 1, size(joints_no, 1) * size(joints_no, 2));
joints_num = size(joints_no, 2);
joints = zeros(1, joints_num);
for i = 1:joints_num
    joints(1, i) = str2double(joints_no{i});
end
joints_no = joints;
clear joints

%% read random db data from class folder
% folder_content = dir(BAT_FOLDER);
% directory_num=size(folder_content,1);
% for n = 3:directory_num  % 2 class recognition, you can define it arbitrarily
%     class_i = class_i+1;
%     if folder_content(n,1).isdir==1
%         class_folder = folder_content(n,1).name;
%         data_folder=[BAT_FOLDER class_folder '/'];
%         class_folder_content = dir ([data_folder,'*',file_ext]);
%         ndata = size (class_folder_content,1);
%         Data_temp = cell(2,joints_num*ndata);
%         for k = 1:ndata;
%             string= [data_folder,class_folder_content(k,1).name];
%             fprintf ('Loading ske data...%s\n',string);
%             % read the bvh files
%             [X Y Z] = readUCFske(string);
%             % get required txt joint 3D data
%             for i = 1:joints_num
%                     Data_temp{1,(k-1)*joints_num+i}= string;
%                     Data_temp{2,(k-1)*joints_num+i} = [X(joints_no(i),:)' Y(joints_no(i),:)' Z(joints_no(i),:)'];
%             end
%         end
%     end
% end
% save Database Data_temp;
load Database;
for i  = 1:joints_num,
    matfilename = [num2str(joints_no(i)) fileprefix];
    if exist(matfilename, 'file')
        load(matfilename);
    else
        Data = cell(2, ndata);
    end
    Data = [Data_temp(1, i:joints_num:end); Data_temp(2, i:joints_num:end)];
    save(num2str(joints_no(i)), 'Data');
end
fclose('all');
