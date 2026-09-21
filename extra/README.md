# extra/ — 同期其它数据集的实验代码

这里的代码**不属于**本仓库两篇论文（ICRA 2018 / TCSVT 2019）的主线，
是同期在其它数据集上做的实验，大多基于 RRV 描述子这一前作。保留是为了存档完整。

| 目录 | 数据集 | 备注 |
|---|---|---|
| `msrc12_gesture/` | MSRC-12 Kinect Gesture，12 类 | 含遮挡实验 |
| `ucf_kinect/` | UCF-Kinect，4 折交叉验证 | |
| `msr_daily_act/` | MSR-DailyActivity3D | |
| `ip_dataset/` | interactplay，16 类 / 4 关节 | 混有 `Determine_segment` 项目的轨迹分割工具 |

## 状态

**这些代码未经整理，与 `src/` 不同：**

- 仍有硬编码的服务器路径（`/home/data/IPdataset/...`），直接跑会失败
- 仍在用 `eval` 拼接动态变量名
- 未做死代码清理，未加函数文档
- 原始数据集不随仓库分发

`src/` 下的三个主线流水线做过审核与重构，情况见
[../docs/CODE_REVIEW.md](../docs/CODE_REVIEW.md)；本目录不在那次审核范围内。

## `__remote.m` 后缀

同名文件在两台机器上出现过内容分叉，两个版本都保留了下来：
不带后缀的来自本地工作副本，带 `__remote` 的来自另一台机器的较新副本。
哪个是最终使用的版本，未经考证。
