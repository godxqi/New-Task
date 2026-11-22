# 产物固定字段（每个阶段都按这个写）

> 目的：让「ID 链可追」有机械抓手，不靠模型自觉。字段不许空着；不适用的写 `N/A` 并给一句理由。

## 通用规则

- 文件名纯 ASCII，尽量用完整英文词（不缩写）。
- 每个产物抬头写：**所属阶段 / 生成日期 / 输入来源**。
- 表格里每个 ID 必须能指回上游（见「ID 体系」）。

## ID 体系

**三条链**：

- **设计链**：`Requirement → Interface → DataModel → DetailedDesign`
- **实施链**：`DetailedDesign → CodeUnit → Review`
- **验证链**：`DetailedDesign → TestPoint → TestCase`

`CodeUnit` 与 `TestPoint` 是 `DetailedDesign` 下的两条并列支线；`TestCase` 在 `TestPoint` 下。`CodeUnit` 的输入不含 `TestCase`。

| 前缀 | 含义 | 产生于 | 指向 |
|---|---|---|---|
| `Requirement-n` | 功能需求条目 | S1 | — |
| `NonFunctionalRequirement-n` | 非功能需求 / 质量属性目标 | S1 定义、S2 细化同一批 | — |
| `Interface-n` | 接口 / 用例边界 | S2 | Requirement |
| `DataModel-n` | 数据模型实体 | S2 | Requirement / Interface |
| `DetailedDesign-n` | 详细设计条目 | S3 | Interface / DataModel / Requirement |
| `TestPoint-n` | 测试点 | S3 | DetailedDesign |
| `TestCase-n` | 测试用例 | S5 | TestPoint（可加 DetailedDesign / Requirement / Interface） |
| `CodeUnit-n` | 编码工作项（S4） | S4 | DetailedDesign / Interface |
| `Review-n` | 审查行，一个 `CodeUnit` 对应一次 `code-review-expert` | S4 | CodeUnit |
| `ArchDecisionRecord-nnnn` | 架构决策记录 | S1 / S2 / S3 | 相关 Interface / DataModel |
| `Risk-n` | 风险 / 未验证项 | 每个阶段（各自编号） | — |

> `NonFunctionalRequirement`：S1 定义 `NonFunctionalRequirement-1..n`；S2 的质量属性表细化同一批 ID，新增属性才续编号。
> `Risk`：每个阶段各自从 `Risk-1` 开始，不做全局连续。

## S1 · requirements.md（功能需求拷问）

| 字段 | 内容 |
|---|---|
| `Requirement-n` | 功能描述（一句话，可验证） |
| 验收点 | 怎么算做完了 |
| 来源 | 哪一轮拷问 / 哪次弹框 |
| 优先级 | 必须有 / 应该有 / 可以有 |

## S1 · nfr.md（非功能需求拷问）

### 边界（第 1 轮）

| 项 | 答案 |
|---|---|
| 系统规模 | 现在多少用户 / 数据？峰值多少？ |
| 约束 | 多少时间？多少预算？有无合规标准？ |

### 质量_1（第 2 轮）

| 字段 | 内容 |
|---|---|
| `NonFunctionalRequirement-n` | 问题（读写比 / 一致性） |
| 目标 / 答案 | 具体值或取向 |
| 为什么重要 | 一句话 |

### 质量_2（第 3 轮）

| 字段 | 内容 |
|---|---|
| `NonFunctionalRequirement-n` | 问题（增长预期 / 失败代价） |
| 目标 / 答案 | 具体值或取向 |
| 为什么重要 | 一句话 |

### 搭法（第 4 轮）

| 方案 | 做法 | 得到 | 放弃 | 倾向 |
|---|---|---|---|---|
| A | … | … | … | … |

> 第 4 轮的取舍，S2-7 正式写成 ArchDecisionRecord。

## S1 · estimation.md（规模估算，第 1 轮问完规模后做）

| 字段 | 内容 |
|---|---|
| 写 QPS | 数值 + 推导 |
| 读 QPS | 数值 + 推导 |
| 峰值系数 | 2~5 倍，取几 |
| 存储 / 年 | 数值 + 推导 |
| 读写比 | 读 : 写 |
| 结论 | 重心在读还是写 |

## S1 · GLOSSARY.md

| 字段 | 内容 |
|---|---|
| 术语 | canonical 词 |
| 定义 | 1~2 句，说明它是什么 |
| `_Avoid_` | 不要用的同义词 |

## S1 / S2 / S3 · ArchDecisionRecord（六块）

```md
# ArchDecisionRecord-nnnn <标题>

- 状态：proposed | accepted | deprecated | superseded by ArchDecisionRecord-nnnn
- 日期：
- 关联：Requirement-n / Interface-n / DataModel-n

## 背景
<问题、约束、当时的力量>

## 决策
<我们选了什么>

## 考虑过的其它选项
- 选项 A：…… → 否决理由：……
- 选项 B：…… → 采纳 / 否决理由：……

## 取舍与后果
+ <得到什么>
- <放弃什么>
- <留下什么技术债 / 触发条件>
```

## S2 · quality-attributes.md

| 字段 | 内容 |
|---|---|
| `NonFunctionalRequirement-n` | 沿用 S1 的编号；属性名（性能 / 可用性 / …） |
| 可度量目标 | 带数字（P99 < 200ms / 99.9% / …） |
| 为什么重要 | 一句话 |
| 和谁冲突 | 例如"性能 ↑ 成本 ↓" |
| 优先级 | 必须 / 重要 / 可接受 |

## S2 · interfaces.md

| 字段 | 内容 |
|---|---|
| `Interface-n` | 动作名（黑盒视角） |
| 输入 | 关键入参 |
| 输出 | 关键出参 |
| 主航道 | 是 / 否 |
| 服务哪些 `Requirement` | Requirement-n（纯非接口需求可写 `N/A` + 理由） |
| 频率 | 高 / 中 / 低（与估算对齐） |

## S2 · data-model.md

| 字段 | 内容 |
|---|---|
| `DataModel-n` | 实体名 |
| 关系 | 与其它实体的一对一 / 一对多 / 多对多 |
| 访问形态 | 按 ID 取 / 范围查 / 关系查 / 追加写 |
| 存储类型 | 关系型 / KV / 文档 / 列存 / 对象存储 / 搜索 / 时序 |
| 为什么 | 访问形态如何决定存储 |
| 关联 `Requirement` / `Interface` | ID |

## S2 · architecture.md

```md
# 架构全景

## Context 图（ASCII）
<系统一个框 + 用户 + 外部系统>

## Container 图（ASCII）
<可独立部署的大块 + 通信 + 存储>

## 组件职责
- <组件>：<做什么>。为什么需要：<理由>。关联 Interface/DM：<ID>

## 关键数据流（2~3 个）
### 场景一：<名称>
1. … 2. …

## 接缝清单
- <最可能被换的块> → 接口：<接口名>
```

## S2 · bottlenecks.md

| 字段 | 内容 |
|---|---|
| 顺序 | 1 / 2 / 3 |
| 瓶颈 | 哪个部件 / 指标 |
| 现象 | 涨 100 倍时哪个数字爆 |
| 破解 | 缓存 / 副本 / 分片 / 异步 / CDN / 读写分离 |
| 触发条件 | 当 <指标> 到 <阈值> 时做 |
| 关联 `ArchDecisionRecord` | ArchDecisionRecord-nnnn（若已决策） |

## S3 · detailed-design.md（`DetailedDesign` 条目）

| 字段 | 内容 |
|---|---|
| `DetailedDesign-n` | 条目名 |
| 所属 Container | Container 名 |
| 模块 | 模块名 |
| 接口签名 / 契约 | 入参 / 出参 / 错误码 / schema |
| 数据结构 | 表 / 字段 / 索引 / 约束 / 校验 |
| 算法 / 状态机 | 关键步骤或状态迁移 |
| 错误处理 | 空 / 重复 / 超时 / 部分失败 / 乱序 |
| 关联 | `Interface-n` / `DataModel-n` / `Requirement-n` |
| 测试点 | 指向 `test-points.md`，**不写 `TestCase`** |

## S3 · work-items.md（工作项建议）

> 放 `.planning/plan2_DetailedDesign/output/work-items.md`，**不写进计划、不写审查行**。

| 字段 | 内容 |
|---|---|
| 建议 `CodeUnit` | 建议编号（S4 定稿时可改） |
| 描述 | 一句话 |
| 触及文件 | 文件 / 目录 |
| 输入 ID | `DetailedDesign-n`（可加 `Interface-n`）；**不含 `TestCase`** |
| 依赖 | 其它 `CodeUnit` |
| 风险 | 需要谁拍板 |

## S3 · test-points.md（测试点）

> 从 `DetailedDesign` 的验收点推导；S5 据此写成正式 `TestCase`。与 `CodeUnit` 解耦。

| 字段 | 内容 |
|---|---|
| `TestPoint-n` | Test Point 编号 |
| 测试点 | 一句话 |
| 来自 `DetailedDesign` | `DetailedDesign-n` |
| 边界 | 空 / 重复 / 超时 / 部分失败 / 乱序 |
| 期望 | 可断言的结果 |

## S4 · 计划里的工作项与审查行

工作项：

| 字段 | 内容 |
|---|---|
| `CodeUnit-n` | 工作项名 |
| 触及文件 | 文件 / 目录 |
| 输入 ID | `DetailedDesign-n`（可加 `Interface-n`） |
| 验收 | 怎么算完成 |
| 审查行 | `Review-n` |

审查行：

```md
- [ ] Review-n ↳ CodeUnit-n <工作项名> 审查：Skill(code-review-expert) → Fix all → 结论回写 findings.md
```

顺序：实施 → 审查（工作树）→ 修复 → 提交。

## S5 · test-cases.md（测试用例）

| 字段 | 内容 |
|---|---|
| `TestCase-n` | 用例名 |
| 验证 | `TestPoint-n`（来自 `DetailedDesign-n`；可加 `Requirement-n` / `Interface-n`） |
| 前置 | 初始状态 |
| 步骤 | 1. … 2. … |
| 期望 | 可断言的结果 |
| 边界 | 空 / 重复 / 超时 / 部分失败 / 乱序 |

## S5 · test-results.md（测试结果）

| 字段 | 内容 |
|---|---|
| `TestCase-n` | 用例名 |
| 状态 | pass / fail / not-run |
| 证据 | 日志 / 命令 / 输出摘要 |

## S5 · coverage-gaps.md（覆盖缺口）

| 字段 | 内容 |
|---|---|
| `TestPoint-n` | 缺口挂在哪个测试点（**必填**） |
| 缺口 | 哪个 `Requirement` / `DetailedDesign` / 边界没测 |
| 原因 | 为什么没测 |
| 出口 | 补测 / 进风险表（`Risk-n`） |

## S6 · reconciliation.md（对账报告）

分别对三条链：

| 链 | 检查 |
|---|---|
| 设计链 | 每个 `Requirement` 有 `Interface` / `DetailedDesign`；每个 `Interface` / `DataModel` 有 `DetailedDesign` |
| 实施链 | 每个 `DetailedDesign` 有 `CodeUnit`；每个 `CodeUnit` 有 `Review` |
| 验证链 | 每个 `DetailedDesign` 有 `TestPoint`；每个 `TestPoint` 有 `TestCase`（或缺口有出口）；每个 `TestCase` 能指回 `TestPoint` |

| 字段 | 内容 |
|---|---|
| 断点 | 哪个 ID 没下游（纯非接口需求写 `N/A` + 理由） |
| 无主产物 | 哪个产物没上游 |
| ArchDecisionRecord 索引 | 每个 ArchDecisionRecord 文件都有索引行 |
| 结论 | 通过 / 打回（回哪一阶段） |

## S7 · deliverables.md（交付清单）

| 项 | 内容 |
|---|---|
| 代码 | 代码根、分支 / 提交、如何运行 |
| 测试 | 测试命令、结果 |
| 设计文档 | `Requirement` / `Interface` / `DataModel` / `DetailedDesign` / `ArchDecisionRecord` 路径 |
| 已知限制 | 未做的功能、已接收的风险 |

## 风险表（每个阶段的 `task_plan.md`）

| 字段 | 内容 |
|---|---|
| `Risk-n` | 风险 / 未验证项（日常语言） |
| 为什么未验证 | 出处 + 根据 |
| 一旦错了的代价 | 赌注 |
| 出口 | 接收 / 解决 / 重新确认（用户给） |
| 落痕 | findings.md 位置 / 新工作项 ID |
