# S4 编码

**目标**：按 S3 的 `DetailedDesign` 与工作项建议落代码；每个 CodeUnit **先审查、后提交**；全部完成后收缩。
**计划目录**：`.planning/plan4_Coding/`
**产物目录**：`.planning/plan4_Coding/output/`

## 代码根与基线

- **代码根 = 与 `.planning/` 同级的目录**，默认 `<task-id>/src/`；S4-1 向用户确认。
- `.git` 在 `<task-id>/`；基线由 bootstrap 记录：无提交的仓库做了空基线，已有提交的仓库记当前 HEAD。**以计划里记的 hash 为准**，不要假设一定存在空提交。
- **不要 `git add .`**；只 add 代码根。`.planning` 不混进代码审查。

## S4-1 建编码计划

1. 确认代码根与基线提交（不是仓库 / 没有基线 → 停下告知）。
2. **问用户一次**："本阶段所有审查一律 Fix all？"——拿到授权后，S4-3 才由 agent 代选 Fix all；没拿到就逐个 CodeUnit 按用户选的档位，不静默覆盖技能的安全规则。
3. **不新建计划**；读 active plan，把临时骨架复写成正式计划。
4. 读 S3 的 `output/`：
   - 把 `work-items.md` 落成正式 `CodeUnit-1..n`：输入 `DetailedDesign`（可加 `Interface`）、触及文件、依赖、验收。
   - **在这里写审查待办行**（每个 `CodeUnit` 一条 `Review-n`）。
5. 计划只写本阶段：目标、工作项、审查行、风险表。

## S4-2 逐工作项实施

- 每个 CodeUnit 开始前重读计划对应段落。
- 按本节末尾的 **karpathy-guidelines** 执行。
- **每个 CodeUnit 都必须产生 diff**；没有 → 停下来告知，不许跳过。

## S4-3 逐工作项审查 → 提交

1. **先清工作树**：把 `.planning/plan4_Coding` 的改动单独提交（`git add .planning/plan4_Coding && git commit -m "plan: CodeUnit-n"`；无改动则跳过），让工作树只剩代码。
2. 调 **Skill `code-review-expert`**，并在调用提示里**明确传入范围**：只审 `git diff -- <代码根>`，**忽略 `.planning/`**。
3. 它默认弹「Fix all / P0-P1 only / 不改」——**S4-1 已授权 → agent 代选 Fix all（P0~P3 全修）；未授权 → 按用户选的档位，不静默覆盖技能规则**。
4. 结论回写 `findings.md`；拒绝修复的写明理由，并进风险表拿出口。
5. 修完后**再提交代码**：`git add <代码根> && git commit -m "CodeUnit-n: <一句话>"`。
6. 每条审查行都必须真调技能，不得"沿用上次口径"。

## S4-4 全部 CodeUnit 完成后收缩 → 收尾

- 调一次 `ponytail:ponytail-review`（吃 `git diff <基线>..HEAD -- <代码根>`），按意见修复。
- 修复后提交：`git add <代码根> && git commit -m "chore: shrink"`。
- 复盘拷问（`grilling` 固定一轮，对象 = 本阶段代码 + findings）。
- 逐条风险确认（代码级风险）。
- 实施链检查：每个 `DetailedDesign` 有 `CodeUnit`，每个 `CodeUnit` 有 `Review`。
- 问："编码完成，是否切到 `plan5_Test`？"
- 用户确认 → **更新当前计划**为「本阶段已完成，下一步 plan5」；**更新 `plan5_Test` 的恢复入口**（已完成：S4；下一步：S5-0 范围、环境与策略；输入：代码根 + S1/S3 `output/`）；`set-active-plan.sh plan5_Test`。
- **提醒提交**：`git add .planning/plan4_Coding .planning/plan5_Test && git commit -m "S4: plan"`。
- **额外提醒**：代码是本阶段核心产物，未提交会影响 S5/S6 的审查与对比。
- 提示**强制 `/clear`** 后输入 `/new-task 继续`。

---

## karpathy-guidelines（S4 编码纪律，全文）

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.
- Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```
