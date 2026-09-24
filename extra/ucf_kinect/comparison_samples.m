function comparison_samples(marker, level)

fileprefix = '.mat';
matfilename = [marker fileprefix];
if exist(matfilename, 'file')
    load(matfilename);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end
samples_r = size(TRAJDB, 2);

for i = 1:samples_r
    directory_loca = find(TRAJDB{1, i} == '/');
    TRAJDB{1, i} = TRAJDB{1, i}(1:directory_loca(2) + 3);
end
dataGID = grp2idx(TRAJDB(1, :)');

EXPERIMENT_NUM = 50;
% level = 0.02;
for experiment_num = 1:EXPERIMENT_NUM

    % select trajectories randomly
    i = 1;
    while i < 21,
        indx = find(dataGID == i);
        indx = indx(randperm(length(indx), 1));
        original_trajectory{i} = TRAJDB{2, indx};
        i = i + 1;
    end

    trainGID = (1:20)'; testGID = (1:20)';
    theta_x = 30; tx = 200; % in degree
    theta_y = 0; ty = 100;
    theta_z = 45; tz = 0;
    s = 0.5; % scale factor
    for i = 1:20
        marker_xyz = original_trajectory{i};
        %     [marker_xyz max_limit min_original] = normalization(marker_xyz);

        mindim = min([max(marker_xyz(:, 1)) - min(marker_xyz(:, 1))...
                      max(marker_xyz(:, 2)) - min(marker_xyz(:, 2))...
                      max(marker_xyz(:, 3)) - min(marker_xyz(:, 3))]);
        maxdim = max([max(marker_xyz(:, 1)) - min(marker_xyz(:, 1))...
                      max(marker_xyz(:, 2)) - min(marker_xyz(:, 2))...
                      max(marker_xyz(:, 3)) - min(marker_xyz(:, 3))]);
        noise_f(i) = mindim / maxdim;
        if mindim < 1
            signal_p = mindim^2;
        else
            signal_p = sqrt(mindim);
        end
        marker_xyz(:, 1) = marker_xyz(:, 1) + (level * randn(1, size(marker_xyz, 1)) * signal_p)';
        marker_xyz(:, 2) = marker_xyz(:, 2) + (level * randn(1, size(marker_xyz, 1)) * signal_p)';
        marker_xyz(:, 3) = marker_xyz(:, 3) + (level * randn(1, size(marker_xyz, 1)) * signal_p)';

        marker_xyz(:, end + 1) = 1; % qici matrix
        marker_xyz = marker_xyz';
        marker_xyz = makehgtform('xrotate', (theta_x * pi) / 180) * marker_xyz;
        marker_xyz = makehgtform('yrotate', (theta_y * pi) / 180) * marker_xyz;
        marker_xyz = makehgtform('zrotate', (theta_z * pi) / 180) * marker_xyz;
        marker_xyz = makehgtform('xrotate', (theta_x * pi) / 180) * marker_xyz;
        marker_xyz = makehgtform('yrotate', (theta_y * pi) / 180) * marker_xyz;
        marker_xyz = makehgtform('zrotate', (theta_z * pi) / 180) * marker_xyz;
        marker_xyz = makehgtform('translate', tx, ty, tz) * marker_xyz;
        marker_xyz = makehgtform('scale', s) * marker_xyz;
        marker_xyz = marker_xyz';
        marker_xyz(:, end) = [];
        noise_trajectory{i} = marker_xyz;

    end

    samples = length(original_trajectory);
    for i = 1:samples
        marker_xyz = double(original_trajectory{i});
        fprintf ('%d of %d integral descriptor...\n', i, samples);
        %     fd = fft(marker_xyz);
        %     fd = fd./repmat(max(fd),size(fd,1),1);
        %     marker_des = fd(2:30,:);

        %     marker_des=descriptor_comp(marker_xyz);

        %     marker_des = integral_invariant(marker_xyz,8,0.08);

        marker_des = integral_invariant_ms(marker_xyz, 8, 0.3);
        marker_des = 0.5 - marker_des;

        TRAJDB_DES{1, i} = marker_des;
    end

    samples = length(noise_trajectory);
    for i = 1:samples
        marker_xyz = double(noise_trajectory{i});
        fprintf ('%d of %d noise integral descriptor...\n', i, samples);
        %     fd = fft(marker_xyz);
        %     fd = fd./repmat(max(fd),size(fd,1),1);
        %     marker_des = fd(2:30,:);

        %     marker_des=descriptor_comp(marker_xyz);

        %     marker_des = integral_invariant(marker_xyz,20,0.05);

        marker_des = integral_invariant_ms(marker_xyz, 15, 0.3);
        marker_des = 0.5 - marker_des;
        TRAJSAMPLES_DES{1, i} = marker_des;
    end

    samples_r = size(TRAJDB_DES, 2);
    samples_t = size(TRAJSAMPLES_DES, 2);
    dtw_distance = zeros(samples_t, samples_r);
    for i = 1:samples_t
        for j = 1:samples_r
            fprintf ('the %d/%d--%d recognition for integral descriptor...%2.2f%%\n', i, j, samples_r * samples_t, (samples_r * (i - 1) + j) * 100 / (samples_r * samples_t));
            %         dtw_distance(i,j)=dtw_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},1);
            [dtw_distance(i, j), ~, ~] = dtw_adj_comparison(TRAJSAMPLES_DES{1, i}, TRAJDB_DES{1, j}, 1, 50);
        end
    end

    [V I] = min(dtw_distance, [], 2); % sum up the recognition accurate ratio
    I'
    for i = 1:20
        for j = 1:20
            confusion_matrix(i, j) = length(find(testGID == i & trainGID(I) == j));
        end
    end
    recog_ratio_interg(experiment_num) = trace(confusion_matrix) / sum(confusion_matrix(:))
    confusion_matrix_interg{1, experiment_num} = confusion_matrix;
end

% save TRAJDB original_trajectory;save TRAJSAMPLES noise_trajectory;
for i = 1:16
    plot3d(original_trajectory{i});
    xlabel('X', 'FontWeight', 'bold'); ylabel('Y', 'FontWeight', 'bold'); zlabel('Z', 'FontWeight', 'bold');
    saveas(gcf, num2str(i), 'png')
end
for i = 1:16
    plot3d(noise_trajectory{i});
    xlabel('X', 'FontWeight', 'bold'); ylabel('Y', 'FontWeight', 'bold'); zlabel('Z', 'FontWeight', 'bold');
    saveas(gcf, strcat(num2str(i), 'samples'), 'png')
end
