# HBPL — Hierarchical Body-Parts Learning

基于人体骨架的动作识别。将人体分解为三层不同尺度的 body-parts，用 HRRV 描述子刻画各部件的旋转与相对速度，
经 Fisher Vector 编码后，通过分层混合范数 ℓ4,1,2 正则的结构化回归同时实现 **同层 body-parts 稀疏选择** 与 **跨层特征耦合**。

## 论文

**期刊版**
Z. Shao, Y. Li, Y. Guo, X. Zhou, and S. Chen.
"A Hierarchical Model for Human Action Recognition from Body-Parts."
*IEEE Transactions on Circuits and Systems for Video Technology*, 29(10):2986–2998, Oct. 2019.
[doi:10.1109/TCSVT.2018.2871660](https://doi.org/10.1109/TCSVT.2018.2871660)

**会议版**
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

## 方法 ↔ 代码对照

| 论文位置 | 环节 | 实现 |
|---|---|---|
| §III-A, Fig.1 / Table I | 三层 body-parts 划分 | 各 `run.m` 中的 `bodyJoints` 元胞（L1/L2/L3 逐层细化） |
| §III-B, 式(1)–(4) | RRV 描述子（四元数 + 相对速度） | `ToZP/Func_RRVdescriptor.m`、`RRV_AngTrj_Original.m`、`Myrotm2quat.m`、`CalSIGN.m` |
| §III-B, Fig.4 | 虚拟刚体（>2 关节的部件） | `ToZP/Func_RRVdescriptor.m` |
| §III-B, 式(5) | HRRV：逐部件/逐层拼接 | `GeneFeatsPerBody.m` → `RRV_DB.mat` / `RRV_SAMPLES.mat` |
| §III-C, 式(6)–(8) | FV 编码 + 时序金字塔 | `GeneFisherCodeJointPyramid.m`（`vl_gmm` / `vl_fisher`，K=32，Z=3） |
| §IV, 式(9)–(13) | HBPL 分层混合范数学习 | `trainBinRegression*.m` + `costFuncRegMultPartGp_v1.m` |
| §IV, 式(14) | 预测 | `predictBinRegression.m` |
| Table II | 混合范数消融 | `costFuncRegMultPartGp_v1_212.m` (ℓ2,1,2)、`_v1_422.m` (ℓ4,2,2)、`_v1.m` (ℓ4,1,2) |
| Fig.6 | 混淆矩阵 | `draw_cm.m` / `draw_confusions.m` |
| §V 鲁棒性 | 噪声 / 遮挡实验 | `testfornoise.m`、`testforocclusion.m`、`addNoiseForMBPL.m`、`shownoise.m`、`showocclusion.m` |

## 目录结构

```
HBPL/
├── hbplSetup.m      路径初始化
├── src/
│   ├── msr_action3d/   MSR-Action3D（20类，567序列，cross-subject）
│   ├── ut_kinect/      UT-Kinect（10类，199序列，cross-subject）
│   ├── ntu_rgbd/       NTU RGB+D（60类，56880样本，CS + CV）
│   └── common/         hbplCost · hbplDataDir · hbplFisherEncodeAction
├── mex/
│   ├── costFuncRegMex/ 混合范数代价函数 MEX（C++ 源码 + VS 工程）
│   └── LogHog/         LogHog 描述子 MEX
├── extra/           同期其它数据集的实验代码（非本两篇论文主线）
└── docs/            代码审核记录
```

每个数据集目录自带一份 `ToZP/`——**三份并非完全相同**，`Func_RRVdescriptor.m` 在
NTU/MSR 版与 UT-Kinect/UCF 版之间存在实现差异，故按数据集分别保留，不要合并。

仓库只含代码。第三方工具箱、数据集、论文成果图都不在版本控制内，见下节。

## 依赖

需要 MATLAB（含 Statistics and Machine Learning Toolbox，`GeneFisherCodeJointPyramid`
用到 `pca`）。两个第三方工具箱不随仓库分发，请自行取得并按各自文档编译 MEX：

| 工具箱 | 用途 | 放置位置 |
|---|---|---|
| [VLFeat 0.9.20](https://www.vlfeat.org/) | `vl_gmm` / `vl_fisher`，Fisher 向量编码 | `third_party/vlfeat-0.9.20/` |
| [LIBSVM 3.17](https://www.csie.ntu.edu.tw/~cjlin/libsvm/) | HRRV-SVM 基线（Table III） | `third_party/libsvm-3.17/` |

`hbplSetup` 按上表路径查找；放在别处的话改一下该文件即可。

`mex/` 下的 C++ 源码（`costFuncRegMex`、`LogHog`）附了 Visual Studio 工程，
主流水线不需要它们——纯 MATLAB 实现已足够，MEX 只是加速版本。

## 数据

三个数据集均由原作者分发，不随仓库提供：

| 数据集 | 获取 |
|---|---|
| MSR-Action3D | [Wang et al. 提供的骨架数据](https://sites.google.com/view/wanqingli/data-sets/msr-action3d) |
| UT-Kinect | [UT-Austin](http://cvrc.ece.utexas.edu/KinectDatasets/HOJ3D.html) |
| NTU RGB+D | [ROSE Lab, NTU](https://rose1.ntu.edu.sg/dataset/actionRecognition/)（需申请） |

代码里没有硬编码路径，位置按以下顺序解析，先命中者生效：

| 内容 | 环境变量 | 默认位置 |
|---|---|---|
| 原始骨架 | `HBPL_RAW_DIR` | `data/` |
| 特征分块缓存 | `HBPL_BATCH_DIR` | `cache/batches/`（自动创建） |

## 运行

```matlab
setenv('HBPL_RAW_DIR', '/path/to/nturgbd_skeletons/ntu_data_mat');
hbplSetup('ntu_rgbd')       % 或 'msr_action3d' / 'ut_kinect'
cd src/ntu_rgbd
run
```

一次只加载一个数据集：三个流水线故意保留同名文件（`run.m`、`GeneFeatsPerBody.m`、
代价函数包装），内容按数据集不同。

### 流水线

```
getLabels                        → 划分 train/test
GeneFeatsPerBody                 → HRRV 描述子    （产出 RRV_DB / RRV_SAMPLES）
GeneFisherCodeJointPyramid       → FV + 时序金字塔（产出 traindata<k> / testdata<k>）
trainBinRegression[_shuffleBatch]→ HBPL 学习      （产出 theta、modelForTest）
predictBinRegression             → 预测 + 混淆矩阵
```

超参（NTU）：`numClusters=32`、`ntotalbh=3`、`batchsize=256`、`lambda=[0.001, 0.2, 0.0]`。
MSR-Action3D / UT-Kinect 用全量 L-BFGS（`trainBinRegression.m`），NTU 数据量大，改用
mini-batch SGD（`trainBinRegression_shuffleBatch.m`）。

运行时间以小时计，瓶颈在 Fisher 向量编码。

### 复现 Table II 的消融

把 `trainBinRegression*.m` 里传给 `minimize` 的目标函数名换掉即可：

| Table II 行 | 目标函数 |
|---|---|
| HBPL-ℓ4,1,2 | `costFuncRegMultPartGp_v2` |
| HBPL-ℓ2,1,2 | `costFuncRegMultPartGp_v1_212` |
| HBPL-ℓ4,2,2 | `costFuncRegMultPartGp_v1_422` |

四个变体都是 `src/common/hbplCost.m` 的薄包装，数学写在那一个文件里。

> **注意**：UT-Kinect 的流水线调用的是 `costFuncRegMultPartGp_v1`（缺外层开方），
> 与另外两个数据集用的 `_v2` 不同。这是已发表结果的实际配置，原样保留。
> 详见 [docs/CODE_REVIEW.md](docs/CODE_REVIEW.md)。

### 鲁棒性实验（论文 §V）

```matlab
testfornoise        % 关节噪声
testforocclusion    % 关节遮挡
shownoise           % 绘制噪声曲线
showocclusion       % 绘制遮挡曲线
```

## 已发表结果（TCSVT Table II / III）

| 方法 | MSR-Action3D | UT-Kinect | NTU RGB+D |
|---|---|---|---|
| HRRV-SVM | 84.98 | 94.0 | 79.43 |
| HBPL-ℓ2,1,2 | 93.41 | 96.0 | 76.94 |
| HBPL-ℓ4,2,2 | 89.01 | 96.0 | 81.82 |
| **HBPL-ℓ4,1,2 (L1+L2+L3)** | **94.87** | **97.0** | **82.00** |

中间产物（`RRV_DB`、`traindata<k>`、`theta` 等）均被 `.gitignore` 排除，由流水线重新生成。

## 代码结构

- `src/common/hbplCost.m` —— 目标函数与梯度，全部数学集中于此；四个混合范数变体是它的薄包装
- `src/common/hbplDataDir.m` —— 路径解析
- `src/common/hbplFisherEncodeAction.m` —— 单动作 Fisher 编码
- `src/<dataset>/` —— 数据集特有的流水线与 body-parts 定义

代码审核结论、已修缺陷、以及几处需要留意的既有行为，见
[docs/CODE_REVIEW.md](docs/CODE_REVIEW.md)。
