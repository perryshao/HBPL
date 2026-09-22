# HBPL — Hierarchical Body-Parts Learning

Skeleton-based human action recognition. A human skeleton is decomposed into
three layers of body-parts at different scales; each part's rotation and
relative velocity are captured by an HRRV descriptor, encoded with Fisher
vectors, and fed to a structured regression whose hierarchical mixed norm
ℓ<sub>4,1,2</sub> performs **sparse body-part selection within a layer** and
**feature coupling across layers** at the same time.

## Paper

**Journal version**
Z. Shao, Y. Li, Y. Guo, X. Zhou, and S. Chen.
"A Hierarchical Model for Human Action Recognition from Body-Parts."
*IEEE Transactions on Circuits and Systems for Video Technology*, 29(10):2986–2998, Oct. 2019.
[doi:10.1109/TCSVT.2018.2871660](https://doi.org/10.1109/TCSVT.2018.2871660)

**Conference version**
Z. Shao, Y. Li, Y. Guo, J. Yang, and Z. Wang.
"A Hierarchical Model for Action Recognition Based on Body Parts."
*IEEE International Conference on Robotics and Automation (ICRA)*, 2018, pp. 1978–1985.

```bibtex
@article{shao2019hierarchical,
  title   = {A Hierarchical Model for Human Action Recognition from Body-Parts},
  author  = {Shao, Zhanpeng and Li, Youfu and Guo, Yao and Zhou, Xiaolong and Chen, Shengyong},
  journal = {IEEE Transactions on Circuits and Systems for Video Technology},
  volume  = {29}, number = {10}, pages = {2986--2998}, year = {2019},
  doi     = {10.1109/TCSVT.2018.2871660}
}
```

## Paper ↔ code

| Paper | Step | Implementation |
|---|---|---|
| §III-A, Fig. 1 / Table I | Three-layer body-part hierarchy | the `bodyJoints` cell array in each `run.m` |
| §III-B, Eq. (1)–(4) | RRV descriptor (quaternion + relative velocity) | `ToZP/Func_RRVdescriptor.m`, `RRV_AngTrj_Original.m`, `Myrotm2quat.m`, `CalSIGN.m` |
| §III-B, Fig. 4 | Virtual rigid body, for parts spanning >2 joints | `ToZP/Func_RRVdescriptor.m` |
| §III-B, Eq. (5) | HRRV: part-wise and layer-wise concatenation | `GeneFeatsPerBody.m` → `RRV_DB.mat`, `RRV_SAMPLES.mat` |
| §III-C, Eq. (6)–(8) | Fisher-vector encoding + temporal pyramid | `GeneFisherCodeJointPyramid.m` (`vl_gmm` / `vl_fisher`, K=32, Z=3) |
| §IV, Eq. (9)–(13) | Hierarchical body-parts learning | `trainBinRegression*.m` + `src/common/hbplCost.m` |
| §IV, Eq. (14) | Prediction | `predictBinRegression.m` |
| Table II | Mixed-norm ablation | `costFuncRegMultPartGp_v2` (ℓ4,1,2), `_v1_212` (ℓ2,1,2), `_v1_422` (ℓ4,2,2) |
| Fig. 6 | Confusion matrices | `draw_cm.m`, `draw_confusions.m` |
| §V | Noise / occlusion robustness | `testfornoise.m`, `testforocclusion.m`, `addNoiseForMBPL.m`, `shownoise.m`, `showocclusion.m` |

## Layout

```
HBPL/
├── hbplSetup.m      path setup
├── src/
│   ├── msr_action3d/   MSR-Action3D   (20 classes, 567 sequences, cross-subject)
│   ├── ut_kinect/      UT-Kinect      (10 classes, 199 sequences, cross-subject)
│   ├── ntu_rgbd/       NTU RGB+D      (60 classes, 56,880 samples, CS + CV)
│   └── common/         hbplCost · hbplDataDir · hbplFisherEncodeAction
├── mex/             optional C++ accelerators, with prebuilt Windows binaries
├── extra/           experiments on other datasets, outside the two papers
└── docs/            code review notes
```

Each dataset folder carries its own `ToZP/`. **The three copies are not
identical**: `Func_RRVdescriptor.m` differs between the NTU/MSR version and
the UT-Kinect version, so they are kept apart on purpose. Do not merge them.

This repository holds code only. Datasets, third-party toolboxes and the paper
PDFs are not redistributed here; see below for where to get them.

## Requirements

MATLAB with the Statistics and Machine Learning Toolbox
(`GeneFisherCodeJointPyramid` calls `pca`). Two third-party toolboxes are not
shipped with this repository — fetch them and build their MEX files per their
own instructions:

| Toolbox | Used for | Expected location |
|---|---|---|
| [VLFeat 0.9.20](https://www.vlfeat.org/) | `vl_gmm` / `vl_fisher`, Fisher-vector encoding | `third_party/vlfeat-0.9.20/` |
| [LIBSVM 3.17](https://www.csie.ntu.edu.tw/~cjlin/libsvm/) | the HRRV-SVM baseline of Table III | `third_party/libsvm-3.17/` |

`hbplSetup` looks in those paths and warns if either is missing. Put them
elsewhere and it is a one-line edit.

The C++ components under `mex/` are optional accelerators; prebuilt Windows
binaries are included and the sources build on Linux and macOS. See
[mex/README.md](mex/README.md).

## Data

All three datasets are distributed by their original authors:

| Dataset | Where |
|---|---|
| MSR-Action3D | [skeleton data from Wang et al.](https://sites.google.com/view/wanqingli/data-sets/msr-action3d) |
| UT-Kinect | [UT Austin CVRC](http://cvrc.ece.utexas.edu/KinectDatasets/HOJ3D.html) |
| NTU RGB+D | [ROSE Lab, NTU](https://rose1.ntu.edu.sg/dataset/actionRecognition/) (request required) |

No paths are hard-coded. Locations resolve in this order, first hit wins:

| Content | Environment variable | Default |
|---|---|---|
| Raw skeletons | `HBPL_RAW_DIR` | `data/` |
| Cached feature chunks | `HBPL_BATCH_DIR` | `cache/batches/` (created on demand) |

## Running

```matlab
setenv('HBPL_RAW_DIR', '/path/to/nturgbd_skeletons/ntu_data_mat');
hbplSetup('ntu_rgbd')       % or 'msr_action3d' / 'ut_kinect'
cd src/ntu_rgbd
run
```

Set up one dataset at a time. The three pipelines deliberately share file
names (`run.m`, `GeneFeatsPerBody.m`, the cost-function wrappers) whose
contents differ per dataset.

### Pipeline

```
getLabels                         -> cross-subject train/test split
GeneFeatsPerBody                  -> HRRV descriptors    (RRV_DB, RRV_SAMPLES)
GeneFisherCodeJointPyramid        -> FV + temporal pyramid (traindata<k>, testdata<k>)
trainBinRegression[_shuffleBatch] -> HBPL weights        (theta, modelForTest)
predictBinRegression              -> labels, confusion matrix, accuracy
```

Hyper-parameters for NTU: `numClusters=32`, `ntotalbh=3`, `batchsize=256`,
`lambda=[0.001, 0.2, 0.0]`. MSR-Action3D and UT-Kinect run full-batch L-BFGS
(`trainBinRegression.m`); NTU RGB+D is too large for that and uses mini-batch
SGD (`trainBinRegression_shuffleBatch.m`).

Expect hours of runtime, dominated by Fisher-vector encoding.

### Reproducing the Table II ablation

Swap the objective name passed to `minimize` in `trainBinRegression*.m`:

| Table II row | Objective |
|---|---|
| HBPL-ℓ4,1,2 | `costFuncRegMultPartGp_v2` |
| HBPL-ℓ2,1,2 | `costFuncRegMultPartGp_v1_212` |
| HBPL-ℓ4,2,2 | `costFuncRegMultPartGp_v1_422` |

All four variants are thin wrappers over `src/common/hbplCost.m`, which is
where the mathematics lives.

> **Note.** The UT-Kinect pipeline calls `costFuncRegMultPartGp_v1`, which
> lacks the outer square root, while the other two datasets call `_v2`, which
> has it. That is the configuration that produced the published numbers and is
> kept as-is. See [docs/CODE_REVIEW.md](docs/CODE_REVIEW.md).

### Robustness experiments (§V)

```matlab
testfornoise        % joint noise
testforocclusion    % joint occlusion
shownoise           % plot the noise curves
showocclusion       % plot the occlusion curves
```

## Published results (TCSVT Tables II / III)

| Method | MSR-Action3D | UT-Kinect | NTU RGB+D |
|---|---|---|---|
| HRRV-SVM | 84.98 | 94.0 | 79.43 |
| HBPL-ℓ2,1,2 | 93.41 | 96.0 | 76.94 |
| HBPL-ℓ4,2,2 | 89.01 | 96.0 | 81.82 |
| **HBPL-ℓ4,1,2 (L1+L2+L3)** | **94.87** | **97.0** | **82.00** |

Intermediate artefacts (`RRV_DB`, `traindata<k>`, `theta`, …) are gitignored
and regenerated by the pipeline.

## Code map

- `src/common/hbplCost.m` — objective and gradient; all four mixed-norm
  variants wrap this single file
- `src/common/hbplDataDir.m` — path resolution
- `src/common/hbplFisherEncodeAction.m` — Fisher encoding of one action
- `src/<dataset>/` — per-dataset pipeline and body-part definitions

[docs/CODE_REVIEW.md](docs/CODE_REVIEW.md) records what this code was audited
for, which defects were fixed, and a few pre-existing behaviours that were
deliberately left alone.
