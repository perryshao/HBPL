function [RRV_SAMPLES]  = GeneFeatsPerBodyForTest(bodyJoints, Normalize_Joints)
%% compute the axises betweeen the root point and reference point for each rigid body --- for test set
load([bodyJoints{1, 1} 'samples.mat']);
samples_t = size(TRAJSAMPLES_CV, 2);
JointGroup = size(bodyJoints, 1);
Normalize_JointGroup = size(Normalize_Joints, 1);
RRV_SAMPLES = cell(1, samples_t);
%% load all data in training dataset
for n = 1:JointGroup
    % the root joint
    load([bodyJoints{n, 1} 'samples.mat']);
    eval([strcat('SAMPLES_', bodyJoints{n, 1}) '=TRAJSAMPLES_CV;']);
    % the reference joint
    load([bodyJoints{n, end} 'samples.mat']);
    eval([strcat('SAMPLES_', bodyJoints{n, end}) '=TRAJSAMPLES_CV;']);

    % for building local coordinate system
    load([bodyJoints{n, 2} 'samples.mat']);
    eval([strcat('SAMPLES_', bodyJoints{n, 2}) '=TRAJSAMPLES_CV;']);
end

%% load the joint data for normlization
for n = 1:Normalize_JointGroup
    % the root joint
    load([Normalize_Joints{n, 1} 'samples.mat']);
    eval([strcat('SAMPLES_', Normalize_Joints{n, 1}) '=TRAJSAMPLES_CV;']);
    % the reference joint
    load([Normalize_Joints{n, end} 'samples.mat']);
    eval([strcat('SAMPLES_', Normalize_Joints{n, end}) '=TRAJSAMPLES_CV;']);

end
%% compute the axises

% normalization by scaling skeleton based on the length of C7-STRN of the 1st frame

for i = 1:samples_t
    fprintf ('get the RRV descriptors for test data %d/%d...\n', i, samples_t);

    % normalization by establishing local coordinate system
    eval(['joint_C7=' strcat('SAMPLES_', Normalize_Joints{1, 1}) '{2,i};']);
    eval(['joint_STRN=' strcat('SAMPLES_', Normalize_Joints{1, 2}) '{2,i};']);
    ScalLeng = norm(joint_C7(1, :) - joint_STRN(1, :));
    eval(['joint_RFWT=' strcat('SAMPLES_', Normalize_Joints{2, 1}) '{2,i};']);
    eval(['joint_LFWT=' strcat('SAMPLES_', Normalize_Joints{2, 2}) '{2,i};']);
    v1 = joint_C7(1, :) - joint_RFWT(1, :); v2 = joint_C7(1, :) - joint_LFWT(1, :);
    Hy = v1 + v2; Hz = cross(v1, v2); Hx = cross(Hy, Hz);
    X_axis = Hx / norm(Hx); Y_axis = Hy / norm(Hy); Z_axis = Hz / norm(Hz);
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
        T_joint_Root = (T_joint_Root - joint_STRN) * RotM'; T_joint_END = (T_joint_END - joint_STRN) * RotM';
        %         T_joint_Root = T_joint_Root-joint_STRN; T_joint_END = T_joint_END-joint_STRN;
        T_joint_Root = T_joint_Root / ScalLeng; T_joint_END = T_joint_END / ScalLeng;
        % ---------------------------transfrom coordinates at each frame---------------------------
        %         eval(['T_joint_Root=' strcat('SAMPLES_',bodyJoints{n,1}) '{2,i};']);
        %         eval(['T_joint_END=' strcat('SAMPLES_',bodyJoints{n,end}) '{2,i};']);
        %         for s = 1:size(T_joint_Root,1)
        %             T_joint_Root(s,:) =( T_joint_Root(s,:)-joint_STRN(s,:))*RotM(:,:,s)';T_joint_END(s,:) = (T_joint_END(s,:)-joint_STRN(s,:))*RotM(:,:,s)';
        %         end
        %         T_joint_Root= T_joint_Root/ScalLeng; T_joint_END = T_joint_END/ScalLeng;
        % -----------------------------------------------------------------------------------------------------
        RRV_SAMPLES{1, i}((n - 1) * T + 1:n * T, :) = Func_RRVdescriptor(T_joint_Root, T_joint_END);
        %         RRV_SAMPLES{1,i}(:,(n-1)*7+1:n*7) = Func_RRVdescriptor(T_joint_Root,T_joint_END);% for DTW recognition
    end
end
save RRV_SAMPLES RRV_SAMPLES -v7.3;
