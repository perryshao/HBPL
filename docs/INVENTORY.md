# 整理溯源记录

整理日期：2026-09-21

## 来源

| 来源 | 路径 | 整理前体积 |
|---|---|---|
| 本地 | `~/Documents/Projects/Work` | 26 GB |
| 远端 | `smb://perry-System-Product-Name._smb._tcp.local/9592df65-…/work` | 2017–2018 快照 |

合并后 `~/Documents/Projects/HBPL` ≈ 324 MB。

## 关键判断：NTU 代码以远端为准

远端并非单纯的旧备份。`NTU3DActionEvaluatingCode` 在远端有 **30 个本地缺失的文件**，
且同名文件普遍更新（本地 2017-09 ↔ 远端 2018-01~03），与 TCSVT 期刊版修回时间吻合。

| 文件 | 本地 | 远端 | 采用 |
|---|---|---|---|
| `costFuncRegMultPartGp_v1.m` | 2017-09-07 | 2018-01-13 | 远端 |
| `run.m` | 2017-11-14 | 2018-03-13 | 远端 |
| `costFuncRegMultPartGp_v1_212.m` | — | 2018-01-21 | 远端（唯一副本） |
| `costFuncRegMultPartGp_v1_422.m` | — | 2018-01-21 | 远端（唯一副本） |
| `trainBinRegression_shuffleBatch.m` | — | 2018-02-03 | 远端（唯一副本） |
| `trainBinRegression_shuffleBatch_norm1.m` | — | 2018-02-12 | 远端（唯一副本） |
| `minimizefullbatch.m` | — | 2017-09-15 | 远端（唯一副本） |
| `testfornoise.m` / `testforocclusion.m` | — | 2017-12 / 2018-01 | 远端（唯一副本） |
| `shownoise.m` / `showocclusion.m` | — | 2018-03-17 | 远端（唯一副本） |
| `read_skeletons_bat.m` | — | 2017-09-10 | 远端（唯一副本） |
| `draw_cm.m` | **2018-03-08** | 2017-11-02 | **本地**（唯一例外） |

远端 NTU 的 111 个 `.m` 已逐一 MD5 校验，与新项目内容完全一致。

`extra/` 下本地与远端同名但内容不同的文件，远端版本另存为 `*__remote.m` 保留，未做取舍。

## ToZP 分歧（勿合并）

RRV 描述子实现 `ToZP/` 在各数据集目录下存在两个分支：

| 分支 | 数据集 |
|---|---|
| `a2621c00…` | NTU RGB+D、MSR-Action3D |
| `6269285 5…` | UT-Kinect、UCF-Kinect、MSR-DailyActivity |
| （第三版，9 文件） | IP / interactplay |

逐文件比对后，两个主分支间**只有 `Func_RRVdescriptor.m` 不同**，其余 7 个文件一致。
差异落在核心描述子上，因此按数据集各保留一份，不做统一。

## 依赖确认

三个核心数据集的主代码经静态扫描，外部依赖仅：

- `vl_fisher` / `vl_gmm` → **vlfeat**
- `svmtrain` / `svmpredict` → **libsvm**
- `LogHog`（21 处，TSSM 基线）→ `mex/LogHog`
- `costFuncRegMex` → `mex/costFuncRegMex`

自定义辅助函数已全部收入（`ToZP/`、`ScSPM/sparse_coding`、`ScSPM/large_scale_svm`、
`bnt`（HMM 基线）、`Kalman`、`l1_ls_matlab`、`PG_Curve-master`、`spectral_saliency_matlab/qtfm`、
`boost_adaboost`、`checkgrad`）。收齐后二次扫描无未解析的自定义函数。

未被核心代码引用、故未收入：`yael_v438`、`pmtk3`（仅取 `checkgrad.m`）、
`exemplarsvm-master`、`computeBoV`、`Aggregating Local Image Descriptors…`、`gnumex2.06`。

## 移动已完成（2026-09-21）

已收入 `HBPL/` 的源文件均已从原目录移走，原目录只剩待分拣的残留。

| 来源 | 移走 | 去向 |
|---|---|---|
| 本地 `Work/` | 39,583 个（0.26 GB） | `~/.Trash/HBPL_moved_*/local/` |
| 远端 `work/` | 631 个（3.2 MB） | `~/Documents/Projects/_moved_HBPL_remote/` |

两个暂存目录中的文件**全部经 MD5 逐字节校验，在 `HBPL/` 内均有一致副本**，
确认无误后可直接删除。

移动清单与残留清单：

| 文件 | 内容 |
|---|---|
| `docs/move_manifest_local.txt` | 39,583 个本地源文件，已全部移走 |
| `docs/move_manifest_remote.txt` | 631 个远端源文件，已全部移走 |
| `docs/residue_local.txt` | 25,085 个**未移动**的本地文件，即待分拣的残留 |

### 清单生成规则

**仅当源文件与 `HBPL/` 中某文件同名且 MD5 逐字节一致时才列入移动清单。**
因此内容有差异的旧版本（如本地 2017-09 的 `costFuncRegMultPartGp_v1.m`，
已被远端 2018-01 版取代）一律不在清单内，留在原地供后续分拣。

额外收紧的两条例外：

- `pmtk3/` 只移走 `checkgrad.m`。其余 44 个命中项是 pmtk3 与 bnt 的内部重复文件，
  不在未收走的工具箱上打洞。
- `MSRAction3DSkeletonReal*-backup/` 整体排除。否则 548 个文件会被抽走 544 个，只剩残骸。

受保护路径（`Determine_segment_Linux/`、`Determine_segment_Mac/`、`Validation 3 Clean/`、
`~/Documents/Publications/`）在清单生成阶段即被过滤，全程未被触碰。

### 遗留的空目录

被整体收走的工具箱在 `Work/` 只剩空壳（`Kalman`、`vlfeat-0.9.20`、`libsvm-3.17`、
`ScSPM`、`PG_Curve-master`、`bnt`），另有约 298 个空目录（本地）和 25 个（远端）。
剪除操作受会话权限限制未执行，可在后续分拣残留时一并处理。

## 原计划清除的内容（当前未执行，仅供参考）

| 类别 | 体积 | 说明 |
|---|---|---|
| 特征/模型缓存 `.mat` | ~24 GB | `RRV_DB`、`RRV_SAMPLES`、`SC_DB`、`SC_SAMPLES`、`traindata`、`testdata`、`PairDistFeats_*`、`TSSM*`、`ENSEMBLE*`、`initialTheta`、`N.mat` / `Nsamples.mat`、`NTU3D_skeletons/train_data_cv.mat`(1.0G) 等 |
| 批次结果目录 | — | `3jointsnoise_results/`、`noise_results/`、`occlu_results/`、`Results/` |
| 冗余图件 | ~40 MB | 与 `.fig` 同名的 `.tif` 导出件 |
| VS 构建垃圾 | ~200 MB | `.ipch`、`.sdf`、`.suo`、`.VC.db`、`.pdb`、`Debug/`、`Log_Hog.zip` |
| MSRC-12 原始数据 | 1.09 GB | 属 RRV 前作，公开可重新下载 |

均可由 `README.md` 的流水线重新生成，或从公开渠道重新获取。

## 保留但非本论文主线

`extra/` 下为同期其它数据集实验（RRV 前作 [22] 及 IP/interactplay），仅保留代码与
`ip_dataset/IPdataset/` 原始数据，中间结果已清除：

- `msrc12_gesture/` — MSRC-12，12 类
- `ucf_kinect/` — UCF-Kinect，4 折交叉验证
- `msr_daily_act/` — MSR-DailyActivity3D
- `ip_dataset/` — IP / interactplay，16 类 / 4 关节（含 `Determine_segment` 项目的部分工具）

## 未触碰

以下属另一项目（轨迹分割与匹配），保留在 `~/Documents/Projects/Work/` 原地未动：

- `Determine_segment_Linux/`
- `Determine_segment_Mac/`
- `Validation 3 Clean/` — OptiTrack / trakSTAR 验证数据与积分不变量匹配代码
