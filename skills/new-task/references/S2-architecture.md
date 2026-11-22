# S2 架构设计

**目标**：产出可被 S3 消费的架构方案：质量属性、接口、数据模型、全景图、瓶颈、ADR。
**依据**：`references/architecture-principles.md`（已内联）。
**分界**：只做 **C4 的 Context + Container 层**；Container 内部留给 S3。
**计划目录**：`.planning/plan1_ArchitectureDesign/`
**产物目录**：`.planning/plan1_ArchitectureDesign/output/`

## 开场

1. 读 S1 的 `output/`：`requirements.md`、`nfr.md`、`estimation.md`、`GLOSSARY.md`、`adr/`。
2. **不新建计划**（bootstrap 已建好 `plan1_ArchitectureDesign`）；读 active plan，把临时骨架复写成正式计划。
3. 更新恢复入口后，打 S2 横幅。

恢复入口示例：

```md
## 恢复入口（/clear 后先读这里）
- 你是 new-task 流程的 **S2 架构设计**，不是新任务。
- 先读：SKILL.md → workflows/task-planning.md → references/S2-architecture.md
- 再读输入：.planning/plan0_RequirementsConfirm/output/
- 已完成：S2-1、S2-2
- 下一步：S2-3 数据模型
- 未决风险：R1（待用户出口）
- 开场动作：调 Skill `caveman` → 打 S2 横幅 → 继续
```

## 子步

所有产物字段见 `artifact-templates.md`；所有图用 **ASCII**。

### S2-1 质量属性

- 读 S1 的 `nfr.md`（边界 + `NFR-1..n`）与 `estimation.md`；**细化同一批 `NFR-n`**（补可度量目标、冲突、优先级），新增属性才续编号。
- 十条属性逐项过（`architecture-principles.md` §3）。产出 `output/quality-attributes.md`。判据：每个目标带数字。

### S2-2 用例与接口边界

- 黑盒动作清单，挑 1~2 条主航道。产出 `output/interfaces.md`，`IF-1..n`。
- 判据：主航道标出，每个动作挂到 `REQ`。

### S2-3 数据模型与存储

- 概念实体 + 关系；每类数据选存储类型 + 为什么（看访问形态）。
- 产出 `output/data-model.md`，`DM-1..n`。判据：每行有存储类型和理由。

### S2-4 架构全景

- 先 Context 再 Container；每个组件写「做什么 + 为什么需要」；画 2~3 条关键数据流。
- 图规则见 §6。产出 `output/architecture.md`。

### S2-5 灵魂部件与接缝

- 挑 1~2 个灵魂部件，选模式，说明为什么；标出最可能被换的接缝。
- 并入 `output/architecture.md`。判据：模式名 + 理由 + 接缝清单。

### S2-6 瓶颈与扩展

- 涨 100 倍，第一 / 第二 / 第三瓶颈；每个写现象 → 破解 → 触发条件。
- 产出 `output/bottlenecks.md`。判据：至少两条瓶颈，各带触发条件。

### S2-7 取舍与 ADR

- S1 `nfr.md` 的「搭法」表是 ADR 候选；每个真正的岔路口一份 ADR 六块，写到 `output/adr/`，计划里留索引行。
- 自检：看不到取舍 = 没想清楚。

## 收尾（切计划门）

- 复盘拷问（`grilling` 固定一轮，对象 = S2 全部产物）。
- 逐条风险确认。
- 设计链检查：`REQ → IF → DM → DS`（DS 在 S3 补）。
- 问："架构完成，是否切到 `plan2_DetailedDesign`？"→ **更新 `plan2_DetailedDesign` 的恢复入口**（已完成：S2；下一步：S3-1 组件划分；输入：S2 `output/`）→ `set-active-plan.sh plan2_DetailedDesign`。
- **提醒提交**：`git add .planning/plan1_ArchitectureDesign && git commit -m "S2: architecture"`。
- 提示**强制 `/clear`** 后输入 `/new-task 继续`。
