# 测试用例

## 功能简介
验证示例登录功能的密码校验契约与失败提示。

- 对应 Requirement-1 / DetailedDesign-1

## 环境与账号
- 命令：`python -m unittest discover -s tests`
- 账号：不适用（代码契约测试，无账号）

## 术语表
| 术语 | 解释 |
|---|---|
| AuthError | 认证失败时抛出的业务异常 |

## 图例
- `[P0]` 核心、`[P1]` 常规、`[P2]` 边界
- 层：`contract` 代码契约 / `functional` 黑盒功能
- 状态：`pass` / `fail` / `not-run`

## 契约层

- **TestCase-1 密码错误抛 AuthError** [P0]
  - 验证: TestPoint-1（DetailedDesign-1）
  - 层: contract
  - 前置条件: 用户 alice 已存在，密码正确
  - 操作步骤: 1. 调用 login("alice", "wrong") 2. 捕获异常
  - 预期结果: 抛出 AuthError，错误码 AUTH_INVALID

## 功能层

- **TestCase-2 连续三次错误密码后出现图形验证码** [P1]
  - 验证: TestPoint-2（Requirement-1）
  - 层: functional
  - 前置条件: 用户 alice 已注册
  - 操作步骤: 1. 用错误密码登录三次 2. 第四次打开登录页
  - 预期结果: 第四次页面出现图形验证码输入框
