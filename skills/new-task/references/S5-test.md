# S5 测试

> **骨架，待定稿**：以下是最小骨架，待与用户细化。

**目标**：用测试验证 `DS` 契约，而不是只验证"跑通了"。
**计划目录**：`.planning/plan4_Test/`
**产物目录**：`.planning/plan4_Test/output/`

## 开场

1. 读 S3 的 `test-points.md` / `DS` 与 S4 的代码。
2. **不新建计划**；读 active plan，把临时骨架复写成正式计划。
3. 打 S5 横幅。

## 子步

### S5-1 写测试用例

- 按 `test-points.md` 写正式 `TC-1..n`，落 `output/test-cases.md`（字段见 `artifact-templates.md`）。
- 每个 `TC` 标明验证的 `TP`（可加 `DS` / `REQ` / `IF`）。
- 覆盖边界：空、重复、超时、部分失败、乱序。

### S5-2 跑测试

- 跑全量，结果落 `output/test-results.md`（pass / fail / not-run）。
- **对着契约验，不是对着实现验**。

### S5-3 覆盖缺口

- 缺口落 `output/coverage-gaps.md`；缺 `TC`、`TC` 没验证契约、边界没覆盖 → **默认必须补**。
- 用户要跳过 → 缺口必须进风险表并拿到出口；不能一次弹框豁免。

### S5-4 测试代码复审 → 提交 → 收尾

1. **先清工作树**：把 `.planning/plan4_Test` 的改动单独提交（`git add .planning/plan4_Test && git commit -m "plan: S5"`），让工作树只剩测试代码。
2. 调 `code-review-expert`，**明确传入范围**：只审 `git diff -- <测试文件>`，忽略 `.planning/`；「Fix all / …」问询由 **agent 代为选 Fix all**（P0~P3 全修）。
3. 修完后提交：`git add <测试文件> && git commit -m "tests: <一句话>"`。
3. 复盘拷问（`grilling` 固定一轮，对象 = 测试清单与结果）。
4. 逐条风险确认。
5. 问："测试完成，是否切到 `plan5_Review`？"→ **更新当前计划**为「本阶段已完成，下一步 plan5」；**更新 `plan5_Review` 的恢复入口**（已完成：S5；下一步：S6-1 对账；输入：前五阶段 `output/` + 代码根）；`set-active-plan.sh plan5_Review`。
6. **提醒提交**：`git add .planning/plan4_Test .planning/plan5_Review && git commit -m "S5: plan"`。
7. **额外提醒**：测试代码不提交，S6 对账与最终 diff 会失真。
8. 提示**强制 `/clear`** 后输入 `/new-task 继续`。
