function [trainGID, testGID] = getLabels()
load DB; load SAMPLES;
train_num = size(TRAJDB, 2); test_num = size(TRAJSAMPLES, 2);
trainGID = zeros(train_num, 1);
testGID = zeros(test_num, 1);
for n = 1:size(TRAJDB, 2)
    trainGID(n) = TRAJDB{1, n}(1);
end
for n = 1:size(TRAJSAMPLES, 2)
    testGID(n) = TRAJSAMPLES{1, n}(1);
end
