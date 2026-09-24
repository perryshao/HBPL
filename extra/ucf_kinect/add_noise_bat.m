function add_noise_bat(joints_no, noise_level, occlu_ratio)
%% define the joint name
m_num = length(joints_no);
indx = randperm(m_num);
occlu_flag = 0;
level = 0;
for j = 1:m_num
    fprintf ('adding noise into the test data...%s\n', joints_no{j});
    %     add_noise(joints_no{1,j},level);
    if any(indx(1:3) == j) && occlu_ratio ~= 0
        occlu_flag = 1;
    end
    if any(indx(1:3) == j) && noise_level ~= 0
        level = noise_level;
    end
    addNoiseForMBPL(joints_no{j}, level, occlu_flag, occlu_ratio);
end
