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
- **代码根目录与 `.planning/` 同级**（默认 `<task-id>/src/`）
- **所有产物在 `.planning/plan<N>_XXXX/output/`**；`.planning` 里不再有同级产物目录
- **进入阶段先建临时计划**（含「恢复入口」块），讨论完再复写
- **遇到真正的取舍 → 强制 `AskUserQuestion` 弹框**：推荐项首项标"(推荐)"，**AI 不得自行拍**
- **每问末位加「解释这个问题与名词」**：调 `answer-me-with-html` 出一页（**一条一页；问题与每个选项各配一张图**），再重弹同一条；它**不算作答**
- **只有用户点选或明确调用才出页** —— AI 不自行渲染
- **阶段末两段固定**：复盘拷问（`grilling` 一轮）→ 逐条风险确认（接收 / 解决 / 重新确认）
- **切计划门 + 强制 `/clear`**：人工确认 → 建下一阶段临时计划 → 切 active → 提示 `/clear` 后输入 `/new-task 继续`
- **S1 分两段拷问**：功能需求 4 轮（直接 / 补充 / 挑战 / 续期）；非功能需求 4 轮固定角度（边界 / 质量_1 / 质量_2 / 搭法）；NFR 单独落 `nfr.md`
- **S2 只做 C4 的 Context + Container；S3 才做 Component 内部**
- **每个阶段只写本阶段该做的事**：S1 需求 / S2 架构 / S3 详设 + 工作项建议 + 测试点 / S4 工作项 + 审查行 / S5 测试 / S6 对账 / S7 交付
- **S4 按 `D:\SKILL.md`（karpathy-guidelines）执行**；每个 WI 一个提交、一次审查（审该 WI 自己的 diff）
- **审查一律 Fix all，P0~P3 全修**；每个 WI 都必须有 diff，无 diff → 停下告知
- **不是 git 仓库 → 停下来告知，不许跳过**
- spec **沉默处** → **问用户**，不要自行决定
- 调别的技能**一律走 Skill 工具、按 id 写**；不要试图"敲斜杠命令"
- **不要**经过 `grill-me`

## 现在开始

- `/new-task <话题>` 且无 active plan → 读索引 → S1 bootstrap（建 `<task-id>/`、git、临时计划）→ 调 `grill-with-docs`。
- `/new-task 继续` 或有 active plan → 读 active plan 的「恢复入口」→ 读对应 `references/S*.md` → 重调 `caveman` → 打横幅 → 继续。
- 每阶段末：复盘 → 风险确认 → 切计划门 → 提示强制 `/clear`。
