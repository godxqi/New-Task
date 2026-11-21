# S4 编码

**目标**：按 S3 的 `DS` 与工作项建议落代码；每个工作项一个提交、一次审查。
**计划目录**：`.planning/plan3_Coding/`
**产物目录**：`.planning/plan3_Coding/output/`
**编码纪律**：`D:\SKILL.md`（karpathy-guidelines）全文；本技能索引末尾也内联一份。

## 代码根目录与提交

- **代码根目录 = 与 `.planning/` 同级的目录**，默认 `<task-id>/src/`；S4-1 时向用户确认，不同就改。
- `.git` 在 `<task-id>/`（bootstrap 已 init）。
- **一个 WI 一个提交**：`WI-n: <一句话>`。
- 审查用**该 WI 自己的提交**（`git diff HEAD~1` / `git show`），**不审累计 diff**。
- 审查后修复：未推送可 `amend` 到同一提交；已推送则追加 fix 提交，并在审查行注明。

## S4-1 建编码计划

1. 确认代码根目录与 `.git`（不是仓库 → 停下告知，不跳过）。
2. `mkdir -p .planning/plan3_Coding/output`；写临时计划（含恢复入口），`set-active-plan.sh plan3_Coding`。
3. 读 S3 的 `output/`：
   - 把 `work-items.md` 落成正式 `WI-1..n`：输入 `DS`（可加 `IF`）、触及文件、依赖、验收。
   - **在这里写审查待办行**（每个 `WI` 一条 `RV-n`）。
4. 计划只写本阶段：目标、工作项、审查行、风险表。

## S4-2 逐工作项实施

- 每个 WI 开始前重读计划对应段落。
- 按 `D:\SKILL.md` 执行：先想清楚、最小实现、只改必须改的、定义可验证的成功标准。
- **每个 WI 都必须产生 diff**；没有 diff → 停下来告知，不许写"跳过"。
- 完成后提交：`WI-n: <一句话>`。

## S4-3 逐工作项审查

- 调 **Skill `code-review-expert`**，输入是**该 WI 的提交 diff**。
- 它默认会弹「Fix all / P0-P1 only / 不改」——**一律按 Fix all，P0~P3 全修**；不要每审一次停一次。
- 结论回写 `findings.md`；拒绝修复的条目必须写明理由，并进风险表拿出口。
- 每条审查行都必须真调技能，不得"沿用上次口径"。

## S4-4 收尾（切计划门）

- 复盘拷问（`grilling` 固定一轮，对象 = 本阶段 diff + findings）。
- 逐条风险确认（代码级风险）。
- 实施链检查：每个 `DS` 有 `WI`，每个 `WI` 有 `RV`。
- 问："编码完成，是否切到 `plan4_Test`？"→ 建 `output/`、写临时计划（含恢复入口）、切 active、提示**强制 `/clear`** 后输入 `/new-task 继续`。
