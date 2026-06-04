---
description: R&D 工具箱入口/帮助/路由。当用户输入 /rnd:help、问「rnd 能干嘛/有哪些命令」、或想开始一段开发任务(理解代码/评审/测试/提交)但没说清用哪个命令时使用。
---

# /rnd:help — 通用研发提效工具箱

你是这套通用 R&D 插件的**编排器**。它跨语言、跨项目复用,靠每个项目的 **profile**(`.claude/rnd-profile.json`,由 `/rnd:init` 生成)来适配。

## 先决条件:项目 profile
任何能力命令开跑前,先看目标项目有没有 `${CLAUDE_PROJECT_DIR}/.claude/rnd-profile.json`:
- **有** → 读它拿 stack / build / test / run / lint 命令与布局。
- **没有** → 建议用户先跑 `/rnd:init`(自动探栈生成 profile);急用也可让 explorer 子代理临时推断,但提醒用户 init 一次更稳。

## 命令
| 命令 | 用途 |
|---|---|
| `/rnd:init` | 探测技术栈,生成/更新项目 profile(新项目第一步) |
| `/rnd:explore <问题>` | 摸清代码:架构图、查调用链、找可复用实现 |
| `/rnd:review` | 评审当前改动 + 重构/简化(委派内置 /code-review、/simplify) |
| `/rnd:test [目标]` | 按 profile 跑测试、复现 bug、verify 改动真生效 |
| `/rnd:ship` | 规范 commit / 开 PR / changelog / 发布 |
| `/rnd:prefs` | 生成/编辑你的全局编码偏好(`~/.claude/CLAUDE.md`) |

## 复用优先(重要)
Claude Code 已内置 `/code-review`、`/simplify`、`/verify`、`/run`、`/security-review`。本工具箱**编排并委派**它们,只补「项目 profile 适配 + 多语言命令 + 统一入口 + 专用子代理」,**不重写**已有能力。

## 子代理(Agent 工具 subagent_type:rnd:<name>)
`rnd:explorer`(只读导航)、`rnd:reviewer`(找问题)、`rnd:refactorer`(改)、`rnd:test-runner`(跑测试/解析失败)、`rnd:debugger`(复现/定位)、`rnd:shipper`(git/PR)。

## 路由
用户说"看懂/找…"→ explore;"评审/重构/简化"→ review;"跑测试/为什么挂/复现/验证"→ test;"提交/PR/发版"→ ship;新项目或命令报"无 profile"→ 先 init。不确定就用 AskUserQuestion 问目标和意图,别瞎猜。
