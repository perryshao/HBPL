function mj = smij_feature(joints_no, m_num, fixed_window)

fileprefix = '.mat';
matfilename = [joints_no{1, 1} fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
samples = size(TRAJDB, 2);
mj = cell(samples, 1);
for i = 1:samples
    fprintf ('%d of %d looking for mj joints...\n', i, samples);
    fileprefix = '.mat';
    joint_num = length(joints_no);
    var_xyz = zeros(1, joint_num);
    for j = 1:joint_num
        matfilename = [joints_no{1, j} fileprefix];
        if exist(matfilename, 'file')
            load(matfilename);
        else
            fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
        end
        marker_xyz = double(TRAJDB{2, i});
        %          fixed_window = fix(size(marker_xyz,1)/m_seg);
        m_seg = fix(size(marker_xyz, 1) / fixed_window);
        window_begin = 1;
        for m = 1:m_seg
            if m == m_seg
                var_xyz(m, j) = norm(var(marker_xyz(window_begin:end, :)), 1);
                window_begin = window_end;
            else
                window_end = fixed_window * m;
                var_xyz(m, j) = norm(var(marker_xyz(window_begin:window_end, :)), 1);
                window_begin = window_end;
            end
        end
    end
    [~, index] = sort(var_xyz, 2, 'descend');
    mj{i} = index(:, 1:m_num);
end
