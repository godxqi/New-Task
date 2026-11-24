# New-Task

这是一套用于开发新需求的工作流, 区别于直接对话让agent开干, 解决了如下问题
- 如何确保需求明确: 使用/grill-me方法论反复讨论需求和/planning-with-file检查决策冲突项
- 如何确保任务过长时, agent做任务的专注力: 使用/planning-with-file为计划创建各个阶段, 并明确每阶段代办项与关键决策
- 如何确保代码质量: 编写代码遵循'karpathy-guidelines', 在每个小阶段后会使用/code-revie-expert检查代码问题与需求实现, 最后一阶段执行完成后会使用/ponytail:review优化代码质量
- 如何帮助用户理解agent提出的问题: 使用/caveman让agent说话简洁, 使用名词闸减少agent自造词语的数量, 并在用户不理解agent语言时, 提供/answer-me-with-html让agent画出对应html详细说明问题

注意此工作流是Claude Code 工作流，本仓库已经包含/new-task以及它依赖的全部技能, 但引用的这些skill都不是最新版, 后续将会阶段式更新到最新版上.

## 七阶段流程

`/new-task <话题>` 启动，spec 见 [`skills/new-task/workflows/task-planning.md`](skills/new-task/workflows/task-planning.md)（唯一权威）。

| 阶段 | 做什么 | 依赖技能 / 工具 |
|------|--------|----------------|
| S1 需求分析 | 功能与非功能需求逐轮拷问、规模估算、术语表 | `caveman`、`grilling`、`answer-me-with-html` |
| S2 架构设计 | C4 Context + Container、接口边界、数据模型、取舍记录 | `domain-modeling`、`grilling` |
| S3 详细设计 | Component 内部、接口契约、数据结构、测试点 | `grilling` |
| S4 编码 | 每个 CodeUnit 先审查后提交；全部完成后 `ponytail` 收缩 | `code-review-expert`、`ponytail` |
| S5 测试 | 契约层 + 功能层；策略 → 用例 → 独立审查 → 执行 → 缺口重跑 | `vendor/qa`（内置）、`case_lint.py`、`validate.sh` |
| S6 审查 | 三条链对账、断点打回、风险出口 | — |
| S7 交付 | 交付清单、运行方式、已知限制 | — |

计划目录为 1 基：`plan1_RequirementsConfirm` … `plan7_Delivery`（S5 = `plan5_Test`，S6 = `plan6_Review`）。

关键约定：阶段横幅每步必打；拷问与风险确认一律用 `AskUserQuestion` 弹框，不铺长文；`/new-task` 仅用户可斜杠调用，不会被模型自动触发。

## S5 测试

S5 是**两层测试**，两层都过才算完成：

- **契约层**：`TestCase ← TestPoint ← DetailedDesign`，验代码契约。
- **功能层**：`TestCase ← TestPoint ← Requirement`，验黑盒行为；按项目类型跑 E2E / API。

子步：`S5-0 范围/环境/策略 → S5-1 写用例 → S5-2 独立审查 → S5-3 写/审测试代码 → S5-4 执行 → S5-5 缺口重跑`。

**调用方式**：`vendor/qa/` 是随附文档与脚本，**不注册为 skill**。用 `Read` 读 `vendor/qa/skills/<name>/SKILL.md`，用 Bash 跑 `scripts/*.py`；不要 `Skill(qa)` / `Skill(test-strategy)`。

产物（`.planning/plan5_Test/output/`）：

| 文件 | 内容 |
|---|---|
| `test-strategy.md` | Risk Map + 功能域 / 十轴范围决策 |
| `test-cases.md` | markmap 用例，ID = `TestCase-n` |
| `test-cases.schema.yaml` | 由 `extract_case_schema.py` 从用例单向抽取 |
| `test-results.md` | pass / fail / not-run + 实际命令 + 出口 / 原因 |
| `coverage-gaps.md` | 缺口挂 `TestPoint-n`；无缺口也写 |

关键规则：

- **先写用例、后读实现**：期望值只来自 `DetailedDesign` / `Requirement`；实现偏离记缺口 / 风险，不回写期望值。
- **环境门禁**：agent 起服务；账号 / token / 测试数据由用户提供，缺了就停。
- **类型门控**：Web → Playwright，HTTP → pytest，库 / CLI → 契约 + CLI 黑盒；不装不用的工具。
- **runner 阶梯**：项目已有测试配置 → 语言内置 runner → `assert` 自检脚本。

机械校验：

```bash
python "${NEW_TASK_SKILL_DIR:-$HOME/.claude/skills/new-task}/scripts/case_lint.py" .planning/plan5_Test/output/test-cases.md
sh "${NEW_TASK_SKILL_DIR:-$HOME/.claude/skills/new-task}/scripts/validate.sh" "$PWD"
sh "${NEW_TASK_SKILL_DIR:-$HOME/.claude/skills/new-task}/tests/run.sh"   # 规则自测
```

## 技能清单

| 技能 | 作用 | 仓库内入口 | 来源 |
|------|------|------------|------|
| `new-task` | 本工作流本体：七阶段流程 spec 与执行规则 | [SKILL.md](skills/new-task/SKILL.md) | 本仓库原创 |
| `qa-skills`（vendor） | S5 方法：测试策略、用例设计、独立审查、E2E / API 工程约定 | [vendor/qa/](skills/new-task/vendor/qa/) | [fishzjp/qa-skills](https://github.com/fishzjp/qa-skills) 0.9.0（MIT，裁剪） |
| `caveman` | 对话输出压缩：答案先行、去掉客套，技术事实不丢 | [SKILL.md](skills/caveman/SKILL.md) | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) |
| `grilling` | 拷问引擎：设计树、frontier、逐轮追问 | [SKILL.md](skills/grilling/SKILL.md) | [mattpocock/skills](https://github.com/mattpocock/skills)（`skills/productivity/grilling`） |
| `planning-with-files-zh` | 基于文件的持久化计划：三件套 + 钩子注入 + 格式校验脚本 | [SKILL.md](skills/planning-with-files-zh/SKILL.md) | [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files)（`skills/i18n/planning-with-files-zh`） |
| `code-review-expert` | 以 git diff 为输入的代码审查，P0~P3 分级 | [SKILL.md](skills/code-review-expert/SKILL.md) | [sanyuan0704/sanyuan-skills](https://github.com/sanyuan0704/sanyuan-skills)（`skills/code-review-expert`） |
| `answer-me-with-html` | 把问题 / 风险解释渲染成一页 HTML | [SKILL.md](skills/answer-me-with-html/SKILL.md) | [QingYunA/answer-me-with-html](https://github.com/QingYunA/answer-me-with-html) |
| `ponytail`（插件） | 反过度设计：`ponytail-review` 只查可删、可收缩的部分 | 不入库，见下方安装 | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |

版本说明：技能内容为 2026-11-12 的快照；2026-11-24 完成 S5 两层测试重构与计划目录 1 基重编号。`grilling` 比上游旧一版（上游新增 "with a fresh context window" 一处措辞）；`planning-with-files-zh` 本机为 v3.25.2，上游已到 v3.28.2；其余技能与上游一致。`qa-skills` 为 0.9.0 的裁剪子集，只保留 S5 用到的 5 个 skill 与 `core/` 引用文件。

## 前置依赖

- **Claude Code**（技能与插件的宿主）
- **Git Bash**（Windows；安装命令按 bash 语义编写）
- **Node.js ≥ 18** —— `answer-me-with-html/scripts/am.mjs` 使用全局 `fetch`、`structuredClone`，18 是硬下限
- **Python ≥ 3.9** —— `planning-with-files-zh` 的钩子脚本与 S5 的 `case_lint.py` / `extract_case_schema.py` 都会调用 python；qa-skills 的公开脚本支持 3.9–3.14
- **Playwright（可选）** —— 仅当被测项目是 Web、需要跑 E2E 时安装；纯库 / CLI 项目不需要

## 安装

```bash
git clone https://github.com/godxqi/New-Task.git
cd New-Task
mkdir -p ~/.claude/skills
cp -r skills/* ~/.claude/skills/
```

`ponytail` 以插件形式安装（已验证版本 **4.9.0**，commit `356918e`）：

```bash
claude plugin marketplace add DietrichGebert/ponytail
claude plugin install ponytail@ponytail
```

装完确认：

```bash
ls ~/.claude/skills/          # 应看到 8 个技能目录（含 new-task）
claude plugin list            # 应看到 ponytail@ponytail 4.9.0
```

PowerShell 用户把复制命令换成 `Copy-Item skills\* "$HOME\.claude\skills\" -Recurse`。

## 已知限制

- **脚本行为**：`answer-me-with-html/scripts/am.mjs` 在本地生成 HTML 文件（内容由模型先写好 Markdown 草稿），只有视频 / 语音相关功能会访问 ElevenLabs TTS 等外部服务；`planning-with-files-zh/scripts/session-catchup.py` 在本机被显式调用时可读取同项目的会话元数据。两者都不会自动上传。
- **安装命令按 Git Bash 语义**（`cp -r`）；纯 PowerShell / cmd 环境未逐一验证，PowerShell 请用上一节的 `Copy-Item`。
- **本仓库是快照镜像**，不是技能的开发源；技能内容以各上游仓库与本机源目录为准。
- **`vendor/qa/` 不会自动触发**：它是随附文档与脚本，不是注册 skill；S5 按路径 `Read`，脚本用 Bash 跑。上游声明原生 Windows 未覆盖，但这里用到的脚本是纯标准库 Python，已在 Git Bash + Python 3.13 下跑通自测。

## 许可

仓库不另设总许可证。每个技能目录内的文件与许可各自保留原样，**引用与再分发请遵循各技能目录内的 LICENSE / 许可声明**及上表中的上游仓库。
