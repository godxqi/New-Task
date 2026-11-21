# S2 架构设计

**目标**：产出可被 S3 消费的架构方案：估算、质量属性、接口、数据模型、全景图、瓶颈、ADR。
**依据**：`references/architecture-principles.md`（已内联）。
**分界**：只做 **C4 的 Context + Container 层**；Container 内部留给 S3。
**计划目录**：`.planning/plan1_ArchitectureDesign/`
**产物目录**：`.planning/plan1_ArchitectureDesign/output/`

## 开场

1. 读 S1 的 `output/`（requirements / GLOSSARY / adr）。
2. `mkdir -p .planning/plan1_ArchitectureDesign/output`（若收尾时已建则跳过）。
3. 写临时计划（含恢复入口），`set-active-plan.sh plan1_ArchitectureDesign`。
4. 打 S2 横幅。

恢复入口示例：

```md
## 恢复入口（/clear 后先读这里）
- 你是 new-task 流程的 **S2 架构设计**，不是新任务。
- 先读：SKILL.md → workflows/task-planning.md → references/S2-architecture.md
- 再读输入：.planning/plan0_RequirementsConfirm/output/
- 已完成：S2-1 … S2-3
- 下一步：S2-4 数据模型
- 未决风险：R1（待用户出口）
- 开场动作：调 Skill `caveman` → 打 S2 横幅 → 继续
```

## 子步

所有产物字段见 `artifact-templates.md`；所有图用 **ASCII**。

### S2-1 估规模

- 写 QPS、读 QPS、峰值系数（2~5 倍）、存储 / 年、读写比；锚点见 `architecture-principles.md` §8。
- 产出 `output/01-estimation.md`。判据：每个数有推导，读写比明确。

### S2-2 质量属性

- 灵魂六问答案 → 质量属性表：属性 / 可度量目标 / 为什么重要 / 和谁冲突。
- 十条属性逐项过（§3）。产出 `output/02-quality.md`。判据：每个目标带数字。

### S2-3 用例与接口边界

- 黑盒动作清单，挑 1~2 条主航道。产出 `output/03-interfaces.md`，`IF-1..n`。
- 判据：主航道标出，每个动作挂到 `REQ`。

### S2-4 数据模型与存储

- 概念实体 + 关系；每类数据选存储类型 + 为什么（看访问形态）。
- 产出 `output/04-data-model.md`，`DM-1..n`。判据：每行有存储类型和理由。

### S2-5 架构全景

- 先 Context 再 Container；每个组件写「做什么 + 为什么需要」；画 2~3 条关键数据流。
- 图规则见 §6。产出 `output/05-architecture.md`。

### S2-6 灵魂部件与接缝

- 挑 1~2 个灵魂部件，选模式，说明为什么；标出最可能被换的接缝。
- 并入 `output/05-architecture.md`。判据：模式名 + 理由 + 接缝清单。

### S2-7 瓶颈与扩展

- 涨 100 倍，第一 / 第二 / 第三瓶颈；每个写现象 → 破解 → 触发条件。
- 产出 `output/06-bottlenecks.md`。判据：至少两条瓶颈，各带触发条件。

### S2-8 取舍与 ADR

- 每个真正的岔路口一份 ADR 六块；写到 `output/adr/`，计划里留索引行。
- 自检：看不到取舍 = 没想清楚。

## 收尾（切计划门）

- 复盘拷问（`grilling` 固定一轮，对象 = S2 全部产物）。
- 逐条风险确认。
- 三条链检查：`REQ → IF → DM → DS`（DS 在 S3 补）。
- 问："架构完成，是否切到 `plan2_DetailedDesign`？"→ 建 `output/`、写临时计划（含恢复入口）、切 active、提示**强制 `/clear`** 后输入 `/new-task 继续`。
