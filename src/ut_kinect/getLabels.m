function [trainGID, testGID] = getLabels(joints_no)
% GETLABELS Read labels from prepared training and test trajectory tables.
%   This function reads an existing split; it does not split raw skeletons.
load([joints_no{1, 1} '.mat']);
load([joints_no{1, 1} 'samples.mat']);
samples_r = size(TRAJDB, 2);
samples_t = size(TRAJSAMPLES, 2);
trainGID = zeros(samples_r, 1);
testGID = zeros(samples_t, 1);
for i = 1:samples_r
    [~, line] = strtok(TRAJDB{1, i}, '/');
    switch lower(line)
        case '/walk:'
            trainGID(i) = 1;
        case '/sitdown:'
            trainGID(i) = 2;
        case '/standup:'
            trainGID(i) = 3;
        case '/pickup:'
            trainGID(i) = 4;
        case '/carry:'
            trainGID(i) = 5;
        case '/throw:'
            trainGID(i) = 6;
        case '/push:'
            trainGID(i) = 7;
        case '/pull:'
            trainGID(i) = 8;
        case '/wavehands:'
            trainGID(i) = 9;
        case '/claphands:'
            trainGID(i) = 10;
        otherwise
            disp('Unknown actions.')
    end
end

for i = 1:samples_t
    [~, line] = strtok(TRAJSAMPLES{1, i}, '/');
    switch lower(line)
        case '/walk:'
            testGID(i) = 1;
        case '/sitdown:'
            testGID(i) = 2;
        case '/standup:'
            testGID(i) = 3;
        case '/pickup:'
            testGID(i) = 4;
        case '/carry:'
            testGID(i) = 5;
        case '/throw:'
            testGID(i) = 6;
        case '/push:'
            testGID(i) = 7;
        case '/pull:'
            testGID(i) = 8;
        case '/wavehands:'
            testGID(i) = 9;
        case '/claphands:'
            testGID(i) = 10;
        otherwise
            disp('Unknown actions.')
    end
end
