modelForTest = cell(1,4);
% save modelFortest14 modelForTest
for experiment_num = 1:4;
	delete testdata.mat;
	delete traindata.mat;
	load_UCFske_bat(joints_no,BAT_FOLDER);
	CV_DataCollect(joints_no,num_folds,experiment_num);
	[trainGID,testGID] = getLabels(joints_no);
	[RRV_DB, RRV_SAMPLES] = GeneFeatsPerBody(bodyJoints,Normalize_Joints);
	load RRV_DB.mat; load RRV_SAMPLES.mat;
	ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)
	numClusters = 32;
	jointNum = jointGroup;
	% temporal pyramid baded on pooling fisher codes
	%     [traindata,testdata,~] = GeneFisherCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,1);
	[traindata,testdata,~] = GeneFisherCodeJointPyramid(RRV_DB,RRV_SAMPLES, jointNum, ntotalbh, numClusters,0, experiment_num);
	save traindata traindata; save testdata testdata;clear traindata testdata; % avoid Out of Memory
	clear RRV_DB RRV_SAMPLES;% to avoid Out of Memory
    
% 	jointNum = jointGroup; % for single modality
% 	numTrain = length(trainGID);numTest = length(testGID);
% 	lambda = [0.01,0.5,0];modalityNum = 1;
% 	load traindata.mat;theta = trainBinRegression(traindata,trainGID,lambda,jointNum,modalityNum); clear traindata;
% 	load testdata.mat; predict_label = predictBinRegression(testdata,theta);clear testdata;
    
% 	load modelForTest14; modelForTest{experiment_num}.theta = theta; save modelForTest14 modelForTest; clear modelForTest;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1st type of svm linear classifer
load traindata.mat;model =  svmtrain(trainGID,traindata', '-c 1 -g 0.07 -t 0 -b 1');clear traindata;
load testdata.mat;[predict_label, accuracy, dec_values] = svmpredict(testGID,testdata', model,'-b 1');clear testdata;
% 
% %2nd type of svm linear classifer
% lambda = 0.1;     % regularization parameter for w
% load traindata.mat;[w, b, class_name] = li2nsvm_multiclass_lbfgs(traindata',trainGID, lambda);clear traindata;
% 
% tic;
% load testdata.mat;[predict_label, ~] = li2nsvm_multiclass_fwd(testdata', w, b, class_name);clear testdata;
% sum_time_svm = toc;
% compu_time_ssm(experiment_num) =sum_time_svm/length(predict_label);
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
end