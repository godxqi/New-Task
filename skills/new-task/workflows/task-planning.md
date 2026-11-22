# 新任务流程（task-planning）· 索引

**状态**：v19 —— 2026-11-22 按第六轮复审返工：
- Fix all 授权规则在 S4-3 / SKILL / 反模式三处统一为「已授权才代选」；
- S5 顺序改为 写测试 → 审测试代码 → 跑测试 → 缺口；
- coverage-gaps 增加 `TestPoint-n` 列，缺口必须挂测试点；
- validate 排除 `A-1..B-5` 范围写法；S4/S5 清工作树无改动可跳过；
- 残留 `NFR` / `ADR` 概念词统一为全称。
**v18** —— 2026-11-22 按第五轮复审返工：
- **所有 ID 改为无空格全称**：Requirement / NonFunctionalRequirement / Interface / DataModel / DetailedDesign / TestPoint / TestCase / CodeUnit / Review / ArchDecisionRecord / Risk；
- S1 bootstrap 与索引对齐（git user、已有提交、基线写七份计划、子步按 references 标题）；
- S4 基线描述改为「以计划记的 hash 为准」；artifact 支线改为 CodeUnit/TestPoint 并列、TestCase 在 TestPoint 下；
- S4-1 一次性拿 Fix all 授权；S7 单独提交行；coverage-gaps 无缺口也写；
- validate：row_check 认列表、DetailedDesign 行允许 Requirement、编号排除 `..` 占位。
**v17** —— 2026-11-22 按第四轮复审返工：
- SKILL.md 与索引对齐「bootstrap 唯一创建者」；
- `code-review-expert` 的范围显式传给它（只审代码根），「Fix all」由 agent 代为选择；
- 提交表补 S4/S5 计划提交与下一阶段恢复入口；
- bootstrap 区分「新仓库 / 已有提交」并检查 git user；子步占位写明按 references 标题；
- 切计划门同时更新当前计划为「已完成」；
- `validate.sh` 细化到行级：CodeUnit↔Review、DetailedDesign↔Interface/DataModel、DetailedDesign↔TestPoint、TestPoint↔TestCase；
- 新增 `TestPoint`（Test Point）；S5/S6 标注统一为「骨架，待定稿」。
**v16** —— 2026-11-22 按第三轮复审返工：
- **先审查、后提交**；每阶段末提醒 commit，S4/S5 额外提醒（代码不提交会影响审查）；
- bootstrap 建**空基线提交** + **一次性建好七个阶段的计划骨架**；切计划门只「更新恢复入口 + 换指针」；
- 提交按阶段 / 按代码根目录**限定路径**，`.planning` 不混进 code review；
- **S2-1 估规模移入 S1-2**（确认需求的一部分）；S2 改为 7 个子步；
- **ponytail 移到 S4-4**（全部 CodeUnit 完成后）；S6 只做对账与验收；
- 删除机器绝对路径，karpathy 全文放进 S4；
- 修复 `validate.sh` 的误报与漏检；补 S5 产物固定文件名。

**历史**：v15 S1 拆功能/NonFunctionalRequirement 拷问；v14 目录与 /clear 恢复；v13 内联架构依据；v12 六阶段；v11 解释页；v10 名词闸；v9 一条一页；v8 解释项；v7 落点；v6 风险确认；v5 修补；v4 审查粒度；v3 横幅；v2 续期框；v1 定稿。

**IRON LAW**：步骤可以被讨论、不能默默跳过 —— 任何偏离必须在当次说出来，并在该阶段计划里留痕。

## Trigger

| 输入 | 分支 |
|---|---|
| `/new-task <话题>`，无 `.planning/.active_plan` | **新任务**：从 S1 bootstrap 起 |
| `/new-task 继续`，或 `/new-task` 且 `.active_plan` 存在 | **继续任务**：读 active plan，不从 S1 重来 |
| `/new-task <话题>`，但 `.active_plan` 已存在，用户选「新建」 | **不在本会话建**：提示"本会话在旧任务里；请在新会话的父目录运行 `/new-task <话题>`"。cwd、active 指针、上下文三者绑定，换任务开新会话最干净 |

**范围**：只处理**新需求（绿地新系统）**。新改造 / 棕地不走本流程。**不自动触发。**

## 外部依赖

| 技能 | 模型侧 id | 前置条件 | 用于 |
|---|---|---|---|
| Caveman | `caveman` | 无 | 每阶段开场（`/clear` 后必须重调） |
| Grill with Docs | `grill-with-docs` | 无（内部调 `grilling` + `domain-modeling`） | S1-1 / S1-2 |
| Grilling | `grilling` | 无 | 各阶段末复盘 |
| Domain Modeling | `domain-modeling` | 无 | 名词、GLOSSARY、ArchDecisionRecord |
| Planning | `planning-with-files-zh` | cwd 下能建 `.planning/` | 每阶段计划 |
| Code Review | `code-review-expert` | 有 diff | S4 每个 WI；S5 测试代码 |
| Ponytail Review | `ponytail:ponytail-review` | 有 diff | S4-4 |

> `caveman` 只压对话输出；计划 / 三件套 / ArchDecisionRecord / 记忆 / commit 写正常文字。**例外：阶段横幅不压。**

## 目录结构

**任务根 `<task-id>/`**（ASCII slug：`[A-Za-z0-9._-]+`）；代码根与 `.planning/` 同级；产物在 `.planning/plan<N>_XXXX/output/`。

```
<task-id>/
├── .git/                               # 仓库根（bootstrap）
├── .planning/
│   ├── plan0_RequirementsConfirm/
│   │   ├── task_plan.md / progress.md / findings.md
│   │   └── output/                     # requirements / nfr / estimation / GLOSSARY / adr
│   ├── plan1_ArchitectureDesign/
│   │   └── output/                     # quality / interfaces / data-model / architecture / bottlenecks / adr
│   ├── plan2_DetailedDesign/
│   │   └── output/                     # detailed-design / work-items / test-points
│   ├── plan3_Coding/
│   │   └── output/
│   ├── plan4_Test/
│   │   └── output/                     # test-cases / test-results / coverage-gaps
│   ├── plan5_Review/
│   │   └── output/                     # reconciliation
│   └── plan6_Delivery/
│       └── output/                     # deliverables
└── src/                                # 代码根，与 .planning 同级
```

- **开场 `cd` 进 `<task-id>/` 一次；此后不再 `cd`**。
- `<task-id>` 必须是 ASCII slug；用户给中文名 → 给一个 ASCII slug 并确认。
- 计划目录 `plan<N>_XXXX`；产物在其中的 `output/`。
- **ArchDecisionRecord / GLOSSARY 落本阶段 `output/`**。

## Bootstrap（只在 S1 开场做一次）

1. `.planning/.active_plan` 已存在 → 走**继续任务**分支，不新建。
2. 用户给 task 名（没给就问）→ 确认 ASCII slug → `mkdir -p <task-id> && cd <task-id>`（**全程唯一一次 cd**）。
3. 检查 git：
   - 不是仓库 → `git init`。
   - 确认 `git config user.name` / `user.email` 已配置；缺 → 停下来让用户配置（不擅自设全局）。
   - 若仓库**没有任何提交** → `git commit --allow-empty -m "chore: baseline"`。
   - 若仓库**已有提交** → **不建空提交**，记当前 `git rev-parse HEAD` 为基线。
   - 把基线 hash 写进七阶段计划。
4. **一次性建好七个阶段的计划骨架**：
   - 对 `plan0_RequirementsConfirm` … `plan6_Delivery`：
     - `mkdir -p .planning/<plan>/output`
     - `cp -n "$HOME/.claude/skills/planning-with-files-zh/templates/task_plan.md" "$HOME/.claude/skills/planning-with-files-zh/templates/findings.md" "$HOME/.claude/skills/planning-with-files-zh/templates/progress.md" .planning/<plan>/`
     - 写最小 `task_plan.md`：恢复入口 + 本阶段子步占位（全部 `pending`）+ 基线提交号。
     - **子步占位按各阶段 `references/S*.md` 的标题生成**：S1-1..S1-4、S2-1..S2-7、S3-1..S3-5、S4-1..S4-4、S5-1..S5-4、S6-1..S6-3、S7-1..S7-3。
5. `sh "$HOME/.claude/skills/planning-with-files-zh/scripts/set-active-plan.sh" plan0_RequirementsConfirm`
6. `sh "$HOME/.claude/skills/planning-with-files-zh/scripts/resolve-plan-dir.sh"` → 必须等于 `.planning/plan0_RequirementsConfirm`，否则**停**。

> **唯一创建者 = bootstrap**。阶段开场不再 `mkdir` / `cp` / `set-active-plan`；阶段收尾只更新下一阶段的恢复入口并换指针。

## 恢复入口（每份 plan 顶部必须有）

```md
## 恢复入口（/clear 后先读这里）
- 你是 new-task 流程的 **S3 详细设计**，不是新任务。
- 先读：SKILL.md → workflows/task-planning.md → references/S3-detailed-design.md
- 再读输入：.planning/plan1_ArchitectureDesign/output/
- 已完成：S3-1、S3-2
- 下一步：S3-3 数据结构
- 未决风险：Risk-2（待用户出口）
- 开场动作：调 Skill `caveman` → 打 S3 横幅 → 继续
```

- **每完成一个子步就更新当前计划的恢复入口**（已完成 / 下一步 / 未决风险）——防止中途 `/clear` 后恢复入口过期。
- **切计划门**更新下一阶段计划的恢复入口（不是重建）。
- **继续任务分支**：读 `.active_plan` → 读该 plan 的 `task_plan.md`（hook 已注入）→ 读索引与阶段 references → 读上一阶段 `output/` → **重调 `caveman`** → 打横幅 → 按「下一步」继续。
- **自愈**：若没确认就 `/clear`，旧计划的恢复入口写「本阶段已完成，下一步切到 planN」；继续分支发现 active plan 已完成 → 提示切换，不重跑。

## 阶段横幅

```
── S<n> <步名>[ · <状态注>] ──────────────────
 S1 需求分析 · S2 架构设计 · S3 详细设计
 S4 编码 · S5 测试 · S6 审查 · S7 交付
──────────────────────────────────────────────
```

- `✓` 跑过、`◀` 当前、无标记未到。
- 状态注：子步（`3/7 数据模型`）、复盘、风险确认。
- 每阶段开场、每完成一个子步、阶段末两段之间各打一次。
- 弹框 `header` 带阶段名。步名固定，不换词、不自造半号。

## 统一阶段节奏

```
本阶段子步 Sx-1 … Sx-n
  ├─ 遇到真正的取舍 → 强制弹框
  ├─ 产物写进本阶段 output/；每完成一个子步 → 更新恢复入口
  ├─ 复盘拷问（grilling 固定一轮）
  ├─ 逐条风险确认（接收 / 解决 / 重新确认）
  └─ 切计划门：
      ① 更新当前计划为「本阶段已完成，下一步 planN」
      ② 更新下一阶段计划的恢复入口
      ③ set-active-plan <下一阶段>
      ④ 提醒提交（本阶段计划 + 下一阶段恢复入口）；S4/S5 额外强调"代码不提交会影响审查"
      ⑤ 提示强制 /clear，清空后 `/new-task 继续`
```

- **先审查、后提交**：S4 每个 CodeUnit 先在**工作树**审，再提交。
- **切计划门是阶段门**；`/clear` 强制。
- 风险出口：接收 / 解决 / 重新确认；选「重新确认」→ 回本阶段改，改完重跑。

## 提交规则（防污染）

| 阶段 | 提交 |
|---|---|
| S1–S3 / S6 | `git add .planning/plan<N>_XXXX .planning/plan<N+1>_XXXX` → commit（含下一阶段恢复入口） |
| S7 | `git add .planning/plan6_Delivery <交付说明文件>` → commit（**没有 plan7**） |
| S4 每个 WI（审查前） | `git add .planning/plan3_Coding && git commit -m "plan: CodeUnit-n"`，清空工作树里的计划改动 |
| S4 每个 WI（审查后） | `git add <代码根> && git commit -m "CodeUnit-n: …"` |
| S4-4 收缩 | `git add <代码根> && git commit -m "chore: shrink"` |
| S4 收尾 | `git add .planning/plan3_Coding .planning/plan4_Test` → commit |
| S5（审查前 / 后） | `git add .planning/plan4_Test && git commit -m "plan: S5"`；审测试 → `git add <测试文件> && git commit -m "tests: …"` |
| S5 收尾 | `git add .planning/plan4_Test .planning/plan5_Review` → commit |

- 不要 `git add .`；每阶段只提交自己的产物。
- **审查前先把 `.planning` 提交掉**，让工作树只剩代码；并明确告诉技能只审代码根。
- 每个阶段末提醒用户 commit；**S4/S5 额外提醒**：代码不提交，后续审查 / 对比会失真。

## 取舍弹框（强制）

**真正的取舍**（同时满足）：① 两个及以上可行选项；② 真实代价交换；③ 影响结构 / 接口 / 数据 / 质量属性，或难逆转。

**形式**：`AskUserQuestion`；推荐项首项标"(推荐)"；背景写进 `description`；**不另铺长文**。**AI 不得自行拍。**

**记录**：满足 ArchDecisionRecord 三条 → 写 ArchDecisionRecord 到本阶段 `output/adr/`，计划里留 `ArchDecisionRecord-nnnn <标题> — <状态>` 索引行。ArchDecisionRecord 追加、不修改；被取代的标 `superseded by ArchDecisionRecord-nnnn`。

**弹框限制**：一次最多 4 问 × 4 选项；超了分批；次要问题写"我按 X 默认，除非你反对"。

**名词闸**：第一次出现的非日常词就地解释或换掉。

**解释项**（每问 / 每条风险末位）：不标推荐、不算作答；调 `answer-me-with-html` 出一页后重弹同一条；**每个结论各占一个独立面板、各配一张 `flow`**；同批多条逐页连开；**只有用户点选或明确调用才出页**。

**事实自己查**：环境能查到的事实派 sub-agent 查，不占弹框额度。

## 阶段索引

| 阶段 | 计划 / 产物 | 细则 |
|---|---|---|
| S1 需求分析 | `plan0_RequirementsConfirm/` | [S1-requirements.md](../references/S1-requirements.md) |
| S2 架构设计 | `plan1_ArchitectureDesign/` | [S2-architecture.md](../references/S2-architecture.md) |
| S3 详细设计 | `plan2_DetailedDesign/` | [S3-detailed-design.md](../references/S3-detailed-design.md) |
| S4 编码 | `plan3_Coding/` | [S4-coding.md](../references/S4-coding.md) |
| S5 测试 | `plan4_Test/` | [S5-test.md](../references/S5-test.md)（骨架，待定稿） |
| S6 审查 | `plan5_Review/` | [S6-review.md](../references/S6-review.md)（骨架，待定稿） |
| S7 交付 | `plan6_Delivery/` | [S7-delivery.md](../references/S7-delivery.md) |

**S1 内部**：`S1-1 功能需求拷问（4 轮）→ S1-2 非功能需求拷问（4 轮）+ 估规模 → S1-3 落计划 → S1-4 复盘 + 风险确认`。

**S2 内部**：`S2-1 质量属性 → S2-2 接口边界 → S2-3 数据模型 → S2-4 架构全景 → S2-5 灵魂部件与接缝 → S2-6 瓶颈 → S2-7 取舍与 ArchDecisionRecord`。

## ID 链（三条）

| 链 | 方向 | 含义 |
|---|---|---|
| **设计链** | `Requirement → Interface → DataModel → DetailedDesign` | 需求 → 接口 → 数据 → 详设 |
| **实施链** | `DetailedDesign → CodeUnit → Review` | 详设 → 工作项 → 审查 |
| **验证链** | `DetailedDesign → TestPoint → TestCase` | 详设 → 测试点 → 测试用例 |

- **`CodeUnit` 的输入只有 `DetailedDesign`（可加 `Interface`），不含 `TestCase`**。
- **NonFunctionalRequirement 编号**：S1 定义 `NonFunctionalRequirement-1..n`；S2 的质量属性表**细化同一批 ID**（补可度量目标与冲突），新增属性才续编号。
- 字段与全称见 [artifact-templates.md](../references/artifact-templates.md)。

## 审查待办行（**S4 计划**）

```md
- [ ] Review-n ↳ CodeUnit-n <工作项名> 审查：Skill(code-review-expert) → Fix all → 结论回写 findings.md
```

- 粒度 = 工作项；只在 S4-1 写。
- **顺序 = 实施 → 审查（工作树 `git diff -- <代码根>`）→ 修复 → 提交**。
- 每个 CodeUnit 都必须有 diff；无 diff → 停下告知，不许跳过。
- 非技术强制：靠计划注入 + 未打勾可见。

## 风险与未验证项表

按 [artifact-templates.md](../references/artifact-templates.md) 写（`Risk-n / 内容 / 为什么未验证 / 代价 / 出口 / 落痕`）。

- 每个阶段 `task_plan.md` 里编号连续；最少一行「本阶段无未验证项与风险」。
- 阶段末逐条确认；未给出口不进下一阶段。

## 完成判据

**只在 [S6-review.md](../references/S6-review.md) 维护一份**；本索引不重复。

## 机械校验

```sh
sh "${NEW_TASK_SKILL_DIR:-$HOME/.claude/skills/new-task}/scripts/validate.sh" "$PWD"
```

- 用户级安装默认路径成立；**项目级安装**时设 `NEW_TASK_SKILL_DIR=<项目>/.claude/skills/new-task`，或直接换成项目路径。
- 检查：七阶段产物齐全、ID 编号连续、设计/实施/验证三条链**行级断点**、ArchDecisionRecord 文件与索引、`nfr.md` / `GLOSSARY.md`。阶段末与 S6 后各跑一次。

## 终止

- S1 中用户说"打住" → 不落计划、不留产物。
- 任一阶段后叫停 → 保留、不回滚、不删；`progress.md` 写明停在哪、为什么、从哪继续。

## 反模式

| 不要 | 为什么 |
|---|---|
| 在 `.planning/` 同级放产物 | 产物统一在 `.planning/plan<N>_XXXX/output/` |
| 阶段开场重复建计划 / 切 active | 唯一创建者是 bootstrap；切计划门只更新恢复入口并换指针 |
| 先提交再审查 | 工作树干净后 `code-review-expert` 看不到变更；必须**先审查、后提交** |
| `git add .` | `.planning` 会混进代码审查；按阶段 / 代码根限定路径 |
| 让 `code-review-expert` 自己扫全树 | 必须显式告诉它只审代码根；审查前先把 `.planning` 提交掉 |
| 未授权就代选 Fix all | S4-1 已授权才由 agent 代选；未授权按用户档位，不静默覆盖 |
| 第一个 CodeUnit 没有父提交 | 无提交的仓库要有空基线；已有提交的仓库记 HEAD 为基线 |
| 已有提交的仓库还建空基线 | 语义不清；直接记当前 HEAD |
| 切计划门不更新当前计划 | 自愈依赖「本阶段已完成，下一步 planN」，必须写 |
| S4/S5 只提交代码 / 测试、不提交计划 | plan3/plan4 与审查行会一直 uncommitted |
| 用长文本代替弹框 | 用户要"点选" |
| AI 自行拍架构 / 接口 / 数据取舍 | 取舍是用户的决策 |
| 跳过复盘 / 风险确认 | 一个抓 AI 的错，一个给用户出口 |
| 风险表空着 | 空表 = 静默跳过 |
| 用户选「重新确认」却直接往下走 | 要改完、重跑 |
| 没确认就切计划 / 没 `/clear` 就继续 | 会注入错计划 |
| 在旧任务会话里新建任务 | 开新会话，从父目录启动 |
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
| 多个 CodeUnit 的审查合并成一条 | 用户按工作项验收 |
| 用累计 diff 审单个 CodeUnit | 审的应是该 CodeUnit 自己的改动 |
| 无 diff 却写"跳过" | 绿地每个 CodeUnit 都应有 diff；有问题停下来告知 |
| 让 S6 跑 ponytail | 它已在 S4-4 全部 CodeUnit 完成后跑 |
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
| 切计划门 | 阶段门：更新恢复入口 + 换指针 + 提示强制 `/clear` |
| 恢复入口 | 计划顶部的块，`/clear` 后据此继续 |
| 三条链 | 设计 `Requirement→Interface→DataModel→DetailedDesign`；实施 `DetailedDesign→CodeUnit→Review`；验证 `DetailedDesign→TestPoint→TestCase` |
| ID 全称 | Requirement / NonFunctionalRequirement / Interface / DataModel / DetailedDesign / TestPoint / TestCase / CodeUnit / Review / ArchDecisionRecord / Risk |

## 边界

- 不管谁来实施（默认当前 agent）
- 不管产物格式（各项目技能的事）
- 不管排期 / 定时
- **不处理新改造 / 棕地改造**

## 缺输入时的行为

| 情况 | 怎么办 |
|---|---|
| `/new-task` 没给话题且无 active plan | 问"要讨论什么"，不猜 |
| 要处理新改造 / 棕地 | 说明本流程只覆盖新需求 |
| 有 active plan 且用户要新建 | 提示开新会话，从父目录启动 |
| task 名不是 ASCII slug | 给一个 ASCII slug 并确认 |
| 建不出 `.planning/` | 说一句再决定落哪，不静默回退 |
| 上一阶段 `output/` 为空 | 停在当前阶段开头，问用户 |
| 不是 git 仓库 | `git init` + 空基线提交；不许跳过 |
| 某个 CodeUnit 没有 diff | 停下来告知，不许写"跳过" |
| 风险表空着且没写「本阶段无风险」 | 先补写，再跑风险确认 |
| 用户选「重新确认」 | 回本阶段改，改完重跑 |
