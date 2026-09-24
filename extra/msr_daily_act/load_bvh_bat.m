function load_bvh_bat(joints_no, random_seed, CLASS_SELECTED, BAT_FOLDER)
file_ext = '.bvh';
fileprefix = '.mat';
samplesfileprefix = 'samples.mat';
joints_num = size(joints_no, 2);
joints = zeros(1, joints_num);
for i = 1:joints_num
    joints(1, i) = str2double(joints_no{i});
end
joints_no = joints;
clear joints
%% read random db data from class folder
folder_content = dir(BAT_FOLDER);
class_num = size(folder_content, 1);
class_selected_num = size(CLASS_SELECTED, 2);
for n = 3:class_num  % 2 class recognition, you can define it arbitrarily
    flag_class_num = CLASS_SELECTED - ones(1, class_selected_num) * (n - 2);
    if all(flag_class_num) == 0
        if folder_content(n, 1).isdir == 1
            class_folder = folder_content(n, 1).name
            data_folder = [BAT_FOLDER class_folder '/'];
            class_folder_content = dir ([data_folder, '*', file_ext]);
            ndata = size (class_folder_content, 1);
            random_db = round(random_seed * ndata);
            random_db(find(random_db == 0)) = 1;
            random_db(find(random_db > ndata)) = ndata;
            for k = 1:ndata;
                string = [data_folder, class_folder_content(k, 1).name];
                fprintf ('Loading txt data...%s\n', string);
                %% read the bvh files
                [~, mot] = readMocap(string);
                bvh_data = mot.jointTrajectories(joints_no, 1);
                %% detect and distinguish the db and samples data.
                col = size(random_seed, 2);
                flag_samples_num = random_db - ones(1, col) * k;
                %% get required bvh joint 3D data
                for i = 1:joints_num
                    %% identify whether there have a mat file in db
                    matfilename = [num2str(joints_no(i)) fileprefix];
                    if exist(matfilename, 'file')
                        load(matfilename);
                    else
                        TRAJDB = cell (2, []);
                    end
                    %% identify whether there have a mat file in samples
                    matfilename = [num2str(joints_no(i)) samplesfileprefix];
                    if exist(matfilename, 'file')
                        load(matfilename);
                    else
                        TRAJSAMPLES = cell (2, []);
                    end
                    %% detect and distinguish the db and samples data.
                    if all(flag_samples_num) == 0
                        TRAJDB{1, end + 1} = string;
                        TRAJDB{2, end} = (bvh_data{i, 1} + mot.rootTranslation)';
                    else
                        TRAJSAMPLES{1, end + 1} = string;
                        TRAJSAMPLES{2, end} = (bvh_data{i, 1} + mot.rootTranslation)';
                    end
                    save(num2str(joints_no(i)), 'TRAJDB');
                    save(matfilename, 'TRAJSAMPLES');
                    clear TRAJDB TRAJSAMPLES
                end
            end
        end
    end
    %     closec3d(itf);
end
fclose('all');
