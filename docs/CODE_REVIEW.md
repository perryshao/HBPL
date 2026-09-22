# Code review

Reviewed 2026-09-21, covering the three dataset pipelines under `src/`
(339 `.m` files, ~25,800 lines before the clean-up).

## Verdict

**The algorithm is implemented correctly.** The hierarchical mixed norm
ℓ<sub>4,1,2</sub> of Eq. (13) and its analytic gradient were checked term by
term:

- ℓ<sub>4</sub> norm inside each body-part: `(Σ_d w_d^4)^(1/4)` ✓
- ℓ<sub>1</sub> across parts, ℓ<sub>2</sub> across layers:
  `(Σ_l (Σ_k ||w^{l,k}||_4)^2)^(1/2)` ✓
- gradient `A_l/√(Σ A²) · w³/(Σw⁴)^(3/4)` ✓, confirmed against finite
  differences

Everything that needed fixing was engineering, not mathematics.

## Defects fixed

### 1. `ddf = ddgradient;` — undefined variable (25 files)

Every cost function declared three outputs `[f, df, ddf]`, but the Hessian was
never implemented and `ddgradient` does not exist anywhere. Any caller asking
for three outputs hit `Undefined function or variable 'ddgradient'`.

**Fixed.** The unified `hbplCost` declares `[f, df]` only. A three-output call
now gets MATLAB's ordinary "Too many output arguments" instead of something
that reads like an internal bug.

### 2. Hard-coded absolute paths (11 files)

`data_folder = '/home/data/nturgbd_skeletons/ntu_train_test/'` ran through the
NTU pipeline, so a fresh clone could not work.

**Fixed.** `src/common/hbplDataDir.m` resolves locations in the order
`HBPL_BATCH_DIR` / `HBPL_RAW_DIR` environment variables → `cache/batches` and
`data/` inside the repository. Runs with no configuration.

### 3. `predictBinRegression` crashed on a test set smaller than one batch

With `batchTimes = floor(N/batchsize)` equal to zero the loop never ran, yet
the code below it indexed `batchtimes + 1` — a variable that was never
assigned.

**Fixed** with a `batchTimes*batchsize < N` guard on the trailing chunk.
Behaviour for whole batches is unchanged.

### 4. NTU's `GeneFisherCodeJointPyramidForTest` never assigned its second output

The signature declares `sum_FvSPM_time`, but the body had no `tic`/`toc` — the
MSR and UT versions do. It went unnoticed because NTU's two callers happen to
request no outputs.

**Fixed** by adding the timing, matching the other two.

## Duplication removed

| Item | Before | After |
|---|---|---|
| Cost functions | 12 files × ~130 lines = 1,560 lines | `hbplCost.m` (176 lines) + 12 wrappers of 23 lines |
| `GeneFeatsPerBody` train/test halves | written out twice, 255 lines | one local function, 135 lines |
| `GeneFisherCodeJointPyramid` encode loop | written four times (train/test × full/partial chunk) | one `encodeToChunks` |
| Per-action Fisher encoding | scattered over four sites | `src/common/hbplFisherEncodeAction.m` |

Numerical equivalence was verified: the original and refactored versions were
each transcribed faithfully into NumPy and compared over two `partGroup`
settings (`[5 10 19]`, `[10 20 38]`) × four variants. **The objective matched
exactly and gradients agreed to ~1e-17** (round-off), with a finite-difference
check confirming the analytic gradient. A static checker also verified block
structure (`if`/`for`/`function` against `end`, bracket balance) across all 348
`.m` files, with no findings.

That verification ran on a machine without MATLAB, so it establishes that the
refactor did not change the arithmetic — **the full pipeline was never actually
executed**. When you first run it on real data, check the result against the
published 94.87 / 97.0 / 82.00.

## Left alone, on purpose

### ⚠️ UT-Kinect uses a different objective from the other two datasets

| Dataset | Calls | Outer aggregation |
|---|---|---|
| MSR-Action3D | `costFuncRegMultPartGp_v2` | `Σ_c (Σ_l A_l²)^(1/2)` — the ℓ4,1,2 of Eq. (13) |
| NTU RGB+D | `costFuncRegMultPartGp_v2` | same |
| **UT-Kinect** | **`costFuncRegMultPartGp_v1`** | **`Σ_c Σ_l A_l²` — no outer square root** |

Table II of the paper reports 97.0 / 94.87 / 82.00 across the three datasets
under the single heading HBPL-ℓ4,1,2. The UT-Kinect column was in fact produced
by `_v1`. The discrepancy is preserved exactly as it was run, and flagged in
the header of `ut_kinect/trainBinRegression.m`. Switching that call to `_v2`
means you are no longer reproducing the published number.

For the same reason, the two ablation variants `_v1_212` (ℓ2,1) and `_v1_422`
(ℓ4,2) are both built on the **square-root-free** `_v1` form, so they are not a
strictly symmetric control against `_v2`.

### Numerical details (annotated, not changed)

- `epsilon = 10e-8` is **1e-7**, not 1e-8. The spelling invites misreading.
- `epsilon` is added *after* the fractional power (`sum(...).^(3/4) + epsilon`),
  not inside it.
- `groupCof = [1 1 1]` is always all-ones, so the three multiplications are
  no-ops; kept as a tunable knob.

All three are untouched. Changing any of them shifts the reproduced results.

### `modelForTest*` file names encode a layer combination

The robustness experiments load different models per the layer combinations of
Table III. The suffix is a **part count**:

| File | Meaning (NTU 10/20/38; MSR·UT 5/10/19) |
|---|---|
| `modelForTest` | all three layers, HBPL(L1+L2+L3) |
| `modelForTest10` | NTU, layer 1 only |
| `modelForTest5+19` | MSR/UT, layers 1 and 3 |

That convention was nowhere recorded, and
`GeneFisherCodeJointPyramidForTest` had `modelForTest10` hard-coded in its
body. It is now an optional argument, defaulting to the same value, and the
convention is documented.

### `minimize.m`

Carl Edward Rasmussen's 2002 L-BFGS implementation, correctly attributed,
logic untouched. It calls the objective by name through `eval(argstr)`; that is
its design, not a defect. The three dataset folders hold identical copies —
worth consolidating into `third_party/` at some point.

### `RRV_DB1` / `RRV_DB2` removed

`GeneFeatsPerBody` used to accumulate the quaternion and velocity halves of
the descriptor separately. In the NTU and UT pipelines they were computed and
never saved — pure waste, and substantial on a 56k-clip dataset. MSR saved
them, but the only consumer was `recognition_ssm_MSRA_bat.m`, which this
clean-up deleted. Should you want the split back, it is `RRV_DB{i}(:,1:4)` and
`(:,5:7)`.

## Dead code

Roughly 100 files per dataset folder were unreachable from any entry point —
HMM, DTW, AdaBoost, ScSPM and TSSM baselines. Reachability was computed from
the seven real entry points (`run`, `testfornoise`, `testforocclusion`,
`shownoise`, `showocclusion`, `draw_confusions`, `draw_cm`), counting
objectives referenced by name as strings inside `minimize(...)`:

| Folder | Kept | Deleted |
|---|---|---|
| `msr_action3d` | 23 | 88 |
| `ut_kinect` | 23 | 72 |
| `ntu_rgbd` | 23 | 89 |

The kept set is closed under function calls, with no dangling references.
