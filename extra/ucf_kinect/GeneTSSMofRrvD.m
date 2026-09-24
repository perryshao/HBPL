function [TSSMofRrvDDB_HOG, TSSMofRrvDSAMPLES_HOG] = GeneTSSMofRrvD(bodyJoints)
load RRV_DB
samples_r = size(RRV_DB, 2);
groupNum = size(bodyJoints, 1);

%% Self-similarity descriptor of training data
TSSMofRrvDDB_HOG = cell (1, samples_r);
for i = 1:samples_r
    fprintf ('%d of %d SSM descriptor...\n', i, samples_r);
    rows = size(RRV_DB{1, i}, 1);
    T = rows / groupNum;
    tempHog = zeros(T * groupNum, 150);
    for n = 1:groupNum
        desMatrix = RRV_DB{1, i}((n - 1) * T + 1:n * T, :);
        Image_TSSM = Temporal_SSM(desMatrix, 10, 1, 1, 0.15); % trajectory matrix,descrip_flag,kernel,belta,c
        Image_TSSM(Image_TSSM <= 0) = 0;
        %         Image_TSSM = floor(Image_TSSM*(2^16-1));
        Image_TSSM = floor((Image_TSSM / max(max(Image_TSSM))) * (2^16 - 1));
        Image_TSSM(isnan(Image_TSSM)) = 0;
        %         ssmDes = Log_hogcalculator(Image_TSSM);
        ssmDes = LogHog(Image_TSSM);
        tempHog((n - 1) * T + 1:n * T, :) =  ssmDes;
    end
    TSSMofRrvDDB_HOG{1, i} =  tempHog;
end
save TSSMofRrvDDB_HOG TSSMofRrvDDB_HOG;

%% Self-similarity descriptor of test data
load RRV_SAMPLES
samples_t = size(RRV_SAMPLES, 2);
TSSMofRrvDSAMPLES_HOG = cell (1, samples_t);
for i = 1:samples_t
    fprintf ('%d of %d samples SSM descriptor...\n', i, samples_t);
    rows = size(RRV_SAMPLES{1, i}, 1);
    T = rows / groupNum;
    tempHog = zeros(T * groupNum, 150);
    for n = 1:groupNum
        desMatrix = RRV_SAMPLES{1, i}((n - 1) * T + 1:n * T, :);
        Image_TSSM =  Temporal_SSM(desMatrix, 10, 1, 1, 0.15);
        Image_TSSM(Image_TSSM <= 0) = 0;
        %          Image_TSSM = floor(Image_TSSM*(2^16-1));
        Image_TSSM = floor((Image_TSSM / max(max(Image_TSSM))) * (2^16 - 1));
        Image_TSSM(isnan(Image_TSSM)) = 0;
        %         ssmDes = Log_hogcalculator(Image_TSSM);
        ssmDes = LogHog(Image_TSSM);
        tempHog((n - 1) * T + 1:n * T, :) =  ssmDes;
    end
    TSSMofRrvDSAMPLES_HOG{1, i} =  tempHog;
end
save TSSMofRrvDSAMPLES_HOG TSSMofRrvDSAMPLES_HOG;
