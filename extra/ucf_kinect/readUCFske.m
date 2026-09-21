%USAGE: drawskt(1,3,1,4,1,2) --- show actions 1,2,3 performed by subjects 1,2,3,4 with instances 1 and 2.
function [X Y Z] = readUCFske(filename)


[ posMat, posConf, oriMat, oriConf ] = loadSkeleton( filename );
% directory_loca=find(filename=='/');
% sub_id =str2double(filename(directory_loca(2)+1:directory_loca(2)+2));
frames =size(posMat,1);
XYZ = reshape(posMat(:,1,:,:),frames,3*15);
X = XYZ(:,1:15)';
Y = XYZ(:,(2-1)*15+1:2*15)';
Z = XYZ(:,(3-1)*15+1:3*15)';

