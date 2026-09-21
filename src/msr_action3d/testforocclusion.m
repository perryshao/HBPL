noise_level = zeros (1,5);
occlu_ratio = [0.1,0.2,0.3,0.4,0];
for m = 1:50
    for n = 1:5
        experiment_num = n;
        fprintf ('copying original data...\n');
        for i=1:length(joints_no)
            copymat_file = joints_no{i};
            copyfile(['mat/' copymat_file '*.mat'],'../MSRActionEvaluatingCode/','f');
        end
        %% add Guassian White Noise to Samples data
        add_noise_bat(joints_no,noise_level(experiment_num),occlu_ratio(experiment_num));
        [trainGID,testGID] = getLabels(joints_no);
        
        [RRV_SAMPLES]  = GeneFeatsPerBodyForTest(bodyJoints,Normalize_Joints);
        ntotalbh = 3; % l = 0,1,2,3 (L=3) blocks are 2^(l)
        jointNum = jointGroup;
        % temporal pyramid baded on pooling fisher codes
        [testdata,~] = GeneFisherCodeJointPyramidForTest(RRV_SAMPLES, jointNum, ntotalbh,0);
        clear RRV_SAMPLES;% to avoid Out of Memory
        
        %%------------------------------------------------------------------%%
        load modelForTest10+19;theta = modelForTest.theta;clear modelForTest;
        predict_label = predictBinRegression(testdata,theta);clear testdata;
        
        %%----------------------------------------------------------------%%
        confusion_matrix = zeros(CLASS_NUM,CLASS_NUM);
        for i = 1:CLASS_NUM
            for j = 1:CLASS_NUM
                confusion_matrix(i,j) = length(find(testGID == i & predict_label == j));
            end
        end
        recog_ratio_smml(experiment_num) = trace(confusion_matrix)/sum(confusion_matrix(:));
        recog_ratio_final_smml = mean(recog_ratio_smml) %#ok<NOPTS>
        confusion_matrix_smml{1,experiment_num} = confusion_matrix;
        
        %% change every test
        %     save test_occlu8 recog_ratio_smml recog_ratio_final_smml confusion_matrix_smml
        eval([ 'save ' strcat('test_10+19occlu',num2str(m)) ' recog_ratio_smml recog_ratio_final_smml confusion_matrix_smml']);
    end
end


recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('test_10+19occlu',num2str(i))]);
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'b');




