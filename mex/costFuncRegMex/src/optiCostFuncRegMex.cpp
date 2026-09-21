#include <math.h>
#include <mex.h>
#include <matrix.h>
#include <mat.h>
#include <time.h>
#include <limits.h>
#include <float.h>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace cv;
using namespace std;
const double PI = 3.1415926535897932384626433832795;

Mat matToCvMat(const mxArray *arrayPtr)
{
	
	double *matData = mxGetPr(arrayPtr);
	int m = mxGetM(arrayPtr);
	int n = mxGetN(arrayPtr);
	// transfer mxArray to Mat in opencv
	Mat cvMat(m,n,CV_64F);
	
	for (int i = 0; i < m; i++)
   {
        for (int j = 0; j < n; j++)
        {
			 cvMat.at<double>(i,j) = matData[j*m+i];
        }
   }
   return cvMat;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* parse input arguments*/
	Mat thetaCol = matToCvMat(prhs[0]);
	Mat X = matToCvMat(prhs[1]);
	Mat Y = matToCvMat(prhs[2]);
	Mat initThetaCol = matToCvMat(prhs[7]);

	double *lambda = mxGetPr(prhs[3]);
	double *C = mxGetPr(prhs[4]);
	double *jointNum = mxGetPr(prhs[5]);
	double *modulaNum = mxGetPr(prhs[6]);


  // cosFunctionReg.m This function returns the function value, partial derivatives
  // and Hessian of the (general dimension) rosenbrock function, given by:
	// C is the class number
	//Initialize some useful values
	// Y = NxC column vector

	// Compute the costJ of a particular choice of theta
	// compute cost costJ
	// X = DxN matrix, J and M is the partition paramters over joints and feature modalities

	int D = X.rows;
	int N = X.cols;
	int J = (int) (D/jointNum[0]);int M = (int)(J/modulaNum[0]);
	// theta = DXC column vector
	Mat thetaReshape = thetaCol.reshape(0,C[0]);
	Mat theta = thetaReshape.t();
	thetaReshape = initThetaCol.reshape(0,C[0]);
	Mat initTheta = thetaReshape.t();
	// costJ = single number
	double costJ = pow(norm(X.t()*theta,Y,NORM_L2),2);

	Mat squareTheta;
	cv::pow(theta,2,squareTheta);
	Mat tempThetaCols(theta.rows,1,CV_64F,Scalar(0));
	cv::reduce(squareTheta,tempThetaCols,1,CV_REDUCE_SUM,-1);
	cv::sqrt(tempThetaCols,tempThetaCols);
	double costRegularizationTerm1 = cv::sum(tempThetaCols)[0];

	Mat tempJ(1,theta.cols,CV_64F,Scalar(0));
	for (int j=0;j<jointNum[0];j++)
	{
		Mat tempM(1,theta.cols,CV_64F,Scalar(0));
		for (int m=0;m<modulaNum[0];m++)
		{
				Mat tempRegularTerm(M,theta.cols,CV_64F,Scalar(0));
				theta(Range(j*J+m*M,j*J+(m+1)*M),Range::all()).copyTo(tempRegularTerm(Range(0,M),Range::all()));
				//theta.rowRange(j*J+m*M,j*J+(m+1)*M).copyTo(tempRegularTerm.rowRange(0,M));
				cv::pow(tempRegularTerm,4,tempRegularTerm);
				cv::reduce(tempRegularTerm,tempRegularTerm.row(0),0,CV_REDUCE_SUM,-1);
				cv::sqrt(tempRegularTerm.row(0),tempRegularTerm.row(0));
				tempM = tempM + tempRegularTerm.row(0);
		}
		cv::sqrt(tempM,tempM);
		tempJ = tempJ + tempM;
	}
	double costRegularizationTerm2 = cv::sum(tempJ)[0];

	double costRegularizationTerm3 = pow(norm(theta,initTheta,NORM_L2),2);

	double costJWithRegularization = costJ + lambda[0]*costRegularizationTerm1
	                                       + lambda[1]*costRegularizationTerm2
		                                   + lambda[2]*costRegularizationTerm3;
	// Compute the partial derivatives and set gradiant to the partial
	// derivatives of the cost w.r.t. each parameter in theta

	// compute the gradient
	Mat gradient = 2*X*(X.t()*theta-Y);

	double epsilon = 10e-8; // to avoid inf when divided by zero
	Mat tempSumCol(theta.rows,1,CV_64F,Scalar(0));
	cv::reduce(squareTheta,tempSumCol,1,CV_REDUCE_SUM,-1);
	cv::sqrt(tempSumCol+epsilon,tempSumCol);
	Mat gradientRegularizationTerm1	= repeat(1/tempSumCol, 1, C[0]).mul(theta);

	Mat gradientRegularizationTerm2(D,C[0],CV_64F,Scalar(0));
	
	for (int j=0;j<jointNum[0];j++)
	{
		Mat tempGrad(1,theta.cols,CV_64F,Scalar(0));
		Mat tempModu(M,theta.cols,CV_64F,Scalar(0));
		for (int m=0;m<modulaNum[0];m++)
		{
			Mat tempPowMatrix(M,theta.cols,CV_64F,Scalar(0));
			theta.rowRange(j*J+m*M,j*J+(m+1)*M).copyTo(tempModu.rowRange(0,M));
			cv::pow(tempModu,4,tempModu);
			cv::reduce(tempModu,tempModu.row(0),0,CV_REDUCE_SUM,-1);
			cv::sqrt(tempModu.row(0),tempModu.row(0));
			tempGrad = tempGrad + tempModu.row(0);
		}
		for (int m=0;m<modulaNum[0];m++)
		{
			Mat tempPowMatrix;Mat tempSumRow(1,theta.cols,CV_64F,Scalar(0));
			theta.rowRange(j*J+m*M,j*J+(m+1)*M).copyTo(tempModu.rowRange(0,M));
			cv::sqrt(tempGrad+epsilon,tempGrad);
			cv::pow(tempModu,4,tempPowMatrix);
			cv::reduce(tempPowMatrix,tempSumRow,0,CV_REDUCE_SUM,-1);
			cv::sqrt(tempSumRow+epsilon,tempSumRow);
			Mat tempModuPow;
			cv::pow(tempModu,3,tempModuPow);
			gradientRegularizationTerm2(Range(j*J+m*M,j*J+(m+1)*M),Range::all()) = tempModuPow/repeat(tempGrad.mul(tempSumRow),M,1);
		}
	}
	Mat gradientRegularizationTerm3 = 2*(theta-initTheta);
	// where [0; theta(2:end)] is the same column vector theta beginning with a value of '0' at index
	// 1 and then containing the old values from index 2:end of theta

	// gradient = DXC column vector
	gradient = gradient + lambda[0]*gradientRegularizationTerm1
					    + lambda[1]*gradientRegularizationTerm2
	                  	+ lambda[2]*gradientRegularizationTerm3;

	double f = costJWithRegularization;
	Mat tempGradient = gradient.t();
	Mat df = tempGradient.reshape(0,D*C[0]); // vec(W)
	int m = df.rows; int n = df.cols;
	double *outputDf; double *outputF;
	plhs[0] = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
	plhs[1] = mxCreateNumericMatrix(m, n, mxDOUBLE_CLASS, mxREAL);
	outputF = mxGetPr(plhs[0]);
	outputF[0] = f;
	outputDf = mxGetPr(plhs[1]);
	for (int i = 0; i < m; i++)
	{
	    for (int j = 0; j < n; j++)
	    {
	        outputDf[j*m + i] =  df.at<double>(i,j);
	    }
	}
}

