% DSRF descriptor: by skaegy (skaegy@gmail.com)
% SVD, and the length of s=1
% input
%    sixdof - n*6 1:3~trajectory 4:6~angular velocity
%    delta_t - the sample rate
% output
%    descriptor - n*6

function Output = RRV_AngTrj(sixdof, options)
if nargin < 2
    error('Need more input');
end
name = fieldnames(options);
if ~ismember('SVD_mode', name)
    SVD_mode = 0;
else
    SVD_mode = options.SVD_mode;
end
if ~ismember('s_cnt', name)
    s_cnt = 50;
else
    s_cnt = options.s_cnt;
end
if ~ismember('Rot_mode', name)
    Rot_mode = 0;
else
    Rot_mode = options.Rot_mode;
end
if ~ismember('unit_length', name)
    unit_length = 0;
else
    unit_length = options.unit_length;
end

if size(sixdof, 1) < size(sixdof, 2)
    sixdof = sixdof';
end
%%
Trj = sixdof(:, 1:3);
n = length(Trj);
AngTrj = sixdof(:, 4:6);

% ---- Calculate Euler axis and angles

if SVD_mode == 1
    RandVec = rand(1, 3);
    RandVec = RandVec ./ norm(RandVec);
    RandBeta = (rand(1) - 0.5) * 2 * pi;
    RandRotM = vrrotvec2mat([RandVec RandBeta]);
    AngTrj = AngTrj * RandRotM; Trj = Trj * RandRotM;
    [U, ~, ~] = svd(AngTrj'); AngTrj = AngTrj * U; Trj = Trj * U;
    SIGN = CalSIGN(AngTrj);

    AngTrj = AngTrj .* repmat(SIGN, n, 1);
    Trj = Trj .* repmat(SIGN, n, 1);
end

% %---- Angular Trajectory
% AngTrj=[cumsum(AngVel)];

%% Interpolation
% --- Interpolation to get the s_seg
Interp_Trj1(:, 1) = interp1(1:n, Trj(:, 1), 1:0.1:n, 'spline');
Interp_Trj1(:, 2) = interp1(1:n, Trj(:, 2), 1:0.1:n, 'spline');
Interp_Trj1(:, 3) = interp1(1:n, Trj(:, 3), 1:0.1:n, 'spline');
Interp_Trj2(:, 1) = interp1(1:length(Interp_Trj1), Interp_Trj1(:, 1), 1:0.1:length(Interp_Trj1), 'spline');
Interp_Trj2(:, 2) = interp1(1:length(Interp_Trj1), Interp_Trj1(:, 2), 1:0.1:length(Interp_Trj1), 'spline');
Interp_Trj2(:, 3) = interp1(1:length(Interp_Trj1), Interp_Trj1(:, 3), 1:0.1:length(Interp_Trj1), 'spline');
clear Interp_Trj1

% ---- Interpolation to get the s_seg
Interp_AngTrj1(:, 1) = interp1(1:n, AngTrj(:, 1), 1:0.1:n, 'spline');
Interp_AngTrj1(:, 2) = interp1(1:n, AngTrj(:, 2), 1:0.1:n, 'spline');
Interp_AngTrj1(:, 3) = interp1(1:n, AngTrj(:, 3), 1:0.1:n, 'spline');
Interp_AngTrj2(:, 1) = interp1(1:length(Interp_AngTrj1), Interp_AngTrj1(:, 1), 1:0.1:length(Interp_AngTrj1), 'spline');
Interp_AngTrj2(:, 2) = interp1(1:length(Interp_AngTrj1), Interp_AngTrj1(:, 2), 1:0.1:length(Interp_AngTrj1), 'spline');
Interp_AngTrj2(:, 3) = interp1(1:length(Interp_AngTrj1), Interp_AngTrj1(:, 3), 1:0.1:length(Interp_AngTrj1), 'spline');
clear Interp_AngTrj1;

%% SRVF
% ---- Resampling
[~, s] = TrjLength(Interp_Trj2);
Interp_Trj2 = Interp_Trj2 / (s + eps);
[s_seg, ~] = TrjLength(Interp_Trj2);

S_seg = repmat(s_seg, 1, s_cnt + 1);
Step = repmat([0:1 / s_cnt:1], length(s_seg), 1);
clear s_seg
[~, min_idx] = min(abs(S_seg - Step));

Trj_bar = Interp_Trj2(min_idx, :); clear Interp_Trj2;
if unit_length == 1
    Trj_bar = Trj_bar * s;
end
V = diff(Trj_bar);
SRVF = V ./ repmat(sqrt(sqrt(sum(V.^2, 2))) + eps, 1, 3);

% ---- Project to the local coordinate
n_s = length(SRVF);
AngVel_bar = Interp_AngTrj2(min_idx, :);
for i = 1:n_s
    RotV = AngVel_bar(i, :) ./ (norm(AngVel_bar(i, :)) + eps);
    RotBeta = norm(AngVel_bar(i, :));
    RotM = vrrotvec2mat([RotV RotBeta]);
    if Rot_mode == 0
        SRVF(i, :) = SRVF(i, :) * RotM;
    elseif Rot_mode == 1
        SRVF(i, :) = SRVF(i, :) * RotM';
    elseif Rot_mode == 2
        SRVF(i, :) = SRVF(i, :);
    end
end
clear V Trj_bar

%% SRAF
% ---- Resampling
AngTrj_bar = Interp_AngTrj2(min_idx, :); clear Interp_AngTrj2;

% ----
V = diff(AngTrj_bar);
for i = 1:length(V)
    quat(i, :) = Myrotv2quat(V(i, :) ./ (norm(V(i, :)) + eps), norm(V(i, :)));
end
clear V AngTrj_bar

%% Remove rotational variance
Output.descriptor = [SRVF quat];
if SVD_mode == 1
    Output.U = U;
    Output.SIGN = SIGN;
end

end
