function [f, df,ddf] = costFuncRegMultPart(theta, X, Y, lambda,C,jointNum, initTheta)

% cosFunctionReg.m This function returns the function value, partial derivatives
% and Hessian of the (general dimension) rosenbrock function, given by:
% C is the class number
% Initialize some useful values
% Y = NxC column vector
if nargout < 7
	initTheta = 0;
end


%% Compute the costJ of a particular choice of theta
% compute cost costJ
% X = DxN matrix, J and M is the partition paramters over joints and feature modalities
D = size(X,1);
J = D/jointNum; % the number of parts
M = J; % the dimension of each part
% theta = DxC column vector
theta = reshape(theta,D,C);
% costJ = single number
costJ = sum(sum((X'*theta-Y).^2));

costRegularizationTerm1 = sum(sqrt(sum(theta.^2,2)));

tempJ = 0;
for j = 1:jointNum
	tempM = sqrt(sum(theta((j-1)*J+1:j*J,:).^4,1));
    tempJ = tempJ+sqrt(tempM);
end
costRegularizationTerm2 = sum(tempJ);
clear tempRegularTerm;

costRegularizationTerm3  =  sum(sum((theta - initTheta).^2));
costJWithRegularization = costJ + lambda(1)*costRegularizationTerm1 + lambda(2)*costRegularizationTerm2...
                          + lambda(3)*costRegularizationTerm3;
% Compute the partial derivatives and set gradiant to the partial
% derivatives of the cost w.r.t. each parameter in theta

%% compute the gradient
gradient  = 2*X*(X'*theta-Y);

clear X;


epsilon = 10e-8;% to avoid inf when devided by zero
gradientRegularizationTerm1 = repmat((sum(theta.^2,2)+epsilon).^(-1/2),1,C).*theta;

gradientRegularizationTerm2 = zeros(D,C);

for j = 1:jointNum
        gradientRegularizationTerm2((j-1)*J+1:j*J,:) = (theta((j-1)*J+1:j*J,:).^3)./repmat(sum(theta((j-1)*J+1:j*J,:).^4,1).^(3/4)+epsilon,J,1);
end

gradientRegularizationTerm3 = 2*(theta - initTheta);


gradient = gradient + lambda(1)*gradientRegularizationTerm1 + lambda(2)*gradientRegularizationTerm2...
                             + lambda(3)*gradientRegularizationTerm3;


f = costJWithRegularization;
gradient = reshape(gradient,D*C,1); % vec(W)

if nargout > 1
  df = gradient;
end

if nargout > 2
  ddf = ddgradient;
end
