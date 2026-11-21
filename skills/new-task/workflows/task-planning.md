# 新任务流程（task-planning）

**状态**：v12 —— 2026-11-21 按用户决定改为**六阶段顺序执行**模型：
`S1 需求分析 → S2 架构设计 → S3 详细设计 → S4 编码 → S5 测试 → S6 审查`。
每个阶段 = 一个独立计划（独立 task-id）+ 一个 `output/` 产物目录；阶段内遇到**真正的取舍强制弹框**问用户；
阶段末做**复盘拷问 + 逐条风险确认**；**不设单独的阶段门**，风险确认就是该阶段的人工点。
**历史**：v11 解释页每个结论各配一张图；v10 名词闸；v9 解释页一条一页；v8 弹框末位「解释」项；
v7 落点改 `.planning/` + 格式硬校验；v6 S3 折入风险确认；v5 `/skill-review` 修补；v4 审查粒度=工作项；
v3 阶段横幅；v2 续期框；v1 经 `/grilling` + `/loop-me` 定稿。
**用途**：用户讨论一个**新需求（绿地新系统）**时，把「需求 → 架构 → 详设 → 编码 → 测试 → 审查」固化成一条顺序执行的流水线，
每一步都有人工介入点（取舍弹框 + 阶段末风险确认），不再一次问完就放行。

**IRON LAW**：步骤可以被讨论、不能默默跳过 —— 任何偏离必须在当次说出来，并在该阶段的计划里留痕。

## Trigger

**事件**：用户敲 `/new-task <话题>`。**不自动触发**。

**范围**：只处理**新需求（绿地新系统）**。新改造 / 棕地改造不走本流程——那类任务有「已有系统」约束，本 spec 不覆盖。

## 外部依赖

**调用一律走 Skill 工具、按 id 写** —— 不要试图"敲斜杠命令"。

| 技能 | 模型侧 id | 前置条件 | 用于 |
|---|---|---|---|
| Caveman | `caveman` | 无 | 全流程开场 |
| Grill with Docs | `grill-with-docs` | 无（内部调用 `grilling` + `domain-modeling`） | S1-1 需求拷问 |
| Grilling | `grilling` | 无 | 各阶段末的复盘拷问；`grill-with-docs` 不可用时单独调 |
| Domain Modeling | `domain-modeling` | 无 | 名词、GLOSSARY、ADR |
| Planning | `planning-with-files-zh` | cwd 下能建 `.planning/` | 每个阶段的计划 |
| Code Review | `code-review-expert` | 有 git diff | S4 每个工作项 |
| Ponytail Review | `ponytail:ponytail-review` | 有 diff | S6 |

> `caveman` **只压对话输出**；计划 / 三件套 / 记忆 / commit 等持久化产物写正常文字。
> **例外：阶段横幅也不压**（导航信息不是叙述）。

## 目录结构

**一个任务一个外层目录**（`<task-id>/`），`.planning/` 与各阶段目录**同层**；`.planning/` **只放计划文件**。

```
<task-id>/
├── .planning/                          # 只放 planning-with-files 的三件套
│   ├── 00_RequirementsConfirm/
│   │   ├── task_plan.md
│   │   ├── progress.md
│   │   └── findings.md
│   ├── 01_ArchitectureDesign/          # 各阶段一个独立计划
│   ├── 02_DetailedDesign/
│   ├── 03_Coding/
│   ├── 04_Test/
│   └── 05_Review/
├── 00_RequirementsConfirm/
│   └── output/                         # S1 产物，交给 S2
├── 01_ArchitectureDesign/
│   └── output/                         # S2 产物，交给 S3
├── 02_DetailedDesign/
│   └── output/
├── 03_Coding/
│   └── output/
├── 04_Test/
│   └── output/
└── 05_Review/
    └── output/
```

规则：

- **cwd 全程保持在 `<task-id>/`**（resolver 与 hook 都取 `$PWD/.planning`）；不要在 Bash 里 `cd` 走。
- 每个阶段开始时：`mkdir -p .planning/<stage-id> && cp -n ~/.claude/skills/planning-with-files-zh/templates/{task_plan,findings,progress}.md .planning/<stage-id>/`
  —— **必须带 `-n`**（重入本阶段时不能冲掉已写的计划）。
- 写活动指针：`sh ~/.claude/skills/planning-with-files-zh/scripts/set-active-plan.sh <stage-id>`
  —— 环境变量不跨 Bash 调用持久，只有 `.active_plan` 指针能跨调用生效。
- 阶段开始时**先读上一阶段的 `output/`**；上一阶段没有输出就说明本阶段缺输入（问用户，不猜）。
- 每个阶段计划内部用 `### 阶段 <子步号>：名称`（如 `### 阶段 S1-1：拷问`）表示**本阶段的子步**，
  每个子步恰好一个 `**状态：** pending|in_progress|complete`；落盘后跑 `check-complete.sh --validate <路径>`，不过就改到过。
- `task_plan.md` 抬头写**任务目录的绝对路径**（"三件套到底落在哪"的唯一事后凭据）。
- `task_plan.md` 只写**自己的规划**；外部资料原文只进 `findings.md`。
- 产物命名**纯 ASCII**（目录 / 文件名英文 + 补零序号；中文只留文案与注释）。

## 阶段横幅

**每一步都必须打**。用户靠它知道"我在哪、还剩几步"。

```
── S<n> <步名>[ · <状态注>] ──────────────────
 S1 需求分析 · S2 架构设计 · S3 详细设计
 S4 编码 · S5 测试 · S6 审查
──────────────────────────────────────────────
```

- `✓` = 该阶段已经跑过、`◀` = 当前阶段、无标记 = 未到。
- `<状态注>` 用于当步子步（`3/8 数据模型`）、复盘段（`复盘拷问`）、风险确认段（`风险确认`），无事省略。
- 打的时机：每个阶段开场；阶段内**每完成一个子步再打一次**（子步位置感）；阶段末两段之间再打一次。
- 弹框 `header` 顺带带阶段（`S2 架构设计`）。
- 步名固定用本节的名字，**不换词、不自造半号**。

## 统一阶段节奏

每个阶段（S1~S6）都套同一个模板：

```
本阶段子步 Sx-1 … Sx-n
  ├─ 遇到真正的取舍 → 强制弹框问用户（见下节）
  ├─ 产物写进 <stage-id>/output/
  ├─ 复盘拷问（AI 挑自己的错）
  └─ 逐条风险确认（用户给出口；0 条就记「本阶段无风险」，直接进下一阶段）
```

- **没有单独的「批准 / 打回」门**。阶段末的人工点就是**逐条风险确认**；出口给完，顺序进下一阶段。
- 复盘拷问固定一轮；它抓的是 AI 自己的错（自相矛盾、过度声称、写错前提），靠自觉必失效。
- 风险确认的条目 = 本阶段 `task_plan.md` 的风险表；每条必须拿到 **接收 / 解决 / 重新确认** 之一。
  选「重新确认」→ 回本阶段相应子步改，改完**重跑本段**，不带着它进下一阶段。
- 复盘拷问 / 风险确认都要打横幅、都要用弹框（形式同各阶段的拷问）。

## 取舍弹框（强制）

**定义**：同时满足以下三条才算「真正的取舍」，必须弹框：

1. 有两个及以上可行选项；
2. 选项之间有真实的代价交换（没有银弹）；
3. 影响结构 / 接口 / 数据 / 质量属性，或难以逆转。

**形式**：`AskUserQuestion` 弹框；推荐项放**首项**并标"(推荐)"；需要背景写进选项 `description`；**不另铺长文**。
每个问题**末位加「解释这个问题与名词」**（见下）。

**AI 不得自行拍架构 / 接口 / 数据取舍**。用户没选，就停在弹框，不许默认。

**记录**：满足 `domain-modeling` 三条（难逆转 / 无背景会困惑 / 真实取舍）→ 写 ADR 到本阶段 `output/adr/`，
并在本阶段 `task_plan.md` 留一行索引 `ADR-NNNN <标题> — <状态>`。

**弹框硬限制**：一次最多 4 问 × 4 选项；超过 4 问分批弹（每批 ≤4）；次要问题写进文本"我按 X 默认，除非你反对"，不占弹框额度。

**名词闸**：题干与选项里**第一次出现的非日常词**（尤其文件里的研究词）必须就地换成日常说法或加括号解释，不许裸搬。

**解释项**（每个问题 / 每条风险末位）：

- **不标"(推荐)"、不算作答**；命中后调 Skill `answer-me-with-html` 渲染**一页**，然后**重弹同一条**。
- 页面内容：问题与冲突点、出现的名词、每个选项选错的后果；**不写流程回顾、不复述推荐**。
- **每个结论各占一个独立面板、各配一张自己的 `flow`**：问题本身一张冲突图；每个选项各一张后果图（推荐项也照画）。
- 同批多条命中 → **逐条各出一页**（逐页连开），不合并成一页多面板。
- **只有用户点选或明确调用 `/answer-me-with-html` 才出页**；AI 不自行渲染。
- 渲染失败 / node 不可用 → 对话里写短解释，不阻塞流程。

**事实自己查**：能从环境查到的事实（项目结构、依赖、现有实现、文件内容），派 sub-agent 查，不占弹框额度、不拿去问用户；只有**决策**进弹框。

## S1 需求分析

**目标**：把模糊需求问清楚，产出需求条目、术语表、计划与风险表。

### S1-1 拷问 —— `grill-with-docs`

- 下限 2 轮，无上限；每轮用弹框收答案（规则见「取舍弹框」）。
- 第 1 轮正常拷问（需求、边界、用户与规模、质量与约束、灵魂六问）。
- 第 2 轮**固定挑战第 1 轮的结论**（找反例、被忽略的选项、过度声称）；翻出新决策就回到正常拷问。
- 下限满后，每轮末弹**续期框**："这一轮拷问完了，要不要再来一轮？"
  - 推荐跟随 frontier：frontier 空 → 首项「不用了，进计划(推荐)」；非空 → 首项「再来一轮(推荐)」并写明还剩几项。
  - **frontier 空了也照弹**；AI 不替用户判断"拷够了"。
- 下限未满时，**不得弹任何"推进 / 要不要继续"的框**。
- **产出**（写进 `00_RequirementsConfirm/output/`）：
  - `requirements.md`：功能需求 `REQ-1..n` + 非功能需求 / 质量属性 + 关键约束；
  - `GLOSSARY.md`：`domain-modeling` 产出的术语表；
  - `adr/`：拷问中凝固的决策（满足三条才写）。

### S1-2 落阶段计划 —— `planning-with-files-zh`

- 三件套落在 `.planning/00_RequirementsConfirm/`（结构见「目录结构」）。
- `task_plan.md` 写：本阶段目标、子步状态、**实施计划（工作包 / 工作项两级）**、决策与 ADR 索引、风险表 `R1..Rn`、审查待办行（每个工作项一条）。
- 审查待办行与风险表的规格见下文两节。
- 格式硬校验：`check-complete.sh --validate` 必须过。

### S1-3 复盘拷问 + 风险确认

- 第一段：`grilling` **固定一轮**，对象 = 本阶段计划与需求条目；专抓自相矛盾、过度声称、写错前提。
- 翻出重大错误 → 回 S1-1 / S1-2 改，改完补一次本段。
- 第二段：**逐条风险确认**（规则见「统一阶段节奏」）；每条拿到出口才进 S2。
- **无单独阶段门**；出口给完直接进 S2。

## S2 架构设计

**依据**：`Refer/01_架构设计/awesome-architecture-main` 的 tutorial 02 / 03 / 06 / 07 / 08 与 `templates/_TEMPLATE.md`。
**分界**：S2 只做 **C4 的 Context + Container 层**；Container 内部留给 S3。
**产物目录**：`01_ArchitectureDesign/output/`。所有图用 **ASCII**（`_TEMPLATE.md` 铁律：任何地方都能看、永不失效）。

### S2-1 估规模（07 ②）

- 信封背面算：写 QPS、读 QPS、峰值系数（平均值的 2~5 倍）、存储 / 年、读写比。
- 锚点：一天 ≈ 10^5 秒；1 千万日活 × 每人每天 10 次 ≈ 1,000 QPS（平均）。
- **产出**：`01-estimation.md`。完成判据：每个数都有出处，读写比明确。

### S2-2 质量属性（02 + 06）

- 把 S1 的灵魂六问答案翻成质量属性表：属性 / **可度量目标** / 为什么重要 / **和谁冲突**。
- 依据 02 的十条属性清单逐项过，确认没漏掉会要命的那条。
- **产出**：`02-quality.md`。完成判据：每个目标有数字（06：「说不出数字的目标都是空话」），标出冲突对。

### S2-3 用例与接口边界（07 ③）

- 把系统当黑盒，列对外动作清单，挑 1~2 条**主航道**（最高频、最能体现系统特点的动作）。
- **产出**：`03-interfaces.md`，每个动作一条 `IF-1..n`。完成判据：主航道标出；服务不了任何用例的模块不设计。

### S2-4 数据模型与存储（07 ④ + 05 章）

- 概念实体 + 关系（不写建表语句）；每类数据选存储类型（关系型 / KV / 文档 / 列存 / 对象存储 / 搜索 / 时序）+ **为什么**（看访问形态）。
- **产出**：`04-data-model.md`，实体 `DM-1..n`。完成判据：每行有存储类型和理由。

### S2-5 架构全景（07 ⑤ + 03 + `_TEMPLATE` 4/5/6）

- **先 Context 再 Container**：Context 把系统当一个框，画用户与外部系统；Container 画出可独立运行的大块、通信方式、存储。
- 每个组件写「做什么 + **为什么需要**」（`_TEMPLATE`：没有「为什么」的部件就是过度设计）。
- 画 2~3 条**关键数据流**（最能体现系统特点的场景）。
- 图规则（03 章）：一张图只用一个抽象层次；箭头标方向和含义；框数 7±2；画出边界（部署 / 信任 / 系统）。
- **产出**：`05-architecture.md`。

### S2-6 灵魂部件与接缝（07 ⑥ + 08）

- 挑 1~2 个**灵魂部件**（被规模压垮的那个），选模式（事件驱动 / CQRS / 队列削峰…），说明为什么。
- 标出「将来最可能换」的**接缝**：用干净接口包住，让演进从重写变成替换。
- **产出**：并入 `05-architecture.md`。完成判据：灵魂部件有模式名和理由；接缝有清单。

### S2-7 瓶颈与扩展（07 ⑦）

- 问：用户涨 100 倍，**第一个撑不住的指标**是什么？第二个？第三个？
- 复用 ② 的数字；按类排查：计算 / 带宽 / 存储容量 / 连接数 / 单点。
- 每个瓶颈写：现象（哪个指标爆）→ 破解（缓存 / 副本 / 分片 / 异步 / CDN / 读写分离）→ **触发条件**（何时做）。
- **不是现在就建 100 倍架构**：现在不建，但知道会死在哪、留好接缝、记下触发条件。
- **产出**：`06-bottlenecks.md`。完成判据：至少第一、第二瓶颈，各带触发条件。

### S2-8 取舍与 ADR（07 ⑧ + 08）

- 每个真正的岔路口写一份 **ADR 六块**：标题 / 状态 / 背景 / 决策 / 考虑过的其它选项 / 取舍与后果。
- 写到 `01_ArchitectureDesign/output/adr/`，索引行写进本阶段 `task_plan.md`。
- 自检（02）：**看不到取舍 = 没想清楚**；每份 ADR 必须能说出"放弃了什么、为什么值得"。
- **产出**：`adr/ADR-NNNN-*.md`。

### S2 收尾

- 复盘拷问（`grilling` 固定一轮，对象 = S2 全部产物）：专抓图与估算不一致、组件没有「为什么」、ADR 缺取舍、过度设计。
- 逐条风险确认（架构风险：假设错了整个设计就崩的那些）。
- ID 链检查：`REQ → IF → DM → ADR` 每一环可追。

## S3 详细设计

**分界**：C4 的 **Component 层**——Container 内部怎么造。跨 Container 的归 S2，Container 内部的归 S3。
**产物目录**：`02_DetailedDesign/output/`。
**产物 ID**：每个详设条目给 `DS-1..n`，挂到 `IF` / `DM` / `REQ`；S5 的 `TC` 再挂到 `DS`。

### S3-1 组件划分

- 对每个 Container，画 Component 图（容器内模块 + 协作）。简单容器不画。
- 每个模块写「做什么 + 为什么」，标出对外的接口。

### S3-2 接口契约

- 把 S2 的 `IF-1..n` 细化成**签名 / 协议 / 错误码 / schema**。
- 跨模块契约在此定稿；S4 不许即兴改，改就回 S3。

### S3-3 数据结构

- 把 `DM-1..n` 细化成表结构 / 字段 / 索引 / 约束 / 校验规则。
- 每张表 / 每个结构写清由哪个模块拥有、谁可以读写。

### S3-4 算法与边界

- 灵魂部件的内部算法、状态机、错误处理、并发与幂等策略。
- 边界情况：空、重复、超时、部分失败、乱序。

### S3-5 工作项细化

- 把 S1-2 的工作项落到**模块 / 文件 / 接口**；每个工作项写明改哪些文件、依赖哪个 `IF` / `DM`、验收点 `TC-1..n`。
- 每个工作项一条审查待办行。

### S3 收尾

- 复盘拷问（`grilling` 固定一轮，对象 = 详设产物）：抓接口与数据不一致、跨模块契约漂移、边界情况漏项。
- 逐条风险确认（细节风险）。
- ID 链检查：每个 `IF` / `DM` 有对应的详设条目，每个工作项挂到条目上。

## S4 编码

- 每个工作项开始前**重读本阶段计划里对应段落**（硬纪律；正确性不押在 hook 上）。
- 编码纪律见「编码纪律（karpathy-guidelines，S4 用）」，**全文照做**。
- 遇到审查待办行即调 **Skill `code-review-expert`**（要有 diff），**P0~P3 全部修复**；结论回写 `findings.md`（拒绝修复必须写明理由）。
- `code-review-expert` 默认 review-first，会弹「Fix all / P0-P1 only / 不改」——**按「Fix all」全修**，不要每审一次停一次。
- **每条审查行都必须真调技能**，不得"沿用上一次已加载的口径"代跑。
- 确无 diff 的工作项（纯读代码）→ 该行写「无 diff，跳过」，不假装审过。
- 最后一个工作项的审查通过后，S4 才算完成。
- **S4 收尾**：复盘拷问（`grilling` 固定一轮，对象 = 本阶段 diff + 审查结论）+ 逐条风险确认（代码级风险）。
- 中途不再停（取舍弹框除外）。

## S5 测试

- 按 `TC-1..n` 写测试；每个 TC 标明它验证的 `REQ` / `IF` / `DS`。
- 跑测试，记录结果；**对着契约验，不是对着实现验**（覆盖率骗不过契约）。
- 覆盖缺口（某个 `REQ` 没有 TC、某个 TC 没验证契约）→ 弹框问用户要不要补。
- **S5 收尾**：复盘拷问（`grilling` 固定一轮，对象 = 测试清单与结果）+ 逐条风险确认（测试风险）。
- 产出：`04_Test/output/`（测试清单 + 结果 + 缺口）。

## S6 审查

- **对账**：`REQ → IF → DM → DS → TC` 每一环都有落点；断开的地方列出来。
- 调一次 `ponytail:ponytail-review`（只吃 diff、只查过度设计）→ 按意见修改（只收缩，不夹带功能变更；拒绝写明理由）。
- 过一遍「完成判据」。
- **S6 收尾**：复盘拷问（`grilling` 固定一轮，对象 = 对账结果 + ponytail 结论）+ 逐条风险确认（最终验收）。

## 审查待办行（S1-2 / S3-5 的产物规格）

**形态**：`- [ ] ↳ <工作项号> <工作项名> 审查：Skill(code-review-expert) → P0~P3 全修 → 结论回写 findings.md`

- **粒度 = 工作项**，一条一行，不许合并、不许按性质归类。
- 每个工作项都配，包括"抓取清单""跑校验脚本"这类；确无 diff 的写「无 diff，跳过」。
- 靠"`task_plan.md` 每轮被重新注入 + 未打勾可见"生效，**非技术强制**。

## 风险与未验证项表（每个阶段的产物规格）

**形态**：本阶段 `task_plan.md` 里一张**编号连续**的清单 `R1..Rn`，每条三列：

| 列 | 写什么 |
|---|---|
| **内容** | 这条未验证项 / 风险是什么。用日常语言；专有名词就地括号解释 |
| **为什么未验证** | 先给出处（哪个文件 / 哪次拷问 / 哪个产物），再写根据 |
| **一旦错了的代价** | 说清赌注，用户才拍得了板 |

- **来源**：① 本阶段拷问残留的未决项；② 本阶段产物里的假设；③ 复盘拷问翻出的过度声称（追加，编号续）。
- **最少一行**：真没有就写「本阶段无未验证项与风险」——**不许空着**（空表 = 静默跳过）。
- 阶段末逐条确认，出口：**接收 / 解决 / 重新确认**（同「统一阶段节奏」）。

## 完成判据（S6 后自查）

- [ ] 六个阶段都有独立计划与 `output/`，状态一致
- [ ] 每个审查待办行要么打勾、要么写明未执行的理由
- [ ] 每个阶段的风险表每条要么写明出口，要么写明未给出口的理由
- [ ] ID 链 `REQ → IF → DM → DS → TC` 无断点
- [ ] 未验证项如实列出（不写"已证明正确"）

> 只校验**有没有留痕**，不校验"结论是否正确"——后者是各阶段风险确认与 S6 管的事。

## 终止

- **S1 中用户说"打住"** → 不落计划、不留产物。
- **任一阶段之后叫停** → **保留、不回滚、不删**，在 `progress.md` 写明停在哪个阶段、为什么、下次从哪继续；产物按当前状态留在原地，**不假装完成**。

## 反模式

| 不要 | 为什么 |
|---|---|
| 在没有 `output/` 产物的情况下进下一阶段 | 下一阶段没有可消费的输入，等于断了链 |
| 用长文本 round 代替弹框 | 用户要的是"点选"而不是"读长文" |
| AI 自行拍架构 / 接口 / 数据取舍 | 取舍是用户的决策；ADR 记的必须是用户的决策 |
| 跳过阶段末的复盘拷问 | 它抓的是 AI 自己的错，靠自觉必失效 |
| 跳过阶段末的逐条风险确认 | 出口由用户给；AI 只负责把条目摆进弹框 |
| 风险表空着不写「本阶段无未验证项与风险」 | 空表 = 静默跳过 |
| 用户选了「重新确认」却直接往下走 | 要回本阶段改完、重跑风险确认段才算有出口 |
| 把文件里的研究词裸搬进弹框 / 风险表 | 用户不共享这些词；第一次出现就得用人话解释 |
| 把 caveman 用到产物上 | 三件套 / 计划 / ADR 必须正常文字 |
| 声称"产物 / 图已证明正确" | 只声称门禁实际覆盖到的那一层 |
| 未点选就自动渲染解释页 | 用户要的是显式调用 |
| 把「解释」项标成"(推荐)"或当作答 / 风险出口 | 它是旁路：解释完重弹同一条 |
| 解释页只给推荐项画图 / 把多个结论塞进一张图 | 每个结论各一张图；一张图只讲一个结论 |
| 绕过 Skill 直接手写 `am.mjs` | 必须调 Skill `answer-me-with-html` 走完整流程 |
| 在 S1 下限未满时弹"要不要继续" | 工作还没产出时的打扰 |
| 在 S1 下限满后自行判断"拷够了" | 要几轮拷问由用户定 |
| 阶段横幅临时换步名 / 自造半号 | 用户靠步名认位置 |
| 把多个工作项的审查合并成一条 | 用户按工作项验收 |
| 用"沿用上次口径"代替真调 `code-review-expert` | 它只吃 git diff，不同工作项 diff 不同 |
| 让 S6 的 ponytail 跟着某条审查行顺手跑 | 它要的是全部完成后的最终 diff |
| 自动触发本流程 | 会劫持普通提问 |
| 为中断做状态机 | 恢复靠三件套本身 |

## 术语

| 词 | 意思 |
|---|---|
| **阶段 / 子步** | 六个大阶段（S1~S6）；每个阶段下的 Sx-1…Sx-n 是子步 |
| **工作包 / 工作项** | 实施计划里的两级（不再叫"阶段"，避免和 S1~S6 混） |
| **阶段计划** | 每个阶段一个独立 task-id，三件套落在 `.planning/<stage-id>/` |
| **output** | 每个阶段的 `<stage-id>/output/`，产物交给下一阶段 |
| **取舍弹框** | 遇到真正的取舍时强制问用户，AI 不自行拍 |
| **复盘拷问** | 阶段末 AI 挑自己的错（自相矛盾 / 过度声称 / 写错前提） |
| **风险确认** | 阶段末逐条给风险定出口（接收 / 解决 / 重新确认），是该阶段的人工点 |
| **审查待办行** | 每个工作项一条，S4 真调 `code-review-expert` |
| **ID 链** | `REQ → IF → DM → DS → TC`，跨阶段可追 |
| **阶段横幅** | 每步开场那三行，回答"我在哪、还剩几步" |

## 边界（本流程不管什么）

- 不管**谁来实施**（默认当前 agent）
- 不管**产物格式**（那是各项目技能的事）
- 不管**排期 / 定时**（触发是用户事件）
- **不处理新改造 / 棕地改造**（只做新需求）

## 编码纪律（karpathy-guidelines，S4 用）

> 来源：`karpathy-guidelines`，以下为原文全文，S4 实施期间全程遵守。

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 缺输入时的行为（不留悬空判断）

| 情况 | 怎么办 |
|---|---|
| 敲 `/new-task` 但没给话题 | 先问一句"要讨论什么"，**不猜** |
| 用户要处理新改造 / 棕地任务 | 说明本流程只覆盖**新需求**，问是否改用其它流程 |
| 建不出 `.planning/` | 说一句再决定落哪，**不静默回退到 cwd 根** |
| 上一阶段 `output/` 为空 | 停在当前阶段开头，问用户；**不跳过** |
| S4 没有产生代码改动（纯文档 / 知识任务） | S6 的 ponytail 记「无 diff，跳过」，不假装审过 |
| S4 的项目不是 git 仓库 | 该工作项审查行写「无 diff（非 git 仓库），跳过」；S6 同处理 |
| 风险表是空的、也没写「本阶段无未验证项与风险」 | 先补写那一行，再跑风险确认段；不静默过 |
| 风险确认段里用户选「重新确认」 | 回本阶段改计划 / 产物 → 改完重跑本段；不带着它进下一阶段 |
