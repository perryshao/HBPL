// DepthMapBinIOSample.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "DepthMapBinFileIO.h"
#include "DepthMap.h"
#include "DepthMap.cpp"
#include "DepthMapBinFileIO.cpp"
#include <mex.h> 
#include <matrix.h>
#include <time.h>
#include <limits.h>
#include <float.h>
#include <string.h>
//This is a sample program to load a depth video file (*.bin). Author: Zicheng Liu
//A depth video file consists of a sequence of depth maps. Each frame corresponds to one depth map.
//A depth map is a matrix of depth values (see CDepthMap in depthmap.h).
//I purposely did not create a data structure to hold all the frames of the depth video because it would result
//in large memory footprint.


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *depthmap,*dimension;
	int nofs = 0; //number of frames conatined in the file (each file is a video sequence of depth maps)
	int ncols = 0;
	int nrows = 0;
	int f; //frame index
	char *buf;
	int   buflen,status;

	/* parse input arguments*/
	buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
	buf = (char *) mxCalloc(buflen, sizeof(char));
	if (buf == NULL)
		mexErrMsgTxt("Not enough heap space to hold converted string.");

	status = mxGetString(prhs[0], buf, buflen); 
   if (status == 0)
     mexPrintf("The converted string is \n%s.\n", buf);
   else
     mexErrMsgTxt("Could not convert string data.");

	/*if (mxIsChar(prhs[0]))
	{
		mxGetString(prhs[0], depthFileName, 82);
	}
	*/
	strlwr(buf);
	
	FILE * fp = fopen(buf, "rb");

	if(fp == NULL)
		mexErrMsgTxt("cannot open files");
	

	ReadDepthMapBinFileHeader(fp, nofs, ncols, nrows);

	/* create output arguments*/
	plhs[0]=mxCreateDoubleMatrix(nrows,ncols*nofs,mxREAL);//output depthmap
	depthmap=mxGetPr(plhs[0]);//output depthmap
	plhs[1]=mxCreateDoubleMatrix(1,3,mxREAL);//output depthmap
	dimension=mxGetPr(plhs[1]);//output depthmap
	//read each frame
	
	for(f=0; f<nofs; f++)
	{
		CDepthMap depthMap;
		depthMap.SetSize(ncols, nrows); //it allocates space
		//the data will be stored in <depthMap>
		ReadDepthMapBinFileNextFrame(fp, ncols, nrows, depthMap);
		for (int r=0;r<nrows;r++)
			for (int c=0;c<ncols;c++)
		depthmap[f*ncols*nrows+c*nrows+r] = (double) depthMap.GetItem(r,c);
	}

	dimension[0] = nrows;dimension[1] = ncols;dimension[2] = nofs;
	fclose(fp);
	fp=NULL;

}