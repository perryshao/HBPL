function [TSSMofParisDDB_HOG, TSSMofParisDSAMPLES_HOG] = GeneTSSMofParisD(joints_no)

load PairDistFeats_DB
samples_r = size(PairDistFeats_DB, 2);
groupNum = size(joints_no, 1);

%% Self-similarity descriptor of training data
TSSMofParisDDB_HOG = cell (1, samples_r);
for i = 1:samples_r
    fprintf ('%d of %d SSM descriptor...\n', i, samples_r);
    rows = size(PairDistFeats_DB{1, i}, 1);
    T = rows / groupNum;
    tempHog = zeros(T * groupNum, 150);
    for n = 1:groupNum
        desMatrix = PairDistFeats_DB{1, i}((n - 1) * T + 1:n * T, :);
        Image_TSSM = Temporal_SSM(desMatrix, 5, 1, 1, 0.25); % trajectory matrix,descrip_flag,kernel,belta,c
        Image_TSSM(Image_TSSM <= 0) = 0;
        %         Image_TSSM = floor(Image_TSSM*(2^16-1));
        Image_TSSM = floor((Image_TSSM / max(max(Image_TSSM))) * (2^16 - 1));
        Image_TSSM(isnan(Image_TSSM)) = 0;
        %         ssmDes = Log_hogcalculator(Image_TSSM);
        ssmDes = LogHog(Image_TSSM);
        tempHog((n - 1) * T + 1:n * T, :) =  ssmDes;
    end
    TSSMofParisDDB_HOG{1, i} =  tempHog;
end
save TSSMofParisDDB_HOG TSSMofParisDDB_HOG;

%% Self-similarity descriptor of test data
load PairDistFeats_SAMPLES
samples_t = size(PairDistFeats_SAMPLES, 2);
TSSMofParisDSAMPLES_HOG = cell (1, samples_t);
for i = 1:samples_t
    fprintf ('%d of %d samples SSM descriptor...\n', i, samples_t);
    rows = size(PairDistFeats_SAMPLES{1, i}, 1);
    T = rows / groupNum;
    tempHog = zeros(T * groupNum, 150);
    for n = 1:groupNum
        desMatrix = PairDistFeats_SAMPLES{1, i}((n - 1) * T + 1:n * T, :);
        Image_TSSM = Temporal_SSM(desMatrix, 5, 1, 1, 0.25);
        Image_TSSM(Image_TSSM <= 0) = 0;
        %          Image_TSSM = floor(Image_TSSM*(2^16-1));
        Image_TSSM = floor((Image_TSSM / max(max(Image_TSSM))) * (2^16 - 1));
        Image_TSSM(isnan(Image_TSSM)) = 0;
        %         ssmDes = Log_hogcalculator(Image_TSSM);
        ssmDes = LogHog(Image_TSSM);
        tempHog((n - 1) * T + 1:n * T, :) =  ssmDes;
    end
    TSSMofParisDSAMPLES_HOG{1, i} =  tempHog;
end
save TSSMofParisDSAMPLES_HOG TSSMofParisDSAMPLES_HOG;
