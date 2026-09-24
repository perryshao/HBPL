function [RRV_DB, RRV_SAMPLES]  = GeneFeatsPerBody(bodyJoints)
%% compute the axises betweeen the root point and reference point for each rigid body --- for training set
load DB;
samples_r = size(TRAJDB, 2);
RRV_DB = cell(1, samples_r);
Joint_ID = bodyJoints;
% Parameters for computing shape context
mean_dist_global = []; % use [] to estimate scale from the data
nbins_theta = 18;
nbins_alpha = 9;
nbins_r = 10;
ndum1 = 0;
eps_dum = 0.15;
r_inner = 0.1;
r_outer = 2.5;
total_bins = nbins_theta * nbins_alpha * nbins_r;

%% compute the 3D shape_context
for i = 1:samples_r
    fprintf ('get the 3D shape context descriptors for training data %d/%d...\n', i, samples_r);
    m = 0;
    for n = str2double(Joint_ID)
        m = m + 1;
        marker_xyz = TRAJDB{2, i}(:, (n - 1) * 3 + 1:n * 3);
        NaN_index = isnan(marker_xyz(:, 1));
        marker_xyz(NaN_index, :) = [];
        nsamp1 = size(marker_xyz, 1);
        % outliers on each iteration
        out_vec_1 = zeros(1, nsamp1 - 4); % beging and ending elements are excluded
        % Frenet Frames
        FrenetVector = Estimate_Frenet(marker_xyz, 20);
        FVector = FrenetVector(3:end - 2, :);
        % compute shape contexts for (transformed) model
        Bsamp = marker_xyz(3:end - 2, :);
        [BH_theta, BH_alpha, mean_dist_1] = sc3d_compute(Bsamp', FVector', mean_dist_global, nbins_theta, nbins_alpha, nbins_r, r_inner, r_outer, out_vec_1);
        RRV_DB{1, i}((m - 1) * total_bins:m * total_bins, :)  = cat(2, BH_theta, BH_alpha);
    end
end

%% compute the 3D shape context for test set
load SAMPLES;
samples_t = size(TRAJSAMPLES, 2);
RRV_SAMPLES = cell(1, samples_r);
for i = 1:samples_t
    fprintf ('get the 3D shape context descriptors for testing data %d/%d...\n', i, samples_r);
    m = 0;
    for n = str2double(Joint_ID)
        m = m + 1;
        marker_xyz = TRAJSAMPLES{2, i}(:, (n - 1) * 3 + 1:n * 3);
        NaN_index = isnan(marker_xyz(:, 1));
        marker_xyz(NaN_index, :) = [];
        nsamp1 = size(marker_xyz, 1);
        % outliers on each iteration
        out_vec_1 = zeros(1, nsamp1 - 4); % beging and ending elements are excluded
        % Frenet Frames
        FrenetVector = Estimate_Frenet(marker_xyz, 20);
        FVector = FrenetVector(3:end - 2, :);
        % compute shape contexts for (transformed) model
        Bsamp = marker_xyz(3:end - 2, :);
        [BH_theta, BH_alpha, mean_dist_1] = sc3d_compute(Bsamp', FVector', mean_dist_global, nbins_theta, nbins_alpha, nbins_r, r_inner, r_outer, out_vec_1);
        RRV_SAMPLES{1, i}((m - 1) * total_bins:m * total_bins, :)  = cat(2, BH_theta, BH_alpha);
    end
end
save RRV_DB RRV_DB;
save RRV_SAMPLES RRV_SAMPLES;
