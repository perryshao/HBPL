function [f, df,ddf] = costFuncRegMultPartGp_v1_212(initialTheta, X, Y, lambda,C,jointNum, preTinitialTheta)

% cosFunctionReg.m This function returns the function value, partial derivatives
% and Hessian of the (general dimension) rosenbrock function, given by:
% C is the class number
% Initialize some useful values
% Y = NxC column vector
if nargin < 7
	preTinitialTheta = 0;
end

%partGroup = [20 0 0];
partGroup = [5 10 19];
groupCof = [1 1 1];
%% Compute the costJ of a particular choice of theta
% compute cost costJ
% X = DxN matrix, J and M is the partition paramters over joints and feature modalities
D = size(X,1);
J = D/jointNum; % the number of parts
% theta = DxC column vector
theta = reshape(initialTheta,D,C);
preTinitialTheta = reshape(preTinitialTheta,D,C);
% costJ = single number
costJ = sum(sum((X'*theta-Y).^2));

costRegularizationTerm1 = sum(sqrt(sum(theta.^2,2)));


%% part group1
tempJ = 0;
for j = 1:partGroup(1)
	tempM = sqrt(sum(theta((j-1)*J+1:j*J,:).^2,1));
    tempJ = tempJ+tempM;
end
costRegularizationTerm2 = tempJ;
clear tempM tempJ ;

% costRegularizationTerm2 = 0;
%% part group2
tempJ = 0;
for j = partGroup(1)+1:partGroup(1)+partGroup(2)
	tempM = sqrt(sum(theta((j-1)*J+1:j*J,:).^2,1));
    tempJ = tempJ+tempM;
end
costRegularizationTerm4 = tempJ;
clear tempM tempJ ;

% costRegularizationTerm4 = 0;
%% part group3
tempJ = 0;
for j = partGroup(1)+partGroup(2)+1:partGroup(1)+partGroup(2)+partGroup(3)
	tempM = sqrt(sum(theta((j-1)*J+1:j*J,:).^2,1));
    tempJ = tempJ+tempM;
end
costRegularizationTerm5 = tempJ;
clear tempM tempJ ;

% costRegularizationTerm5 = 0;
%% compute the sum cost                                    
costRegularizationTermRow = groupCof(1)*costRegularizationTerm2.^2+groupCof(2)*costRegularizationTerm4.^2+...
                                           groupCof(3)*costRegularizationTerm5.^2;
costRegularizationTermMain = sum(costRegularizationTermRow);


costRegularizationTerm3  =  sum(sum((theta - preTinitialTheta).^2));

costJWithRegularization = costJ + lambda(1)*costRegularizationTerm1 + lambda(2)*costRegularizationTermMain+ lambda(3)*costRegularizationTerm3;

% Compute the partial derivatives and set gradiant to the partial
% derivatives of the cost w.r.t. each parameter in theta
%% compute the gradient
gradient  = 2*X*(X'*theta-Y);

clear X;

epsilon = 10e-8; % to avoid inf when devided by zero
gradientRegularizationTerm1 = repmat((sum(theta.^2,2)+epsilon).^(-1/2),1,C).*theta;


%% part group1
gradientRegularizationTerm2 = zeros(D,C);
for j = 1:partGroup(1)
     gradientRegularizationTerm2((j-1)*J+1:j*J,:) = repmat(costRegularizationTerm2,J,1).*((theta((j-1)*J+1:j*J,:))./repmat(sum(theta((j-1)*J+1:j*J,:).^2,1).^(1/2)+epsilon,J,1));
%      gradientRegularizationTerm2((j-1)*J+1:j*J,:) = (costRegularizationTerm2^3/costRegularizationTermMain^3)*((theta((j-1)*J+1:j*J,:).^3)./repmat(sum(theta((j-1)*J+1:j*J,:).^4,1).^(3/4)+epsilon,J,1));
%      gradientRegularizationTerm2((j-1)*J+1:j*J,:) = repmat(costRegularizationTerm2,J,1).*...
%                                                                                ((theta((j-1)*J+1:j*J,:).^3)./(repmat(sum(theta((j-1)*J+1:j*J,:).^4,1).^(3/4)+epsilon,J,1)));
end

% gradientRegularizationTerm2 =0;
%% part group2
gradientRegularizationTerm4 = zeros(D,C);
for j = partGroup(1)+1:partGroup(1)+partGroup(2)
    gradientRegularizationTerm4((j-1)*J+1:j*J,:) = repmat(costRegularizationTerm4,J,1).*((theta((j-1)*J+1:j*J,:))./repmat(sum(theta((j-1)*J+1:j*J,:).^2,1).^(1/2)+epsilon,J,1));
%     gradientRegularizationTerm4((j-1)*J+1:j*J,:) = (costRegularizationTerm4^3/costRegularizationTermMain^3)*((theta((j-1)*J+1:j*J,:).^3)./repmat(sum(theta((j-1)*J+1:j*J,:).^4,1).^(3/4)+epsilon,J,1));
%     gradientRegularizationTerm4((j-1)*J+1:j*J,:) =  repmat(costRegularizationTerm4,J,1).*...
%                                                                                ((theta((j-1)*J+1:j*J,:).^3)./(repmat(sum(theta((j-1)*J+1:j*J,:).^4,1).^(3/4)+epsilon,J,1)));
end

% gradientRegularizationTerm4 =0;
%% part group3
gradientRegularizationTerm5 = zeros(D,C);
for j = partGroup(1)+partGroup(2)+1:partGroup(1)+partGroup(2)+partGroup(3)
     gradientRegularizationTerm5((j-1)*J+1:j*J,:) = repmat(costRegularizationTerm5,J,1).*((theta((j-1)*J+1:j*J,:))./repmat(sum(theta((j-1)*J+1:j*J,:).^2,1).^(1/2)+epsilon,J,1));
%      gradientRegularizationTerm5((j-1)*J+1:j*J,:) = (costRegularizationTerm5^3/costRegularizationTermMain^3)*((theta((j-1)*J+1:j*J,:).^3)./repmat(sum(theta((j-1)*J+1:j*J,:).^4,1).^(3/4)+epsilon,J,1));
%      gradientRegularizationTerm5((j-1)*J+1:j*J,:) = repmat(costRegularizationTerm5,J,1).*...
%                                                                                ((theta((j-1)*J+1:j*J,:).^3)./(repmat(sum(theta((j-1)*J+1:j*J,:).^4,1).^(3/4)+epsilon,J,1)));
end

% gradientRegularizationTerm5 =0;
%% compute the sum gradient
gradientRegularizationTerm3 = 2*(theta - preTinitialTheta);


gradient = gradient + lambda(1)*gradientRegularizationTerm1 + lambda(2)*(groupCof(1)*gradientRegularizationTerm2+groupCof(2)*gradientRegularizationTerm4...
                                +groupCof(3)*gradientRegularizationTerm5)+ lambda(3)*gradientRegularizationTerm3;


f = costJWithRegularization;
gradient = reshape(gradient,D*C,1); % vec(W)

if nargout > 1
  df = gradient;
end

if nargout > 2
  ddf = ddgradient;
end
