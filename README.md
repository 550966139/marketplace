# rnd-toolkit — 你的研发 AI 助手工具箱

一套可复用的 Claude Code 命令,帮你在**任何项目**里干日常开发活:看懂代码、评审、跑测试、提交发布。
**装一次,处处能用**,而且会随你开发不断完善。

---

## 它能帮你干嘛

装好后,在任何项目里输入这些命令(都以 `/rnd:` 开头):

| 你想干嘛 | 用这个命令 | 它会做什么 |
|---|---|---|
| 让 AI 先认识这个项目 | `/rnd:init` | 自动看出项目用什么语言/框架、怎么构建和测试,记成一张"项目说明卡"。**进新项目第一步** |
| 看懂一段代码 | `/rnd:explore 你的问题` | 帮你摸清结构、找到该改哪儿、有没有现成实现 |
| 评审 / 改进代码 | `/rnd:review` | 找 bug + 提重构/简化建议,**你点头了才动手** |
| 跑测试 / 查为什么挂了 | `/rnd:test` | 按项目自己的测试命令跑,挂了帮你定位原因 |
| 提交代码 / 开 PR | `/rnd:ship` | 规范地提交、开 PR、写更新日志(**推送前先问你**) |
| 记下你的编码偏好 | `/rnd:prefs` | 建一份"我喜欢怎么写代码"的文件,以后 AI 写代码照着来 |
| 忘了有哪些命令 | `/rnd:help` | 列出全部命令、帮你挑 |

> 背后还有 6 个"专家小助手"(探索、评审、重构、测试、调试、提交),AI 会**按需自动调用**它们,你平时不用直接管。

支持的语言/技术:Python、JavaScript/TypeScript、Go、Rust、C/C++、Java、机器人/仿真。

---

## 怎么装(一次性,复制粘贴)

在 Claude Code 里依次输入这三行:

```
/plugin marketplace add https://github.com/550966139/marketplace.git
/plugin install rnd@rnd-toolkit
/reload-plugins
```

装完后,进任意项目先跑一下 `/rnd:init`(让 AI 认识这个项目),然后上面那些命令就能用了。

---

## 怎么用(几个例子)

- 刚进一个不熟的项目 → 先 `/rnd:init`
- "这个登录功能在哪实现的?" → `/rnd:explore 登录功能在哪实现`
- 写完一段想让人帮忙把关 → `/rnd:review`
- "测试怎么红了?" → `/rnd:test`
- 想提交 → `/rnd:ship`
- 第一次用、想让 AI 记住你的写码习惯 → `/rnd:prefs`(然后把生成的文件填一下)

---

## 想要最新版

这个仓库有更新后,在 Claude Code 里:

```
/plugin marketplace update rnd-toolkit
/plugin update rnd@rnd-toolkit
/reload-plugins
```

---
---

## 技术细节(普通使用不用看,给开发/维护者)

**这是什么(术语版)**:这个 git 仓**同时是一个 Claude Code marketplace**(`.claude-plugin/marketplace.json`),里面含一个插件 **`rnd`**(`plugins/rnd/`)。插件技能的调用名固定带命名空间 `rnd:`(所以是 `/rnd:init` 而不是 `/rnd init`)。

**"项目说明卡" = `rnd-profile.json`**:`/rnd:init` 在项目里生成 `.claude/rnd-profile.json`(记录 stack / build / test / run / lint 命令、目录布局、约定),所有 `/rnd:*` 命令和子代理读它来适配该项目。探栈逻辑在 `plugins/rnd/scripts/detect-stack.sh`(多语言,输出 JSON)。

**安装范围(scope)**:`/plugin install ... --scope user|project|local`。`user`=本机全项目可用(默认);`project`=写进项目 `.claude/settings.json` 随 git 共享;`local`=只本项目且不进 git。

**版本/更新**:`plugins/rnd/.claude-plugin/plugin.json` **故意不写 `version`** → 用 git commit SHA 当版本,**每次 push 即是新版本**,`/plugin update` 取最新。想做稳定发布再加显式 `version`(semver)。

**本地开发(边改边用)**:
```
/plugin marketplace add /home/yfb/rnd-toolkit      # 把本地仓当 marketplace
/plugin install rnd@rnd-toolkit --scope local
/reload-plugins                                    # SKILL.md 改动即时生效;agent 改动需 reload
bash plugins/rnd/scripts/detect-stack.sh <某项目目录>   # 单测探栈器,应输出合法 JSON
```

**目录结构**:
```
rnd-toolkit/
├── .claude-plugin/marketplace.json     # marketplace 清单(列出插件)
└── plugins/rnd/
    ├── .claude-plugin/plugin.json      # 插件清单(name=rnd,不写 version)
    ├── skills/{help,init,explore,review,test,ship,prefs}/SKILL.md
    ├── agents/{explorer,reviewer,refactorer,test-runner,debugger,shipper}.md
    └── scripts/detect-stack.sh         # 多语言探栈(被 /rnd:init 调用)
```

**设计原则**:
- **复用优先**:Claude Code 已内置 `/code-review`、`/simplify`、`/verify`、`/run` 等,本插件**编排并委派**它们,不重写。
- **引擎与项目知识分层**:插件是项目无关的引擎;每个项目的 profile(`rnd-profile.json`)+ 个人偏好(`~/.claude/CLAUDE.md`,由 `/rnd:prefs` 生成)提供适配上下文。
- **半自动 + 关键点问你**:子代理只读/算/跑、不直接提问;主循环在写文件、起大算力、推送/发布等节点先问你确认。

**怎么扩**:加能力 → 新建 `plugins/rnd/skills/<x>/SKILL.md`(+ 需要的 `agents/<y>.md`);加独立模块 → 在 `plugins/` 下加新插件并登记进 `marketplace.json`。变更记录见 `CHANGELOG.md`。
