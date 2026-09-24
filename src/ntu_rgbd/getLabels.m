function [trainGID, testGID] = getLabels(joints_no)
% GETLABELS Read labels from prepared training and test trajectory tables.
%   This function reads an existing split; it does not split raw skeletons.
load([joints_no{1, 1} '.mat']);
load([joints_no{1, 1} 'samples.mat']);
samples_r = size(TRAJDB_CV, 2);
samples_t = size(TRAJSAMPLES_CV, 2);
trainGID = zeros(samples_r, 1);
testGID = zeros(samples_t, 1);
for i = 1:samples_r
    trainGID(i) = TRAJDB_CV{1, i};
end
for i = 1:samples_t
    testGID(i) =  TRAJSAMPLES_CV{1, i};
end
