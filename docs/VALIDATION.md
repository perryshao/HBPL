# Cross-language validation — 2026-09-24

The maintained HBPL paths passed the checks below without a MATLAB or Octave
runtime. This follows the Cross-View-Learning review strategy: static checks,
source-derived execution with explicit dependency bridges, independent numerical
references, and bounded pipeline smoke runs. It does not establish MATLAB runtime
compatibility or reproduce the paper's experiments.

Machine-readable measurements and source SHA-256 hashes are recorded in
[VALIDATION_RESULTS.json](VALIDATION_RESULTS.json). The comparison baseline is
commit `a8ba15c9cdbf28821d080a8507e6728179074d50`.

## What was executed

A restricted evaluator reads the actual MATLAB AST produced by MISS_HIT 0.9.44
and evaluates supported arithmetic and control flow with NumPy. It implements
one-based indexing and column-major reshape; unsupported syntax or functions
raise errors. Small evaluator checks cover indexing, `end`, deletion and reshape.
This evaluator is a validation adapter, not an independent MATLAB implementation.

| Check | Result |
|---|---|
| All 463 tracked MATLAB files | Style checks pass; lint has no parse errors and 21 previously documented filename/declaration findings. |
| `hbplCost`: four variants, two body-part layouts, scalar/vector priors and group weights | 32 comparisons against an independently vectorized reference pass; maximum objective error below 1e-12 and gradient error below 3e-14. Zero weights remain finite. |
| Dataset objective wrappers | All 12 wrappers pass the optional-prior checks. |
| Historical objective behavior | Explicit full-vector-prior outputs match the baseline source exactly for all four variants. |
| Finite differences | The unsquared variant agrees within numerical tolerance away from zero. All three squared variants reproduce the historical factor-of-two discrepancy described below. |
| Actual RRV and quaternion source, all three datasets | Match an independent SciPy rotation reference within 2e-16; stationary descriptors are finite. MATLAB rotation toolbox calls use explicit Python bridges. |
| Actual temporal pooling and action encoder | 14 boundary cases pass, including empty/short clips, body-part concatenation and optional projection. |
| Actual NTU disk prediction control flow | N = 0, 1, 255, 256, 257, 511, 512, 513 at batch size 256 passes through a SciPy MAT-file bridge. |
| Actual NTU training control flow | N = 1, 255, 256, 257, 512, 513 over 40 epochs visits each sample once per epoch with aligned targets. Seeded NumPy chunk permutations and a recording optimizer stub are used; this check does not train a model. |

The Python Fisher bridge was additionally compared with **compiled VLFeat 0.9.20
C code**, across 24 combinations of dimensions, mixture counts and clip lengths,
including empty input and negligible mixture priors. Maximum absolute error was
1.71e-15. The local arm64 scalar build disables SIMD and replaces x86 CPU-feature
detection with zero flags via a forced-include header. The Fisher/GMM source
files are unmodified. This is not a build or execution of MATLAB MEX binaries.

## Pipeline smoke runs

Each smoke run covers input trajectories, person-centric normalization, RRV,
diagonal GMM fitting, temporal Fisher encoding, hierarchical objective training,
and class prediction. Body-part definitions come from the corresponding `run.m`.
RRV, pooling, encoding and objective functions execute through the source-AST
adapter. Raw-data loading and frame normalization are Python transcriptions.

GMM fitting uses scikit-learn, and optimization uses SciPy L-BFGS-B in place of
VLFeat GMM fitting and MATLAB `minimize.m`. Settings are deliberately small:
three classes, two GMM components, pyramid `[1, 2]`, and at most 35 optimizer
iterations. These substitutions and reduced settings prevent numerical or
accuracy-equivalence claims for the published full pipeline.

| Data | Train / test clips | Feature matrix | Objective before → after | Train / test accuracy |
|---|---|---|---|---|
| Real MSR Action3D subset, first 16 frames | 12 / 6 | 2856 × 18 | 12 → 0.051932 | 100% / 50% |
| Real UT-Kinect subset, first 16 frames | 6 / 3 | 2856 × 9 | 6 → 0.025404 | 100% / 100% |
| Synthetic NTU-style 50-joint trajectories, 10 frames | 6 / 3 | 5712 × 9 | 6 → 0.040669 | 100% / 100% |

MSR uses the existing `db`/`samples` folders for classes 1–3. UT uses walk,
sitDown and standUp from s01/s02 for training and s03 for testing. NTU uses
generated trajectories because the full NTU data are unavailable locally.
These tiny splits and percentages are smoke measurements, not benchmark results.
MSR and UT stopped at the iteration cap; only the synthetic NTU run reported
optimizer convergence. Smoke acceptance checks finite outputs, loss reduction
and training fit, not held-out accuracy or convergence.

The UT entry point also contained an obsolete copy step targeting the external
`../UTKinectEvaluatingCode/` directory. It was removed: prepared joint tables
continue to be loaded from the current dataset folder as documented. The AST
checks cover the resulting file; the complete MATLAB entry point was not run.

## Known limits and retained behavior

- `l4_1_sq`, `l2_1_sq` and `l4_2_sq` retain the historical hierarchical gradient
  missing a factor of two relative to the stated objective. Finite differences
  confirm this discrepancy. It is not corrected by these smoke runs, including
  UT's successful loss reduction. A mathematical change requires a separate
  experiment and rerun of results.
- No full MATLAB/Octave run, MATLAB toolbox integration, MEX ABI validation,
  full-dataset training, original optimizer equivalence, or paper-accuracy
  reproduction was performed. The archived `extra/` experiments received static
  checks, not comprehensive runtime validation.
- Prepared MAT-table construction, the complete GMM sampling loop, PCA
  whitening consistency, degenerate skeletons and path switching retain the
  limitations listed in [POLISH_REVIEW.md](POLISH_REVIEW.md).
- Original precompiled MEX files and historical recovered source archives are
  preserved. The native Fisher check does not validate other MEX components.
  `.gitattributes` exempts the recovered `DepthMapBinIO-src` tree and two original
  Visual Studio `ReadMe.txt` files from line-ending conversion and whitespace
  checks, retaining their recovery provenance hashes. Maintained sources use
  the repository formatting rules.

## Local evidence and rerun

Validation scripts, logs, input manifests, build command and the local native
library are kept outside the repository in
`~/Documents/ChatGPT/旧项目整理/HBPL-validation-20260924/`. The repository does not
distribute a `tests/` directory or raw datasets. The JSON report records the
validation-script hashes; a fresh clone alone cannot rerun these local checks.

The local run used Python 3.11 with NumPy, SciPy, scikit-learn and MISS_HIT 0.9.44.
From the parent of that evidence directory:

```sh
OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python HBPL-validation-20260924/validate.py
OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python HBPL-validation-20260924/native_fisher.py
```

The scripts contain the local checkout and MISS_HIT installation paths. Reusing
them elsewhere requires adjusting those paths, supplying the stated datasets,
and rebuilding the native library with a platform-appropriate command.
