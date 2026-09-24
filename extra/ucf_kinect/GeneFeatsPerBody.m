function [RRV_DB, RRV_SAMPLES]  = GeneFeatsPerBody(bodyJoints, Normalize_Joints)
%% compute the axises betweeen the root point and reference point for each rigid body --- for training set
load([bodyJoints{1, 1} '.mat']);
samples_r = size(TRAJDB, 2);
JointGroup = size(bodyJoints, 1);
Normalize_JointGroup = size(Normalize_Joints, 1);
RRV_DB = cell(1, samples_r);

%% load all data in training dataset
for n = 1:JointGroup
    % the root joint
    load([bodyJoints{n, 1} '.mat']);
    eval([strcat('DB_', bodyJoints{n, 1}) '=TRAJDB;']);
    % the reference joint
    load([bodyJoints{n, end} '.mat']);
    eval([strcat('DB_', bodyJoints{n, end}) '=TRAJDB;']);

    % for building local coordinate system
    load([bodyJoints{n, 2} '.mat']);
    eval([strcat('DB_', bodyJoints{n, 2}) '=TRAJDB;']);

end
%% load the joint data for normlization
for n = 1:Normalize_JointGroup
    % the root joint
    load([Normalize_Joints{n, 1} '.mat']);
    eval([strcat('DB_', Normalize_Joints{n, 1}) '=TRAJDB;']);
    % the reference joint
    load([Normalize_Joints{n, end} '.mat']);
    eval([strcat('DB_', Normalize_Joints{n, end}) '=TRAJDB;']);

end
%% compute the axises
for i = 1:samples_r
    fprintf ('get the RRV descriptors for training data %d/%d...\n', i, samples_r);

    % normalization by establishing local coordinate system
    eval(['joint_C7=' strcat('DB_', Normalize_Joints{1, 1}) '{2,i};']);
    eval(['joint_STRN=' strcat('DB_', Normalize_Joints{1, 2}) '{2,i};']);
    ScalLeng = norm(joint_C7(1, :) - joint_STRN(1, :));
    Z_axis = joint_C7(1, :) - joint_STRN(1, :);
    eval(['joint_RFWT=' strcat('DB_', Normalize_Joints{2, 1}) '{2,i};']);
    eval(['joint_LFWT=' strcat('DB_', Normalize_Joints{2, 2}) '{2,i};']);
    Y_axis = cross(Z_axis, joint_LFWT(1, :) - joint_RFWT(1, :));
    X_axis = cross(Y_axis, Z_axis);
    X_axis = X_axis ./ repmat(norm(X_axis), 1, 3); Y_axis = Y_axis ./ repmat(norm(Y_axis), 1, 3); Z_axis = Z_axis ./ repmat(norm(Z_axis), 1, 3);
    RotM = [X_axis; Y_axis; Z_axis];

    for n = 1:JointGroup
        eval(['Vec_ER=' strcat('DB_', bodyJoints{n, 1}) '{2,i}-' strcat('DB_', bodyJoints{n, end}) '{2,i};']);
        T = size(Vec_ER, 1);

        %         RotVec=zeros(T-1,4);
        %         for j = 1:T-1
        %             RotVec(j,:)=vrrotvec(Axises(j,:)', Axises(j+1,:)');
        %         end
        %         Traj_augular=RotVec(:,1:3).*repmat(RotVec(:,4),1,3);
        %         Traj =eval([strcat('DB_', bodyJoints{n,end}) '{2,i};']);
        %         Traj_6Dof = [Traj(1:end-1,:) Traj_augular];
        %         options = struct('SVD_mode',{1});
        %         RRV_output=RRV_AngTrj_Original(Traj_6Dof,options);
        %         RRV_DB{1,i}((n-1)*(T-2)+1:n*(T-2),:) = RRV_output.descriptor;
        eval(['T_joint_Root=' strcat('DB_', bodyJoints{n, 1}) '{2,i};']);
        eval(['T_joint_END=' strcat('DB_', bodyJoints{n, end}) '{2,i};']);
        %         T_joint_Root = T_joint_Root*RotM'+repmat(joint_STRN(1,:),T,1);T_joint_END = T_joint_END*RotM'+repmat(joint_STRN(1,:),T,1);
        T_joint_Root = T_joint_Root / ScalLeng; T_joint_END = T_joint_END / ScalLeng;
        RRV_DB{1, i}((n - 1) * T + 1:n * T, :) = Func_RRVdescriptor(T_joint_Root, T_joint_END);
        %         RRV_DB{1,i}(:,(n-1)*7+1:n*7)  = Func_RRVdescriptor(T_joint_Root,T_joint_END);% for DTW recognition

        % multiple modality
        RRV_DB1{1, i}((n - 1) * T + 1:n * T, :) = RRV_DB{1, i}((n - 1) * T + 1:n * T, 1:4);
        RRV_DB2{1, i}((n - 1) * T + 1:n * T, :) = RRV_DB{1, i}((n - 1) * T + 1:n * T, 5:7);

        %% QDCT descriptor
        %         % parameters for  QDCT
        %         absexp = 2; % best value yet with 2.1 (heavily influences the result(s))
        %         dctaxis = unit(quaternion(-1,-1,-1)); % the QDCT axis
        %         L = 'L'; % Left- ('L') or Right-sided ('R') QDCT
        %         tempDes=Func_RRVdescriptor(T_joint_Root,T_joint_END);
        %         QuaterMatrix = tempDes(:,1:4);
        %         QIR=quaternion(QuaterMatrix(:,1),QuaterMatrix(:,2),QuaterMatrix(:,3),QuaterMatrix(:,4));
        %         mu=unit(dctaxis); % ensure a unit (pure) quaternion as axis
        %         DCTIR=qdct2(QIR,mu,L);
        %         IDCTIR=iqdct2(sign(DCTIR),mu,L);
        % %         S=abs(IDCTIR).^absexp;
        % %         S=S-min(min(S));
        % %         S=S/max(max(S));
        %         S = [IDCTIR.w IDCTIR.x IDCTIR.y IDCTIR.z];
        %         RRV_DB{1,i}((n-1)*T+1:n*T,:) =  [S tempDes(:,5:7)];

        %         if n == 1
        %             Vec_ER=Vec_ER./repmat(sqrt(sum(Vec_ER.^2,2))+eps,1,3);
        %             Vec_ER_next=[Vec_ER(2:end,:);Vec_ER(end,:)];
        %             Vec_ER_next=Vec_ER_next./repmat(sqrt(sum(Vec_ER_next.^2,2))+eps,1,3);
        %             RotVec = zeros(T,4);
        %             for t=1:T
        %                 %--- rigid body
        %                 a=Vec_ER(t,:)./(norm(Vec_ER(t,:))+eps);
        %                 b=Vec_ER_next(t,:)./(norm(Vec_ER_next(t,:))+eps);
        %                 RotVec(t,:) = vrrotvec(a,b);
        %             end
        %             [U,~,~] = svd(RotVec(:,1:3)');
        %             SIGN=CalSIGN(RotVec(:,1:3));
        %         end
        %
        %         RRV_DB{1,i}(:,(n-1)*7+1:n*7)  = Func_RRVdescriptor(T_joint_Root,T_joint_END,U,SIGN);% for DTW recognition

    end
end
%% compute the axises betweeen the root point and reference point for each rigid body --- for test set
load([bodyJoints{1, 1} 'samples.mat']);
samples_t = size(TRAJSAMPLES, 2);
RRV_SAMPLES = cell(1, samples_t);
%% load all data in training dataset
for n = 1:JointGroup
    % the root joint
    load([bodyJoints{n, 1} 'samples.mat']);
    eval([strcat('SAMPLES_', bodyJoints{n, 1}) '=TRAJSAMPLES;']);
    % the reference joint
    load([bodyJoints{n, end} 'samples.mat']);
    eval([strcat('SAMPLES_', bodyJoints{n, end}) '=TRAJSAMPLES;']);

    % for building local coordinate system
    load([bodyJoints{n, 2} 'samples.mat']);
    eval([strcat('SAMPLES_', bodyJoints{n, 2}) '=TRAJSAMPLES;']);
end
%% load the joint data for normlization
for n = 1:Normalize_JointGroup
    % the root joint
    load([Normalize_Joints{n, 1} 'samples.mat']);
    eval([strcat('SAMPLES_', Normalize_Joints{n, 1}) '=TRAJSAMPLES;']);
    % the reference joint
    load([Normalize_Joints{n, end} 'samples.mat']);
    eval([strcat('SAMPLES_', Normalize_Joints{n, end}) '=TRAJSAMPLES;']);

end
%% compute the axises
for i = 1:samples_t
    fprintf ('get the RRV descriptors for test data %d/%d...\n', i, samples_t);

    eval(['joint_C7=' strcat('SAMPLES_', Normalize_Joints{1, 1}) '{2,i};']);
    eval(['joint_STRN=' strcat('SAMPLES_', Normalize_Joints{1, 2}) '{2,i};']);
    ScalLeng = norm(joint_C7(1, :) - joint_STRN(1, :));
    Z_axis = joint_C7(1, :) - joint_STRN(1, :);
    eval(['joint_RFWT=' strcat('SAMPLES_', Normalize_Joints{2, 1}) '{2,i};']);
    eval(['joint_LFWT=' strcat('SAMPLES_', Normalize_Joints{2, 2}) '{2,i};']);
    Y_axis = cross(Z_axis, joint_LFWT(1, :) - joint_RFWT(1, :));
    X_axis = cross(Y_axis, Z_axis);
    X_axis = X_axis ./ repmat(norm(X_axis), 1, 3); Y_axis = Y_axis ./ repmat(norm(Y_axis), 1, 3); Z_axis = Z_axis ./ repmat(norm(Z_axis), 1, 3);
    RotM = [X_axis; Y_axis; Z_axis];

    for n = 1:JointGroup
        eval(['Vec_ER=' strcat('SAMPLES_', bodyJoints{n, 1}) '{2,i}-' strcat('SAMPLES_', bodyJoints{n, end}) '{2,i};']);
        T = size(Vec_ER, 1);
        %         RotVec=zeros(T-1,4);
        %         for j = 1:T-1
        %             RotVec(j,:)=vrrotvec(Axises(j,:)', Axises(j+1,:)');
        %         end
        %         Traj_augular=RotVec(:,1:3).*repmat(RotVec(:,4),1,3);
        %         Traj =eval([strcat('SAMPLES_', bodyJoints{n,end}) '{2,i};']);
        %         Traj_6Dof = [Traj(1:end-1,:) Traj_augular];
        %         options = struct('SVD_mode',{1});
        %         RRV_output=RRV_AngTrj_Original(Traj_6Dof,options);
        %         RRV_SAMPLES{1,i}((n-1)*(T-2)+1:n*(T-2),:)  = RRV_output.descriptor;
        eval(['T_joint_Root=' strcat('SAMPLES_', bodyJoints{n, 1}) '{2,i};']);
        eval(['T_joint_END=' strcat('SAMPLES_', bodyJoints{n, end}) '{2,i};']);
        %         T_joint_Root = T_joint_Root*RotM'+repmat(joint_STRN(1,:),T,1);T_joint_END = T_joint_END*RotM'+repmat(joint_STRN(1,:),T,1);
        T_joint_Root = T_joint_Root / ScalLeng; T_joint_END = T_joint_END / ScalLeng;
        RRV_SAMPLES{1, i}((n - 1) * T + 1:n * T, :) = Func_RRVdescriptor(T_joint_Root, T_joint_END);
        %         RRV_SAMPLES{1,i}(:,(n-1)*7+1:n*7) = Func_RRVdescriptor(T_joint_Root,T_joint_END);% for DTW recognition
        % multiple modality
        RRV_SAMPLES1{1, i}((n - 1) * T + 1:n * T, :) = RRV_SAMPLES{1, i}((n - 1) * T + 1:n * T, 1:4);
        RRV_SAMPLES2{1, i}((n - 1) * T + 1:n * T, :) = RRV_SAMPLES{1, i}((n - 1) * T + 1:n * T, 5:7);

        %% QDCT descriptor
        %         % parameters for  QDCT
        %         absexp = 2; % best value yet with 2.1 (heavily influences the result(s))
        %         dctaxis = unit(quaternion(-1,-1,-1)); % the QDCT axis
        %         L = 'L'; % Left- ('L') or Right-sided ('R') QDCT
        %         tempDes=Func_RRVdescriptor(T_joint_Root,T_joint_END);
        %         QuaterMatrix = tempDes(:,1:4);
        %         QIR=quaternion(QuaterMatrix(:,1),QuaterMatrix(:,2),QuaterMatrix(:,3),QuaterMatrix(:,4));
        %         mu=unit(dctaxis); % ensure a unit (pure) quaternion as axis
        %         DCTIR=qdct2(QIR,mu,L);
        %         IDCTIR=iqdct2(sign(DCTIR),mu,L);
        % %         S=abs(IDCTIR).^absexp;
        % %         S=S-min(min(S));
        % %         S=S/max(max(S));
        %         S = [IDCTIR.w IDCTIR.x IDCTIR.y IDCTIR.z];
        %         RRV_SAMPLES{1,i}((n-1)*T+1:n*T,:) =  [S tempDes(:,5:7)];

        %         if n == 1
        %             Vec_ER=Vec_ER./repmat(sqrt(sum(Vec_ER.^2,2))+eps,1,3);
        %             Vec_ER_next=[Vec_ER(2:end,:);Vec_ER(end,:)];
        %             Vec_ER_next=Vec_ER_next./repmat(sqrt(sum(Vec_ER_next.^2,2))+eps,1,3);
        %             RotVec = zeros(T,4);
        %             for t=1:T
        %                 %--- rigid body
        %                 a=Vec_ER(t,:)./(norm(Vec_ER(t,:))+eps);
        %                 b=Vec_ER_next(t,:)./(norm(Vec_ER_next(t,:))+eps);
        %                 RotVec(t,:) = vrrotvec(a,b);
        %             end
        %             [U,~,~] = svd(RotVec(:,1:3)');
        %             SIGN=CalSIGN(RotVec(:,1:3));
        %         end
        %         RRV_SAMPLES{1,i}(:,(n-1)*7+1:n*7) = Func_RRVdescriptor(T_joint_Root,T_joint_END,U,SIGN);% for DTW recognition

    end
end
save RRV_DB RRV_DB;
save RRV_SAMPLES RRV_SAMPLES;

% multiple modality
save RRV_DB1 RRV_DB1;
save RRV_SAMPLES1 RRV_SAMPLES1;
save RRV_DB2 RRV_DB2;
save RRV_SAMPLES2 RRV_SAMPLES2;
