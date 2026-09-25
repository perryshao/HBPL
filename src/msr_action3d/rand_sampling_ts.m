function [X] = rand_sampling_ts(TRAJDB_DES, num_smp)
% sample local features for unsupervised codebook training

num_training = length(TRAJDB_DES); % num of images
num_per_training = round(num_smp / num_training);
num_smp = num_per_training * num_training;
dimFea = size(TRAJDB_DES{1, 1}, 2);

X = zeros(dimFea, num_smp);
cnt = 0;

for ii = 1:num_training,
    num_fea = size(TRAJDB_DES{1, ii}, 1);
    rndidx = randperm(num_fea);
    if num_fea == 0
        error('rand_sampling_ts:emptyClip', 'Cannot sample an empty descriptor clip.');
    end
    % Repeat the shuffled cycle when a small clip cannot fill the sample quota.
    % For quotas up to two cycles, this preserves the historical ordering.
    if num_per_training > num_fea
        rndidx = repmat(rndidx, 1, ceil(num_per_training / num_fea));
    end
    X(:, cnt + 1:cnt + num_per_training) = TRAJDB_DES{1, ii}(rndidx(1:num_per_training), :)';
    cnt = cnt + num_per_training;
end;
