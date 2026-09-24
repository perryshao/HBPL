function [f, df, ddf] = costFunctionReg(theta, X, Y, lambda, C, jointNum, modulaNum, initTheta)

% cosFunctionReg.m This function returns the function value, partial derivatives
% and Hessian of the (general dimension) rosenbrock function, given by:
% C is the class number
% Initialize some useful values
% Y = NxC column vector
if nargout < 7
    initTheta = 0;
end
modalityNum = modulaNum;

% nBases1 = 1024;nBases2 = 128;%nBases3 = 128; % for sparse coding
numClusters1 = 32; numClusters2 = 32; DimFeat1 = 4; DimFeat2 = 3;  % for fisher vector

%% Compute the costJ of a particular choice of theta
% compute cost costJ
% X = DxN matrix, J and M is the partition parameters over joints and feature modalities
D = size(X, 1); N = size(X, 2);
J = D / jointNum;
ntotalbh = 3;
% M(1:modalityNum) = ones(1,2).*(J/modalityNum); % if dimensions of each modality are equal.

% M(1:modalityNum) = [nBases1*sum(2.^(0:ntotalbh))]; % for single modality
% M(1:modalityNum) = [nBases1*sum(2.^(0:ntotalbh)) nBases2*sum(2.^(0:ntotalbh))];% if dimensions of each modality is not equal
M(1:modalityNum) = [numClusters1 * 2 * DimFeat1 * sum(2.^(0:ntotalbh)) numClusters2 * 2 * DimFeat2 * sum(2.^(0:ntotalbh))]; % if dimensions of each modality is not equal
% theta = DxC column vector
theta = reshape(theta, D, C);
% costJ = single number
costJ = sum(sum((X' * theta - Y).^2));

costRegularizationTerm1 = sum(sqrt(sum(theta.^2, 2)));

tempJ = 0;
for j = 1:jointNum
    tempM = 0;
    tempRegularTerm = theta((j - 1) * J + 1:j * J, :);
    tempIndexM = 0;
    for m = 1:modalityNum
        tempM = tempM + sqrt(sum(tempRegularTerm(tempIndexM + 1:tempIndexM + M(m), :).^4, 1));
        tempIndexM = tempIndexM + M(m);
    end
    tempJ = tempJ + sqrt(tempM);
end
costRegularizationTerm2 = sum(tempJ);
clear tempRegularTerm;

costRegularizationTerm3  =  sum(sum((theta - initTheta).^2));
costJWithRegularization = costJ + lambda(1) * costRegularizationTerm1 + lambda(2) * costRegularizationTerm2 ...
                          + lambda(3) * costRegularizationTerm3;
% Compute the partial derivatives and set gradiant to the partial
% derivatives of the cost w.r.t. each parameter in theta

%% compute the gradient
gradient  = 2 * X * (X' * theta - Y);

% ddgradient = sparse(D*C,D*C);
% subD = floor(D/8);subN = floor(N/8);
% XX = sparse(D,D);
% for i = 1:8
%     for j = 1:9
%         if j < 9
%            XX((i-1)*subD+1:i*subD,(i-1)*subD+1:i*subD) = X((i-1)*subD+1:i*subD,(j-1)*subN+1:j*subN)*(X((i-1)*subD+1:i*subD,(j-1)*subN+1:j*subN))';
%         else
%            XX((i-1)*subD+1:i*subD,(i-1)*subD+1:i*subD) = X((i-1)*subD+1:i*subD,(j-1)*subN+1:end)*(X((i-1)*subD+1:i*subD,(j-1)*subN+1:end))';
%         end
%     end
% end
% clear X;
% for i = 1:C
%   ddgradient((i-1)*D+1:i*D,(i-1)*D+1:i*D) = XX;
% end
% clear XX;
clear X;

epsilon = 10e-8; % to avoid inf when devided by zero
gradientRegularizationTerm1 = repmat((sum(theta.^2, 2) + epsilon).^(-1 / 2), 1, C) .* theta;

% tic;
% ddgradientRegularizationTerm1 = 2;
% gradientRegularizationTerm2 = zeros(D,C);
% ddgradientRegularizationTerm2 = zeros(D*C,D*C);
% for c = 1:C
%   for j = 1:jointNum
%       tempGrad = 0;
%       startPosJoint = (j-1)*J+1;
%       for m = 1:modalityNum
%           tempModu = theta(startPosJoint+(m-1)*M:startPosJoint+m*M-1,c);
%           tempGrad = tempGrad + sqrt(sum(tempModu.^4));
%       end
%       for m = 1:modalityNum
%           tempModu = theta(startPosJoint+(m-1)*M:startPosJoint+m*M-1,c);
%           startPosM = startPosJoint+(m-1)*M;
%           for i = 1:M
%               gradientRegularizationTerm2(startPosM+i-1,c) = (tempModu(i)^3)/(sqrt(sum(tempModu.^4)+epsilon)*sqrt(tempGrad+epsilon));
% %                 for ii = 1:M
% %                     if ii == i
% %                         ddgradientRegularizationTerm2((c-1)*C+startPosM+i-1,(c-1)*C+startPosM+ii-1) = -tempGrad^(-3/2)*(sum(tempModu.^4)^(-2))*tempModu(i)^6 ...
% %                         +3*tempGrad^(-1/2)*(sum(tempModu.^4))^(-1/2)*tempModu(i)^2+(-2)*tempGrad^(-1/2)*(sum(tempModu.^4))^(-3/2)*tempModu(i)^6;
% %                     else
% %                         ddgradientRegularizationTerm2((c-1)*C+startPosM+i-1,(c-1)*C+startPosM+ii-1) = -tempGrad^(-3/2)*(sum(tempModu.^4)^(-2))*tempModu(i)^3 ...
% %                         *tempModu(ii)^3+(-2)*tempGrad^(-1/2)*(sum(tempModu.^4))^(-3/2)*tempModu(i)^3*tempModu(ii)^3;
% %                     end
% %                 end
% %                 for mm = 1:modalityNum
% %                     if m ~= mm
% %                         tempOtherModu = theta(startPosJoint+(mm-1)*M:startPosJoint+mm*M-1,c);
% %                         for ii = 1:M
% %                         ddgradientRegularizationTerm2((c-1)*C+startPosM+i-1,(c-1)*C+startPosJoint+(mm-1)*M+ii) = -tempGrad^(-3/2)*(sum(tempOtherModu.^4))^(-3/2)...
% %                         *(sum(tempModu.^4))^(-1/2)*tempModu(i)^3*tempOtherModu(ii)^3;
% %                         end
% %                     end
% %                 end
%           end
%       end
%   end
% end
% toc;

gradientRegularizationTerm2 = zeros(D, C);
% ddgradientRegularizationTerm2 = zeros(D*C,D*C);
for j = 1:jointNum
    tempGrad = 0;
    startPosJoint = (j - 1) * J + 1;
    tempIndexM = 0;
    for m = 1:modalityNum
        tempModu = theta(startPosJoint + tempIndexM:startPosJoint + tempIndexM + M(m) - 1, :);
        tempGrad = tempGrad + sqrt(sum(tempModu.^4, 1));
        tempIndexM = tempIndexM + M(m);
    end
    tempIndexM = 0;
    for m = 1:modalityNum
        tempModu = theta(startPosJoint + tempIndexM:startPosJoint + tempIndexM + M(m) - 1, :);
        startPosM = startPosJoint + tempIndexM;
        gradientRegularizationTerm2(startPosM:startPosM + M(m) - 1, :) = (tempModu.^3) ./ repmat(sqrt(sum(tempModu.^4, 1) + epsilon) .* sqrt(tempGrad + epsilon), M(m), 1);
        tempIndexM = tempIndexM + M(m);
    end
end

gradientRegularizationTerm3 = 2 * (theta - initTheta);
% ddgradientRegularizationTerm3 = 2;
% where [0; theta(2:end)] is the same column vector theta beginning with a value of '0' at index
% 1 and then containing the old values from index 2:end of theta

% gradient = DXC column vector
% gradientRegularizationTerm1(isnan(gradientRegularizationTerm1)) = 0;% to eliminate the NaN
% gradientRegularizationTerm2(isnan(gradientRegularizationTerm2)) = 0;% to eliminate the NaN
% gradientRegularizationTerm3(isnan(gradientRegularizationTerm3)) = 0;% to eliminate the NaN

gradient = gradient + lambda(1) * gradientRegularizationTerm1 + lambda(2) * gradientRegularizationTerm2 ...
                             + lambda(3) * gradientRegularizationTerm3;
% gradient = (DXC)x(DXC) column vector
% ddgradient = ddgradient + lambda(1)*ddgradientRegularizationTerm1 + lambda(2)*ddgradientRegularizationTerm2 + ...
%              lambda(3)*ddgradientRegularizationTerm3;

f = costJWithRegularization;
gradient = reshape(gradient, D * C, 1); % vec(W)

if nargout > 1
    df = gradient;
end

if nargout > 2
    ddf = ddgradient;
end
