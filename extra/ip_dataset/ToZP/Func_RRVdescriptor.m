% New relative -- the new descriptor for skeleton  : by skaegy (skaegy@gmail.com)
% input
%    trj1 - n*3 trajectory1
%    trj2 - n*3 trajectory2 %--vector=trj1-trj2 velocity=trj2
% output
%    descriptor - n*7 1:4~quaternion 5:7~Velocity*Rotation Matrix

function descriptor = Func_RRVdescriptor(T_joint_Root, T_joint_END, U, SIGN)

if nargin < 3
    U = eye(3);
    SIGN = ones(1, 3);
end
% v5, the new definition of the roll, pitch and yaw
% given three joints, 13,11,3 the rotation is the rotation of the normal
% vector of the plane13_11_3

if size(T_joint_Root, 1) < size(T_joint_Root, 2)
    T_joint_Root = T_joint_Root';
end
n = size(T_joint_Root, 1);
if size(T_joint_END, 1) < size(T_joint_END, 2)
    T_joint_END = T_joint_END';
end

%% All the tensors are computed by the relative positions (Local coordinate system)
% --- Mean vector
Vec_ER = T_joint_END - T_joint_Root;
Vec_ER = Vec_ER ./ repmat(sqrt(sum(Vec_ER.^2, 2)) + eps, 1, 3);
Vec_ER_next = [Vec_ER(2:end, :); Vec_ER(end, :)];
Vec_ER_next = Vec_ER_next ./ repmat(sqrt(sum(Vec_ER_next.^2, 2)) + eps, 1, 3);

% --- Velocity
Vel_joint_End = gradient((T_joint_END)')';
VelNorm_End = Vel_joint_End ./ repmat(sqrt((sqrt(sum(Vel_joint_End.^2, 2))) + eps), 1, 3);

% remove rotation variations
% RotVec = zeros(n,4);
% for i=1:n
%     %--- rigid body
%     a=Vec_ER(i,:)./(norm(Vec_ER(i,:))+eps);
%     b=Vec_ER_next(i,:)./(norm(Vec_ER_next(i,:))+eps);
%     RotVec(i,:) = vrrotvec(a,b);
% end
% [U,~,~] = svd(RotVec(:,1:3)');
% SIGN=CalSIGN(RotVec(:,1:3));

% Vec_ER=Vec_ER*U;Vec_ER_next=Vec_ER_next*U;
% Vec_ER=Vec_ER.*repmat(SIGN,n,1);
% Vec_ER_next=Vec_ER_next.*repmat(SIGN,n,1);

Vec_ER = Vec_ER * U; Vec_ER_next = Vec_ER_next * U;
Vec_ER = Vec_ER .* repmat(SIGN, n, 1);
Vec_ER_next = Vec_ER_next .* repmat(SIGN, n, 1);
descriptor = zeros(n, 7);
for i = 1:n
    % --- rigid body
    a = Vec_ER(i, :) ./ (norm(Vec_ER(i, :)) + eps);
    b = Vec_ER_next(i, :) ./ (norm(Vec_ER_next(i, :)) + eps);

    % when there is a 0 length vector existed in trajectory
    if norm(a) == 0 || norm(b) == 0
        RotM = eye(3);
    elseif any(isnan(a)) || any(isnan(b))  % for occlusion
        RotM = NaN * eye(3);
    else
        r = vrrotvec(a, b);
        if ~isreal(r)
            r = real(r);
        end
        RotM = vrrotvec2mat(r);
    end

    %     RotM=vrrotvec2mat(vrrotvec(a,b));

    quat = Myrotm2quat(RotM');

    Velocity_axis = VelNorm_End(i, :) * RotM;
    %     Velocity_axis=VelNorm_End(i,:);
    descriptor(i, :) = [quat Velocity_axis];
end

end
