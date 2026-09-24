// DepthMapBinIOSample.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "DepthMapBinFileIO.h"

//This is a sample program to load a depth video file (*.bin). Author: Zicheng Liu
//A depth video file consists of a sequence of depth maps. Each frame corresponds to one depth map.
//A depth map is a matrix of depth values (see CDepthMap in depthmap.h).
//I purposely did not create a data structure to hold all the frames of the depth video because it would result
//in large memory footprint.
int _tmain(int argc, _TCHAR* argv[])
{
	//char depthFileName[] = "G:\\\\public\\depthData\\a01_s01_e01_sdepth.bin";
	char depthFileName[] = "D:\\\\My work\\Motion database\\MSR Action3D\\MSR-Action3D\\a01_s01_e01_sdepth.bin";
	
	FILE * fp = fopen(depthFileName, "rb");

	if(fp == NULL)
		return 1;

	
	int nofs = 0; //number of frames conatined in the file (each file is a video sequence of depth maps)
	int ncols = 0;
	int nrows = 0;
	ReadDepthMapBinFileHeader(fp, nofs, ncols, nrows);

	printf("number of frames=%i\n", nofs);

	//read each frame
	int f; //frame index
	for(f=0; f<nofs; f++)
	{
		CDepthMap depthMap;
		depthMap.SetSize(ncols, nrows); //it allocates space
		//the data will be stored in <depthMap>
		ReadDepthMapBinFileNextFrame(fp, ncols, nrows, depthMap);

		//check to see what has been loaded for DEBUG purpose:
		int nNonZeroPoints = depthMap.NumberOfNonZeroPoints();
		float avg = depthMap.AvgNonZeroDepth();
		printf("frame[%i], ncols=%i, nrows=%i, count=%i, avg=%f\n", f, depthMap.GetNCols(), depthMap.GetNRows(), nNonZeroPoints, avg );
	}

	fclose(fp);
	fp=NULL;

	return 0;
}

