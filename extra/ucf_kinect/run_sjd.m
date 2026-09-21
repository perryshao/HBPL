modelForTest = cell(1,4);
for experiment_num = 1:4;
	delete testdata.mat;
	delete traindata.mat;
	load_UCFske_bat(joints_no,BAT_FOLDER);
	CV_DataCollect(joints_no,num_folds,experiment_num);
	[trainGID,testGID] = getLabels(joints_no);
	 [PairDistFeats_DB,PairDistFeats_SAMPLES]  = GenePairDistFeatsBodyJoint(joints_no);
     
     load PairDistFeats_DB.mat; load PairDistFeats_SAMPLES.mat; 
    ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)  
    jointNum = jointGroup; 
    numClusters = 32;
    % temporal pyramid baded on pooling fisher codes
%     [traindata,testdata,~] = GeneFisherCodePyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, ntotalbh,1);
     [traindata,testdata,~] = GeneFisherCodeJointPyramid(PairDistFeats_DB,PairDistFeats_SAMPLES, jointNum, ntotalbh,numClusters,1,experiment_num);
     save traindata traindata; save testdata testdata;clear traindata testdata; % avoid Out of Memory
     clear PairDistFeats_DB PairDistFeats_SAMPLES;% to avoid Out of Memory
     
	jointNum = jointGroup; % for single modality
	numTrain = length(trainGID);numTest = length(testGID);
	lambda = [0.01,0.5,0];modalityNum = 1;
	load traindata.mat;theta = trainBinRegression(traindata,trainGID,lambda,jointNum,modalityNum); clear traindata;
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
end