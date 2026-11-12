# New-Task

一套「讨论新需求 → 拷问收敛 → 落计划 → 复查与风险确认 → 实施 → 收缩」的 Claude Code 工作流，以及它依赖的全部技能。仓库内容是本机 `~/.claude/skills/` 的镜像快照，按原目录结构收录，装到另一台机器上即可复现同一套流程。

## 六步流程

`/new-task <话题>` 启动，spec 见 [`skills/new-task/workflows/task-planning.md`](skills/new-task/workflows/task-planning.md)（唯一权威）。

| 步骤 | 做什么 | 依赖技能 |
|------|--------|----------|
| S1 拷问 | 弹框逐轮追问需求，推荐答案置首项；下限 2 轮，续期由用户定 | `caveman`、`grilling`、`answer-me-with-html` |
| S2 落计划 | 在 `.planning/<plan-id>/` 写 `task_plan.md` / `findings.md` / `progress.md`，含审查待办行与风险表 | `planning-with-files-zh` |
| S3 复查拷问与风险确认 | 先让 AI 挑计划自己的错，再由用户逐条给风险出口（接收 / 解决 / 重新确认） | `grilling`、`answer-me-with-html` |
| S4 检查点 | 把计划当 Brief 交给用户，拿到「开干」才继续 | — |
| S5 实施 | 按工作项推进，每项完成即审查并修 P0~P3 | `code-review-expert` |
| S6 收尾 | 全部完成后只做一次过度设计收缩审查 | `ponytail`（插件） |

关键约定：阶段横幅每步必打；拷问与风险确认一律用 `AskUserQuestion` 弹框，不铺长文；`/new-task` 仅用户可斜杠调用，不会被模型自动触发。

## 技能清单

| 技能 | 作用 | 仓库内入口 | 来源 |
|------|------|------------|------|
| `new-task` | 本工作流本体：六步流程 spec 与执行规则 | [SKILL.md](skills/new-task/SKILL.md) | 本仓库原创 |
| `caveman` | 对话输出压缩：答案先行、去掉客套，技术事实不丢 | [SKILL.md](skills/caveman/SKILL.md) | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) |
| `grilling` | 拷问引擎：设计树、frontier、逐轮追问 | [SKILL.md](skills/grilling/SKILL.md) | [mattpocock/skills](https://github.com/mattpocock/skills)（`skills/productivity/grilling`） |
| `planning-with-files-zh` | 基于文件的持久化计划：三件套 + 钩子注入 + 格式校验脚本 | [SKILL.md](skills/planning-with-files-zh/SKILL.md) | [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files)（`skills/i18n/planning-with-files-zh`） |
| `code-review-expert` | 以 git diff 为输入的代码审查，P0~P3 分级 | [SKILL.md](skills/code-review-expert/SKILL.md) | [sanyuan0704/sanyuan-skills](https://github.com/sanyuan0704/sanyuan-skills)（`skills/code-review-expert`） |
| `answer-me-with-html` | 把问题 / 风险解释渲染成一页 HTML | [SKILL.md](skills/answer-me-with-html/SKILL.md) | [QingYunA/answer-me-with-html](https://github.com/QingYunA/answer-me-with-html) |
| `ponytail`（插件） | 反过度设计：`ponytail-review` 只查可删、可收缩的部分 | 不入库，见下方安装 | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) |

版本说明：本仓库为 2026-11-12 的快照。`grilling` 比上游旧一版（上游新增 "with a fresh context window" 一处措辞）；`planning-with-files-zh` 本机为 v3.25.2，上游已到 v3.28.2；其余技能与上游一致。

## 前置依赖

- **Claude Code**（技能与插件的宿主）
- **Git Bash**（Windows；安装命令按 bash 语义编写）
- **Node.js ≥ 18** —— `answer-me-with-html/scripts/am.mjs` 使用全局 `fetch`、`structuredClone`，18 是硬下限
- **Python ≥ 3.8** —— `planning-with-files-zh` 的钩子脚本（`inject-plan.sh`、`skill-hook.sh`、`resolve-plan-dir.sh` 等）会调用 python；脚本用了 walrus 语法，8 是硬下限

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
ls ~/.claude/skills/          # 应看到 6 个技能目录
claude plugin list            # 应看到 ponytail@ponytail 4.9.0
```

PowerShell 用户把复制命令换成 `Copy-Item skills\* "$HOME\.claude\skills\" -Recurse`。

## 已知限制

- **脚本行为**：`answer-me-with-html/scripts/am.mjs` 在本地生成 HTML 文件（内容由模型先写好 Markdown 草稿），只有视频 / 语音相关功能会访问 ElevenLabs TTS 等外部服务；`planning-with-files-zh/scripts/session-catchup.py` 在本机被显式调用时可读取同项目的会话元数据。两者都不会自动上传。
- **安装命令按 Git Bash 语义**（`cp -r`）；纯 PowerShell / cmd 环境未逐一验证，PowerShell 请用上一节的 `Copy-Item`。
- **本仓库是快照镜像**，不是技能的开发源；技能内容以各上游仓库与本机源目录为准。

## 许可

仓库不另设总许可证。每个技能目录内的文件与许可各自保留原样，**引用与再分发请遵循各技能目录内的 LICENSE / 许可声明**及上表中的上游仓库。
