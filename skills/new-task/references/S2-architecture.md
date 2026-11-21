# S2 架构设计

**目标**：产出可被 S3 消费的架构方案：估算、质量属性、接口、数据模型、全景图、瓶颈、ADR。
**依据**：`references/architecture-principles.md`（已内联）。
**分界**：只做 **C4 的 Context + Container 层**；Container 内部留给 S3。
**产物目录**：`01_ArchitectureDesign/output/`
**计划目录**：`.planning/plan1_ArchitectureDesign/`

## 开场

1. 读 S1 的 `00_RequirementsConfirm/output/`（requirements / GLOSSARY / adr）。
2. 建临时计划 `plan1_ArchitectureDesign`，写最小 `task_plan.md`，切 `.active_plan`。
3. 打 S2 横幅。

## 子步

所有产物字段见 `artifact-templates.md`；所有图用 **ASCII**。

### S2-1 估规模

- 写 QPS、读 QPS、峰值系数（2~5 倍）、存储 / 年、读写比。
- 锚点见 `architecture-principles.md` §8。
- 产出 `01-estimation.md`。判据：每个数有推导，读写比明确。

### S2-2 质量属性

- 灵魂六问答案 → 质量属性表：属性 / 可度量目标 / 为什么重要 / 和谁冲突。
- 十条属性逐项过（`architecture-principles.md` §3），别漏掉会要命的那条。
- 产出 `02-quality.md`。判据：每个目标带数字。

### S2-3 用例与接口边界

- 黑盒动作清单，挑 1~2 条主航道。
- 产出 `03-interfaces.md`，`IF-1..n`。判据：主航道标出，每个动作挂到 `REQ`。

### S2-4 数据模型与存储

- 概念实体 + 关系；每类数据选存储类型 + 为什么（看访问形态）。
- 产出 `04-data-model.md`，`DM-1..n`。判据：每行有存储类型和理由。

### S2-5 架构全景

- 先 Context 再 Container；每个组件写「做什么 + 为什么需要」；画 2~3 条关键数据流。
- 图规则见 `architecture-principles.md` §6。
- 产出 `05-architecture.md`。

### S2-6 灵魂部件与接缝

- 挑 1~2 个灵魂部件（被规模压垮的那个），选模式，说明为什么。
- 标出最可能被换的接缝，用干净接口包住。
- 并入 `05-architecture.md`。判据：有模式名 + 理由 + 接缝清单。

### S2-7 瓶颈与扩展

- 涨 100 倍，第一 / 第二 / 第三瓶颈；每个写现象 → 破解 → 触发条件。
- 产出 `06-bottlenecks.md`。判据：至少两条瓶颈，各带触发条件。

### S2-8 取舍与 ADR

- 每个真正的岔路口一份 ADR 六块（`artifact-templates.md`）。
- 写到 `01_ArchitectureDesign/output/adr/`；索引行写进本阶段 `task_plan.md`。
- 自检：看不到取舍 = 没想清楚。

## 收尾

- 复盘拷问（`grilling` 固定一轮，对象 = S2 全部产物）：抓图与估算不一致、组件没有「为什么」、ADR 缺取舍、过度设计。
- 逐条风险确认（架构风险：假设错了整个设计就崩的那些）。
- ID 链检查：`REQ → IF → DM → ADR` 每环可追。
- **人工确认**：问"架构完成，是否切到 `plan2_DetailedDesign` 并 `/clear`？"
  - 首项「切换并建议 /clear」(推荐) / 「切换但不 clear」/「先停」。
  - 这是切计划前的人工点，不是阶段门；用户确认后才切 `.active_plan`。
