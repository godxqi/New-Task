---
name: new-task
description: 讨论一个新需求（绿地新系统）时走这条固定流程：S1 需求分析 → S2 架构设计 → S3 详细设计 → S4 编码 → S5 测试 → S6 审查 → S7 交付。每个阶段一个独立计划；遇到取舍强制弹框；阶段末复盘 + 风险确认 + 切计划门（强制 /clear）。仅用户可斜杠调用。
disable-model-invocation: true
argument-hint: "新需求话题；或输入「继续」从 active plan 恢复"
---

**先读 `workflows/task-planning.md`（索引 + 共享规则），再按阶段读 `references/S*.md`。**

本目录的 `workflows/` 与 `NOTES.md` 是 `loop-me` 的工作区约定：`workflows/task-planning.md` 是流程索引；`references/` 是各阶段细则与内联的架构依据；`scripts/validate.sh` 是机械校验；`NOTES.md` 只是设计素材，**执行时不要读它**。

## 硬约束

> 本节是**速览**：与 `workflows/task-planning.md` 冲突时**一律以索引 + references 为准**。

- **先调 Skill `caveman` 再开工** —— 对话压缩（**例外**：阶段横幅不压）；`/clear` 后要**重调**
- **七阶段顺序执行**：`S1 → S2 → S3 → S4 → S5 → S6 → S7`，不跳步、不合并
- **`/new-task 继续` 走恢复分支**：读 `.planning/.active_plan`，不从 S1 重来
- **`<task-id>` 必须是 ASCII slug**（`[A-Za-z0-9._-]+`）
- **代码根目录与 `.planning/` 同级**（默认 `<task-id>/src/`）
- **所有产物在 `.planning/plan<N>_XXXX/output/`**
- **计划唯一创建者是 bootstrap**：一次建好七个阶段骨架；阶段开场只读并复写成正式计划，**不新建**；切计划门只「更新恢复入口 + 换指针」
- **遇到真正的取舍 → 强制 `AskUserQuestion` 弹框**：推荐项首项标"(推荐)"，**AI 不得自行拍**
- **每问末位加「解释这个问题与名词」**：调 `answer-me-with-html` 出一页（**一条一页；问题与每个选项各配一张图**），再重弹同一条；它**不算作答**
- **只有用户点选或明确调用才出页** —— AI 不自行渲染
- **阶段末两段固定**：复盘拷问（`grilling` 一轮）→ 逐条风险确认（接收 / 解决 / 重新确认）
- **切计划门**：更新当前计划为「已完成，下一步 planN」→ 更新下一阶段恢复入口 → 换指针 → 提醒提交 → 强制 `/clear`
- **S2 只做 C4 的 Context + Container；S3 才做 Component 内部**
- **S5 两层都要过**：契约层（`DetailedDesign`）+ 功能层（`Requirement`）；子步 `S5-0..S5-5`
- **S5 先写用例、后读实现**：期望值只来自 `DetailedDesign` / `Requirement`；实现偏离进 `coverage-gaps` / `Risk`，不回写期望值
- **S5-0 环境门禁**：agent 起服务；账号 / token / 测试数据由用户提供；缺了停在 S5-0，不猜
- **S5 类型门控**：Web → E2E，HTTP → API，库 / CLI → 契约 + CLI 黑盒；不装不用的工具
- **S5 方法来自 `vendor/qa/`**：只读，不改 vendor；`case_lint.py` / `extract_case_schema.py` 必须过
- **每个阶段只写本阶段该做的事**
- **S4 按 `references/S4-coding.md` 的 karpathy-guidelines 执行**；每个 CodeUnit **先审查、后提交**；只提交代码根
- **调 `code-review-expert` 时把范围传给它**：只审 `<代码根>` 的 diff，忽略 `.planning/`；它的「Fix all / …」问询——**S4-1 已授权 → agent 代选；未授权 → 按用户档位，不静默覆盖**
- **ponytail 在 S4-4 全部 CodeUnit 完成后跑**
- **每阶段末提醒提交**；S4/S5 额外提醒：代码 / 测试不提交会影响审查
- **不是 git 仓库 → `git init`；没有提交 → 空基线；有提交 → 记当前 HEAD 为基线**
- **ID 全称**：Requirement / NonFunctionalRequirement / Interface / DataModel / DetailedDesign / TestPoint / TestCase / CodeUnit / Review / ArchDecisionRecord / Risk
- spec **沉默处** → **问用户**，不要自行决定
- 调别的技能**一律走 Skill 工具、按 id 写**；不要试图"敲斜杠命令"
- **`vendor/qa/` 不是注册技能**：按路径 `Read` 其 `SKILL.md`；脚本用 Bash 跑；不要 `Skill(qa)` / `Skill(test-strategy)`
- **不要**经过 `grill-me`

## 现在开始

- `/new-task <话题>` 且无 active plan → 读索引 → S1 bootstrap（ASCII slug、git 基线、一次建好七阶段计划）→ 调 `grill-with-docs`。
- `/new-task 继续` 或有 active plan → 读 active plan 的「恢复入口」→ 读对应 `references/S*.md` → 重调 `caveman` → 打横幅 → 继续。
- 每阶段末：复盘 → 风险确认 → 切计划门（更新两个恢复入口、换指针、提醒提交、强制 `/clear`）。
