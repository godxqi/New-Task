---
name: new-task
description: 讨论一个新需求（绿地新系统）时走这条固定流程：S1 需求分析 → S2 架构设计 → S3 详细设计 → S4 编码 → S5 测试 → S6 审查。每个阶段一个独立计划；遇到取舍强制弹框；阶段末复盘 + 逐条风险确认 + 切计划前人工确认。仅用户可斜杠调用。
disable-model-invocation: true
argument-hint: "要讨论的新需求；留空则先问你"
---

**先读 `workflows/task-planning.md`（索引 + 共享规则），再按阶段读 `references/S*.md`。**

本目录的 `workflows/` 与 `NOTES.md` 是 `loop-me` 的工作区约定：`workflows/task-planning.md` 是流程索引与共享规则；`references/` 是各阶段细则与内联的架构依据；`NOTES.md` 只是设计素材，**执行时不要读它**。

## 硬约束

> 本节是**速览**：与 `workflows/task-planning.md` 冲突时**一律以索引 + references 为准**。

- **先调 Skill `caveman` 再开工** —— 对话压缩（**例外**：阶段横幅不压）
- **六阶段顺序执行**：`S1 → S2 → S3 → S4 → S5 → S6`，不跳步、不合并
- **每个阶段一个独立计划**：`.planning/plan<N>_XXXX/` 只放三件套；产物放同层 `NN_XXXX/output/`，交给下一阶段
- **进入阶段先建临时计划**，讨论完再复写；不要等计划写完才开始
- **遇到真正的取舍 → 强制 `AskUserQuestion` 弹框**：推荐项首项标"(推荐)"，**AI 不得自行拍**
- **每问末位加「解释这个问题与名词」**：调 `answer-me-with-html` 出一页（**一条一页；问题与每个选项各配一张图**），再重弹同一条；它**不算作答**
- **只有用户点选或明确调用才出页** —— AI 不自行渲染
- **阶段末两段固定**：复盘拷问（`grilling` 一轮）→ 逐条风险确认（接收 / 解决 / 重新确认）
- **切计划前人工确认**：问"是否切到下一阶段计划并 `/clear`？"；切目录不是自动的
- **S2 只做 C4 的 Context + Container；S3 才做 Component 内部**
- **每个阶段只写本阶段该做的事**：S1 需求 / S2 架构 / S3 详设 + 工作项建议 / S4 工作项 + 审查行 / S5 测试 / S6 对账
- **不是 git 仓库 → 停下来告知，不许跳过**（审查依赖 diff）
- spec **沉默处** → **问用户**，不要自行决定
- 调别的技能**一律走 Skill 工具、按 id 写**；不要试图"敲斜杠命令"
- **不要**经过 `grill-me`（空壳，模型调不到）

## 现在开始

调 Skill `caveman` → 读 `workflows/task-planning.md` → 从 S1 起执行（**每阶段先打横幅、先建临时计划**）→ S1 用 `grill-with-docs`，下限满后每轮末弹续期框 → 每阶段末复盘 + 风险确认 + 切计划确认 → 顺序推进到 S6。
