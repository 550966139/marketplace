# Changelog

本插件用 commit-SHA 作版本(plugin.json 未写 version),每次 push 即更新。本文件记录有意义的变更。

## Unreleased

### Changed
- 路由技能 `rnd` 改名 `help`(`/rnd:rnd` → `/rnd:help`,去掉绕口的双 rnd)。
- `plugin.json` 删除非法的 `skills`/`agents` 字段,组件改为标准自动发现(修安装时 `agents: Invalid input`)。
- 新增 `/rnd:prefs`:脚手架生成本机 `~/.claude/CLAUDE.md` 全局编码偏好模板(前端/后端/通用),内容私有、不进仓;覆盖"主循环直接写代码"路径。

### Added — 初版骨架(v0)
- marketplace `rnd-toolkit` + 插件 `rnd`。
- 技能:`/rnd`(路由)、`/rnd:init`(探栈生成 `.claude/rnd-profile.json`)、`/rnd:explore`、`/rnd:review`、`/rnd:test`、`/rnd:ship`。
- 子代理:`explorer`、`reviewer`、`refactorer`、`test-runner`、`debugger`、`shipper`(均通用、多语言、读项目 profile;遵守插件 agent 限制:无 hooks/mcpServers/permissionMode/memory)。
- `scripts/detect-stack.sh`:多语言探栈(Python/JS-TS/Go/Rust/C++/Java/ROS/robotics-sim),输出 JSON profile,主栈优先、命令去歧义。
- 设计:复用内置 `/code-review` `/simplify` `/verify` `/run`;引擎与项目知识分层;半自动 + 关键点问用户。

### TODO / 下一步
- `/rnd:init` 对 monorepo 多子包的栈/命令细分。
- 各语言 lint/test 命令的更细适配(uv/poetry、pnpm/yarn、gradle/maven 等)。
- 视使用情况加 hooks(如保存即 lint)或更多专用子代理。
