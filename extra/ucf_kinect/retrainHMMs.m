function model = retrainHMMs(traindata,trainGID)
class_num = length(unique(trainGID));
O = size(traindata{1},1);
% N = 1+(O-10)/4; %features
N = 1+(O-4)/4; %features
%% training with whole feature vector
% model = cell(class_num,1);
% for i = 1:class_num
%     data = traindata(trainGID == i);
%     if isempty(data)
%         continue;
%     end
%     M = 2; Q = 3; cov_type = 'diag'; cov_prior = 0.05;
%     try
%         model{i}=trainHMM(data,M,Q,cov_type,cov_prior);
%     catch
%         model{i}=trainHMM(data,M,Q,cov_type,cov_prior);
%     end
%     while isnan( model{i}.loglik)
%         try
%             model{i}=trainHMM(data,M,Q,cov_type,cov_prior);
%         catch
%             model{i}=trainHMM(data,M,Q,cov_type,cov_prior);
%         end
%     end
% end

%% training with each features
model = cell(class_num,N);
for j = 1:N
    for i = 1:class_num
        data = traindata(trainGID == i);
        if isempty(data)
            continue;
        end  
        for k= 1: length(data)
            if j == 1
                data{k} = data{k}(1:4,2:end-2);
                M = 2;Q = 3;cov_type = 'diag';cov_prior = 0.01;
            else
                data{k} = data{k}(((j-2)*4+4+1):((j-1)*4+4),2:end-2);
                M = 2; Q=3; cov_type = 'diag'; cov_prior = 0.001; 
            end
        end
        try
            model{i,j}=trainHMM(data,M,Q,cov_type,cov_prior);
        catch
            model{i,j}=trainHMM(data,M,Q,cov_type,cov_prior);
        end
        while isnan(model{i,j}.loglik) 
            try
                model{i,j}=trainHMM(data,M,Q,cov_type,cov_prior);
            catch
                model{i,j}=trainHMM(data,M,Q,cov_type,cov_prior);
            end
        end     
    end
end
%% backup of training with each features
% model = cell(class_num,N);
% for j = 1:N
%     for i = 1:class_num
%         data = traindata(trainGID == i);
%         if isempty(data)
%             continue;
%         end  
%         for k= 1: length(data)
%             if j == 1
%                 data{k} = data{k}(1:10,2:end-2);
%                 M = 2;Q = 3;cov_type = 'diag';cov_prior = 0.01;
%             else
%                 data{k} = data{k}(((j-2)*4+10+1):((j-1)*4+10),2:end-2);
%                 if j == 2 || j == 3 || j == 6
%                     M = 2; Q = 3; cov_type = 'diag'; cov_prior = 0.1;
%                 elseif j == 5 || j == 8 || j == 9
%                     M = 2; Q = 3;cov_type = 'diag'; cov_prior = 0.001;
%                 elseif j == 4
%                     M = 2; Q = 3; cov_type = 'diag'; cov_prior = 0.0001; 
%                 else
%                     M = 2; Q = 3; cov_type = 'diag'; cov_prior = 0.1; 
%                 end
%             end
%         end
%         try
%             model{i,j}=trainHMM(data,M,Q,cov_type,cov_prior);
%         catch
%             model{i,j}=trainHMM(data,M,Q,cov_type,cov_prior);
%         end
%         while isnan(model{i,j}.loglik) 
%             try
%                 model{i,j}=trainHMM(data,M,Q,cov_type,cov_prior);
%             catch
%                 model{i,j}=trainHMM(data,M,Q,cov_type,cov_prior);
%             end
%         end     
%     end
% end

