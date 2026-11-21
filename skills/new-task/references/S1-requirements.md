# S1 需求分析

**目标**：把模糊需求问清楚，产出需求条目、术语表、本阶段计划与风险表。
**计划目录**：`.planning/plan0_RequirementsConfirm/`
**产物目录**：`.planning/plan0_RequirementsConfirm/output/`

## 开场（Bootstrap，只在 S1 做一次）

1. `.planning/.active_plan` 已存在 → 走**继续任务**分支，不新建。
2. 用户给 task 名（没给就问）→ `mkdir -p <task-id> && cd <task-id>`（**全程唯一一次 cd**）。
3. 检查 git：不是仓库 → 问是否 `git init`（在 `<task-id>/` 下）；**不许跳过**。
4. `mkdir -p .planning/plan0_RequirementsConfirm/output`
5. `cp -n "$HOME/.claude/skills/planning-with-files-zh/templates/task_plan.md" "$HOME/.claude/skills/planning-with-files-zh/templates/findings.md" "$HOME/.claude/skills/planning-with-files-zh/templates/progress.md" .planning/plan0_RequirementsConfirm/`
6. `sh "$HOME/.claude/skills/planning-with-files-zh/scripts/set-active-plan.sh" plan0_RequirementsConfirm`
7. `sh "$HOME/.claude/skills/planning-with-files-zh/scripts/resolve-plan-dir.sh"` → 必须等于 `.planning/plan0_RequirementsConfirm`，否则**停**。

临时 `task_plan.md` 顶部写恢复入口：

```md
## 恢复入口（/clear 后先读这里）
- 你是 new-task 流程的 **S1 需求分析**，不是新任务。
- 先读：SKILL.md → workflows/task-planning.md → references/S1-requirements.md
- 再读输入：无（首个阶段）
- 已完成：bootstrap
- 下一步：S1-1 拷问
- 未决风险：无
- 开场动作：调 Skill `caveman` → 打 S1 横幅 → 继续
```

然后打 S1 横幅，调 `grill-with-docs`。

## S1-1 拷问 —— `grill-with-docs`

- 下限 2 轮，无上限；每轮用弹框（规则见索引的「取舍弹框」）。
- 第 1 轮：功能边界、用户与规模、质量与约束、灵魂六问。
- 第 2 轮固定挑战第 1 轮结论。
- 下限满后每轮末弹续期框；frontier 空了也照弹。
- 产出到 `.planning/plan0_RequirementsConfirm/output/`：
  - `requirements.md`：`REQ-1..n` + `NFR-1..n` + 关键约束
  - `GLOSSARY.md`
  - `adr/`（满足 ADR 三条才写）

## S1-2 落阶段计划

**只写本阶段的事**：

- 本阶段目标
- 子步状态（`### 阶段 S1-1：拷问` / `S1-2` / `S1-3`）
- 本阶段产出清单（requirements / GLOSSARY / ADR）
- 决策与 `ADR` 索引
- 风险表（按 `artifact-templates.md`）

**不写**实施计划、工作项、审查行。落盘后跑 `check-complete.sh --validate`。

## S1-3 复盘拷问 + 风险确认

- `grilling` 固定一轮，对象 = 需求条目与本阶段计划。
- 翻出重大错误 → 回 S1-1 / S1-2 改，改完补一次本段。
- 逐条风险确认（接收 / 解决 / 重新确认）。

## 收尾（切计划门）

1. 风险给完出口后，问："S1 完成，是否切到 `plan1_ArchitectureDesign`？"
2. 用户确认 → 建 `.planning/plan1_ArchitectureDesign/output/`，写临时计划（含恢复入口），`set-active-plan.sh plan1_ArchitectureDesign`。
3. 告诉用户：**`/clear` 是强制的**；清空后输入 `/new-task 继续`。
4. 用户 `/clear` 后的第一条会走「继续任务」分支。
