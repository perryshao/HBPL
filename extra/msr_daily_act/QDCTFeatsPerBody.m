function [RrvDCT_DB, RrvDCT_SAMPLES]  = QDCTFeatsPerBody(bodyJoints)

load RRV_DB
samples_r = size(RRV_DB, 2);
groupNum = size(bodyJoints, 1);

% parameters for  QDCT
absexp = 2; % best value yet with 2.1 (heavily influences the result(s))
dctaxis = unit(quaternion(-1, -1, -1)); % the QDCT axis
L = 'L'; % Left- ('L') or Right-sided ('R') QDCT
do_normalize = true;

%% Self-similarity descriptor of training data
RrvDCT_DB = cell (1, samples_r);
for i = 1:samples_r
    fprintf ('%d of %d RrvDCT descriptor...\n', i, samples_r);
    rows = size(RRV_DB{1, i}, 1);
    T = rows / groupNum;
    tempQCT = zeros(T * groupNum, 1);
    for n = 1:groupNum
        QuaterMatrix = RRV_DB{1, i}((n - 1) * T + 1:n * T, 1:4);
        QIR = quaternion(QuaterMatrix(:, 1), QuaterMatrix(:, 2), QuaterMatrix(:, 3), QuaterMatrix(:, 4));
        mu = unit(dctaxis); % ensure a unit (pure) quaternion as axis
        DCTIR = qdct2(QIR, mu, L);
        IDCTIR = iqdct2(sign(DCTIR), mu, L);
        S = abs(IDCTIR).^absexp;
        if do_normalize
            S = S - min(min(S));
            S = S / max(max(S));
        end
        tempQCT((n - 1) * T + 1:n * T, :) =  S;
    end
    RrvDCT_DB{1, i} =  tempQCT;
end
save RrvDCT_DB RrvDCT_DB;

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
