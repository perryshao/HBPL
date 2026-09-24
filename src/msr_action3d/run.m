% RUN Execute the MSR-Action3D HBPL pipeline using prepared trajectory tables.
%   Run hbplSetup('msr_action3d') first. The current folder must contain
%   <jointId>.mat and <jointId>samples.mat with TRAJDB and TRAJSAMPLES.
%   getLabels reads the existing split; raw-data preparation is not included.

clear;
experiment_num = 1;
EXPERIMENT_TIMES = experiment_num; % only run 1 time for the cross-subject experiment
CLASS_NUM = 20; % the number of class category
%% define the directory of c3d data and corresponding numbers of directories
BAT_FOLDER = 'MSRAction3DSkeletonReal3D/';  % location of raw skeleton files
file_ext = '.txt'; % the extension of skeleton files

distance_matrix_smml = cell(1, EXPERIMENT_TIMES);
confusion_matrix_smml = cell(1, EXPERIMENT_TIMES);
distance_matrix_diff = cell(1, EXPERIMENT_TIMES);
confusion_matrix_diff = cell(1, EXPERIMENT_TIMES);
compu_time_svm = zeros(1, EXPERIMENT_TIMES);
compu_time_diff = zeros(1, EXPERIMENT_TIMES);
compu_time_bof = zeros(1, EXPERIMENT_TIMES);
recog_ratio_diff = zeros(1, EXPERIMENT_TIMES);
recog_ratio_smml = zeros(1, EXPERIMENT_TIMES);
%% define the joint name
RANK = '16'; RKNE = '14'; LANK = '17'; LKNE = '15';
LELB = '9'; LWRA = '11'; RELB = '8'; RWRA = '10';
STRN = '7'; HEAD = '20'; RSHO = '1'; LSHO = '2';
LFWT = '6'; RFWT = '5'; C7 = '3'; T10 = '4';
RFIN = '12'; LFIN = '13'; RTOE = '18'; LTOE = '19';
ENSEMBLE = 'ENSEMBLE';
%% joints number in the skeleton of MSR-Action3D
joints_no = {HEAD; C7; RFIN; RWRA; RELB; RSHO; LFIN; LWRA; LELB; LSHO
             T10; STRN; RFWT; RKNE; RANK; RTOE; LFWT; LKNE; LANK; LTOE};
% joint groups for virtual rigid bodies
bodyJoints = {
              HEAD STRN; ...
              C7   RFIN; ...
              C7   LFIN; ...
              STRN RTOE; ...
              STRN LTOE
              HEAD T10; ...
              C7   STRN; ....
              C7   RELB; ...
              RELB RFIN; ...
              C7   LELB; ...
              LELB LFIN; ...
              STRN RKNE; ...
              RKNE RTOE; ...
              STRN LKNE; ...
              LKNE LTOE
              HEAD  C7; ...
              C7    RSHO; ...
              RSHO  RELB; ...
              RELB  RWRA; ...
              RWRA RFIN; ...
              C7    LSHO; ...
              LSHO  LELB; ...
              LELB  LWRA; ...
              LWRA LFIN; ...
              C7    T10; ...
              T10   STRN; ...
              STRN  RFWT; ...
              RFWT  RKNE; ...
              RKNE  RANK; ...
              RANK  RTOE; ...
              STRN  LFWT; ...
              LFWT  LKNE; ...
              LKNE  LANK; ...
              LANK  LTOE ...
             };
jointGroup = size(bodyJoints, 1);
% jointGroup = length(joints_no);
Normalize_Joints = {
                    C7   STRN; ...
                    RFWT LFWT ...
                   }; % Normalize the skeleton using these key joints nearby the STRN joint
% fprintf ('copying original data...\n');
% for i=1:length(joints_no)
%     copymat_file = joints_no{i};
%     copyfile(['mat/' copymat_file '*.mat'],'../MSRActionEvaluatingCode/','f');
% end
[trainGID, testGID] = getLabels(joints_no);
[RRV_DB, RRV_SAMPLES] = GeneFeatsPerBody(bodyJoints, Normalize_Joints);
% [PairDistFeats_DB,PairDistFeats_SAMPLES] = GenePairDistFeatsPerJoint(joints_no);
load RRV_DB.mat; load RRV_SAMPLES.mat;
ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)
numClusters = 32;
jointNum = jointGroup;
% temporal pyramid based on pooling fisher codes
%     [traindata,testdata,~] = GeneFisherCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,1);
[traindata, testdata, ~] = GeneFisherCodeJointPyramid(RRV_DB, RRV_SAMPLES, jointNum, ntotalbh, numClusters, 0);
save traindata traindata; save testdata testdata; clear traindata testdata; % avoid Out of Memory
clear RRV_DB RRV_SAMPLES; % to avoid Out of Memory
jointNum = jointGroup; % for single modality
numTrain = length(trainGID); numTest = length(testGID);
%         lambda = [0.01,0.5,0];modalityNum = 1;
lambda = [0.01, 0.5, 0.0]; modalityNum = 1;
load traindata.mat; theta = trainBinRegression(traindata, trainGID, lambda, jointNum, modalityNum); clear traindata;
load testdata.mat; predict_label = predictBinRegression(testdata, theta); clear testdata;
load modelForTest; modelForTest.theta = theta; save modelForTest modelForTest; clear modelForTest;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1st type of svm linear classifier
% load traindata.mat;model =  svmtrain(trainGID,traindata', '-c 1 -g 0.07 -t 0 -b 1');clear traindata;
% load testdata.mat;[predict_label, accuracy, dec_values] = svmpredict(testGID,testdata', model,'-b 1');clear testdata;

% 2nd type of svm linear classifier
% lambda = 0.1;     % regularization parameter for w
% load traindata.mat;[w, b, class_name] = li2nsvm_multiclass_lbfgs(traindata',trainGID, lambda);clear traindata;

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
