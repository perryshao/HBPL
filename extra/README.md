# extra/ — experiments on other datasets

This code is **not** part of the two papers this repository accompanies
(ICRA 2018 / TCSVT 2019). It covers contemporaneous experiments on other
datasets, mostly built on the earlier RRV descriptor. It is kept for the
record.

| Folder | Dataset | Notes |
|---|---|---|
| `msrc12_gesture/` | MSRC-12 Kinect Gesture, 12 classes | includes occlusion experiments |
| `ucf_kinect/` | UCF-Kinect, 4-fold cross-validation | |
| `msr_daily_act/` | MSR-DailyActivity3D | |
| `ip_dataset/` | interactplay, 16 classes / 4 joints | mixed with trajectory-segmentation tools from a separate `Determine_segment` project |

## Status

**Unlike `src/`, this code has not been cleaned up:**

- server paths are still hard-coded (`/home/data/IPdataset/...`), so it will
  not run as-is
- dynamic variable names are still built with `eval`
- dead code was not pruned and no function documentation was added
- the raw datasets are not distributed here

The three main pipelines under `src/` were reviewed and refactored. This folder
was outside the scope of that review.

## The `__remote.m` suffix

Some files diverged between two machines and both versions were kept: the
plain name is the local working copy, the `__remote` one is the newer copy
from the other machine. Which of the two was actually used was not
established.
