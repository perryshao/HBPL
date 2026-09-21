function predictLabel = predictBinRegression(theta,testGID,batchsize)
% data_folder = '/home/data/IPdataset/train_test_rrv/';%--for ubuntu
data_folder = 'C:/Users/perry/Desktop/MyDocuments/work/MicrosoftGestureEvaluatingCode/train_test_rrv/';
N = length(testGID);
batchTimes = floor(N/batchsize);
predictLabel = zeros(N,1);
for batchtimes = 1:batchTimes
        eval(['load ' data_folder strcat('testdata',num2str(batchtimes))]);
        eval(['Xbatch= ' strcat('testdata',num2str(batchtimes)) ';']);
        fprintf('Testing Batch times %d\n', batchtimes)
        [~,predictLabel((batchtimes-1)*batchsize+1:batchtimes*batchsize)] = max(Xbatch'*theta,[],2);
        eval(['clear ' strcat('testdata',num2str(batchtimes))]);
end
eval(['load ' data_folder strcat('testdata',num2str(batchtimes+1))]);
eval(['Xbatch= ' strcat('testdata',num2str(batchtimes+1)) ';']);
fprintf('Testing Batch times %d \n',batchtimes+1)
[~,predictLabel(batchtimes*batchsize+1:end)] = max(Xbatch'*theta,[],2);
eval(['clear ' strcat('testdata',num2str(batchtimes+1))]);
