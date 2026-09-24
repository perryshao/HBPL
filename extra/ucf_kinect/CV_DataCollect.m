function CV_DataCollect(joints_no, num_folds, num_test)

load([joints_no{1} '.mat']);
samples_n = size(Data, 2);
if num_test == 1
    idx = randperm(samples_n);
    save idx idx;
else
    load idx;
end
n_test = floor(samples_n / num_folds);
test_idx = idx((num_test - 1) * n_test + 1:num_test * n_test);
temp = 1:samples_n;
temp(test_idx) = [];
train_idx = temp;
TRAJDB = cell(2, samples_n - n_test);
TRAJSAMPLES = cell(2, n_test);
for i = 1:length(joints_no)
    load([joints_no{i} '.mat']);
    n = 1;
    for j = train_idx
        TRAJDB{1, n} = Data{1, j};
        TRAJDB{2, n} = Data{2, j};
        n = n + 1;
    end
    m = 1;
    for j = test_idx
        TRAJSAMPLES{1, m} = Data{1, j};
        TRAJSAMPLES{2, m} = Data{2, j};
        m = m + 1;
    end
    save(joints_no{i}, 'TRAJDB');
    save([joints_no{i} 'samples.mat'], 'TRAJSAMPLES');
end
