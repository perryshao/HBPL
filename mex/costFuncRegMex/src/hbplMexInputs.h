#ifndef HBPL_MEX_INPUTS_H
#define HBPL_MEX_INPUTS_H

#include <mex.h>
#include <cmath>
#include <climits>

// Validate the legacy eight-input/two-output contract before touching buffers.
inline void hbplValidateCostInputs(int nlhs, int nrhs, const mxArray *prhs[])
{
    if (nrhs != 8 || nlhs != 2)
        mexErrMsgIdAndTxt("HBPL:costArity", "Expected eight inputs and two outputs.");

    for (int k = 0; k < nrhs; ++k)
    {
        const mxArray *a = prhs[k];
        if (!mxIsDouble(a) || mxIsComplex(a) || mxIsSparse(a) || mxGetNumberOfDimensions(a) != 2 ||
            mxGetNumberOfElements(a) == 0 || mxGetNumberOfElements(a) > INT_MAX ||
            mxGetM(a) > INT_MAX || mxGetN(a) > INT_MAX)
            mexErrMsgIdAndTxt("HBPL:costType",
                              "Inputs must be nonempty real full double matrices.");
        const double *values = mxGetPr(a);
        for (mwSize i = 0; i < mxGetNumberOfElements(a); ++i)
            if (!std::isfinite(values[i]))
                mexErrMsgIdAndTxt("HBPL:costFinite", "Inputs must contain only finite values.");
    }
    for (int k = 4; k <= 6; ++k)
    {
        const double value = mxGetPr(prhs[k])[0];
        if (mxGetNumberOfElements(prhs[k]) != 1 || value < 1 || value > INT_MAX ||
            value != std::floor(value))
            mexErrMsgIdAndTxt("HBPL:costCount",
                              "Class, joint and modality counts must be positive integers.");
    }

    const mwSize d = mxGetM(prhs[1]);
    const mwSize n = mxGetN(prhs[1]);
    const mwSize classes = static_cast<mwSize>(mxGetPr(prhs[4])[0]);
    const mwSize joints = static_cast<mwSize>(mxGetPr(prhs[5])[0]);
    const mwSize modalities = static_cast<mwSize>(mxGetPr(prhs[6])[0]);
    if (d > static_cast<mwSize>(INT_MAX) / classes || d % joints != 0 ||
        (d / joints) % modalities != 0 || d / joints < modalities || mxGetM(prhs[2]) != n ||
        mxGetN(prhs[2]) != classes || mxGetNumberOfElements(prhs[3]) != 3 || mxGetN(prhs[0]) != 1 ||
        mxGetN(prhs[7]) != 1 || mxGetM(prhs[0]) != d * classes || mxGetM(prhs[7]) != d * classes)
        mexErrMsgIdAndTxt("HBPL:costShape",
                          "Inconsistent feature, target, parameter or group dimensions.");
}

#endif
