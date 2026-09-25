# LogHog OpenCV 4 port and validation

Date: 2026-09-25. Baseline: `c7c3a7b`. This follow-up resolves the LogHog build
blocker recorded in [RUNTIME_VALIDATION.md](RUNTIME_VALIDATION.md).
Machine-readable evidence is in
[LOGHOG_VALIDATION_RESULTS.json](LOGHOG_VALIDATION_RESULTS.json).

## Interface migration

The source used OpenCV 2.x `cv::FilterEngine`, `cv::createLinearFilter` and
`FilterEngine::apply`. These interfaces are described in the
[OpenCV 2.4 filtering documentation](https://docs.opencv.org/2.4.13.7/modules/imgproc/doc/filtering.html).
The two derivative filters now call the public
[`cv::filter2D` interface](https://docs.opencv.org/4.13.0/d4/d86/group__imgproc__filter.html).
Both retain their original 3-by-3 correlation kernels, centered anchor, zero
delta and constant zero border:

```text
dx:  0  0  0      dy:  0  1  0
    -1  0  1           0  0  0
     0  0  0           0 -1  0
```

The active sources no longer include the Windows `stdafx.h`/`targetver.h` chain
or the unused mexopencv wrappers. The calculator header is independent of MEX
types. A variable named `or` (a standard C++ keyword) is renamed to
`orientationRange`. Historical Visual Studio project files are retained as
archives; the new build helper compiles the two active C++ files directly.

The gateway requires exactly one input and one output. Input is a nonempty,
real, full, finite square double matrix. The default descriptor is an
N-by-150 double matrix for an N-by-N image. Invalid dimensions, types, output
counts, nonfinite values and overflowing gradients now raise `HBPL:LogHog*`
errors. Core configuration and integer dimension products are checked before
allocation. C++ exceptions unwind temporary buffers before becoming MEX errors.

## Build and use

Install OpenCV 4 development headers and `opencv_core`/`opencv_imgproc` libraries
for the same architecture as the selected MATLAB or Octave installation. The
helper supports macOS/Linux prefixes containing `include/opencv4` and `lib`.
Windows requires a separately configured compiler/linker setup.

```matlab
root = '/path/to/HBPL';
opencvPrefix = '/path/to/opencv-prefix';
outputDir = fullfile(root, 'cache', 'loghog');
addpath(fullfile(root, 'mex', 'LogHog'));
binaryPath = build_loghog(opencvPrefix, outputDir);
addpath(outputDir, '-begin');
assert(strcmp(which('LogHog'), binaryPath));
features = LogHog(double(ssm));
```

Use a separate output directory. The helper uses `mkoctfile --mex` in Octave and
`mex` in MATLAB. Only the Octave branch has been executed here; the MATLAB
branch needs a configured compatible C++ compiler and validation in MATLAB.
An Octave `.mex` is not a MATLAB `.mexmaca64` and must not be renamed for use
in MATLAB. Clear a previously loaded LogHog before switching builds, and check
`which('LogHog')` to avoid selecting an old binary in the current directory.

This machine has a verified Octave build at:

```text
~/Documents/Projects/HBPL/cache/loghog-octave/LogHog.mex
```

It uses OpenCV 4.13.0 from `/tmp/hbpl-native` and Octave 10.3.0 from
`/tmp/iid-octave`, with the local compiler environment recorded in the validation
scripts. These temporary dependency prefixes must remain available for the
module to load. For a permanent installation, supply an enduring dependency
prefix and rebuild. No dependency libraries, generated modules or datasets are
committed. All 31 tracked historical MEX binaries remain byte-identical; their
behavior does not acquire the new guards until rebuilt for their target host.

## Executed validation

| Layer | Executed coverage | Result |
|---|---|---|
| C++ port regression | 42 images; original descriptor arithmetic with independent scalar derivative filters, using OpenCV 4 angular primitives | Maximum absolute difference 0 |
| NumPy histogram reference | 30 images; independently computed voting, normalization and packing, with the same OpenCV polar conversion | Maximum absolute difference 2.63e-7; tolerance 1e-6 |
| ASan + UBSan | Actual gateway and calculator; 42 valid images and 12 invalid calls through a test-only MEX storage/error shim | Passed |
| Actual Octave MEX | Built using `build_loghog.m`; 42 synthetic images plus 3 real MSR skeleton-derived self-similarity images | All 45 passed; maximum absolute difference 8.94e-8 |
| Actual Octave error handling | 11 invalid type/shape/value/output-count calls | All rejected with the expected error family |
| Source checks | New MATLAB build helper and the three changed C++/header files | MISS_HIT style/lint and clang-format checks passed |

Synthetic fixtures include sizes 1, 2, 3, 8, 17, 32 and 64 with zero, constant,
ramp, corner impulse, sinusoidal and self-similarity-like patterns. Real fixtures
use the first 24 frames of three MSR clips, flatten their 20 joints into
60-coordinate frame vectors, and scale pairwise Euclidean distances to a
maximum of 255. They exercise descriptor extraction, not full TSSM training.

### Numerical interpretation and limits

The port preserves the original histogram arithmetic and normalization,
including historical mode 0 behaving as L1. It is not a redesign of unsigned
orientation endpoint handling. An additional NumPy version using exact
`atan2` was **not equivalent**: its maximum descriptor difference was 0.580145
on the checked fixtures. Investigation identified different endpoint-bin
choices on constant images when replacing OpenCV's approximate polar angles.
OpenCV documents approximate angles in
[`cartToPolar`](https://docs.opencv.org/4.13.0/d2/de8/group__core__array.html).
The passing NumPy comparison therefore shares this angular primitive; it is
independent for histogram construction, but not for angle evaluation.

The zero-difference C++ comparison uses saved baseline arithmetic adapted to
OpenCV 4 with scalar filters. It is not a comparison with the original OpenCV
2.x runtime or an old Windows MEX binary. ASan/UBSan instrument our C++ sources;
the linked OpenCV library is prebuilt and uninstrumented, and leak detection
was disabled. These bounded checks do not establish every memory path as safe.

No MATLAB runtime is available. MATLAB ABI compatibility, Windows rebuilding,
the complete TSSM baseline and full published benchmark accuracies remain
unverified. The earlier bounded HBPL pipeline results retain their original
scope; LogHog is a historical TSSM component, not a dependency of `hbplCost.m`.

## Local evidence and rerun

Validation tools and artifacts are kept outside the repository at
`~/Documents/ChatGPT/旧项目整理/HBPL-loghog-validation-20260925/`.
They include saved baseline sources, scalar/NumPy references, sanitizer harness,
fixtures, logs and JSON results. No `tests/` directory is distributed.

With the recorded local NumPy/SciPy environment and native dependencies:

```sh
python build.py
python check_reference.py
python make_octave_fixtures.py
python run_octave.py
```

The Python angular adapter requires the local `build/polar.dylib`, built from
`native/polar.cpp` against the same OpenCV prefix. Scripts reuse the previous
runtime validation's Octave compiler environment. A fresh clone needs those
dependencies, adapted paths and real-data fixtures before reproducing this
local run. The JSON report records source, script and adapter hashes.
