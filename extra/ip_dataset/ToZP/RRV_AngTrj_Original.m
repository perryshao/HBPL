% DSRF descriptor: by skaegy (skaegy@gmail.com)
% SVD, and the length of s=1
% input
%    sixdof - n*6 1:3~trajectory 4:6~angular velocity
%    delta_t - the sample rate
% output
%    descriptor - n*6
% vrrotvec(A,B)


function Output=RRV_AngTrj_Original(sixdof,options) 
if nargin<2
    error('Need more input');
end
name=fieldnames(options);
if ~ismember('SVD_mode',name)
    SVD_mode=0;
else
    SVD_mode=options.SVD_mode;
end
if ~ismember('Rot_mode',name)
    Rot_mode=0;
else
    Rot_mode=options.Rot_mode;
end

if size(sixdof,2)~=6
    sixdof=sixdof';
end
%%
Trj=sixdof(:,1:3);
n=length(Trj);
AngTrj=sixdof(:,4:6);
%---- Calculate Euler axis and angles

if SVD_mode==1
%     RandVec=rand(1,3);
%     RandVec=RandVec./norm(RandVec);
%     RandBeta=(rand(1)-0.5)*2*pi;
%     RandRotM=vrrotvec2mat([RandVec RandBeta]);
%     AngTrj=AngTrj*RandRotM;Trj=Trj*RandRotM;
    [U,~,~]=svd(AngTrj');AngTrj=AngTrj*U;Trj=Trj*U;
    SIGN=CalSIGN(AngTrj);
    AngTrj=AngTrj.*repmat(SIGN,n,1);
    Trj=Trj.*repmat(SIGN,n,1); 
end

%% RRV
%---- Resampling
W=diff(AngTrj);
V=diff(Trj);
SRVF=V./repmat(sqrt(sqrt(sum(V.^2,2)))+eps,1,3);
for i=1:length(W)
    RotBeta=norm(W(i,:)); RotV=W(i,:)./(norm(W(i,:))+eps);
    quat(i,:)=Myrotv2quat(RotV,RotBeta);
    RotM=vrrotvec2mat([RotV RotBeta]);
    if Rot_mode==0
        SRVF(i,:)=SRVF(i,:)*RotM;
    elseif Rot_mode==1
        SRVF(i,:)=SRVF(i,:)*RotM';
    elseif Rot_mode==2
        SRVF(i,:)=SRVF(i,:);
    end
end

clear W V 


%% Remove rotational variance
Output.descriptor=[ quat SRVF ];
if SVD_mode==1
    Output.U=U;
    Output.SIGN=SIGN;
end

end



