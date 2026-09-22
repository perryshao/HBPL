# Third-party notices

The MIT licence in [`LICENSE`](LICENSE) covers the code written for this
project, and nothing else. The files below were written by others, are vendored
here unmodified, and keep their own terms. This list is provided in good faith;
where a file carries no explicit licence text, the upstream project's terms
govern.

## minimize.m — Carl Edward Rasmussen

Polack-Ribiere conjugate gradient / line-search minimiser, 2001–2002.
Distributed by the author alongside *Gaussian Processes for Machine Learning*
(Rasmussen & Williams, MIT Press), which permits use and modification for any
purpose provided the notice is retained.

Copies at:

- `src/msr_action3d/minimize.m`
- `src/ut_kinect/minimize.m`
- `src/ntu_rgbd/minimize.m`
- `extra/ip_dataset/minimize.m`
- `extra/msrc12_gesture/minimize.m`
- `extra/msr_daily_act/minimize.m`
- `extra/ucf_kinect/minimize.m`

Upstream: <http://learning.eng.cam.ac.uk/carl/code/minimize/>

## MxArray, mexopencv headers — Kota Yamaguchi

MATLAB↔OpenCV bridge from [mexopencv](https://github.com/kyamagu/mexopencv),
2012, BSD licensed.

- `mex/LogHog/src/MxArray.hpp`
- `mex/LogHog/src/MxArray.cpp`
- `mex/LogHog/src/mexopencv.hpp`
- `mex/LogHog/src/mexopencv_features2d.hpp`

## ndSparse.m — Matt Jacobson

N-dimensional sparse array class. Copyright Xoran Technologies, Inc. 2010,
distributed through the MATLAB File Exchange under its BSD-style terms.

- `extra/ip_dataset/ndSparse.m`
- `extra/msrc12_gesture/ndSparse.m`

## dist2.m — Ian T. Nabney

Squared-distance helper from the Netlab toolbox, 1996–2001.

- `extra/ip_dataset/dist2.m`
- `extra/msrc12_gesture/dist2.m`

## Not distributed here

VLFeat and LIBSVM are required to run the pipeline but are **not** included in
this repository; fetch them from upstream under their own licences (VLFeat:
BSD-2-Clause; LIBSVM: BSD-3-Clause). See the README.

Datasets (MSR-Action3D, UT-Kinect, NTU RGB+D) are distributed by their
original authors under their own terms and are likewise not included.
