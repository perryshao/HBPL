# MEX components

The MATLAB pipelines under `src/` use `hbplCost.m`; they do not require these
legacy C++ components. Keep the source and prebuilt binaries for historical
experiments, but do not substitute the MEX objectives for a MATLAB wrapper
without checking both the interface and the regularizer.

| Component | Historical purpose |
|---|---|
| `costFuncRegMex` | Part/modality mixed-norm regression objective and gradient |
| `optiCostFuncRegMex` | Vectorized implementation of that legacy objective |
| `LogHog` | Log-polar HOG descriptor used by TSSM baselines |

## Prebuilt binaries

The repository includes Windows x64 (`.mexw64`) binaries under
`costFuncRegMex/bin/win64/`, `LogHog/bin/win64/`, and historical dataset
folders. All 31 tracked binaries were preserved byte-for-byte during the
September 2026 polish. No Linux (`.mexa64`) or macOS (`.mexmaci64`,
`.mexmaca64`) binaries are present in this checkout.

These are historical builds. Their compatibility with the current MATLAB
release has not been tested. Source edits do not update a prebuilt binary;
rebuild with a compatible compiler and MATLAB environment when needed.

## Source interface

Both cost-function entry points read **eight inputs**:

```matlab
[f, df] = costFuncRegMex(theta, X, Y, lambda, classNum, ...
                        jointNum, modalityNum, priorTheta);
```

`theta` and `priorTheta` are column-major weight vectors, `X` is D-by-N,
`Y` is N-by-classNum, and `lambda` contains three weights. The C++ source
now checks real, full, finite double arrays, positive integral partition counts,
compatible dimensions and integer bounds. Request exactly eight inputs and both
outputs; invalid calls raise `HBPL:cost*` errors before buffers are accessed.
The old binaries lack these guards and can still crash on invalid calls.

This is **not** the seven-argument `costFuncRegMultPartGp_v2` interface. The
C++ regularizer partitions weights by joint and modality and does not use
`partGroup` to couple three body-part layers. Numerical equality with
`hbplCost` is therefore not expected. The earlier seven-argument comparison
example was invalid and has been removed.

## Building from source

All three components depend on OpenCV and a MATLAB or Octave MEX toolchain.
The cost-function sources include legacy OpenCV headers and constants. The
Visual Studio projects describe the original build environment; the current
LogHog sources no longer require their Windows precompiled-header chain.

The two cost-function sources were built with OpenCV 4.13.0 and C++17 for native
sanitizers and Octave 10.3.0 MEX execution. The local build provides compatibility
`matrix.h`/`mat.h` includes and defines `CV_REDUCE_SUM=cv::REDUCE_SUM`.
Those environment-specific validation adapters are not distributed.
This does not validate a MATLAB build or its ABI.

LogHog now uses the public OpenCV 4 `filter2D` interface in place of
`FilterEngine`/`createLinearFilter`. Build it with
[`LogHog/build_loghog.m`](LogHog/build_loghog.m) into a separate directory.
The rebuilt Octave module passed numerical regression and invalid-input checks;
the same source also passed bounded native ASan/UBSan checks.

### Building LogHog

Install matching-architecture OpenCV 4 development headers under
`<opencvPrefix>/include/opencv4` and libraries under `<opencvPrefix>/lib`.
The helper supports macOS/Linux and links `opencv_core` and `opencv_imgproc`.
Windows requires a separately configured build.

```matlab
root = '/path/to/HBPL';
opencvPrefix = '/path/to/opencv-prefix';
outputDir = fullfile(root, 'cache', 'loghog');
addpath(fullfile(root, 'mex', 'LogHog'));
clear LogHog;
binaryPath = build_loghog(opencvPrefix, outputDir);
addpath(outputDir, '-begin');
assert(strcmp(which('LogHog'), binaryPath));
features = LogHog(double(ssm));
```

LogHog requires exactly one input and one output. Input must be a nonempty,
real, full, finite N-by-N double matrix; the default output is N-by-150.
The helper uses `mkoctfile` in Octave and `mex` in MATLAB. Only the Octave build
has been executed; the MATLAB branch and ABI require validation with MATLAB
and a configured C++ compiler. An Octave `.mex` cannot be renamed into a MATLAB
binary. Keep the selected OpenCV installation available for runtime linking.
Use a separate output directory to preserve historical binaries.

The port retains the original histogram arithmetic and OpenCV polar-angle
approximation. Exact `atan2` can select different unsigned endpoint bins.
Neither original OpenCV 2 binary equivalence nor full published benchmark
reproduction has been established.

### Cost-function comparison

Before using a rebuilt library, compare its values and gradients against the
matching historical MATLAB objective on valid inputs. Do not use the
three-layer `_v2` objective as a reference for the part/modality MEX objective.

## Third-party code

`LogHog/src/MxArray.{hpp,cpp}`, `mexopencv.hpp`, and
`mexopencv_features2d.hpp` originate from
[mexopencv](https://github.com/kyamagu/mexopencv) by Kota Yamaguchi.
Their copyright and licence notices are retained; see
[THIRD-PARTY-NOTICES.md](../THIRD-PARTY-NOTICES.md).

## Recovered depth reader

Original DepthMapBinIO sources and project files are in `DepthMapBinIO-src/`.
This historical depth-data reader retains legacy platform assumptions. Its
current binary is unchanged, the recovered source has not been rebuilt, and
source-to-binary equivalence has not been established.
