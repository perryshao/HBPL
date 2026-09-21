function [traindata, testdata, trainGID,testGID]=construct_svmdata(TRAJDB,TRAJSAMPLES,...
                              TRAJDB_DES,TRAJSAMPLES_DES,INTEGRATE_DES,INTEGRATESAMPLES_DES)
samples_r = size(TRAJDB,2);
samples_t = size(TRAJSAMPLES,2); 
r_rows = zeros(1,samples_r);
for i=1:samples_r   
       directory_loca=find(TRAJDB{1,i}=='/');
       TRAJDB{1,i}=TRAJDB{1,i}(1:directory_loca(2));
       r_rows(i) = size(TRAJDB{2,i},1);
end
trainGID = grp2idx(TRAJDB(1,:)');
t_rows = zeros(1,samples_t);
for i=1:samples_t   
       directory_loca=find(TRAJSAMPLES{1,i}=='/');
       TRAJSAMPLES{1,i}=TRAJSAMPLES{1,i}(1:directory_loca(2));
       t_rows(i) = size(TRAJSAMPLES{2,i},1);
end
testGID = grp2idx(TRAJSAMPLES(1,:)');
dim_root = size(TRAJDB_DES{1,1},2);
dim_orien = size(INTEGRATE_DES{1,1},2);
traindata = zeros(samples_r,(dim_root+dim_orien)*max(r_rows)+1);
for i=1:samples_r   
       m = size(TRAJDB_DES{1,i},1);
       traindata(i,1) = m;
       traindata(i,2:m*dim_root+1) = reshape(TRAJDB_DES{1,i},1,m*dim_root);
       traindata(i,(m*dim_root+2):(m*dim_root+1+m*dim_orien)) = reshape(INTEGRATE_DES{1,i},1,m*dim_orien);
end

testdata = zeros(samples_t,(dim_root+dim_orien)*max(t_rows));
for i=1:samples_t   
       m = size(TRAJSAMPLES_DES{1,i},1);
       testdata(i,1) = m;
       testdata(i,2:m*dim_root+1) = reshape(TRAJSAMPLES_DES{1,i},1,m*dim_root);
       testdata(i,(m*dim_root+2):(m*dim_root+1+m*dim_orien)) = reshape(INTEGRATESAMPLES_DES{1,i},1,m*dim_orien);
end
       
