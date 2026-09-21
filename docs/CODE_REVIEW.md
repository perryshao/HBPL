# 代码审核记录

审核日期：2026-09-21。对象：`src/` 下三个数据集流水线（整理前 339 个 `.m`，约 25,800 行）。

## 结论

**算法实现正确。** 逐项核对了论文 Eq.(13) 的分层混合范数 ℓ4,1,2 及其解析梯度：

- 部件内 ℓ4 范数：`(Σ_d w_d^4)^(1/4)` ✓
- 部件间 ℓ1 聚合、层间 ℓ2 耦合：`(Σ_l (Σ_k ||w^{l,k}||_4)^2)^(1/2)` ✓
- 梯度 `A_l/√(Σ A²) · w³/(Σw⁴)^(3/4)` ✓，并通过有限差分复核

问题都在工程层面，已在本次整理中处理。

## 修复的缺陷

### 1. `ddf = ddgradient;` — 未定义变量（25 个文件）

所有 cost function 都声明 `[f, df, ddf]` 三输出，但 Hessian 从未实现，`ddgradient` 不存在。
任何人以三输出调用都会撞上 `Undefined function or variable 'ddgradient'`。

**处理**：统一的 `hbplCost` 只声明 `[f, df]`。三输出调用现在得到 MATLAB 标准的
"Too many output arguments"，而不是一个看起来像内部 bug 的报错。

### 2. 硬编码绝对路径（11 个文件）

`data_folder = '/home/data/nturgbd_skeletons/ntu_train_test/'` 遍布 NTU 流水线，
clone 下来必然跑不了。

**处理**：新增 `src/common/hbplDataDir.m`，按 `HBPL_BATCH_DIR` / `HBPL_RAW_DIR`
环境变量 → 仓库内 `cache/batches`、`data/` 的顺序解析。零配置可跑。

### 3. `predictBinRegression` 在测试集小于一个 batch 时崩溃

`batchTimes = floor(N/batchsize)` 为 0 时循环不执行，其后却用 `batchtimes+1` 索引，
而 `batchtimes` 从未定义。

**处理**：尾块改为 `if batchTimes*batchsize < N` 守卫。整批情形行为不变。

### 4. NTU 的 `GeneFisherCodeJointPyramidForTest` 第二输出从未赋值

签名声明 `sum_FvSPM_time`，函数体里没有 `tic/toc`（MSR/UT 版本有）。
NTU 的两个调用方恰好不取该输出，所以一直没暴露。

**处理**：补上计时，与 MSR/UT 行为一致。

## 去重

| 项目 | 整理前 | 整理后 |
|---|---|---|
| cost function | 12 个文件 × ~130 行 = 1560 行 | `hbplCost.m` 176 行 + 12 个 23 行包装 |
| `GeneFeatsPerBody` 训练/测试两半 | 各写一遍，255 行 | 一个内部函数，135 行 |
| `GeneFisherCodeJointPyramid` 编码循环 | 写 4 遍（训练/测试 × 整批/余数） | 一个 `encodeToChunks` |
| 单动作 Fisher 编码 | 散在 4 处 | `src/common/hbplFisherEncodeAction.m` |

重构时验证了数学等价性：把原版与重构版各自如实转写成 NumPy，在两组 `partGroup`
（`[5 10 19]` / `[10 20 38]`）× 四个变体上比对，**目标函数完全相同，梯度最大相对偏差
~1e-17**（浮点噪声量级），并用有限差分确认解析梯度正确。另用静态检查器核对了全部 348 个
`.m` 的块结构（`if`/`for`/`function` 与 `end` 配对、括号平衡），0 处问题。

验证在没有安装 MATLAB 的机器上完成，因此只证明重构未改变算术，**未曾真实运行完整流水线**。
首次在真实数据上跑出结果时，请对照论文的 94.87 / 97.0 / 82.00 复核一次。

## 未改动但需要知道的地方

### ⚠️ UT-Kinect 用的目标函数与另外两个数据集不同

| 数据集 | 调用 | 外层聚合 |
|---|---|---|
| MSR-Action3D | `costFuncRegMultPartGp_v2` | `Σ_c (Σ_l A_l²)^(1/2)` — 即 Eq.(13) 的 ℓ4,1,2 |
| NTU RGB+D | `costFuncRegMultPartGp_v2` | 同上 |
| **UT-Kinect** | **`costFuncRegMultPartGp_v1`** | **`Σ_c Σ_l A_l²`（缺外层开方）** |

论文 Table II 把三个数据集的 97.0 / 94.87 / 82.00 都归在 HBPL-ℓ4,1,2 名下。
UT-Kinect 那一栏实际由 `_v1` 产生。**按你的要求原样保留**，并在
`ut_kinect/trainBinRegression.m` 的文档里显式标注。改成 `_v2` 就不再是已发表的数值。

同样地，Table II 的两个消融变体 `_v1_212`（ℓ2,1）和 `_v1_422`（ℓ4,2）也都建立在
**无外层开方**的 `_v1` 形式上，与带开方的 `_v2` 并非严格对称的对照。

### 数值细节（按要求只标注不改）

- `epsilon = 10e-8` 实际是 **1e-7**，不是 1e-8。写法容易误读。
- `epsilon` 加在分数幂**之后**（`sum(...).^(3/4) + epsilon`），而非幂运算内部。
- `groupCof = [1 1 1]` 恒为全一，三处乘法是空操作；作为可调旋钮保留。

三者都保持原样，改动任何一个都会让复现结果偏移。

### `modelForTest*` 文件名编码了层组合

鲁棒性实验按 Table III 的层组合加载不同模型，文件名后缀是**部件数**：

| 文件 | 含义（NTU：10/20/38；MSR·UT：5/10/19） |
|---|---|
| `modelForTest` | 三层全用，HBPL(L1+L2+L3) |
| `modelForTest10` | NTU 仅 L1 |
| `modelForTest5+19` | MSR/UT 的 L1+L3 |

原先这个约定没有任何记录，`GeneFisherCodeJointPyramidForTest` 把
`modelForTest10` 写死在函数体里。现在改成可选参数（默认值不变），并在文档里写明约定。

### `minimize.m`

Carl Edward Rasmussen 2002 年的 L-BFGS 实现，署名完整，逻辑未改。
它用 `eval(argstr)` 按名字调用目标函数——这是其设计使然，不是缺陷。
三个数据集目录各有一份相同副本，推送前可考虑合并进 `third_party/`。

### `RRV_DB1` / `RRV_DB2` 已移除

原先在 `GeneFeatsPerBody` 里累积描述子的四元数半部与速度半部。
NTU/UT 只算不存，纯浪费内存（NTU 5.7 万样本规模下相当可观）；
MSR 会存盘，但唯一消费者是本次删除的 `recognition_ssm_MSRA_bat.m`。
需要时可直接由 `RRV_DB{i}(:,1:4)` 和 `(:,5:7)` 取得。

## 死代码

每个数据集目录约 100 个文件从未被任何入口调用——HMM、DTW、AdaBoost、ScSPM、
TSSM 等历史基线。从 7 个真实入口（`run`、`testfornoise`、`testforocclusion`、
`shownoise`、`showocclusion`、`draw_confusions`、`draw_cm`）做可达性分析，
并把字符串形式的函数引用（`minimize(..., 'costFunc...')`）计入后：

| 目录 | 保留 | 删除 |
|---|---|---|
| `msr_action3d` | 23 | 88 |
| `ut_kinect` | 23 | 72 |
| `ntu_rgbd` | 23 | 89 |

保留集经闭包检查，无悬空引用。清单见 `docs/delete_dead_code.txt`。
