---
name: new-task
description: 讨论一个新需求（绿地新系统）时走这条固定流程：S1 需求分析 → S2 架构设计 → S3 详细设计 → S4 编码 → S5 测试 → S6 审查。每个阶段一个独立计划；遇到取舍强制弹框；阶段末复盘 + 逐条风险确认。仅用户可斜杠调用。
disable-model-invocation: true
argument-hint: "要讨论的新需求；留空则先问你"
---

**先读 `workflows/task-planning.md`（唯一权威），然后端到端照它走。**

本目录的 `workflows/` 与 `NOTES.md` 是 `loop-me` 的工作区约定：`workflows/task-planning.md` 是 spec 的唯一权威；`NOTES.md` 只是设计素材，**执行时不要读它** —— 不要为了"规范化"改名（改名会让 `loop-me` 下次找不到它）。

## 硬约束

> 本节是**速览**：与 `workflows/task-planning.md` 冲突时**一律以 spec 为准**（速览可能滞后）。

- **先调 Skill `caveman` 再开工** —— 对话输出压缩（**例外**：阶段横幅不压）
- **六阶段顺序执行**：`S1 需求分析 → S2 架构设计 → S3 详细设计 → S4 编码 → S5 测试 → S6 审查`，不跳步、不合并
- **每个阶段一个独立计划**：`.planning/<stage-id>/` 只放三件套；产物放同层 `<stage-id>/output/`，交给下一阶段
- **遇到真正的取舍 → 强制 `AskUserQuestion` 弹框**：推荐项放首项标"(推荐)"，背景写进 `description`，**AI 不得自行拍**
- **每问末位加「解释这个问题与名词」**：命中后调 `answer-me-with-html` 出一页（**一条一页，多条命中逐页连开；问题本身与每个选项各配一张自己的图**），再重弹同一问；它**不算作答**
- **只有用户点选或明确调用 `/answer-me-with-html` 才出页** —— AI 不自行出页
- **阶段末两段固定**：复盘拷问（AI 挑自己的错）→ **逐条风险确认**（接收 / 解决 / 重新确认）；**没有单独的阶段门**，风险确认就是该阶段的人工点
- 审查待办行与**风险表**的粒度与规格 —— **全部以 spec 为准**，不要即兴发挥、不要"这次特殊"
- **S2 只做 C4 的 Context + Container；S3 才做 Component 内部** —— 跨 Container 的归 S2，容器内部的归 S3
- spec **沉默处** → **问用户**，不要自行决定
- 调别的技能**一律走 Skill 工具、按 id 写**（拷问 = `grill-with-docs` / `grilling`，落计划 = `planning-with-files-zh`，审查 = `code-review-expert`，收缩 = `ponytail:ponytail-review`）；**不要**试图"敲斜杠命令"
- **不要**经过 `grill-me`（7 行空壳，且 `disable-model-invocation` → 模型根本调不到）

## 现在开始

调 Skill `caveman` → 读 spec → 从 S1 起执行（**每步先打阶段横幅**）→ S1 用 `grill-with-docs`，下限满后每轮末弹续期框 → 每阶段末做复盘 + 逐条风险确认 → 顺序推进到 S6。
