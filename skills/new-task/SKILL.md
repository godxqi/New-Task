---
name: new-task
description: 讨论一个新问题（新需求 / 新改造 / 新设计）时走这条固定流程：拷问收敛 → 落三件套计划 → 复查拷问 → 逐条风险确认 → 实施 → 收缩。仅用户可斜杠调用。
disable-model-invocation: true
argument-hint: "要讨论的话题（新需求 / 新改造 / 新设计）；留空则先问你"
---

**先读 `workflows/task-planning.md`（唯一权威），然后端到端照它走。**

本目录的 `workflows/` 与 `NOTES.md` 是 `loop-me` 的工作区约定：`workflows/task-planning.md` 是 spec 的唯一权威；`NOTES.md` 只是设计素材，**执行时不要读它** —— 不要为了"规范化"改名（改名会让 `loop-me` 下次找不到它）。

## 硬约束

> 本节是**速览**：与 `workflows/task-planning.md` 冲突时**一律以 spec 为准**（速览可能滞后）。

- **先调 Skill `caveman` 再开工** —— 本流程的对话输出压缩（**例外见 spec**：阶段横幅不压）
- **拷问每轮用 `AskUserQuestion` 弹框收答案**：推荐答案放**首项**并标"(推荐)"；需要背景就写进选项的 `description`，**不要另铺长文**
- **每问末位加「解释这个问题与名词」**：命中后调 `answer-me-with-html` 出一页（**一条一页，多条命中就逐页连开**），再重弹同一问；它**不算作答**，真实答案因此最多 3 条
- **只有用户点选或明确调用 `/answer-me-with-html` 才出页** —— AI 不自行出页
- 步骤顺序、检查点位置、审查待办行与**风险表**的粒度与规格 —— **全部以 `workflows/task-planning.md` 为准**，不要即兴发挥、不要跳步、不要"这次特殊"
- **S3 有两段**（复查拷问 → **风险确认**），顺序固定、**都不可跳**；风险确认要**逐条**拿到用户的出口（**接收 / 解决 / 重新确认**），**没给完不进 S4**（软门禁：靠打勾可见 + AI 纪律，非技术强制）
- spec **沉默处**（它没写的判断）→ **问用户**，不要自行决定
- 每当你想"该做某事了"时，先确认 spec 里有没有写：写了照做，没写就问
- 调别的技能**一律走 Skill 工具、按 id 写**（拷问 = `grilling`，落计划 = `planning-with-files-zh`，审查 = `code-review-expert`，收缩 = `ponytail:ponytail-review`）；**不要**试图"敲斜杠命令"
- **不要**经过 `grill-me`（7 行空壳，且 `disable-model-invocation` → 模型根本调不到）

## 现在开始

调 Skill `caveman` → 读 spec → 从 S1 起执行（**每步先打阶段横幅**，每轮弹框）→ **S1 下限满后每轮末弹续期框**（要不要再来一轮，由用户定）→ **S3 两段跑完**（复查拷问 → 逐条风险确认，全拿到出口）→ 到 S4 停下，把计划当 Brief 交给用户。
