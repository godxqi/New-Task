# 新任务流程（task-planning）· 索引

**状态**：v15 —— 2026-11-22 按用户指示：S1 拆成**功能需求拷问（4 轮：直接 / 补充 / 挑战 / 续期）** + **非功能需求拷问（4 轮固定角度：边界 / 质量_1 / 质量_2 / 搭法）**；NFR 单独落 `nfr.md`。
**v14** —— 2026-11-21 按第二轮复审返工：
- **代码根目录与 `.planning/` 同级**；**所有产物移进 `.planning/plan<N>_XXXX/output/`**（推翻 v13 的"产物与 `.planning` 同级"）；
- 增加 **`/new-task 继续`** 恢复分支 + 每个计划里的**恢复入口**块；`/clear` 改为**强制**；
- S1 补完整 **bootstrap**；S4 按 `D:\SKILL.md`（karpathy-guidelines）执行，补代码根目录、按 WI 提交；
- ID 链拆成**设计 / 实施 / 验证**三条；审查恢复 **P0~P3 全修**；
- 增加 `scripts/validate.sh` 机械校验；补 S4/S5/S6/S7 子步；补 S7 交付。

**历史**：v13 内联架构依据、拆 references；v12 六阶段；v11 解释页每结论各配图；v10 名词闸；v9 一条一页；v8 解释项；v7 落点 + 格式校验；v6 风险确认折入；v5 修补；v4 审查粒度=工作项；v3 横幅；v2 续期框；v1 定稿。

**IRON LAW**：步骤可以被讨论、不能默默跳过 —— 任何偏离必须在当次说出来，并在该阶段计划里留痕。

## Trigger

| 输入 | 分支 |
|---|---|
| `/new-task <话题>`，且 `.planning/.active_plan` 不存在 | **新任务**：从 S1 bootstrap 起 |
| `/new-task 继续`，或 `/new-task` 且 `.active_plan` 存在 | **继续任务**：读 active plan，**不从 S1 重来**（见「恢复入口」） |
| `/new-task <话题>`，但 `.active_plan` 已存在 | 问一句：继续当前任务，还是新建（新建会另开 `<task-id>/`，不覆盖旧的） |

**范围**：只处理**新需求（绿地新系统）**。新改造 / 棕地不走本流程。**不自动触发。**

## 外部依赖

| 技能 | 模型侧 id | 前置条件 | 用于 |
|---|---|---|---|
| Caveman | `caveman` | 无 | 每阶段开场（`/clear` 后必须重调） |
| Grill with Docs | `grill-with-docs` | 无（内部调 `grilling` + `domain-modeling`） | S1-1 / S1-2 |
| Grilling | `grilling` | 无 | 各阶段末复盘 |
| Domain Modeling | `domain-modeling` | 无 | 名词、GLOSSARY、ADR |
| Planning | `planning-with-files-zh` | cwd 下能建 `.planning/` | 每阶段计划 |
| Code Review | `code-review-expert` | 有 git diff | S4 每个 WI |
| Ponytail Review | `ponytail:ponytail-review` | 有 diff | S6 |

> `caveman` 只压对话输出；计划 / 三件套 / ADR / 记忆 / commit 写正常文字。**例外：阶段横幅不压。**

## 目录结构

**代码根目录与 `.planning/` 同级；产物、ADR、GLOSSARY 全部在 `.planning/plan<N>_XXXX/output/` 内。**

```
<task-id>/
├── .git/                               # 仓库根（bootstrap 时 git init 在这）
├── .planning/                          # 计划 + 产物
│   ├── plan0_RequirementsConfirm/
│   │   ├── task_plan.md
│   │   ├── progress.md
│   │   ├── findings.md
│   │   └── output/                     # S1 产物（requirements / GLOSSARY / adr）
│   ├── plan1_ArchitectureDesign/
│   │   └── output/
│   ├── plan2_DetailedDesign/
│   │   └── output/
│   ├── plan3_Coding/
│   │   └── output/
│   ├── plan4_Test/
│   │   └── output/
│   ├── plan5_Review/
│   │   └── output/
│   └── plan6_Delivery/
│       └── output/
└── src/                                # 代码根目录，与 .planning 同级
```

规则：

- **开场 `cd` 进 `<task-id>/` 一次；此后不再 `cd` 走**。
- **计划目录 = `plan<N>_XXXX`；产物目录 = 同目录下的 `output/`**。
- **ADR / GLOSSARY 落本阶段 `output/`**（S1：`plan0_RequirementsConfirm/output/adr/`、`.../GLOSSARY.md`）。
- 每阶段进入时 `mkdir -p .planning/plan<N>_XXXX/output`，建**临时计划**并 `set-active-plan.sh`。
- 阶段开始先读上一阶段 `output/`；为空 → 停下来问用户。
- 计划内部用 `### 阶段 <子步号>：名称`（如 `### 阶段 S1-1：功能需求拷问`）；`### 阶段` 是格式关键字，`S1-1` 是子步号。
- 每个子步恰好一个 `**状态：**`；跑 `check-complete.sh --validate`。
- `task_plan.md` 抬头写任务目录绝对路径；外部资料只进 `findings.md`。
- 产物命名纯 ASCII。

## Bootstrap（只在 S1 开场做一次）

1. `.planning/.active_plan` 已存在 → 走**继续任务**分支，不新建。
2. 用户给 task 名（没给就问）→ `mkdir -p <task-id> && cd <task-id>`（**全程唯一一次 cd**）。
3. 检查 git：不是仓库 → 问是否 `git init`（在 `<task-id>/` 下）；**不许跳过**。
4. `mkdir -p .planning/plan0_RequirementsConfirm/output`
5. `cp -n "$HOME/.claude/skills/planning-with-files-zh/templates/task_plan.md" "$HOME/.claude/skills/planning-with-files-zh/templates/findings.md" "$HOME/.claude/skills/planning-with-files-zh/templates/progress.md" .planning/plan0_RequirementsConfirm/`
6. `sh "$HOME/.claude/skills/planning-with-files-zh/scripts/set-active-plan.sh" plan0_RequirementsConfirm`
7. `sh "$HOME/.claude/skills/planning-with-files-zh/scripts/resolve-plan-dir.sh"` → 解析结果必须等于 `.planning/plan0_RequirementsConfirm`，否则**停**。

## 恢复入口（`/clear` 后先读这里）

每个阶段的临时 `task_plan.md` 顶部必须有这一块：

```md
## 恢复入口（/clear 后先读这里）
- 你是 new-task 流程的 **S3 详细设计**，不是新任务。
- 先读：SKILL.md → workflows/task-planning.md → references/S3-detailed-design.md
- 再读输入：.planning/plan1_ArchitectureDesign/output/
- 已完成：S3-1、S3-2
- 下一步：S3-3 数据结构
- 未决风险：R2（待用户出口）
- 开场动作：调 Skill `caveman` → 打 S3 横幅 → 继续
```

**继续任务分支**：

1. 读 `.planning/.active_plan` → 读该 plan 的 `task_plan.md`（hook 已注入）。
2. 读 `SKILL.md` → 本索引 → 恢复入口指定的 `references/S*.md`。
3. 读上一阶段 `output/`。
4. **重调 Skill `caveman`**（会话级，`/clear` 后没了）。
5. 打本阶段横幅，按「下一步」继续。

**自愈**：若用户没确认就 `/clear`，旧计划的恢复入口写「本阶段已完成，下一步切到 planN」；继续分支发现 active plan 已完成 → 提示切换，不重跑。

## 阶段横幅

```
── S<n> <步名>[ · <状态注>] ──────────────────
 S1 需求分析 · S2 架构设计 · S3 详细设计
 S4 编码 · S5 测试 · S6 审查 · S7 交付
──────────────────────────────────────────────
```

- `✓` 跑过、`◀` 当前、无标记未到。
- 状态注：子步（`3/8 数据模型`）、复盘、风险确认。
- 每阶段开场、每完成一个子步、阶段末两段之间各打一次。
- 弹框 `header` 带阶段名。步名固定，不换词、不自造半号。

## 统一阶段节奏

```
本阶段子步 Sx-1 … Sx-n
  ├─ 遇到真正的取舍 → 强制弹框
  ├─ 产物写进本阶段 output/（临时计划随时复写）
  ├─ 复盘拷问（grilling 固定一轮）
  ├─ 逐条风险确认（接收 / 解决 / 重新确认）
  └─ 切计划门：人工确认 → 建下一阶段临时计划（含恢复入口）→ 切 active → 建 output → 提示 /clear
```

- **切计划门是阶段门**：切目录不是自动的；人工确认后才切。
- **`/clear` 强制**：不 clear 不进下一阶段。提示用户：`/clear` 后输入 `/new-task 继续`。
- 风险出口：接收 / 解决 / 重新确认；选「重新确认」→ 回本阶段改，改完重跑。
- 复盘 / 风险确认都要打横幅、都要用弹框。

## 取舍弹框（强制）

**真正的取舍**（同时满足）：① 两个及以上可行选项；② 真实代价交换；③ 影响结构 / 接口 / 数据 / 质量属性，或难逆转。

**形式**：`AskUserQuestion`；推荐项首项标"(推荐)"；背景写进 `description`；**不另铺长文**。**AI 不得自行拍。**

**记录**：满足 ADR 三条 → 写 ADR 到本阶段 `output/adr/`，计划里留 `ADR-nnnn <标题> — <状态>` 索引行。ADR 编号追加、不修改；被取代的旧 ADR 标 `superseded by ADR-nnnn`。

**弹框限制**：一次最多 4 问 × 4 选项；超了分批；次要问题写"我按 X 默认，除非你反对"。

**名词闸**：第一次出现的非日常词就地解释或换掉。

**解释项**（每问 / 每条风险末位）：不标推荐、不算作答；调 `answer-me-with-html` 出一页后重弹同一条；**每个结论各占一个独立面板、各配一张 `flow`**；同批多条逐页连开；**只有用户点选或明确调用才出页**。

**事实自己查**：环境能查到的事实派 sub-agent 查，不占弹框额度。

## 阶段索引

| 阶段 | 计划 / 产物 | 细则 |
|---|---|---|
| S1 需求分析 | `plan0_RequirementsConfirm/{,output/}` | [S1-requirements.md](../references/S1-requirements.md) |
| S2 架构设计 | `plan1_ArchitectureDesign/{,output/}` | [S2-architecture.md](../references/S2-architecture.md) |
| S3 详细设计 | `plan2_DetailedDesign/{,output/}` | [S3-detailed-design.md](../references/S3-detailed-design.md) |
| S4 编码 | `plan3_Coding/{,output/}` | [S4-coding.md](../references/S4-coding.md) |
| S5 测试 | `plan4_Test/{,output/}` | [S5-test.md](../references/S5-test.md)（暂留空） |
| S6 审查 | `plan5_Review/{,output/}` | [S6-review.md](../references/S6-review.md)（暂留空） |
| S7 交付 | `plan6_Delivery/{,output/}` | [S7-delivery.md](../references/S7-delivery.md) |

每阶段只写本阶段的事：S1 需求 / S2 架构 / S3 详设 + 工作项建议 + 测试点 / S4 工作项 + 审查行 / S5 测试 / S6 对账 / S7 交付。

**S1 的内部顺序**：`S1-1 功能需求拷问（4 轮：直接 / 补充 / 挑战 / 续期）→ S1-2 非功能需求拷问（4 轮固定角度：边界 / 质量_1 / 质量_2 / 搭法）→ S1-3 落计划 → S1-4 复盘 + 风险确认`。

## ID 链（三条，不是一条）

| 链 | 方向 | 含义 |
|---|---|---|
| **设计链** | `REQ → IF → DM → DS` | 需求 → 接口 → 数据 → 详设 |
| **实施链** | `DS → WI → RV` | 详设 → 工作项 → 审查 |
| **验证链** | `DS → TC` | 详设 → 测试用例 |

- **`WI` 的输入只有 `DS`（可加 `IF`），不含 `TC`**；测试从契约推导，不从实现推导。
- S6 分别对三条链查断点；不能按单链 `REQ → … → TC` 查。
- 字段见 [artifact-templates.md](../references/artifact-templates.md)。

## 审查待办行（**S4 计划**）

```md
- [ ] RV-n ↳ WI-n <工作项名> 审查：Skill(code-review-expert) → Fix all → 结论回写 findings.md
```

- 粒度 = 工作项，一条一行，不许合并；只在 S4-1 写。
- **每个 WI 都必须有 diff**；无 diff → 停下来告知，**不许跳过**。
- 审查用**该 WI 自己的提交**（`git diff HEAD~1`），避免累计 diff。
- 靠计划注入 + 未打勾可见，非技术强制。

## 风险与未验证项表

**按 [artifact-templates.md](../references/artifact-templates.md) 的字段写**（`R-n / 内容 / 为什么未验证 / 代价 / 出口 / 落痕`）。

- 每个阶段 `task_plan.md` 里编号连续；最少一行「本阶段无未验证项与风险」，不许空着。
- 阶段末逐条确认；未给出口不进下一阶段。

## 完成判据

**只在 [S6-review.md](../references/S6-review.md) 维护一份**；本索引不重复。S6 后自查，不在两处各写一份。

## 机械校验

`sh scripts/validate.sh <task-id>`：检查计划 / output 齐全、ID 引用存在、编号连续、三条链无断点。阶段末与 S6 后各跑一次，退出码看得见。

## 终止

- S1 中用户说"打住" → 不落计划、不留产物。
- 任一阶段后叫停 → 保留、不回滚、不删；`progress.md` 写明停在哪、为什么、从哪继续。

## 反模式

| 不要 | 为什么 |
|---|---|
| 在 `.planning/` 同级放产物 | 产物统一在 `.planning/plan<N>_XXXX/output/` |
| 没有 `output/` 产物就进下一阶段 | 下一阶段没有输入 |
| 用长文本代替弹框 | 用户要"点选" |
| AI 自行拍架构 / 接口 / 数据取舍 | 取舍是用户的决策 |
| 跳过复盘 / 风险确认 | 一个抓 AI 的错，一个给用户出口 |
| 风险表空着 | 空表 = 静默跳过 |
| 用户选「重新确认」却直接往下走 | 要改完、重跑 |
| 没确认就切计划 / 没 `/clear` 就继续 | 会注入错计划 |
| 裸搬研究词进弹框 / 风险表 | 用户不共享这些词 |
| caveman 用到产物上 | 产物必须正常文字 |
| 声称"产物 / 图已证明正确" | 只声称实际覆盖的那一层 |
| 未点选就自动渲染解释页 | 用户要显式调用 |
| 解释项标推荐或当作答 / 出口 | 它是旁路 |
| 解释页只给推荐项画图 / 多结论塞一张图 | 每个结论各一张图 |
| 绕过 Skill 手写 `am.mjs` | 必须走完整流程 |
| 功能需求拷问没到第 4 轮就弹续期 | 工作没产出时的打扰 |
| 第 4 轮不问用户就自行进 S1-2 | 要不要再来一轮由用户定 |
| 阶段横幅临时换步名 / 自造半号 | 用户靠步名认位置 |
| 多个 WI 的审查合并成一条 | 用户按工作项验收 |
| 用累计 diff 审单个 WI | 审的应是该 WI 自己的提交 |
| 无 diff 却写"跳过" | 绿地每个 WI 都应有 diff；有问题停下来告知 |
| 让 S6 的 ponytail 顺手跑 | 要全部完成后的最终 diff |
| 自动触发本流程 | 会劫持普通提问 |
| 为中断做状态机 | 恢复靠计划里的恢复入口 |

## 术语

| 词 | 意思 |
|---|---|
| 阶段 / 子步 | 七个大阶段 S1~S7；每个阶段下的 Sx-1…Sx-n 是子步 |
| 计划 / 产物 | `.planning/plan<N>_XXXX/` 放计划与 `output/` 产物 |
| 工作包 / 工作项 | 实施计划里的两级；工作项在 S3 建议、S4 定稿 |
| 取舍弹框 | 遇到真正的取舍时强制问用户 |
| 复盘拷问 | 阶段末 AI 挑自己的错 |
| 风险确认 | 阶段末逐条给风险定出口 |
| 切计划门 | 阶段门：人工确认后切计划；`/clear` 强制 |
| 恢复入口 | 计划顶部的块，`/clear` 后据此继续 |
| 三条链 | 设计 `REQ→IF→DM→DS`；实施 `DS→WI→RV`；验证 `DS→TC` |
| ID 简写 | `REQ` Requirement / `NFR` Non-Functional Requirement / `IF` Interface / `DM` Data Model / `DS` Detailed Design / `TC` Test Case / `WI` Code Unit / `RV` Review / `ADR` Arch Decision Record / `R` Risk（详见 `artifact-templates.md`） |

## 边界

- 不管谁来实施（默认当前 agent）
- 不管产物格式（各项目技能的事）
- 不管排期 / 定时
- **不处理新改造 / 棕地改造**

## 编码纪律（karpathy-guidelines，S4 用）

> 来源：`D:\SKILL.md`（karpathy-guidelines）。S4 实施期间全程遵守。

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

## 缺输入时的行为

| 情况 | 怎么办 |
|---|---|
| `/new-task` 没给话题且无 active plan | 问"要讨论什么"，不猜 |
| 要处理新改造 / 棕地 | 说明本流程只覆盖新需求 |
| 建不出 `.planning/` | 说一句再决定落哪，不静默回退 |
| 上一阶段 `output/` 为空 | 停在当前阶段开头，问用户 |
| 不是 git 仓库 | 停下来告知，问是否 `git init`；不许跳过 |
| 某个 WI 没有 diff | 停下来告知，不许写"跳过" |
| 风险表空着且没写「本阶段无风险」 | 先补写，再跑风险确认 |
| 用户选「重新确认」 | 回本阶段改，改完重跑 |
