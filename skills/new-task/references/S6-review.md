# S6 审查

> **暂留空**：以下是最小骨架，待与用户细化。

**目标**：对账三条链，做最终收缩，给出可验收结论。
**计划目录**：`.planning/plan5_Review/`
**产物目录**：`.planning/plan5_Review/output/`

## 子步

### S6-1 对账三条链

分别查，不能按单链 `REQ → … → TC` 查：

| 链 | 检查 |
|---|---|
| 设计链 | 每个 `REQ` 有 `IF` / `DS`；每个 `IF` / `DM` 有 `DS` |
| 实施链 | 每个 `DS` 有 `WI`；每个 `WI` 有 `RV` |
| 验证链 | 每个 `DS` 有 `TC`；每个 `TC` 能指回 `DS` |

另查：每条 `ADR` 有索引行；断点列出来并标明回哪一阶段。
产出 `output/reconciliation.md`。

### S6-2 收缩

- 调一次 `ponytail:ponytail-review`（只吃最终 diff、只查过度设计）。
- 按意见修改：只收缩、不夹带功能变更；拒绝写明理由。

### S6-3 完成判据（唯一一份）

- [ ] 七个阶段都有独立计划与 `output/`
- [ ] 每条审查行打勾或写明未执行理由
- [ ] 每个阶段风险表每条有出口或未给出口理由
- [ ] 设计链 / 实施链 / 验证链无断点
- [ ] `ADR` 索引完整；被取代的 ADR 标 `superseded by`
- [ ] `scripts/validate.sh <task-id>` 通过
- [ ] 未验证项如实列出

### S6-4 收尾

- 复盘拷问（`grilling` 固定一轮，对象 = 对账结果 + ponytail 结论）。
- 逐条风险确认。
- 结论：**通过** / **打回**（写明回哪一阶段、补什么）。
- 通过后问："是否切到 `plan6_Delivery`？"→ 建 `.planning/plan6_Delivery/output/`、写临时计划（含恢复入口）、`set-active-plan.sh plan6_Delivery`、提示**强制 `/clear`** 后输入 `/new-task 继续`。
