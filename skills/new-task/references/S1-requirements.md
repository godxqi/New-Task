# S1 需求分析

**目标**：先问清功能需求，再问清非功能需求并做规模估算，产出需求、NFR、估算、术语、本阶段计划与风险表。
**计划目录**：`.planning/plan0_RequirementsConfirm/`
**产物目录**：`.planning/plan0_RequirementsConfirm/output/`

## 开场（Bootstrap，只在 S1 做一次）

1. `.planning/.active_plan` 已存在 → 走**继续任务**分支，不新建。
2. 用户给 task 名（没给就问）→ 确认 **ASCII slug**（`[A-Za-z0-9._-]+`）→ `mkdir -p <task-id> && cd <task-id>`（**全程唯一一次 cd**）。
3. 检查 git：
   - 不是仓库 → `git init`。
   - 确认 `git config user.name` / `user.email` 已配置；缺 → 停下来让用户配置（不擅自设全局）。
   - 若仓库**没有任何提交** → `git commit --allow-empty -m "chore: baseline"`。
   - 若仓库**已有提交** → **不建空提交**，记当前 `git rev-parse HEAD` 为基线。
   - 把基线 hash 写进七阶段计划。
4. **一次性建好七个阶段的计划骨架**：对 `plan0_RequirementsConfirm` … `plan6_Delivery`：
   - `mkdir -p .planning/<plan>/output`
   - `cp -n "$HOME/.claude/skills/planning-with-files-zh/templates/task_plan.md" "$HOME/.claude/skills/planning-with-files-zh/templates/findings.md" "$HOME/.claude/skills/planning-with-files-zh/templates/progress.md" .planning/<plan>/`
   - 写最小 `task_plan.md`：恢复入口 + 子步占位（全部 `pending`）+ 基线提交号。
   - **子步占位按各阶段 `references/S*.md` 的标题生成**：S1-1..S1-4、S2-1..S2-7、S3-1..S3-5、S4-1..S4-4、S5-1..S5-4、S6-1..S6-3、S7-1..S7-3。
5. `sh "$HOME/.claude/skills/planning-with-files-zh/scripts/set-active-plan.sh" plan0_RequirementsConfirm`
6. `sh "$HOME/.claude/skills/planning-with-files-zh/scripts/resolve-plan-dir.sh"` → 必须等于 `.planning/plan0_RequirementsConfirm`，否则**停**。

> 唯一创建者是 bootstrap；后续阶段不再 `mkdir` / `cp` / `set-active-plan`（切计划门只更新恢复入口并换指针）。

临时 `task_plan.md` 的恢复入口：

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

## S1-1 功能需求拷问 —— `grill-with-docs`

**共四轮**，每轮用弹框（规则见索引「取舍弹框」）。

| 轮次 | 做什么 |
|---|---|
| **第 1 轮 直接提问** | 系统要做什么？核心功能、MVP 边界、谁用、哪些明确不做 |
| **第 2 轮 补充提问** | 补第 1 轮漏掉的角色、异常路径、外部依赖、边界情况 |
| **第 3 轮 挑战前两轮** | 找反例、被忽略的选项、过度声称、自相矛盾 |
| **第 4 轮 问是否再次拷问** | 推荐跟随 frontier；选「再来一轮」→ **固定加一轮「补充提问」**，再弹本问；选「不用了」→ 进 S1-2 |

**产出**：`output/requirements.md`，`Requirement-1..n`。

## S1-2 非功能需求拷问 —— `grill-with-docs`

**共四轮，固定角度**，每轮用弹框。

| 轮次 | 角度 | 必须问的问题 |
|---|---|---|
| **第 1 轮** | 不能逾越的边界 | 规模多大？用户 / 数据 / 峰值？约束？时间 / 预算 / 合规？ |
| **第 2 轮** | 要做的有多好_1 | 读多写少还是写多读少？一致性要求？能容忍短暂不一致吗？ |
| **第 3 轮** | 要做的有多好_2 | 增长预期？平缓还是爆发？各部分失败的代价？ |
| **第 4 轮** | 有哪几种搭法 | 每个方案各拿什么换什么？（候选方案 + 取舍） |

- **四轮固定，不弹续期框。**
- **第 1 轮问完规模后，就地做规模估算**（原 S2-1 移到这里）：写 QPS、读 QPS、峰值系数、存储 / 年、读写比。锚点见 `architecture-principles.md` §8。
- **产出**：
  - `output/nfr.md`：边界 / 质量_1 / 质量_2 / 搭法（`NonFunctionalRequirement-1..n` + 候选方案表）
  - `output/estimation.md`：规模估算（字段见 `artifact-templates.md`）

## S1-3 落阶段计划

**只写本阶段的事**：

- 本阶段目标
- 子步状态（`### 阶段 S1-1：功能需求拷问` / `S1-2` / `S1-3` / `S1-4`）
- 产出清单（requirements / nfr / estimation / GLOSSARY / ADR）
- 决策与 `ArchDecisionRecord` 索引
- 风险表（按 `artifact-templates.md`）

**不写**实施计划、工作项、审查行。落盘后跑 `check-complete.sh --validate`。

## S1-4 复盘拷问 + 风险确认

- `grilling` 固定一轮，对象 = 需求、NFR、估算与本阶段计划。
- 翻出重大错误 → 回 S1-1 / S1-2 / S1-3 改，改完补一次本段。
- 逐条风险确认（接收 / 解决 / 重新确认）。

## 收尾（切计划门）

1. 风险给完出口后，问："S1 完成，是否切到 `plan1_ArchitectureDesign`？"
2. 用户确认 → **更新当前计划**为「本阶段已完成，下一步 plan1」。
3. **更新 `plan1_ArchitectureDesign/task_plan.md` 的恢复入口**（已完成：S1；下一步：S2-1 质量属性；输入：S1 `output/`）。
4. `set-active-plan.sh plan1_ArchitectureDesign`。
5. **提醒提交**：`git add .planning/plan0_RequirementsConfirm .planning/plan1_ArchitectureDesign && git commit -m "S1: requirements"`。
6. 告诉用户：**`/clear` 强制**；清空后输入 `/new-task 继续`。
