# Repository polish and review — 2026-09-24

Subsequent original-code execution and runtime fixes are documented in
[RUNTIME_VALIDATION.md](RUNTIME_VALIDATION.md). Validation statements below
describe the initial polish pass unless explicitly updated.

## Scope and baseline

The working repository is `HBPL` on branch `main`, based on `a8ba15c`.
The handover contained 447 modified tracked files from the previous Claude
Code session. Those changes were retained and backed up before this pass.
During the initial polish pass, the older `Projects/HBPL` directory and all SMB
source directories were left unchanged. The subsequent project synchronization
and cross-language validation are recorded in [VALIDATION.md](VALIDATION.md).

The review inventory contains 463 tracked MATLAB files and 15 C/C++ source
or header files. It covers the three main pipelines, shared helpers, archived
experiments under `extra/`, and MEX sources. All 31 tracked Windows MEX
binaries are unchanged. The four vendored mexopencv files received no further
edits in this pass. Dataset-specific `ToZP` implementations, `__remote`
alternatives, published experiment settings, licences, and author notices
are retained. No `tests/` directory was added.

## Formatting and comments

- MATLAB indentation uses four spaces, with unindented top-level function
  bodies. Operators, assignments, commas, comments, and continuations use
  consistent spacing. Trailing whitespace, redundant blank lines, and mixed
  line endings were removed.
- Existing statement terminators and console output are preserved. Archived
  experiment menus and commented alternative configurations are retained.
- Eleven project C/C++ files were formatted using the checked-in
  `.clang-format`; includes and executable tokens were preserved.
- `.editorconfig`, `.gitattributes`, and `miss_hit.cfg` record the conventions.
  Public names, long historical signatures, and leading operators in long
  formulas are deliberately permitted.
- Comments and documentation remain English. Corrected descriptor dimensions
  in `hbplFisherEncodeAction`: input rows hold consecutive frame blocks per
  body-part, and columns hold descriptor components.
- Corrected references to the optimizer: `minimize.m` is nonlinear conjugate
  gradient, not L-BFGS. NTU uses shuffled batches with one line search per batch.
- Corrected the data contract and MEX documentation. Raw skeleton paths do
  not replace prepared per-joint MAT files, and the legacy MEX objective is
  not a drop-in implementation of the three-layer `hbplCost` objective.

## Explicit code fixes beyond formatting

| File | Problem | Change |
|---|---|---|
| `src/common/hbplCost.m` | Optional proximal target defaults to scalar zero, which cannot be reshaped into a non-scalar D-by-C matrix. The wrappers also pass scalar zero. | Expand scalar targets to D-by-C; retain reshape for full vectors. Explicit vector inputs keep the same arithmetic. |
| `src/ntu_rgbd/trainBinRegression_shuffleBatch.m` | Training always loaded a final partial chunk, including when N was an exact multiple of batch size and the encoder had not written it. | Load the partial chunk only when samples remain. |
| `extra/ip_dataset/predictBinRegression_2mod.m` | An incomplete `eval` expression prevented parsing; the tail also referenced an undefined loop variable for a small test set. | Complete the expression, use `batchTimes`, and guard the partial chunk. |
| `src/common/checkgrad.m` | Primary function was named `check`, unlike the file and documented API. | Rename the primary declaration to `checkgrad`; preserve its arithmetic and attribution. |
| `src/ut_kinect/run.m` | A legacy copy step targeted `../UTKinectEvaluatingCode/`, outside the current layout. | Remove the obsolete copy; continue reading prepared joint MAT tables from the current dataset folder. Added during cross-language validation. |

The original training equations, learning settings, feature computations, and
randomization were otherwise retained.

## Validation and its limits

- **463 MATLAB files:** parsed successfully and pass the configured MISS_HIT
  0.9.44 style checks. Checks use tracked paths to avoid two ignored,
  machine-generated `pathdef.m` files.
- **Formatting equivalence:** complete MATLAB parse-tree dumps before and
  after formatting match byte-for-byte. This comparison was performed after
  the three explicit runtime/syntax fixes above. The later signature fix is
  recorded separately. AST comparison verifies expression and statement
  structure, not runtime correctness.
- **C/C++ formatting:** lexical token sequences were compared for all eleven
  reformatted project files and match. No MEX compilation was performed.
- **Whitespace and assets:** checked LF endings, spaces instead of tabs,
  trailing whitespace, blank-line runs, final newlines, and `git diff --check`.
  SHA-256 checks confirm all 31 MEX binaries match the handover snapshot.
- **Static lint:** no parse errors. Remaining naming findings are the 19
  archived `__remote.m` function alternatives and two legacy `gene_TSSM.m`
  files whose declarations say `GeneTSSM`. They were not renamed or merged.
- **Independent arithmetic checks:** a Python transcription checked chunk
  ranges for N = 0, 1, 255, 256, 257, 511, 512, and 513 at batch size 256.
  This verifies the boundary rule; it does not execute the training function
  or claim support for training on an empty dataset.
- **Gradient review:** an independent scalar-class finite-difference check
  covered both `[5 10 19]` and `[10 20 38]`, two features per part, and four
  hierarchical variants. It confirms the factor-of-two issue below; after
  accounting for that factor, maximum relative error was below 3e-7 for the
  sampled nonzero weights. This is a transcription check, not a MATLAB test.

No usable MATLAB or Octave executable was available during this review.
Toolbox-dependent execution, MEX ABI compatibility, real-data training,
accuracy reproduction, and exhaustive behavior of historical experiments
in the original MATLAB runtime remain unverified. Subsequent Python smoke runs
on real MSR/UT subsets and synthetic NTU trajectories are documented separately
in [VALIDATION.md](VALIDATION.md). The earlier review's blanket mathematical-correctness
claim has been removed.

## Findings deliberately kept separate from polish

### High: squared variants return a differently scaled hierarchical gradient

In `hbplCost`, `l4_1_sq`, `l2_1_sq`, and `l4_2_sq` omit the factor 2 required
by differentiation of their stated hierarchical penalty. The fit and
proximal terms do include their factor 2. This is therefore not a uniform
rescaling of the whole gradient. UT-Kinect selects a squared variant.
The historical epsilon stabilization also makes the returned gradients
approximations of the unsmoothed objectives near zero.

Changing this can change optimization trajectories and reported results.
The equations are preserved and the discrepancy is now documented in the
function. A mathematical correction should be a separate, numerically
validated change with experiments rerun.

### High: prepared data and external dependencies are still required

`getLabels` and `GeneFeatsPerBody` load per-joint MAT tables from the current
folder. NTU expects `TRAJDB_CV` / `TRAJSAMPLES_CV`; the other pipelines expect
`TRAJDB` / `TRAJSAMPLES`. The table contents determine the split. The retained
entry points do not build those tables from raw skeletons. VLFeat is required
for Fisher encoding; the RRV descriptors also call `vrrotvec` and
`vrrotvec2mat`, which must be available in the MATLAB installation.

### High: legacy MEX uses another penalty; historical binaries are unchecked

The initial C++ objective read eight inputs and wrote two outputs without checking
counts, classes, sparsity, or dimensions. The 2026-09-25 runtime pass reproduced
an output-buffer overrun and added source-level contract guards. Historical
prebuilt binaries are unchanged and remain unchecked; rebuild before using the fix.
Its joint/modality penalty has no three-layer `partGroup` aggregation. The
previous seven-argument equivalence example was removed. The sources also
require OpenCV, and LogHog retains Windows-specific precompiled-header
includes. The runtime follow-up builds the two cost objectives for Octave and
native sanitizers; LogHog still requires an API port.

### Medium: archived experiments retain historical execution assumptions

`extra/` is a collection of experiments, not a validated second pipeline.
It still contains machine-specific paths, `eval`-constructed variables,
workspace-dependent scripts, and references to external helpers/data.
Twenty-one archived cost functions assign an undefined `ddgradient` if a
third output is requested. Other legacy batch functions still unconditionally
load remainder chunks. Several `gene_TSSM` implementations reference feature
tables that are not inputs. These findings are not solved by successful
parsing and should be addressed when each experiment is revived.

### Medium: existing numerical and configuration edge cases

- PCA codebook training whitens projected samples, whereas per-action encoding
  applies the stored projection without the same whitening factors.
- GMM sampling loops can fail to terminate if every sampled descriptor is zero.
- Person-centric frame construction divides by torso and axis norms without
  a degenerate-skeleton guard.
- Calling `hbplSetup` for another dataset adds paths without removing the
  previous dataset; the current folder also has MATLAB path precedence.
- Model filenames in robustness scripts select historical layer combinations;
  they are not automatically generated by one default `run` invocation.

These are recorded for follow-up rather than silently changing historical
experimental behavior during formatting.
