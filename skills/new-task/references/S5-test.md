# S5 测试

**目标**：用两层测试验证。**契约层**验 `DetailedDesign` 契约；**功能层**验 `Requirement` 的黑盒行为。两层都过才算完成。
**计划目录**：`.planning/plan5_Test/`
**产物目录**：`.planning/plan5_Test/output/`
**方法来源**：`vendor/qa/`（qa-skills 0.9.0 裁剪子集，MIT）。规则细节见 `S5-test-design.md`。

**调用方式**：`vendor/qa/` 是随附文档与脚本，**不是注册 skill**。
用 `Read` 按路径读 `vendor/qa/skills/<name>/SKILL.md`，**不要** `Skill(qa)` / `Skill(test-strategy)`；
脚本用 Bash 直接跑 `scripts/*.py`。vendor 内部 `../core/...` 的相对路径按目录结构解析。

## 开场

1. 读 active plan、S1 `requirements.md`、S3 `detailed-design.md` / `test-points.md`。**不读 S4 代码**——先写用例，后读实现。
2. **不新建计划**；读 active plan，把临时骨架复写成正式计划。
3. 重调 `caveman`，打 S5 横幅。

## S5-0 范围、环境与策略

1. **判定项目类型**（决定执行层，不决定是否测试）：

   | 类型 | 契约层 | 功能层执行 |
   |---|---|---|
   | 库 / 纯脚本 | 必做 | agent 写 CLI/函数级黑盒脚本 |
   | CLI | 必做 | 同上，按命令入口 |
   | HTTP / API | 必做 | `vendor/qa/skills/api-testing`（pytest + requests） |
   | Web | 必做 | `vendor/qa/skills/automated-e2e-testing`（Playwright） |

2. **环境门禁**（缺就停，不猜、不伪造）：
   - agent 负责按项目命令启动被测服务；起不来 → 停下告知。
   - 账号 / token / 测试数据由用户提供；缺 → `AskUserQuestion` 问，拿不到则本轮功能层记 `not-run` + 原因 + `Risk` 出口。
   - 运行依赖（Playwright / pytest / requests）缺失 → 问用户；**作为项目依赖安装，不是全局装**。

3. **跑测试策略**：按 `vendor/qa/skills/test-strategy/SKILL.md` 产出 `output/test-strategy.md`：
   - Risk Map（每条风险挂证据）；
   - `functional_scope`：功能 / 边界 / 异常 / 权限 / 状态 / 数据一致性；
   - `type_scope`：十轴逐轴 `include / exclude / handoff`，exclude 必写理由；
   - 本任务实际只保留有信号的轴，其余全部 `exclude` 并写「无信号」。
4. 范围取舍触及真实代价 → 强制 `AskUserQuestion`。
5. 更新恢复入口：已完成 S5-0；下一步 S5-1 写用例；输入：S1/S3 产物 + `test-strategy.md`。

## S5-1 写两层用例

**先写用例，不读实现。** 期望值只准来自 `DetailedDesign` / `Requirement`；不得从代码反推。

1. **每个 `TestPoint` 至少一条 `TestCase`**：契约层来源 `DetailedDesign`，功能层来源 `Requirement`。
2. **功能层覆盖**：`test-strategy.md` 纳入的每个功能域 / 每条 Critical、High 风险至少一条 `TestCase`。
3. 按 `S5-test-design.md` 的格式写 `output/test-cases.md`（markmap，ID = `TestCase-n`）：
   - 头部四块：功能简介 / 环境与账号 / 术语表 / 图例；
   - 每个用例：`验证`、`层`、`前置条件`、`操作步骤`、`预期结果`。
4. 边界必须覆盖：空、重复、超时、部分失败、乱序；异步行为写判定时限。
5. 抽 schema：`python "${NEW_TASK_SKILL_DIR:-$HOME/.claude/skills/new-task}/scripts/extract_case_schema.py" output/test-cases.md output/test-cases.schema.yaml`。
6. 跑 lint：`python "${NEW_TASK_SKILL_DIR:-$HOME/.claude/skills/new-task}/scripts/case_lint.py" output/test-cases.md`，退出码 1 必须修复后重跑。
7. **实现偏离扫描（写完用例后才做）**：读 S4 代码与设计对照；不一致 → 记 `coverage-gaps.md` 或 `Risk`，**不回写期待值**。
8. 更新恢复入口：下一步 S5-2 用例审查。

## S5-2 用例独立审查

1. **干净 subagent，只读**：输入 = S1 `requirements.md` + S3 `detailed-design.md` / `test-points.md` + `test-strategy.md` + `test-cases.md`。**不给代码根、不给写用例时的推理**。
2. 按 `S5-test-design.md` 的审查清单逐条检查。
3. 输出：在 `test-cases.md` 末尾追加「审查记录」；未解决项进 `coverage-gaps.md` / `Risk`。**subagent 不改用例**。
4. 主 agent 按意见修 → 重抽 schema → 重跑 lint。
5. **提交计划**：`git add .planning/plan5_Test && git commit -m "plan: S5"`。

## S5-3 写测试代码 + 审查 + 提交

1. 每条 `TestCase` 对应一个测试；测试名带 `TestCase-n`，便于结果回填。
2. 契约层：测试放在代码根的测试目录，用项目既定框架。
3. 功能层：按项目类型读对应 vendor skill 的工程约定（Page Object / 请求封装 / 证据收集）。
4. 调 `code-review-expert`，**范围只给测试代码**：`git diff -- <测试文件>`，忽略 `.planning/`。Fix 授权沿用 S4-1；未授权则逐项问。
5. 修完提交：`git add <测试文件> && git commit -m "tests: S5"`。

## S5-4 执行

1. **runner 规则**（不预设工具）：项目已有测试配置 → 用它；没有 → 用语言内置 runner；仍没有 → `assert` 自检脚本。
2. 跑契约层全量；功能层按类型执行，**至少一条主路径冒烟**。
3. 结果落 `output/test-results.md`：`TestCase-n | 状态 | 证据 / 实际命令 | 出口或原因`。
   - 状态只取 `pass / fail / not-run`；
   - **必须记录实际命令**，S6 据此复现。
4. 对着契约验，不是对着实现验。

## S5-5 缺口 + 重跑 + 收尾

1. 缺口落 `output/coverage-gaps.md`；**无缺口也写「无缺口」，文件必须存在**。
2. 每个缺口挂具体 `TestPoint-n`；缺用例 / 用例没验契约 / 边界没覆盖 → 默认必须补。
3. 补齐后**重抽 schema、重跑 lint、重跑全量**，更新 `test-results.md`；新补用例必须在结果里。
4. `fail` 修到 `pass`，修不了 → `Risk` 出口；`not-run` 写明原因并给出口。
5. 跑 `validate.sh`，要求 0 退出。
6. 复盘拷问（`grilling` 固定一轮，对象 = 策略、用例、结果）。
7. 逐条风险确认。
8. 问："测试完成，是否切到 `plan6_Review`？"
9. 用户确认 → 更新当前计划为「本阶段已完成，下一步 plan6」；更新 `plan6_Review` 恢复入口（已完成：S5；下一步：S6-1 对账；输入：前五阶段 `output/` + 代码根）；`set-active-plan.sh plan6_Review`。
10. **提醒提交**：`git add .planning/plan5_Test .planning/plan6_Review && git commit -m "S5: plan"`。
11. **额外提醒**：测试代码不提交，S6 对账与最终 diff 会失真。
12. 提示**强制 `/clear`** 后输入 `/new-task 继续`。

## 本阶段不做

- 不改生产代码让测试变绿（要改 → 回 S3/S4，见回归规则）。
- 不做 Bug 根因分析、回归清单、测试报告（这些不在 S5）。
- 不引入 vendor 之外的 QA 框架；不新增运行时依赖。
