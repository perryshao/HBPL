function CS_DataCollect(joints_no)

load([joints_no{1} '.mat']);
samples_n = size(Data, 2);
TRAJDB = cell(2, samples_n / 2);
TRAJSAMPLES = cell(2, samples_n / 2);
TRAJDB_idx = zeros(1, samples_n / 2);
TRAJSAMPLES_idx = zeros(1, samples_n / 2);
m = 1; n = 1;
for j = 1:samples_n
    actionName = find(Data{1, j} == '/');
    subject = str2double(Data{1, j}(actionName(2) + 1:actionName(2) + 2));
    if mod(subject, 2) == 0
        TRAJSAMPLES_idx(m) = j;
        m = m + 1;
    else
        TRAJDB_idx(n) = j;
        n = n + 1;
    end
end
clear Data;
for i = 1:length(joints_no)
    load([joints_no{i} '.mat']);

    TRAJSAMPLES(1, :) = Data(1, TRAJSAMPLES_idx);
    TRAJSAMPLES(2, :) = Data(2, TRAJSAMPLES_idx);
    TRAJDB(1, :) = Data(1, TRAJDB_idx);
    TRAJDB(2, :) = Data(2, TRAJDB_idx);

    save(joints_no{i}, 'TRAJDB');
    save([joints_no{i} 'samples.mat'], 'TRAJSAMPLES');
end
