# Python, native sanitizers and Octave — 2026-09-25

The IID validation approach was applied to HBPL: independent NumPy calculations,
actual C++ sources under AddressSanitizer/UndefinedBehaviorSanitizer, and GNU
Octave 10.3.0 execution of the maintained MATLAB pipeline functions. This extends
the earlier [source-AST validation](VALIDATION.md) with original-code execution.
Detailed measurements and source hashes are in
[RUNTIME_VALIDATION_RESULTS.json](RUNTIME_VALIDATION_RESULTS.json).

## Runtime defects found and fixed

1. **Sampling short descriptor clips.** The three `rand_sampling_ts` functions
   repeated a shuffled index list at most once. Requesting ten samples from
   three descriptors raised an out-of-bounds error in Octave. They now repeat
   the shuffled cycle as often as needed and reject empty clips explicitly.
   Seeded checks cover quotas of 1, 3, 5 and 10; the order is unchanged for the
   previously valid one/two-cycle cases.
2. **VLFeat output-buffer contract.** The local VLFeat 0.9.20 `vl_gmm.c` allocates
   `OUT(POSTERIORS)` at output slot five unconditionally, even when callers only
   request three outputs. Initial original-code runs suffered native heap
   corruption and process crashes. The three maintained GMM call sites now
   request all five outputs, discarding the last two. VLFeat source and GMM
   equations are unchanged. The complete three-dataset run then passed in a
   single Octave process, including two NTU codebook/encoding passes.
3. **Legacy C++ objective output overrun.** Both `costFuncRegMex` and
   `optiCostFuncRegMex` wrote `plhs[1]` regardless of the requested output count.
   Exact-sized output buffers reproduced a heap-buffer-overflow under ASan in
   both original sources. A shared validator now enforces eight inputs and two
   outputs, real/full/finite double arrays, positive integral counts, compatible
   dimensions and safe integer sizes before reading or writing buffers.

The precompiled Windows MEX files are unchanged and **do not contain these C++
guards**. Rebuild the sources for the actual MATLAB platform before using the
fixes there. Rebuilt Octave and native test binaries remain outside the project.

## Original-code pipeline coverage

The test prepares per-joint MAT trajectory tables from local raw inputs, then
executes the actual `getLabels`, `GeneFeatsPerBody`, RRV/quaternion functions,
`rand_sampling_ts`, `GeneFisherCodeJointPyramid`, temporal pooling, objective
wrappers, training and prediction functions. Original VLFeat 0.9.20 GMM/Fisher
MEX gateways are compiled for Octave. Training uses the original `minimize.m`,
including the existing full-batch or 40-epoch NTU training loops.

No Python replacement optimizer or GMM is used in this run. Python supplies
fixtures and numerical references. The full `run.m` experiment scripts and their
default benchmark settings are not executed: the smoke calls use three classes,
two GMM components and pyramid `[1, 2]`. The original GMM sampling quotas remain
10,000 for MSR/UT and 50,000 for NTU.

| Dataset/input | Train / test clips | Train feature shape | Objective before → after | Train / test accuracy |
|---|---|---|---|---|
| Real MSR Action3D subset, up to 24 frames | 6 / 3 | 2856 × 6 | 6 → 0.0328424 | 100% / 66.7% |
| Real UT-Kinect subset, up to 24 frames | 6 / 3 | 2856 × 6 | 6 → 0.0236904 | 100% / 100% |
| Synthetic NTU-style 50-joint trajectories, 24 frames | 6 / 3 | 5712 × 6 | 6 → 0.0791050 | 100% / 100% |

MSR uses two training and one test clip per class from the existing `db` and
`samples` folders for classes 1–3. UT uses walk, sitDown and standUp, with s01/s02
for training and s03 for testing. These tiny splits do not reproduce a benchmark
or establish recognition quality. Acceptance checks finite outputs, dimensions,
loss reduction and valid labels; it does not require held-out accuracy.

Additional executable checks:

- All three datasets' descriptors agree with the prior Python reference within
  4.1e-12 absolute error. That reference's rotation calculations were previously
  checked against SciPy; it is not an independent MATLAB runtime.
- Twelve actual objective/wrapper cases agree with independent NumPy equations:
  maximum objective error 1.37e-12 and gradient error 8.53e-14. Scalar default
  priors also agree with explicit zero vectors.
- NTU encoder MAT files cover both exact and partial chunks (batch sizes 3 and
  4). Eight actual prediction cases cover N = 0, 1, 255, 256, 257, 511, 512, 513.
- Six NTU training cases cover N = 1, 255, 256, 257, 512, 513 with the actual
  optimizer and 40-epoch loop. Simple separable fixtures classify correctly;
  stale training chunk files are removed between cases to expose erroneous
  extra-chunk loads. These are regression fixtures, not learning benchmarks.
- Two native objective executables pass ASan/UBSan on two valid modality
  fixtures each and 16 invalid-call fixtures each. Valid results match the
  original sources bit-for-bit and NumPy to below 9e-16 for the tested gradients.
- Both objective sources are also compiled as real Octave MEX modules. Four
  valid gateway calls match native results; ten invalid calls (output count,
  single/complex/sparse arrays and non-finite values) raise contract errors.
- All 463 MATLAB files pass MISS_HIT 0.9.44 style/parsing checks. The existing
  21 historical naming findings remain documented in the polish review.

## Compatibility adapters and limits

Two missing MATLAB toolbox functions, `vrrotvec` and `vrrotvec2mat`, are supplied
by explicit axis-angle/Rodrigues adapters in the external validation directory.
An Octave-only `save` adapter preserves caller variables and MATLAB's `.mat`
extension convention, replacing `-v7.3` with MAT v7 for these small fixtures.
Consequently this run verifies MAT interchange, not MATLAB v7.3/HDF5 support or
multi-gigabyte serialization.

VLFeat uses the local scalar arm64 C build from the earlier validation. SIMD is
disabled and x86 CPU detection uses a test-only zero-flags adapter. The real
MEX gateways and GMM/Fisher computations are used. The isolated Conda Octave
installation needs the launcher/compiler environment workaround recorded in
IID's validation; the scripts set those variables locally.

The native MEX API shim only supplies storage and error handling for sanitizer
executables. It does not replace OpenCV mathematics. The run uses OpenCV 4.13.0,
Apple Clang, C++17, ASan and UBSan; leak detection is disabled. OpenCV itself is
a prebuilt library and is not sanitizer-instrumented. This does not prove that
every native memory path or MATLAB ABI is safe.

At the time of this run, LogHog could not compile with OpenCV 4.13.0 because
`FilterEngine` and `createLinearFilter` were unavailable. The subsequent
[LogHog port](LOGHOG_PORT.md) resolves this blocker with `filter2D` and records
separate numerical, native sanitizer and actual Octave MEX results. This
report and its JSON retain the original run as a historical snapshot.
Recovered DepthMapBinIO and archived `extra/` experiments are also outside the
runtime coverage. No old binary was executed as a substitute for its source.

The previously documented squared hierarchical-gradient discrepancy is retained.
The legacy C++ modality gradient also repeatedly square-roots its accumulated
factor inside the modality loop; the NumPy regression deliberately reproduces
that historical arithmetic. Matching it is not a claim that it is the exact
derivative. Mathematical changes require separate experiments. PCA/whitening,
degenerate skeletons, raw-data reader completeness, full datasets and published
accuracies remain outside this run.

## Evidence and rerun

Local scripts, before/after failure logs, build logs, native executables, MAT
fixtures and reports are stored at
`~/Documents/ChatGPT/旧项目整理/HBPL-runtime-validation-20260925/`.
No `tests/` directory, benchmark data or generated models are added to Git.
The JSON report records hashes of the project sources and validation scripts.

With the local Python environment containing NumPy/SciPy/MISS_HIT and the
Octave/OpenCV installations used for this run:

```sh
python HBPL-runtime-validation-20260925/build_octave.py
python HBPL-runtime-validation-20260925/make_fixtures.py
python HBPL-runtime-validation-20260925/launch.py all
python HBPL-runtime-validation-20260925/build_cost.py
python HBPL-runtime-validation-20260925/check_native.py
python HBPL-runtime-validation-20260925/build_cost_octave.py
python HBPL-runtime-validation-20260925/launch_boundaries.py
python HBPL-runtime-validation-20260925/compare_octave_native.py
```

`build_cost.py` intentionally reproduces the two old ASan failures using saved
baseline sources; `check_native.py` requires the fixed sources to pass.
The local scripts contain machine paths and reuse the earlier native VLFeat
build. A fresh clone alone cannot reproduce this local run. The report's hashes
identify the exact artifacts used; adapt paths and supply dependencies/data
before rerunning elsewhere.
