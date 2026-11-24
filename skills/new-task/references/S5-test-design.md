# S5 用例设计与执行约定

> 方法来源：`vendor/qa/skills/`（qa-skills 0.9.0，MIT）。本文只保留代码契约测试适用的部分；
> 黑盒执行细则按项目类型查对应 vendor skill。
>
> vendor 文档里的文件名与 ID 一律按下表替换：`测试用例_markmap.md` → `test-cases.md`、
> `测试用例.schema.yaml` → `test-cases.schema.yaml`、`测试策略.md` → `test-strategy.md`、
> `TC-{模块号}-{序号}` → `TestCase-n`。

## 1. test-cases.md 格式

**文件头部（lint E1 检查这四块，标签不要改名）**：

```md
## 功能简介
一句话说明被测范围；列出对应的 Requirement-n / Interface-n。

## 环境与账号
runner 命令、依赖、环境变量、账号 / token。
纯库无账号时写：「不适用（代码契约测试，无账号）」。

## 术语表
用例里出现的业务词、领域词 → 一句解释。

## 图例
pass / fail / not-run、P0/P1/P2、层 contract/functional、Risk-n 的含义。
```

**用例块**：

```md
## 契约层

- **TestCase-1 密码错误抛 AuthError** [P0]
  - 验证: TestPoint-3（DetailedDesign-2）
  - 层: contract
  - 前置条件: 已存在用户 alice，密码正确
  - 操作步骤: 1. 调用 login("alice", "wrong") 2. 捕获异常
  - 预期结果: 抛出 AuthError，错误码 AUTH_INVALID，且不返回 session

## 功能层

- **TestCase-7 连续三次错误密码后出现图形验证码** [P1]
  - 验证: TestPoint-11（Requirement-4）
  - 层: functional
  - 前置条件: 用户 alice 已注册
  - 操作步骤: 1. 用错误密码登录三次 2. 第四次打开登录页
  - 预期结果: 第四次页面出现图形验证码输入框
```

- ID 只用 `TestCase-n`，连续编号；`n` 与 `test-cases.schema.yaml` 一致。
- 章节标题可用 `## 契约层` / `## 功能层`，不需要模块编号。
- 代码位置（`文件:行`）不放正文，放文末 `## 附录：代码证据`。
- 正文可以写函数名、类型名、错误码——这是契约测试的验证对象。

## 2. 用例设计清单

每个功能域至少覆盖：

1. **主流程**：最短正向路径至少一条，「太显然」不是省略理由。
2. **负向**：非法输入、缺必填、权限拒绝、重复提交、超限。
3. **边界**：数值上下限、字符串长度、分页大小、日期区间、枚举值。
4. **状态**：每个状态节点一条；每条边一条；非法转换与终态约束各至少一条负向。
5. **数据一致性**：一次写操作后，列表 / 详情 / 计数 / 缓存 / 搜索索引同步刷新。
6. **权限**：角色 × 操作 × 资源；越权访问必须单独成条（若策略纳入）。
7. **异步 / 可靠**（有信号才做）：超时、重试、部分失败、乱序、幂等。
8. **时间双侧**：时限 / 有效期类规则，边界前一拍与到达时刻各一条。

## 3. 优先级

- **P0**：失败会导致核心功能不可用；P0 自检——这条挂了，用户还能不能完成核心操作？
- **P1**：正常功能 + 常见异常（默认）。
- **P2**：极端输入、低频场景、需特殊环境。
- P0 占比超过 35%（≥6 条用例时）会触发 lint W5，须逐条复核。

## 4. 期望值（oracle）硬规则

1. **只来自 `DetailedDesign` / `Requirement`**，不得从实现反推；实现与设计不一致 → 记 `coverage-gaps` / `Risk`，不改期望值。
2. **可判定**：禁止「正常 / 正确 / 处理好 / 视情况 / 待确认」；必须写可观察结果。
3. **可追溯**：每条的 `验证` 字段指向存在的 `TestPoint-n`。
4. **唯一**：含「或」的结果拆成多条。
5. **异步写时限**：「稍后 / 自动 / 生效」必须写「多久不发生判失败」。
6. **断言范围 ≤ 验证强度**：两个样本不能断言全局唯一；UI 操作不能断言数据库约束。

## 5. 可执行性红线

以下任一命中，该条用例无效：

1. 步骤或期望含占位符（`{xxx}`、`<xxx>`、某数据）。
2. 操作入口不可达（函数不存在、命令没有、URL 404 且未标 TODO）。
3. 期望不可判定。
4. 异步预期无时限。
5. 前置条件不可获得且未说明来源。
6. 用例名称断言超出步骤能证明的范围。
7. 契约测试的期望值没有指向任何设计条目。

## 6. 独立审查清单（S5-2 subagent）

- [ ] 每个 `TestPoint-n` 至少有一条 `TestCase-n`，或缺口有出口。
- [ ] 每条 `TestCase` 有 `验证` / `层` / `前置条件` / `操作步骤` / `预期结果`。
- [ ] `验证` 指向的 `TestPoint` 存在，且其来源（`DetailedDesign` / `Requirement`）与 `层` 一致。
- [ ] 期望值可判定、唯一、可追溯；没有实现反推的痕迹（如「与当前返回值一致」）。
- [ ] 主流程、负向、边界、状态、一致性按第 2 节覆盖到位。
- [ ] Critical / High 风险在 `test-strategy.md` 里都有对应用例。
- [ ] 没有重复用例、没有一条测多个点。
- [ ] 契约层与功能层没有混写；同一 TestPoint 不双计数。

## 7. test-results.md 格式

| 字段 | 内容 |
|---|---|
| `TestCase-n` | 用例编号 |
| 状态 | `pass` / `fail` / `not-run` |
| 证据 / 命令 | 实际执行的命令 + 输出摘要；**必须可复现** |
| 出口 / 原因 | `fail` → `Risk-n` 或修复记录；`not-run` → 原因 + 出口；`pass` → `—` |

## 8. 执行约定

**runner 阶梯**（先探再跑，不预设工具）：

1. 项目已有测试配置（`package.json` scripts / `Makefile` test / `go.mod` / `Cargo.toml` / `pom.xml` / `*.csproj` / `pyproject`）→ 用项目命令。
2. 没有 → 语言内置 runner：`python -m unittest`、`node --test`、`go test`、`cargo test`、`dotnet test`。
3. 仍没有（C/C++、脚本）→ 写 `assert` 自检脚本直接跑。
4. 命令必须记进 `test-results.md`。

**类型门控**：

- Web → Playwright E2E（`vendor/qa/skills/automated-e2e-testing`）。
- HTTP → pytest + requests（`vendor/qa/skills/api-testing`）。
- 库 / CLI → 契约测试 + CLI 黑盒脚本，不装 Playwright。

**环境门禁**：agent 起服务；账号 / token / 数据由用户提供；缺了停在 S5-0。

**冒烟**：功能层至少一条主路径，证明「系统能起来、主路径能通」；不承担功能覆盖。

## 9. 与 vendor/qa 的对应

| 本约定 | vendor 来源 | 改动 |
|---|---|---|
| 用例格式、四段式 | `core/case-format.md` | ID 改 `TestCase-n`，去掉模块编号 |
| 可执行性红线 | `core/executability.md` | 「代码优先」改为「设计优先、写后读码」 |
| 覆盖清单 | `core/coverage.md` | 只取代码契约适用项 |
| 类型轴 | `core/test-type-matrix.md` | 只取功能 / 边界 / 异常 / 状态 / 一致性 / 并发 |
| 风险评级 | `core/risk-model.md` | 原样 |
| 策略结构 | `skills/test-strategy/SKILL.md` | 原样，产物落 `test-strategy.md` |
| 独立审查 | `skills/test-case-review/SKILL.md` | 只读、不改用例 |
| E2E / API 工程约定 | `skills/automated-e2e-testing`、`skills/api-testing` | 按类型调用 |
