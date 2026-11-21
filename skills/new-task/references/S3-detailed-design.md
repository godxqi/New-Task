# S3 详细设计

**目标**：把 S2 的架构落到 Container 内部：模块、接口契约、数据结构、算法边界，并给 S4 一份工作项建议。
**分界**：C4 的 **Component 层**——Container 内部怎么造。跨 Container 的归 S2，容器内部的归 S3。
**产物目录**：`02_DetailedDesign/output/`
**计划目录**：`.planning/plan2_DetailedDesign/`

## 开场

1. 读 S1 / S2 的 `output/`（尤其 `IF` / `DM` / `05-architecture.md`）。
2. 建临时计划 `plan2_DetailedDesign`，切 `.active_plan`。
3. 打 S3 横幅。

## 子步

所有条目按 `artifact-templates.md` 的 `DS` 字段写。

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

### S3-5 工作项建议（交接，不写计划）

- 产出 `02_DetailedDesign/output/work-items.md`：建议工作项，字段见 `artifact-templates.md` 的「编码工作项建议清单」。
- 每条写明：输入 `DS` / `IF` / `TC`、触及文件、依赖。
- **不写进计划、不写审查待办行** —— 那些在 S4-1 定稿。

## 收尾

- 复盘拷问（`grilling` 固定一轮，对象 = 详设产物）：抓接口与数据不一致、跨模块契约漂移、边界漏项。
- 逐条风险确认（细节风险）。
- ID 链检查：每个 `IF` / `DM` 有对应 `DS`；每条 `DS` 挂到 `REQ`。
- **人工确认**：问"详设完成，是否切到 `plan3_Coding` 并 `/clear`？"
  - 首项「切换并建议 /clear」(推荐) / 「切换但不 clear」/「先停」。
