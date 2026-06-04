# rnd-toolkit

可复用的 **Claude Code 插件**,做通用研发提效。一次建好、托管在 git、装进任意项目用、随开发持续完善。

> 这个仓**同时是一个 Claude Code marketplace**(`.claude-plugin/marketplace.json`),里面含一个插件 **`rnd`**(`plugins/rnd/`)。

## 它给你什么

装上后,在任意项目里可用一组 `/rnd:*` 命令(命名空间固定为 `rnd:`):

| 命令 | 用途 |
|---|---|
| `/rnd:init` | 探测技术栈,生成项目 profile(`.claude/rnd-profile.json`)。**新项目第一步** |
| `/rnd:explore <问题>` | 摸清代码:架构地图、查调用链、找可复用实现(只读) |
| `/rnd:review` | 评审当前改动 + 重构/简化(委派内置 `/code-review`、`/simplify`) |
| `/rnd:test [目标]` | 按 profile 跑测试、复现 bug、验证改动真生效 |
| `/rnd:ship` | 规范 commit / 开 PR / changelog / 发布 |
| `/rnd` | 入口/路由(不确定用哪个时打它) |

背后是一组通用、多语言的子代理:`rnd:explorer`、`rnd:reviewer`、`rnd:refactorer`、`rnd:test-runner`、`rnd:debugger`、`rnd:shipper`。

**设计原则**
- **复用优先**:Claude Code 已内置 `/code-review`、`/simplify`、`/verify`、`/run` 等 —— 本插件**编排并委派**它们,只补「项目适配 + 多语言 + 统一入口 + 专用子代理」,不重写。
- **引擎与项目知识分层**:插件是项目无关的引擎;每个项目用 `/rnd:init` 生成 `.claude/rnd-profile.json`(栈/命令/约定),通用智能体读它来适配。
- **半自动 + 关键点问你**:子代理只读/算/跑、不直接提问;主循环在写文件、起大算力、推送/发布等节点用问答找你确认。

支持多语言:Python、JS/TS、Go、Rust、C/C++、Java、机器人/仿真(ROS、MuJoCo/mjlab/Isaac)。

## 安装(在别的项目里用)

```bash
# 1) 添加这个 marketplace(每台机器一次)
/plugin marketplace add <你的-git-url>          # 或 owner/repo(GitHub 简写)

# 2) 安装插件
/plugin install rnd@rnd-toolkit --scope user     # user=全项目可用;也可 --scope project(随项目 git 共享)

# 3) 进到某个项目,先建 profile
/rnd:init
# 然后就能 /rnd:explore | /rnd:review | /rnd:test | /rnd:ship
```

## 更新

`plugins/rnd/.claude-plugin/plugin.json` **故意不写 `version`** → 用 git commit SHA 当版本,**每次 push 即是新版本**,各项目 `/plugin update rnd@rnd-toolkit` 取最新。适合持续完善。
> 等想做稳定发布再在 `plugin.json` 加显式 `version`(semver),那之后每次发布都要 bump。

## 本地开发 / 迭代

```bash
# 把本地仓当 marketplace 装,边改边用
/plugin marketplace add /home/yfb/rnd-toolkit
/plugin install rnd@rnd-toolkit --scope local

# 改完热加载:SKILL.md 即时生效;agent/hook 改动需 reload
/reload-plugins
```

校验探栈器:
```bash
bash plugins/rnd/scripts/detect-stack.sh <某项目目录>   # 应输出合法 JSON profile
```

## 目录结构

```
rnd-toolkit/
├── .claude-plugin/marketplace.json     # marketplace 清单(列出插件)
└── plugins/rnd/
    ├── .claude-plugin/plugin.json      # 插件清单(name=rnd,不写 version)
    ├── skills/{rnd,init,explore,review,test,ship}/SKILL.md
    ├── agents/{explorer,reviewer,refactorer,test-runner,debugger,shipper}.md
    └── scripts/detect-stack.sh         # 多语言探栈(被 /rnd:init 调用)
```

## 路线图 / 怎么扩

- 加能力 → 新建 `plugins/rnd/skills/<x>/SKILL.md`(+ 需要的 `agents/<y>.md`)。
- 加独立模块 → 在 `plugins/` 下加新插件,登记进 `marketplace.json` 的 `plugins[]`。
- 让某条流程自动化 → 用 plugin `hooks/hooks.json`(注意:插件 agent 不能带 hooks/mcpServers/permissionMode/memory)。

详见 `CHANGELOG.md`。
