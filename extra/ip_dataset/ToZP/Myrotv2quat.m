% Axis angle to Quaternion
% by skaegy (skaegy@gmail.com)

% input
%    rotv, rotation vector
%    angle,
% output
%    quat, unit quaternion

function quat = Myrotv2quat(rotv, angle)
qw = cos(angle / 2);
qx = rotv(1) * sin(angle / 2);
qy = rotv(2) * sin(angle / 2);
qz = rotv(3) * sin(angle / 2);
quat = [qw qx qy qz];
end
