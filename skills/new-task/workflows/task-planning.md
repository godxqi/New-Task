# 新任务流程（task-planning）· 索引

**状态**：v13 —— 2026-11-21 按复审意见返工：
- 架构依据**内联**到 `references/architecture-principles.md`，不再依赖外部目录；
- 阶段细节拆到 `references/S1..S6-*.md`，本文件只做索引与共享规则；
- 计划目录改为 `.planning/plan<N>_XXXX/`；ADR / GLOSSARY 落对应阶段的 `output/`；
- 每个阶段进入时先建**临时计划**，讨论完再复写；
- 阶段末风险确认后，**切计划前人工确认**并提示 `/clear`；
- 删除旧模型里"非代码任务可跳过"与"不在版本库就跳过"的描述；审查不再按等级统一全修。

**历史**：v12 六阶段顺序执行；v11 解释页每个结论各配一张图；v10 名词闸；v9 解释页一条一页；
v8 弹框末位「解释」项；v7 落点改 `.planning/` + 格式硬校验；v6 S3 折入风险确认；v5 `/skill-review` 修补；
v4 审查粒度=工作项；v3 阶段横幅；v2 续期框；v1 经 `/grilling` + `/loop-me` 定稿。

**IRON LAW**：步骤可以被讨论、不能默默跳过 —— 任何偏离必须在当次说出来，并在该阶段计划里留痕。

## Trigger

用户敲 `/new-task <话题>`，**只处理新需求（绿地新系统）**。新改造 / 棕地任务不走本流程。**不自动触发。**

## 外部依赖

| 技能 | 模型侧 id | 前置条件 | 用于 |
|---|---|---|---|
| Caveman | `caveman` | 无 | 全流程开场 |
| Grill with Docs | `grill-with-docs` | 无（内部调 `grilling` + `domain-modeling`） | S1-1 |
| Grilling | `grilling` | 无 | 各阶段末复盘；`grill-with-docs` 不可用时单独调 |
| Domain Modeling | `domain-modeling` | 无 | 名词、GLOSSARY、ADR |
| Planning | `planning-with-files-zh` | cwd 下能建 `.planning/` | 每个阶段的计划 |
| Code Review | `code-review-expert` | 有 git diff | S4 每个工作项；S5 测试代码 |
| Ponytail Review | `ponytail:ponytail-review` | 有 diff | S6 |

> `caveman` 只压对话输出；计划 / 三件套 / ADR / 记忆 / commit 写正常文字。**例外：阶段横幅不压。**

## 目录结构

**一个任务一个外层目录**（`<task-id>/`）；`.planning/` 与各阶段目录**同层**；`.planning/` **只放计划文件**。

```
<task-id>/
├── .planning/                          # 只放 planning-with-files 三件套
│   ├── plan0_RequirementsConfirm/
│   │   ├── task_plan.md
│   │   ├── progress.md
│   │   └── findings.md
│   ├── plan1_ArchitectureDesign/
│   ├── plan2_DetailedDesign/
│   ├── plan3_Coding/
│   ├── plan4_Test/
│   └── plan5_Review/
├── 00_RequirementsConfirm/
│   └── output/                         # 产物 + adr/ + GLOSSARY.md
├── 01_ArchitectureDesign/
│   └── output/                         # 产物 + adr/
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

- **cwd 全程保持在 `<task-id>/`**；不要在 Bash 里 `cd` 走。
- **计划目录名 = `plan<N>_XXXX`**；阶段产物目录名 = `NN_XXXX/output/`。两层不同名，避免混淆。
- **ADR / GLOSSARY 落对应阶段的 `output/`**（S1：`00_RequirementsConfirm/output/adr/`、`.../GLOSSARY.md`）。
- 每个阶段**开始时先建临时计划**（最小 `task_plan.md`）并 `set-active-plan.sh <plan-id>`，让 hook 有东西可注入；本阶段讨论 / 产出完再**复写**成正式计划。
- 阶段开始时**先读上一阶段的 `output/`**；为空 → 停下来问用户，不跳过。
- 计划内部用 `### 阶段 <子步号>：名称`（如 `### 阶段 S1-1：拷问`）表示子步；`### 阶段` 是 `planning-with-files-zh` 的格式关键字，`S1-1` 才是子步号。
- 每个子步恰好一个 `**状态：** pending|in_progress|complete`；落盘后跑 `check-complete.sh --validate`，不过就改到过。
- `task_plan.md` 抬头写**任务目录绝对路径**；外部资料只进 `findings.md`。
- 产物命名**纯 ASCII**。

## 阶段横幅

```
── S<n> <步名>[ · <状态注>] ──────────────────
 S1 需求分析 · S2 架构设计 · S3 详细设计
 S4 编码 · S5 测试 · S6 审查
──────────────────────────────────────────────
```

- `✓` = 跑过、`◀` = 当前、无标记 = 未到。
- `<状态注>`：子步（`3/8 数据模型`）、复盘（`复盘拷问`）、风险确认（`风险确认`）。
- 每阶段开场、每完成一个子步、阶段末两段之间各打一次。
- 弹框 `header` 带阶段名。步名固定，不换词、不自造半号。

## 统一阶段节奏

```
本阶段子步 Sx-1 … Sx-n
  ├─ 遇到真正的取舍 → 强制弹框问用户
  ├─ 产物写进 <stage>/output/（临时计划随时复写）
  ├─ 复盘拷问（AI 挑自己的错，grilling 固定一轮）
  ├─ 逐条风险确认（用户给出口；0 条记「本阶段无风险」）
  └─ 人工确认：是否切到下一阶段计划并 /clear？
```

- **没有单独的阶段门**；但**切计划文件前必须人工确认**（"切换并建议 /clear" / "切换但不 clear" / "先停"）。切目录不是自动的。
- 风险出口：**接收 / 解决 / 重新确认**。选「重新确认」→ 回本阶段改，改完重跑本段。
- 复盘 / 风险确认都要打横幅、都要用弹框。

## 取舍弹框（强制）

**真正的取舍**（同时满足才弹框）：① 两个及以上可行选项；② 真实代价交换；③ 影响结构 / 接口 / 数据 / 质量属性，或难逆转。

**形式**：`AskUserQuestion`；推荐项首项标"(推荐)"；背景写进 `description`；**不另铺长文**。**AI 不得自行拍。**

**记录**：满足 ADR 三条（难逆转 / 无背景会困惑 / 真实取舍）→ 写 ADR 到本阶段 `output/adr/`，并在本阶段 `task_plan.md` 留索引行 `ADR-nnnn <标题> — <状态>`。

**弹框限制**：一次最多 4 问 × 4 选项；超了分批；次要问题写"我按 X 默认，除非你反对"。

**名词闸**：题干与选项里第一次出现的非日常词，必须就地换日常说法或加括号解释。

**解释项**（每问 / 每条风险末位）：

- 不标"(推荐)"、不算作答；命中后调 `answer-me-with-html` 出一页，然后重弹同一条。
- 页面：问题与冲突点、名词、每个选项选错的后果；不写流程回顾、不复述推荐。
- **每个结论各占一个独立面板、各配一张自己的 `flow`**；问题本身一张冲突图，每个选项各一张后果图（推荐项也照画）。
- 同批多条命中 → 逐条各出一页；不合并。
- **只有用户点选或明确调用才出页**；AI 不自行渲染。渲染失败 → 对话里短解释，不阻塞。

**事实自己查**：能从环境查到的事实派 sub-agent 查，不占弹框额度；只有决策进弹框。

## 阶段索引

| 阶段 | 目标 | 计划目录 | 产物目录 | 细则 |
|---|---|---|---|---|
| S1 需求分析 | 需求条目、术语、本阶段计划、风险 | `plan0_RequirementsConfirm` | `00_RequirementsConfirm/output/` | [S1-requirements.md](../references/S1-requirements.md) |
| S2 架构设计 | 估算、质量属性、接口、数据、全景、瓶颈、ADR | `plan1_ArchitectureDesign` | `01_ArchitectureDesign/output/` | [S2-architecture.md](../references/S2-architecture.md) |
| S3 详细设计 | 模块、契约、数据结构、算法、工作项建议 | `plan2_DetailedDesign` | `02_DetailedDesign/output/` | [S3-detailed-design.md](../references/S3-detailed-design.md) |
| S4 编码 | 工作项、代码、审查行 | `plan3_Coding` | `03_Coding/output/` | [S4-coding.md](../references/S4-coding.md) |
| S5 测试 | TC、覆盖、缺口、测试代码复审 | `plan4_Test` | `04_Test/output/` | [S5-test.md](../references/S5-test.md) |
| S6 审查 | 对账、收缩、验收 | `plan5_Review` | `05_Review/output/` | [S6-review.md](../references/S6-review.md) |

**每个阶段只写本阶段该做的事**：S1 写需求与计划；S2 写架构；S3 写详设 + 工作项建议；S4 才写工作项与审查行；S5 写测试；S6 写对账。

## 产物字段与 ID

- **固定字段**：见 [artifact-templates.md](../references/artifact-templates.md)。
- **ID 体系**：`REQ → IF → DM → ADR`（S1/S2），`DS`（S3），`WI → RV`（S4），`TC`（S5），S6 对账覆盖全部。
- 每个产物抬头写：所属阶段 / 日期 / 输入来源。

## 审查待办行（**S4 计划**的产物规格）

```md
- [ ] RV-n ↳ WI-n <工作项名> 审查：Skill(code-review-expert) → 结论回写 findings.md
```

- 粒度 = 工作项，一条一行，不许合并。
- 只在 **S4-1 建编码计划**时写；S1 / S3 不写（工作项到 S4 才定稿）。
- 确无 diff 的写「无 diff，跳过」，不假装审过。
- 非技术强制：靠计划注入 + 未打勾可见。

## 风险与未验证项表（**每个阶段**的规格）

本阶段 `task_plan.md` 里编号连续的 `R1..Rn`，每条：

| 列 | 写什么 |
|---|---|
| 内容 | 风险 / 未验证项，日常语言 |
| 为什么未验证 | 出处 + 根据 |
| 一旦错了的代价 | 赌注 |
| 出口 | 接收 / 解决 / 重新确认（用户给） |

- 来源：本阶段拷问残留、产物假设、复盘翻出的过度声称。
- 最少一行：真没有写「本阶段无未验证项与风险」——**不许空着**。
- 阶段末逐条确认；未给出口不进下一阶段。

## 完成判据（S6 后自查）

- [ ] 六个阶段都有独立计划与 `output/`
- [ ] 每条审查行打勾或写明未执行理由
- [ ] 每个阶段风险表每条有出口或未给出口理由
- [ ] ID 链 `REQ → IF → DM → DS → WI → TC` 无断点；ADR 索引完整
- [ ] 未验证项如实列出

## 终止

- S1 中用户说"打住" → 不落计划、不留产物。
- 任一阶段后叫停 → 保留、不回滚、不删；在 `progress.md` 写明停在哪、为什么、从哪继续；不假装完成。

## 反模式

| 不要 | 为什么 |
|---|---|
| 在没有 `output/` 产物时进下一阶段 | 下一阶段没有可消费的输入 |
| 用长文本代替弹框 | 用户要"点选"，不是"读长文" |
| AI 自行拍架构 / 接口 / 数据取舍 | 取舍是用户的决策；ADR 记的必须是用户的决策 |
| 跳过阶段末复盘 / 风险确认 | 一个抓 AI 的错，一个给用户出口 |
| 风险表空着 | 空表 = 静默跳过 |
| 用户选「重新确认」却直接往下走 | 要改完、重跑风险确认段 |
| 裸搬研究词进弹框 / 风险表 | 用户不共享这些词 |
| caveman 用到产物上 | 计划 / ADR 必须正常文字 |
| 声称"产物 / 图已证明正确" | 只声称实际覆盖的那一层 |
| 未点选就自动渲染解释页 | 用户要显式调用 |
| 解释项标"(推荐)"或当作答 / 出口 | 它是旁路 |
| 解释页只给推荐项画图 / 多结论塞一张图 | 每个结论各一张图 |
| 绕过 Skill 直接手写 `am.mjs` | 必须走完整流程 |
| S1 下限未满时弹"要不要继续" | 工作没产出时的打扰 |
| S1 下限满后自行判断"拷够了" | 由用户定 |
| 阶段横幅临时换步名 / 自造半号 | 用户靠步名认位置 |
| 多个工作项的审查合并成一条 | 用户按工作项验收 |
| 用"沿用上次口径"代替真调 `code-review-expert` | 只吃 diff，不同工作项不同 |
| 让 S6 的 ponytail 顺手跑 | 要全部完成后的最终 diff |
| 自动触发本流程 | 会劫持普通提问 |
| 为中断做状态机 | 恢复靠三件套 |

## 术语

| 词 | 意思 |
|---|---|
| 阶段 / 子步 | 六个大阶段 S1~S6；每个阶段下的 Sx-1…Sx-n 是子步 |
| 计划 / 产物 | `.planning/plan<N>_XXXX/` 放计划；`NN_XXXX/output/` 放产物 |
| 工作包 / 工作项 | 实施计划里的两级；工作项在 S3 建议、S4 定稿 |
| 取舍弹框 | 遇到真正的取舍时强制问用户 |
| 复盘拷问 | 阶段末 AI 挑自己的错 |
| 风险确认 | 阶段末逐条给风险定出口，是该阶段的人工点 |
| 切计划确认 | 阶段末切计划前的人工确认，可建议 `/clear` |
| ID 链 | `REQ → IF → DM → DS → WI → TC`；ADR / RV 挂在其上 |

## 边界

- 不管谁来实施（默认当前 agent）
- 不管产物格式（各项目技能的事）
- 不管排期 / 定时
- **不处理新改造 / 棕地改造**

## 编码纪律（karpathy-guidelines，S4 用）

> 来源：`karpathy-guidelines`，S4 实施期间全程遵守。

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

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

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.
- Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

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

## 缺输入时的行为

| 情况 | 怎么办 |
|---|---|
| 敲 `/new-task` 但没给话题 | 先问"要讨论什么"，不猜 |
| 用户要处理新改造 / 棕地任务 | 说明本流程只覆盖新需求 |
| 建不出 `.planning/` | 说一句再决定落哪，不静默回退 |
| 上一阶段 `output/` 为空 | 停在当前阶段开头，问用户，不跳过 |
| **不是 git 仓库** | **停下来告知用户**，问是否 `git init`；**不许跳过**（审查依赖 diff） |
| 风险表空着且没写「本阶段无风险」 | 先补写，再跑风险确认 |
| 用户选「重新确认」 | 回本阶段改，改完重跑风险确认段 |
