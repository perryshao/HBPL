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
assumes real, full double arrays, positive integral partition counts, and
matching dimensions. It reads all inputs and writes both outputs without
validating the argument counts or array types. Inspect the source and supply
both outputs; invalid calls can crash MATLAB.

This is **not** the seven-argument `costFuncRegMultPartGp_v2` interface. The
C++ regularizer partitions weights by joint and modality and does not use
`partGroup` to couple three body-part layers. Numerical equality with
`hbplCost` is therefore not expected. The earlier seven-argument comparison
example was invalid and has been removed.

## Building from source

All three components depend on OpenCV as well as the MATLAB MEX headers.
The cost-function sources include legacy OpenCV headers and constants;
`LogHog` additionally includes the Windows `stdafx.h`/`targetver.h` chain.
The Visual Studio projects describe the original build environment.

A Linux, macOS, or current-OpenCV port requires adapting those includes,
compiler settings, and API calls. No portable build command has been verified
in this checkout. The previous instructions omitted required OpenCV flags
for the cost functions and Windows-specific dependencies for `LogHog`.

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

Original DepthMapBinIO sources and project files are in `DepthMapBinIO-src/`. See [recovery notes](../docs/MEX_RECOVERY.md). The current binary is unchanged and the recovered source has not been rebuilt.
