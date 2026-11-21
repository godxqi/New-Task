# S1 需求分析

**目标**：把模糊需求问清楚，产出需求条目、术语表、本阶段计划与风险表。
**产物目录**：`00_RequirementsConfirm/output/`
**计划目录**：`.planning/plan0_RequirementsConfirm/`

## 开场（只在 S1 做一次）

1. 确定任务根目录 `<task-id>/`（用户给名字；cwd 必须在这里）。
2. 检查 git：不是仓库 → **停下来告知用户**，问是否 `git init`；**不许跳过**（S4/S6 的审查都依赖 diff）。
3. 建**临时计划**：`mkdir -p .planning/plan0_RequirementsConfirm && cp -n <templates> ...`，写一份最小 `task_plan.md`（只有目标 + 子步占位），
   `set-active-plan.sh plan0_RequirementsConfirm`。**先让 hook 有东西可注入**，讨论完再复写成正式计划。
4. 打 S1 横幅，调 Skill `grill-with-docs`。

## S1-1 拷问 —— `grill-with-docs`

- 下限 2 轮，无上限；每轮用弹框（规则见 `workflows/task-planning.md` 的「取舍弹框」）。
- 第 1 轮正常拷问：功能边界、用户与规模、质量与约束、灵魂六问。
- 第 2 轮**固定挑战第 1 轮结论**：找反例、被忽略的选项、过度声称。
- 下限满后每轮末弹续期框；frontier 空了也照弹；AI 不替用户判断"拷够了"。
- **产出**（`00_RequirementsConfirm/output/`）：
  - `requirements.md`：`REQ-1..n` + `NFR-1..n` + 关键约束（字段见 `artifact-templates.md`）
  - `GLOSSARY.md`：术语表
  - `adr/`：拷问中凝固的决策（满足 ADR 三条才写）

## S1-2 落阶段计划 —— `planning-with-files-zh`

**只写本阶段该做的事**，不提前写架构 / 编码：

- 本阶段目标
- 子步状态（`### 阶段 S1-1：拷问` / `S1-2` / `S1-3`，每条一个 `**状态：**`）
- **本阶段产出清单**（requirements / GLOSSARY / ADR）
- 决策与 `ADR` 索引
- 风险表 `R1..Rn`（每条三列 + 出口）

**不写**：实施计划、工作项、审查待办行 —— 那些在 S3-5 / S4 才定。

落盘后跑 `check-complete.sh --validate`，不过就改到过。

## S1-3 复盘拷问 + 风险确认

- 第一段：`grilling` 固定一轮，对象 = 需求条目与本阶段计划；专抓自相矛盾、过度声称、写错前提。
- 翻出重大错误 → 回 S1-1 / S1-2 改，改完补一次本段。
- 第二段：逐条风险确认（接收 / 解决 / 重新确认）；每条拿到出口才进 S2。

## 收尾

- 风险确认给完出口后，问一句：**"S1 完成，是否切到 `plan1_ArchitectureDesign` 并 `/clear`？"**
  - 首项「切换并建议 /clear」(推荐) / 「切换但不 clear」/「先停」。
- 用户确认后再建 S2 的临时计划、切 `.active_plan`；**切目录不是自动的**。
