# S1 需求分析

**目标**：先问清功能需求，再问清非功能需求，产出 `requirements.md` / `nfr.md` / `GLOSSARY.md` / 本阶段计划与风险表。
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
- 下一步：S1-1 功能需求拷问
- 未决风险：无
- 开场动作：调 Skill `caveman` → 打 S1 横幅 → 继续
```

然后打 S1 横幅。

## S1-1 功能需求拷问

**对象**：系统要做什么。**共四轮**，每轮用弹框（规则见索引的「取舍弹框」）。

| 轮次 | 做什么 |
|---|---|
| **第 1 轮 直接提问** | 系统要做什么？核心功能、MVP 边界、谁用、哪些明确不做 |
| **第 2 轮 补充提问** | 补第 1 轮漏掉的角色、异常路径、外部依赖、边界情况 |
| **第 3 轮 挑战前两轮** | 找反例、被忽略的选项、过度声称、自相矛盾 |
| **第 4 轮 问是否再次拷问** | "这轮完了，要不要再来一轮？"推荐跟随 frontier（空→不用了 / 非空→再来一轮）；选「再来一轮」→ **固定加一轮「补充提问」**，然后**再弹本问**；选「不用了」→ 进 S1-2 |

**产出**：`output/requirements.md`，`REQ-1..n`（字段见 `artifact-templates.md`）。

## S1-2 非功能需求拷问

**对象**：系统要做得多好、有哪些边界、有哪几种搭法。**共四轮，固定角度**，每轮用弹框。

| 轮次 | 角度 | 必须问的问题 |
|---|---|---|
| **第 1 轮** | 有哪些系统不能逾越的边界？ | 系统规模多大？现在多少用户 / 数据？峰值多少？<br>有什么约束？多少时间？多少预算？有无合规标准？ |
| **第 2 轮** | 系统要做的有多好_1？ | 系统是读多写少，还是写多读少？<br>数据一致性要求？刚写的必须立刻能读到吗？能容忍短暂不一致吗？ |
| **第 3 轮** | 系统要做的有多好_2？ | 增长预期？一年后会涨到多少？是平缓还是会爆发？<br>各部分失败的代价？这个东西挂了 / 数据丢了，后果有多严重？ |
| **第 4 轮** | 有哪几种搭法？ | 每个方案各拿什么换什么？（候选方案 + 取舍，不急着定） |

- **四轮固定，不弹续期框**；每轮问完即记录。
- **产出**：`output/nfr.md`（边界 / 质量_1 / 质量_2 / 搭法），`NFR-1..n` + 候选方案表（字段见 `artifact-templates.md`）。
- 第 4 轮的候选方案与取舍，S2-8 会正式写成 ADR。

## S1-3 落阶段计划

**只写本阶段的事**：

- 本阶段目标
- 子步状态（`### 阶段 S1-1：功能需求拷问` / `S1-2` / `S1-3` / `S1-4`）
- 本阶段产出清单（requirements / nfr / GLOSSARY / ADR）
- 决策与 `ADR` 索引
- 风险表（按 `artifact-templates.md`）

**不写**实施计划、工作项、审查行。落盘后跑 `check-complete.sh --validate`。

## S1-4 复盘拷问 + 风险确认

- `grilling` 固定一轮，对象 = 需求条目、NFR 与本阶段计划；专抓自相矛盾、过度声称、写错前提。
- 翻出重大错误 → 回 S1-1 / S1-2 / S1-3 改，改完补一次本段。
- 逐条风险确认（接收 / 解决 / 重新确认）。

## 收尾（切计划门）

1. 风险给完出口后，问："S1 完成，是否切到 `plan1_ArchitectureDesign`？"
2. 用户确认 → 建 `.planning/plan1_ArchitectureDesign/output/`，写临时计划（含恢复入口），`set-active-plan.sh plan1_ArchitectureDesign`。
3. 告诉用户：**`/clear` 是强制的**；清空后输入 `/new-task 继续`。
4. 用户 `/clear` 后的第一条会走「继续任务」分支。
