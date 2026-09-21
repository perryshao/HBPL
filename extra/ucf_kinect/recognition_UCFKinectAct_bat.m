% modified to support running in occlusion situation -- modified by perry
clear all
% delete *.mat  % only run when firstly loading data
EXPERIMENT_TIMES=4;
CLASS_NUM = 16;% class numbers for classification task 
%% define the directory of c3d data and corresponding numbers of directories
BAT_FOLDER = 'UCFKinectSkeletonReal/';  %LOCATION OF C3D FILES
file_ext = '.ske';

distance_matrix_ssm = cell(1,EXPERIMENT_TIMES);
confusion_matrix_ssm = cell(1,EXPERIMENT_TIMES);
distance_matrix_diff = cell(1,EXPERIMENT_TIMES);
confusion_matrix_diff = cell(1,EXPERIMENT_TIMES);
compu_time_svm = zeros(1,EXPERIMENT_TIMES);
compu_time_diff = zeros(1,EXPERIMENT_TIMES);
compu_time_bof = zeros(1,EXPERIMENT_TIMES);
recog_ratio_diff = zeros(1,EXPERIMENT_TIMES);
recog_ratio_ssm = zeros(1,EXPERIMENT_TIMES);
%% define the joint name
RANK = '12' ;RKNE = '11';LANK = '15';LKNE = '14';
LELB = '8';LWRA = '9';RELB = '5';RWRA = '6';
STRN = '3';HEAD = '1';RSHO = '4';LSHO = '7';
LFWT = '13'; RFWT = '10';C7 ='2';
ENSEMBLE = 'ENSEMBLE';
%% load targets of joints
% partition joints into 4 groups
% joints_no = {RFIN RWRA,RELB,RSHO;...
%              LFIN LWRA,LELB,LSHO;...
%              RFWT,RKNE,RANK,RTOE;...
%              LFWT,LKNE,LANK,LTOE;};     
% partition joints into 20 groups

joints_no = {HEAD;C7;RWRA;RELB;RSHO;LWRA;LELB;LSHO;
             STRN;RFWT;RKNE;RANK; LFWT;LKNE;LANK;}; 
% jointNum = length(joints_no);


% [trainGID,testGID] = getLabels(joints_no);


% compare joints between themself with the hip-center joint and include the scale normalization      
pairJoints = { HEAD STRN;...
               C7 STRN;...
               RWRA STRN;...
               RELB STRN;...
               RSHO STRN;...
               LWRA STRN;...
               LELB STRN;...
               LSHO STRN;...
               RFWT STRN;...
               RKNE STRN;...
               RANK STRN;...
               LFWT STRN;...
               LKNE STRN;...
               LANK STRN;...
             }; 
jointNum = length(pairJoints);
% [trainGID,testGID] = getLabels(joints_no);
 

bodyJoints = { 
                       HEAD  RFWT;...
                       C7       RWRA;...
                       C7       LWRA;...
                       STRN  RANK;...
                       STRN  LANK;...
                       
                       HEAD  STRN;...
                       C7       RFWT;....
                       C7       RELB;...
                       RSHO  RWRA;...
                       C7       LELB;...
                       LSHO  LWRA;...
                       STRN  RKNE;...
                       RFWT RANK;...
                       STRN LKNE;...
                       LFWT LANK;...
                       
                       
                       HEAD  C7;...
                       C7       RSHO;...
                       RSHO  RELB;...
                       RELB   RWRA;...
                       C7       LSHO;...
                       LSHO  LELB;...
                       LELB   LWRA;...
                       C7      STRN;...
                       STRN RFWT;...
                       RFWT RKNE;...
                       RKNE RANK;...
                       STRN LFWT;...
                       LFWT LKNE;...
                       LKNE LANK;...
                      };
%  jointGroup = length(joints_no);
  jointGroup = size(bodyJoints,1);
 num_folds = 4;%4-fold cross-validation
 Normalize_Joints = {    
                                  C7 STRN;...
                                  RFWT LFWT;...        
                                }; %Normalize the skeleton using these key joints nearby the STRN joint
 
for experiment_num=1:num_folds  
    %% load data initially for the first running      
    load_UCFske_bat(joints_no,BAT_FOLDER);
	CV_DataCollect(joints_no,num_folds,experiment_num);
    [trainGID,testGID] = getLabels(joints_no);
    preprocess_bat(joints_no,1); 
   
    %% loading the original data
%     fprintf ('copying original data...\n');
%     for i=1:length(joints_no)
%         copymat_file = joints_no{1,i};
%         copyfile(['mat/' copymat_file '*.mat'],'../MSRActionEvaluatingCode/','f');
%     end
    %% add Guassian White Noise to Samples data
%     add_noise_bat(joints_no,noise_level(experiment_num));
    %% generate the self-similarity descriptors for represenation
    %     [PairDistFeats_DB,PairDistFeats_SAMPLES]  = GenePairDistFeats(pairJoints);
%     [PairDistFeats_DB,PairDistFeats_SAMPLES] = GenePairDistFeatsPerJoint(pairJoints);
    [PairDistFeats_DB,PairDistFeats_SAMPLES]  = GenePairDistFeatsBodyJoint(bodyJoints);
    [RRV_DB, RRV_SAMPLES] = GeneFeatsPerBody(bodyJoints,Normalize_Joints);
    
    [TSSMDB_HOG, TSSMSAMPLES_HOG]= GeneTSSM(pairJoints);
    [TSSMofParisDDB_HOG, TSSMofParisDSAMPLES_HOG]= GeneTSSMofParisD(pairJoints);
    [TSSMofRrvDDB_HOG, TSSMofRrvDSAMPLES_HOG]= GeneTSSMofRrvD(bodyJoints);
   %% SSM based sparse coding
    load TSSMDB_HOG.mat;load TSSMSAMPLES_HOG.mat;
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    % temporal pyramid baded on spooling sparce coding
    [traindata,testdata,sum_ScSPM_time] = GeneScCodeJointPyramid(TSSMDB_HOG,TSSMSAMPLES_HOG,jointNum, ntotalbh,1024,1);
    compu_time_bof(experiment_num) =sum_ScSPM_time/length(testGID);
    save traindata traindata; save testdata testdata; clear traindata testdata; % avoid Out of Memory
    clear TSSMDB_HOG TSSMSAMPLES_HOG;% to avoid Out of Memory
    
    %% pairDistance based spase coding
    load PairDistFeats_DB.mat; load PairDistFeats_SAMPLES.mat; 
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    % temporal pyramid baded on pooling fisher codes
%     [traindata,testdata,~] = GeneScCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,1);
    [traindata,testdata,~] = GeneScCodeJointPyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, jointNum, ntotalbh,128,0);
     save traindata traindata; save testdata testdata;clear traindata testdata; % avoid Out of Memory
     clear PairDistFeats_DB PairDistFeats_SAMPLES;% to avoid Out of Memory
     
     %% RRV based spase coding
    load RRV_DB.mat; load RRV_SAMPLES.mat; 
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    % temporal pyramid baded on pooling fisher codes
%     [traindata,testdata,~] = GeneScCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,1);
    [traindata,testdata,~] = GeneScCodeJointPyramid(RRV_DB,RRV_SAMPLES, jointGroup, ntotalbh,512,0);
     save traindata traindata; save testdata testdata;clear traindata testdata; % avoid Out of Memory
     clear PairDistFeats_DB PairDistFeats_SAMPLES;% to avoid Out of Memory
     %% the SSM of RRV based spase coding
    load TSSMofRrvDDB_HOG.mat; load TSSMofRrvDSAMPLES_HOG.mat; 
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    % temporal pyramid baded on pooling fisher codes
%     [traindata,testdata,~] = GeneScCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,1);
    [traindata,testdata,~] = GeneScCodeJointPyramid(TSSMofRrvDDB_HOG,TSSMofRrvDSAMPLES_HOG, jointGroup, ntotalbh,1024,0);
     save traindata traindata; save testdata testdata;clear traindata testdata; % avoid Out of Memory
     clear TSSMofRrvDDB_HOG TSSMofRrvDSAMPLES_HOG;% to avoid Out of Memory
    
    %% SSM based fisher vector coding % both self-similarity and pairs distances descriptors to be encoded by fisher vectors
    % only self-similarity descriptors to be encoded by fisher vectors
    load TSSMDB_HOG.mat;load TSSMSAMPLES_HOG.mat; load PairDistFeats_DB.mat; load PairDistFeats_SAMPLES.mat;
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    % temporal pyramid baded on pooling fisher codes
     [traindataOfpairD,testdataOfpairD,~] = GeneFisherCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,1);
%      [traindataOfpairD,testdataOfpairD,~] = GeneFisherCodeJointPyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, jointNum, ntotalbh,1);
     [traindataOfssm,testdataOfssm,~] = GeneFisherCodeJointPyramid(TSSMDB_HOG,TSSMSAMPLES_HOG,jointNum, ntotalbh,1);
     traindata = [traindataOfssm;traindataOfpairD];testdata = [testdataOfssm;testdataOfpairD];
     traindata = GetModalityData(traindata,jointNum,modalityNum,ntotalbh);
     testdata = GetModalityData(testdata,jointNum,modalityNum,ntotalbh); 
     save traindata traindata; save testdata testdata;clear traindata testdata; % avoid Out of Memory
     clear traindataOfssm testdataOfssm traindataOfpairD testdataOfpairD;
     clear TSSMDB_HOG TSSMSAMPLES_HOG PairDistFeats_DB PairDistFeats_SAMPLES;% to avoid Out of Memory
     
     %% SSM based fisher vector coding % only self-similarity descriptors to be encoded by fisher vectors
    load TSSMDB_HOG.mat;load TSSMSAMPLES_HOG.mat; 
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    % temporal pyramid baded on pooling fisher codes
     [traindata,testdata,~] = GeneFisherCodeJointPyramid(TSSMDB_HOG,TSSMSAMPLES_HOG,jointNum, ntotalbh,1);
     save traindata traindata; save testdata testdata;clear traindata testdata; % avoid Out of Memory
     clear TSSMDB_HOG TSSMSAMPLES_HOG;% to avoid Out of Memory
      %% RRV descriptors based fisher vector coding % only RRV descriptors to be encoded by fisher vectors
    load RRV_DB.mat; load RRV_SAMPLES.mat; 
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    numClusters = 32;
    jointNum = jointGroup; 
    % temporal pyramid baded on pooling fisher codes
%     [traindata,testdata,~] = GeneFisherCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,1);
     [traindata,testdata,~] = GeneFisherCodeJointPyramid(RRV_DB,RRV_SAMPLES, jointNum, ntotalbh, numClusters,0);
     save traindata traindata; save testdata testdata;clear traindata testdata; % avoid Out of Memory
     clear RRV_DB RRV_SAMPLES;% to avoid Out of Memory
     
     %% 2 modalities: RRV and pairDistFeats are encoded by  fisher vector coding, respectively. % 
    load RRV_DB.mat; load RRV_SAMPLES.mat; 
    load PairDistFeats_DB.mat; load PairDistFeats_SAMPLES.mat; 
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    numClusters = 32;
    jointNum = jointGroup; 
    modalityNum = 2;
    % temporal pyramid baded on pooling fisher codes
     [traindataOfQuan,testdataOfQuan,~] = GeneFisherCodeJointPyramid(RRV_DB,RRV_SAMPLES, jointNum, ntotalbh,numClusters,0);
     [traindataOfpaird,testdataOfpaird,~] = GeneFisherCodeJointPyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, jointNum, ntotalbh,numClusters,0);
     traindata = [traindataOfQuan;traindataOfpaird];testdata = [testdataOfQuan;testdataOfpaird];
     clear traindataOfQuan testdataOfQuan traindataOfpaird testdataOfpaird;
     clear RRV_DB1 RRV_SAMPLES1 RRV_DB2 RRV_SAMPLES2;% to avoid Out of Memory
    traindata = GetModalityData(traindata,jointNum,modalityNum,ntotalbh);
    testdata = GetModalityData(testdata,jointNum,modalityNum,ntotalbh);
    save traindata traindata; save testdata testdata; clear traindata testdata ; % avoid Out of Memory
    
     
      %% 2 modalities devided by RRV descriptors are encoded by  fisher vector coding, respectively. % 
    load RRV_DB1.mat; load RRV_SAMPLES1.mat; 
    load RRV_DB2.mat; load RRV_SAMPLES2.mat; 
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    numClusters = 32;
    jointNum = jointGroup; 
    modalityNum = 2;
    % temporal pyramid baded on pooling fisher codes
%     [traindata,testdata,~] = GeneFisherCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,1);
     [traindataOfQuan,testdataOfQuan,~] = GeneFisherCodeJointPyramid(RRV_DB1,RRV_SAMPLES1, jointNum, ntotalbh,numClusters,0);
     [traindataOfReV,testdataOfRev,~] = GeneFisherCodeJointPyramid(RRV_DB2,RRV_SAMPLES2, jointNum, ntotalbh,numClusters,0);
     traindata = [traindataOfQuan;traindataOfReV];testdata = [testdataOfQuan;testdataOfRev];
     clear traindataOfQuan testdataOfQuan traindataOfReV testdataOfRev;
     clear RRV_DB1 RRV_SAMPLES1 RRV_DB2 RRV_SAMPLES2;% to avoid Out of Memory
    traindata = GetModalityData(traindata,jointNum,modalityNum,ntotalbh);
    testdata = GetModalityData(testdata,jointNum,modalityNum,ntotalbh);
    save traindata traindata; save testdata testdata; clear traindata testdata ; % avoid Out of Memory
    
    %% Pairs Distant descriptors based fisher vector coding % only Pairs Distant descriptors to be encoded by fisher vectors
    load PairDistFeats_DB.mat; load PairDistFeats_SAMPLES.mat; 
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    % temporal pyramid baded on pooling fisher codes
%     [traindata,testdata,~] = GeneFisherCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,1);
     [traindata,testdata,~] = GeneFisherCodeJointPyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, jointNum, ntotalbh,1);
     save traindata traindata; save testdata testdata;clear traindata testdata; % avoid Out of Memory
     clear PairDistFeats_DB PairDistFeats_SAMPLES;% to avoid Out of Memory
     
    %% SSM and skeleton based sparse coding     
    load TSSMDB_HOG.mat;load TSSMSAMPLES_HOG.mat;load TSSMDB_SKELETON.mat;load TSSMSAMPLES_SKELETON.mat;
    load PairDistFeats_DB.mat; load PairDistFeats_SAMPLES.mat; 
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    modalityNum = 2;
    % pyramid baded on spooling sparce coding based on
    % self-similarity descriptor and skeleton features
    [traindataOfssm,testdataOfssm,~] = GeneScCodeJointPyramid(TSSMDB_HOG,TSSMSAMPLES_HOG,jointNum, ntotalbh,1024,0);
    [traindataOfskel,testdataOfskel,~] = GeneScCodeJointPyramid(TSSMDB_SKELETON,TSSMSAMPLES_SKELETON,jointNum, ntotalbh,1024,0);
    [traindataOfpaird,testdataOfpaird,~] = GeneScCodeJointPyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, jointNum, ntotalbh,128,0);
    traindata = [traindataOfssm;traindataOfskel;traindataOfpaird];testdata = [testdataOfssm;testdataOfskel;testdataOfpaird];
     clear traindataOfssm testdataOfssm traindataOfskel testdataOfskel traindataOfpaird testdataOfpaird;
     clear TSSMDB_HOG TSSMSAMPLES_HOG TSSMDB_SKELETON TSSMSAMPLES_SKELETON PairDistFeats_DB PairDistFeats_SAMPLES;% to avoid Out of Memory
    traindata = GetModalityData(traindata,jointNum,modalityNum,ntotalbh);
    testdata = GetModalityData(testdata,jointNum,modalityNum,ntotalbh);
    save traindata traindata; save testdata testdata; clear traindata testdata ; % avoid Out of Memory
    %% SSM and PairDistant based sparse coding     
%     load TSSMDB_HOG.mat;load TSSMSAMPLES_HOG.mat;load PairDistFeats_DB.mat;load PairDistFeats_SAMPLES.mat;
    load TSSMDB_HOG.mat;load TSSMSAMPLES_HOG.mat;load TSSMofParisDDB_HOG.mat; load TSSMofParisDSAMPLES_HOG.mat;
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    modalityNum = 2;
    % pyramid baded on spooling sparce coding based on
    % self-similarity descriptor and skeleton features
    [traindataOfssm,testdataOfssm,~] = GeneScCodeJointPyramid(TSSMDB_HOG,TSSMSAMPLES_HOG,jointNum, ntotalbh,1024,1);
%     [traindataOfpaird,testdataOfpaird,~] = GeneScCodeJointPyramid(PairDistFeats_DB,PairDistFeats_SAMPLES,jointNum, ntotalbh,128,0);
    [traindataOfpaird,testdataOfpaird,~] = GeneScCodeJointPyramid(TSSMofParisDDB_HOG,TSSMofParisDSAMPLES_HOG,jointNum, ntotalbh,512,1);
    
    traindata = [traindataOfssm;traindataOfpaird];testdata = [testdataOfssm;testdataOfpaird];
    traindata = GetModalityData(traindata,jointNum,modalityNum,ntotalbh);
    testdata = GetModalityData(testdata,jointNum,modalityNum,ntotalbh);
    save traindata traindata; save testdata testdata; clear traindata testdata ; % avoid Out of Memory
    clear traindataOfssm testdataOfssm traindataOfskel testdataOfskel;
    
%     clear TSSMDB_HOG TSSMSAMPLES_HOG TSSMDB_SKELETON TSSMSAMPLES_SKELETON;% to avoid Out of Memory
     clear TSSMDB_HOG TSSMSAMPLES_HOG TSSMofParisDDB_HOG TSSMofParisDSAMPLES_HOG;% to avoid Out of Memory
     
    %%%%%%%%%%% using predefined kernels%%%%%%%%%%%%%%%%%%%%%
%     numTrain = length(trainGID);numTest = length(testGID);
    
    % norm1 distance
%     Svm_kernel = @(X,Y)distance_matrix_norm1(X,Y);
%     K =  [ (1:numTrain)' , Svm_kernel(traindata,traindata) ];
%     KK = [ (1:numTest)'  , Svm_kernel(testdata,traindata)  ];

    % chi-square statistic
%     dist_func=@chi_square_statistics_fast; 
%     K =  [ (1:numTrain)' , pdist2(traindata,traindata,dist_func) ];
%     KK = [ (1:numTest)'  , pdist2(testdata,traindata,dist_func)  ];

    % cityblock, norm1
%     K =  [ (1:numTrain)' , pdist2(traindata,traindata,'cityblock') ];
%     KK = [ (1:numTest)'  , pdist2(testdata,traindata,'cityblock')  ];
    
    % Pyramid Matching kernel
    
%     Pyramid_kernel = @(X,Y)PyramidMatching(X,Y,ntotalbh,num_words);
%     K =  [ (1:numTrain)' , Pyramid_kernel(traindata,traindata) ];
%     model = svmtrain(trainGID,K,'-t 4 -b 1');
        

%     
%     tic;
%     KK = [ (1:numTest)'  , Pyramid_kernel(testdata,traindata)  ];
% 	[predict_label, accuracy, dec_values] = svmpredict(testGID,KK, model,'-b 1');
%     sum_time_svm = toc;
%     compu_time_svm(experiment_num) =sum_time_svm/size(testdata,1);

    %%%%%%%%%%% using linear kernels%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  load traindata.mat;model =  svmtrain(trainGID,traindata, '-c 1 -g 0.07 -t 0 -b 1');clear traindata;
  load testdata.mat;[predict_label, accuracy, dec_values] = svmpredict(testGID,testdata, model,'-b 1');clear testdata;
  
    
    %%%%%%%%%%% using linear kernels based on ScSPM%%%%%%%%%%%%%%%%%%%%%
    
    % Sparse Coding Pyramid Matching Linear SVM
    
    lambda = 0.1;     % regularization parameter for w
    load traindata.mat;[w, b, class_name] = li2nsvm_multiclass_lbfgs(traindata',trainGID, lambda);clear traindata;
    
    tic;
    load testdata.mat;[predict_label, ~] = li2nsvm_multiclass_fwd(testdata', w, b, class_name);clear testdata;
    sum_time_svm = toc;
    compu_time_ssm(experiment_num) =sum_time_svm/length(predict_label);

  
    %%%%%%%%%%%%%%%%% using stardard kernels  %%%%%%%%%%%%%%%%%%%%%%%%
%     model = svmtrain(trainGID,traindata,'-t 2 -b 0');
%     tic;
%     [predict_label1, accuracy1, dec_values1] = svmpredict(testGID,testdata, model,'-b 0');
%     sum_time_svm = toc;
%     compu_time_svm(experiment_num) =sum_time_svm/length(predict_label1);
        %%%%%%%%%%%%%%%%%%% using multiple binary regression %%%%%%%%%%%%%%%%%%%
        jointNum = jointGroup; % for single modality
        numTrain = length(trainGID);numTest = length(testGID);
        lambda = [0.01,0.5,0];modalityNum = 1;
        load traindata.mat;theta = trainBinRegression(traindata,trainGID,lambda,jointNum,modalityNum);save theta theta;clear traindata;
        load testdata.mat; predict_label = predictBinRegression(testdata,theta);clear testdata;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        confusion_matrix = zeros(CLASS_NUM,CLASS_NUM);
        for i = 1:CLASS_NUM
            for j = 1:CLASS_NUM
                confusion_matrix(i,j) = length(find(testGID == i & predict_label == j));
            end
        end
        
        recog_ratio_smml(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:));
        recog_ratio_final_smml = mean(recog_ratio_smml) %#ok<NOPTS>
        confusion_matrix_smml{1,experiment_num} = confusion_matrix;
  %% dtw for RRV descriptors  
  load RRV_DB.mat; load RRV_SAMPLES.mat;
  samples_r=size(RRV_DB,2);
  samples_t=size(RRV_SAMPLES,2);
  dtw_distance = zeros(samples_t,samples_r);
  for i=1:samples_t
      for j=1:samples_r
          fprintf ('the %d/%d--%d recognition for RRV descriptor...%2.2f%%\n',i,j,samples_r*samples_t,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
          [dtw_distance(i,j), ~, path]=dtw_adj_matching(RRV_SAMPLES{1,i},RRV_DB{1,j},50,jointGroup,10);
          %             [dtw_distance(i,j), ~, ~]=dtw_adj_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},50);
      end
  end
  [~,I]=min(dtw_distance,[],2); % sum up the recognition accurate ratio
  
  for i = 1:CLASS_NUM
      for j = 1:CLASS_NUM
          confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j));
      end
  end
  recog_ratio_rrv(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:)); %#ok<SAGROW>
  
  recog_ratio_final_rrv = mean(recog_ratio_rrv) %#ok<NOPTS>
  confusion_matrix_rrv{1,experiment_num} = confusion_matrix;
  distance_matrix_rrv{1,experiment_num} = dtw_distance;
  
    %% implement recognition using integral invariant
%     samples_r=size(INTEGRATE_DES,2);
%     samples_t=size(INTEGRATESAMPLES_DES,2);
%     dtw_distance = zeros(samples_t,samples_r);
%     for i=1:samples_t
%         for j=1:samples_r
%             fprintf ('the %d/%d--%d recognition for integral descriptor...%2.2f%%\n',i,j,samples_r*samples_t,(samples_r*(i-1)+j)*100/(samples_r*samples_t));
%             [dtw_distance(i,j), ~, path]=dtw_adj_matching(testdata{1,i},traindata{1,j},50,7);
% %             [dtw_distance(i,j), ~, ~]=dtw_adj_orien(TRAJSAMPLES_DES{1,i},TRAJDB_DES{1,j},INTEGRATESAMPLES_DES{1,i},INTEGRATE_DES{1,j},50); 
%         end   
%     end
%     [~,I]=min(dtw_distance,[],2); % sum up the recognition accurate ratio
%     
% 
%     for i = 1:CLASS_NUM
%         for j = 1:CLASS_NUM
%             confusion_matrix(i,j) = length(find(testGID == i & trainGID(I) == j)); 
%         end
%     end
%     recog_ratio_interg(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:)); %#ok<SAGROW>
%     
%     recog_ratio_final_interg = mean(recog_ratio_interg) %#ok<NOPTS>
%     confusion_matrix_interg{1,experiment_num} = confusion_matrix;
%     distance_matrix_interg{1,experiment_num} = dtw_distance;    
    
    %% save and delete data
    delete *.mat;
    save  RECOGNITION_TALBLE_INTERG distance_matrix_ssm distance_matrix_interg;
    save  RECOGNITION_RATIO confusion_matrix_ssm confusion_matrix_interg...
         recog_ratio_interg recog_ratio_ssm compu_time_svm compu_time_ssm compu_time_bof; %recog_ratio_svm;
    clearvars -except BAT_FOLDER EXPERIMENT_PARA experiment_num EXPERIMENT_TIMES  CLASS_SELECTED SAMPLES_NUM CLASS_NUM noise_level;
    load RECOGNITION_RATIO; load RECOGNITION_TALBLE_INTERG;
end
% close(h);
fprintf('Recognition task has completed!\n');
fclose('all');
clear all;

