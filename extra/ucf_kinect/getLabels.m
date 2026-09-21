function [trainGID,testGID]=getLabels(joints_no)
%%  build the labels for training and testing
load([joints_no{1,1} '.mat']);
load([joints_no{1,1} 'samples.mat']);
samples_r = size(TRAJDB,2);
samples_t = size(TRAJSAMPLES,2); 
trainGID = zeros(samples_r,1);
testGID = zeros(samples_t,1);
for i=1:samples_r   
       directory_loca=find(TRAJDB{1,i}=='/');
       trainGID(i)=str2double(TRAJDB{1,i}(directory_loca(2)+5:directory_loca(2)+6));
end
for i=1:samples_t   
       directory_loca=find(TRAJSAMPLES{1,i}=='/');
       testGID(i)=str2double(TRAJSAMPLES{1,i}(directory_loca(2)+5:directory_loca(2)+6));
end


