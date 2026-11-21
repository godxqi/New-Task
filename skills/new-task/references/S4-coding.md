# S4 编码

**目标**：按 S3 的 `DS` 与工作项建议落代码，每个工作项审一次，结论可追。
**产物目录**：`03_Coding/output/`
**计划目录**：`.planning/plan3_Coding/`

## S4-1 建编码计划（阶段开始时）

1. 确认**是 git 仓库**；不是 → **停下来告知用户**，不跳过（`code-review-expert` 依赖 diff）。
2. 建临时计划 `plan3_Coding`，切 `.active_plan`。
3. 读 S3 的 `02_DetailedDesign/output/`：
   - 把「工作项建议」落成正式 `WI-1..n`：输入 `DS` / `TC`、触及文件、依赖、验收。
   - **在这里写审查待办行**（每个 `WI` 一条 `RV-n`），格式见 `artifact-templates.md`。
4. 计划只写本阶段：目标、工作项、审查行、风险表。不写测试 / 审查阶段的计划。

## 执行

- 每个工作项开始前**重读计划对应段落**（硬纪律，不押在 hook 上）。
- 编码纪律见 `workflows/task-planning.md` 的「编码纪律（karpathy-guidelines）」。
- 遇到审查行即调 **Skill `code-review-expert`**（要有 diff）：
  - 审查结论回写 `findings.md`；
  - **按结论逐条修复**；**不再按等级统一全修**；
  - 未修复的条目必须进风险表拿出口（接收 / 解决 / 重新确认），不许静默放过。
- **每条审查行都必须真调技能**，不得"沿用上次口径"；确无 diff 的工作项写「无 diff，跳过」，不假装审过。
- 最后一个工作项的审查处理完，S4 才算完成。

## 收尾

- 复盘拷问（`grilling` 固定一轮，对象 = 本阶段 diff + findings）：抓漏测、越界改动、与 `DS` 不一致。
- 逐条风险确认（代码级风险）。
- **人工确认**：问"编码完成，是否切到 `plan4_Test` 并 `/clear`？"
  - 首项「切换并建议 /clear」(推荐) / 「切换但不 clear」/「先停」。
