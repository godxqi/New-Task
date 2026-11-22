# S7 交付

**目标**：把可运行的系统、文档与决策记录打包，交给用户。
**计划目录**：`.planning/plan6_Delivery/`
**产物目录**：`.planning/plan6_Delivery/output/`

## 开场

1. 读前六个阶段的 `output/`、代码根、测试结果。
2. **不新建计划**；读 active plan，把临时骨架复写成正式计划。
3. 打 S7 横幅。

## 子步

### S7-1 交付清单

产出 `output/deliverables.md`：

| 项 | 内容 |
|---|---|
| 代码 | 代码根、分支 / 提交、如何运行 |
| 测试 | 测试命令、结果 |
| 设计文档 | `Requirement` / `Interface` / `DataModel` / `DetailedDesign` / `ArchDecisionRecord` 路径 |
| 已知限制 | 未做的功能、已接收的风险 |

### S7-2 打包与说明

- README / 运行说明：启动、依赖、环境变量、测试命令。
- 若用户要交付包：打 zip / tar，路径写进交付清单。
- **不夹带新功能**；只做交付所需的说明与打包。

### S7-3 收尾

- 复盘拷问（`grilling` 固定一轮，对象 = 交付清单）。
- 逐条风险确认（交付风险）。
- **提醒提交**：`git add .planning/plan6_Delivery <交付说明文件> && git commit -m "S7: delivery"`。
- 全流程结束。
