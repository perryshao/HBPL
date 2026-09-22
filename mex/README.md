# MEX components

Two optional C++ accelerators. **Neither is required**: the MATLAB pipeline in
`src/` is self-contained and reproduces the published numbers without them.

| Component | What it does | Called by |
|---|---|---|
| `costFuncRegMex` | Objective and gradient of the hierarchical mixed norm, Eq. (13) | an alternative to `hbplCost.m`, selected by name in `trainBinRegression*.m` |
| `optiCostFuncRegMex` | Same objective, further hand-optimised | as above |
| `LogHog` | Log-polar HOG descriptor | the TSSM depth baselines |

## Prebuilt binaries

Only the Windows builds survive from the original work. They were compiled
against MATLAB R2014-era headers with Visual Studio 2012 (`v110`).

| Platform | File | Status |
|---|---|---|
| Windows x64 | `costFuncRegMex/bin/win64/costFuncRegMex.mexw64` | shipped |
| Windows x64 | `costFuncRegMex/bin/win64/optiCostFuncRegMex.mexw64` | shipped |
| Windows x64 | `LogHog/bin/win64/LogHog.mexw64` | shipped |
| Linux x64 | `*.mexa64` | **not available** -- build from source |
| macOS Intel | `*.mexmaci64` | **not available** -- build from source |
| macOS Apple silicon | `*.mexmaca64` | **not available** -- build from source |

The Linux and macOS binaries were never produced, or did not survive; the
source is here, so they can be built in one command.

MEX binaries are ABI-tied to the MATLAB release that compiled them. A
`.mexw64` from 2014 may refuse to load under a much newer MATLAB, in which
case rebuild rather than file a bug.

## Building

From MATLAB, in this directory:

```matlab
mex costFuncRegMex/src/costFuncRegMex.cpp     -outdir costFuncRegMex/bin
mex costFuncRegMex/src/optiCostFuncRegMex.cpp -outdir costFuncRegMex/bin
```

`LogHog` additionally needs OpenCV, which it reaches through the bundled
`mexopencv` headers (`MxArray.hpp`, `mexopencv.hpp`):

```matlab
mex LogHog/src/LogHog.cpp LogHog/src/MxArray.cpp -ILogHog/src ...
    -I/usr/local/include/opencv4 -L/usr/local/lib ...
    -lopencv_core -lopencv_imgproc -outdir LogHog/bin
```

Adjust the OpenCV include and library paths for your installation. On Windows
the Visual Studio projects (`*.vcxproj`, `*.sln`) are also included; they
expect `MATLABROOT` to resolve and were last opened with VS2012.

Put the resulting binary somewhere on the MATLAB path -- the dataset folders
under `src/` are the usual place, and already hold the Windows copies.

## Verifying a build

The MEX objective must agree with the MATLAB one. After building, compare them
on random input:

```matlab
hbplSetup('msr_action3d')
D = 102; C = 4; N = 7; partGroup = [5 10 19];
X = randn(D, N);  Y = full(sparse(1:N, randi(C, 1, N), 1, N, C));
w = randn(D*C, 1);  lambda = [0.001 0.2 0.05];
[f1, g1] = costFuncRegMultPartGp_v2(w, X, Y, lambda, C, sum(partGroup), zeros(D*C,1));
[f2, g2] = costFuncRegMex(          w, X, Y, lambda, C, sum(partGroup), zeros(D*C,1));
fprintf('objective %.3e   gradient %.3e\n', abs(f1-f2), max(abs(g1-g2)));
```

Both differences should be at round-off level. Note that `costFuncRegMex`
predates the `_v2` variant, so check which mixed norm it implements before
reading a mismatch as a bug -- see `docs/CODE_REVIEW.md` on the `_v1` / `_v2`
distinction.

## Third-party code

`LogHog/src/MxArray.{hpp,cpp}` and `mexopencv.hpp` come from
[mexopencv](https://github.com/kyamagu/mexopencv) by Kota Yamaguchi,
BSD licensed. They are vendored unmodified.
