delete testdata.mat;
delete traindata.mat;
clear all
% delete *.mat  % only run when firstly loading data
EXPERIMENT_TIMES = 1;
experiment_num = EXPERIMENT_TIMES;
CLASS_NUM = 16; % class numbers for classification task
%% define the directory of c3d data and corresponding numbers of directories
BAT_FOLDER = 'UCFKinectSkeletonReal/';  % LOCATION OF C3D FILES
file_ext = '.ske';

distance_matrix_ssm = cell(1, EXPERIMENT_TIMES);
confusion_matrix_ssm = cell(1, EXPERIMENT_TIMES);
distance_matrix_diff = cell(1, EXPERIMENT_TIMES);
confusion_matrix_diff = cell(1, EXPERIMENT_TIMES);
compu_time_svm = zeros(1, EXPERIMENT_TIMES);
compu_time_diff = zeros(1, EXPERIMENT_TIMES);
compu_time_bof = zeros(1, EXPERIMENT_TIMES);
recog_ratio_diff = zeros(1, EXPERIMENT_TIMES);
recog_ratio_ssm = zeros(1, EXPERIMENT_TIMES);
%% define the joint name
RANK = '12'; RKNE = '11'; LANK = '15'; LKNE = '14';
LELB = '8'; LWRA = '9'; RELB = '5'; RWRA = '6';
STRN = '3'; HEAD = '1'; RSHO = '4'; LSHO = '7';
LFWT = '13'; RFWT = '10'; C7 = '2';
ENSEMBLE = 'ENSEMBLE';
%% load targets of joints
joints_no = {HEAD; C7; RWRA; RELB; RSHO; LWRA; LELB; LSHO
             STRN; RFWT; RKNE; RANK; LFWT; LKNE; LANK};

bodyJoints = {
              HEAD  RFWT; ...
              C7    RWRA; ...
              C7    LWRA; ...
              STRN  RANK; ...
              STRN  LANK
              HEAD  STRN; ...
              C7    RFWT; ....
              C7    RELB; ...
              RSHO  RWRA; ...
              C7    LELB; ...
              LSHO  LWRA; ...
              STRN  RKNE; ...
              RFWT RANK; ...
              STRN LKNE; ...
              LFWT LANK
              HEAD  C7; ...
              C7    RSHO; ...
              RSHO  RELB; ...
              RELB  RWRA; ...
              C7    LSHO; ...
              LSHO  LELB; ...
              LELB  LWRA; ...
              C7    STRN; ...
              STRN RFWT; ...
              RFWT RKNE; ...
              RKNE RANK; ...
              STRN LFWT; ...
              LFWT LKNE; ...
              LKNE LANK ...
             };
%  jointGroup = length(joints_no);
jointGroup = size(bodyJoints, 1);
Normalize_Joints = {
                    C7 STRN; ...
                    RFWT LFWT ...
                   }; % Normalize the skeleton using these key joints nearby the STRN joint

load_UCFske_bat(joints_no, BAT_FOLDER);
CS_DataCollect(joints_no);
[trainGID, testGID] = getLabels(joints_no);
[RRV_DB, RRV_SAMPLES] = GeneFeatsPerBody(bodyJoints, Normalize_Joints);
load RRV_DB.mat; load RRV_SAMPLES.mat;
ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)
numClusters = 32;
jointNum = jointGroup;
% temporal pyramid based on pooling fisher codes
%     [traindata,testdata,~] = GeneFisherCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,1);
[traindata, testdata, ~] = GeneFisherCodeJointPyramid(RRV_DB, RRV_SAMPLES, jointNum, ntotalbh, numClusters, 0, experiment_num);
save traindata traindata; save testdata testdata; clear traindata testdata; % avoid Out of Memory
clear RRV_DB RRV_SAMPLES; % to avoid Out of Memory

jointNum = jointGroup; % for single modality
numTrain = length(trainGID); numTest = length(testGID);
lambda = [0.01, 0.5, 0]; modalityNum = 1;
load traindata.mat; theta = trainBinRegression_norm1(traindata, trainGID, lambda, jointNum, modalityNum); clear traindata;
load testdata.mat; predict_label = predictBinRegression(testdata, theta); clear testdata;
load CSmodelForTest; modelForTest.theta = theta; save CSmodelForTest10 modelForTest; clear modelForTest;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1st type of svm linear classifier
% load traindata.mat;model =  svmtrain(trainGID,traindata', '-c 1 -g 0.07 -t 0 -b 1');clear traindata;
% load testdata.mat;[predict_label, accuracy, dec_values] = svmpredict(testGID,testdata', model,'-b 1');clear testdata;
%
% %2nd type of svm linear classifier
% lambda = 0.1;     % regularization parameter for w
% load traindata.mat;[w, b, class_name] = li2nsvm_multiclass_lbfgs(traindata',trainGID, lambda);clear traindata;
%
% tic;
% load testdata.mat;[predict_label, ~] = li2nsvm_multiclass_fwd(testdata', w, b, class_name);clear testdata;
% sum_time_svm = toc;
% compu_time_ssm(experiment_num) =sum_time_svm/length(predict_label);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
confusion_matrix = zeros(CLASS_NUM, CLASS_NUM);
for i = 1:CLASS_NUM
    for j = 1:CLASS_NUM
        confusion_matrix(i, j) = length(find(testGID == i & predict_label == j));
    end
end
recog_ratio_smml(experiment_num) = trace(confusion_matrix) / sum(confusion_matrix(:));
recog_ratio_final_smml = mean(recog_ratio_smml) %#ok<NOPTS>
confusion_matrix_smml{1, experiment_num} = confusion_matrix;
