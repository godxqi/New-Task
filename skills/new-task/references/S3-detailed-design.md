# S3 详细设计

**目标**：把 S2 的架构落到 Container 内部：模块、接口契约、数据结构、算法边界；给 S4 工作项建议、给 S5 测试点。
**分界**：C4 的 **Component 层**——Container 内部怎么造。跨 Container 的归 S2。
**计划目录**：`.planning/plan2_DetailedDesign/`
**产物目录**：`.planning/plan2_DetailedDesign/output/`

## 开场

1. 读 S1 / S2 的 `output/`（尤其 `IF` / `DM` / `05-architecture.md`）。
2. `mkdir -p .planning/plan2_DetailedDesign/output`，写临时计划（含恢复入口），切 active。
3. 打 S3 横幅。

## 子步

条目按 `artifact-templates.md` 的 `DS` 字段写。

### S3-1 组件划分

- 对每个 Container 画 Component 图（容器内模块 + 协作）；简单容器不画。
- 每个模块写「做什么 + 为什么」，标出对外接口。

### S3-2 接口契约

- 把 `IF-1..n` 细化成签名 / 协议 / 错误码 / schema。
- 跨模块契约在此定稿；S4 不许即兴改，改就回 S3。

### S3-3 数据结构

- 把 `DM-1..n` 细化成表结构 / 字段 / 索引 / 约束 / 校验规则。
- 每个结构写清由哪个模块拥有、谁可以读写。

### S3-4 算法与边界

- 灵魂部件的内部算法、状态机、错误处理、并发与幂等策略。
- 边界情况：空、重复、超时、部分失败、乱序。

### S3-5 交接产物（不写计划、不写审查行）

- `output/work-items.md`：编码工作项建议。输入只有 `DS`（可加 `IF`），**不含 `TC`**；字段见模板。
- `output/test-points.md`：从 `DS` 的验收点推导的**测试点**；S5 据此写成正式 `TC`。
- **不写进计划、不写审查待办行** —— 工作项在 S4-1 定稿，TC 在 S5 定稿。

## 收尾（切计划门）

- 复盘拷问（`grilling` 固定一轮，对象 = 详设产物）。
- 逐条风险确认（细节风险）。
- 设计链检查：每个 `IF` / `DM` 有对应 `DS`；每条 `DS` 挂到 `REQ`。
- 问："详设完成，是否切到 `plan3_Coding`？"→ 建 `output/`、写临时计划（含恢复入口）、切 active、提示**强制 `/clear`** 后输入 `/new-task 继续`。
