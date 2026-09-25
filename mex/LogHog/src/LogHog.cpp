#include "log_hogcalculator.h"
#include <mex.h>
#include <climits>
#include <cmath>
#include <exception>
#include <cstdio>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 1 || nlhs != 1)
        mexErrMsgIdAndTxt("HBPL:LogHogArity", "LogHog requires one input and one output.");
    const mxArray *input = prhs[0];
    if (!mxIsDouble(input) || mxIsComplex(input) || mxIsSparse(input) ||
        mxGetNumberOfDimensions(input) != 2 || mxGetM(input) == 0 || mxGetM(input) != mxGetN(input))
        mexErrMsgIdAndTxt("HBPL:LogHogType",
                          "Input must be a nonempty real full square double matrix.");
    if (mxGetNumberOfElements(input) > INT_MAX)
        mexErrMsgIdAndTxt("HBPL:LogHogSize", "Image exceeds integer index limits.");
    const double *pixels = mxGetPr(input);
    for (mwSize i = 0; i < mxGetNumberOfElements(input); ++i)
        if (!std::isfinite(pixels[i]))
            mexErrMsgIdAndTxt("HBPL:LogHogFinite", "Image values must be finite.");

    // Catch C++ failures after temporary OpenCV buffers have been unwound.
    char failure[1024] = {};
    try
    {
        const int size = static_cast<int>(mxGetM(input));
        cv::Mat image(size, size, CV_64F);
        for (int row = 0; row < size; ++row)
            for (int col = 0; col < size; ++col)
                image.at<double>(row, col) = pixels[col * size + row];

        LogHogCalculator calculator(30, 8, 4, 6, "unsigned", 4);
        cv::Mat descriptor = calculator.ExtractHogsDiagonal(image);
        plhs[0] = mxCreateDoubleMatrix(descriptor.rows, descriptor.cols, mxREAL);
        double *output = mxGetPr(plhs[0]);
        for (int row = 0; row < descriptor.rows; ++row)
            for (int col = 0; col < descriptor.cols; ++col)
                output[col * descriptor.rows + row] = descriptor.at<double>(row, col);
    }
    catch (const std::exception &error)
    {
        std::snprintf(failure, sizeof(failure), "%s", error.what());
    }
    if (failure[0] != '\0')
        mexErrMsgIdAndTxt("HBPL:LogHogComputation", "%s", failure);
}
