# S6 审查

> **暂留空**：以下是最小骨架，待与用户细化。ponytail 已移到 S4-4。

**目标**：对账三条链，给出可验收结论。
**计划目录**：`.planning/plan5_Review/`
**产物目录**：`.planning/plan5_Review/output/`

## 开场

1. 读前五个阶段的 `output/` 与各自的 `task_plan.md`。
2. **不新建计划**；读 active plan，把临时骨架复写成正式计划。
3. 打 S6 横幅。

## 子步

### S6-1 对账三条链

分别查，不能按单链 `REQ → … → TC` 查：

| 链 | 检查 |
|---|---|
| 设计链 | 每个 `REQ` 有 `IF` / `DS`；每个 `IF` / `DM` 有 `DS` |
| 实施链 | 每个 `DS` 有 `WI`；每个 `WI` 有 `RV` |
| 验证链 | 每个 `DS` 有 `TC`；每个 `TC` 能指回 `DS` |

- **纯非接口需求**（文案、合规）允许 `N/A`，但必须写一句理由。
- 另查：每个 `ADR` 文件在计划里有索引行；被取代的标 `superseded by`。
- 断点列出来并标明回哪一阶段。产出 `output/reconciliation.md`。

### S6-2 完成判据（唯一一份）

- [ ] 七个阶段都有独立计划与 `output/`
- [ ] 每条审查行打勾或写明未执行理由
- [ ] 每个阶段风险表每条有出口或未给出口理由
- [ ] 设计链 / 实施链 / 验证链无断点（`N/A` 有理由）
- [ ] `ADR` 文件与索引一一对应
- [ ] `sh "$HOME/.claude/skills/new-task/scripts/validate.sh" "$PWD"` 通过
- [ ] 未验证项如实列出

### S6-3 收尾

- 复盘拷问（`grilling` 固定一轮，对象 = 对账结果）。
- 逐条风险确认。
- 结论：**通过** / **打回**（打回写明回哪一阶段、补什么；回炉细节待定）。
- 通过后问："是否切到 `plan6_Delivery`？"→ **更新 `plan6_Delivery` 的恢复入口**（已完成：S6；下一步：S7-1 交付清单）→ `set-active-plan.sh plan6_Delivery`。
- **提醒提交**：`git add .planning/plan5_Review && git commit -m "S6: review"`。
- 提示**强制 `/clear`** 后输入 `/new-task 继续`。
