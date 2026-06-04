---
description: 规范地提交、开 PR、写 changelog、走发布流程。当用户输入 /rnd:ship、或说「提交一下/开个 PR/发版/写 changelog」时使用。涉及推送/PR/发布前会先跟用户确认。
---

# /rnd:ship $ARGUMENTS

把改动按项目规范交付出去。

## 步骤
1. 读 `${CLAUDE_PROJECT_DIR}/.claude/rnd-profile.json` 拿提交/分支/changelog 约定。看 `git status`/`git diff` 与当前分支。
2. 派 `rnd:shipper` 子代理走流程(**一条一条直连 git,不用不透明管道脚本**):
   - 若在默认分支(main/master)上有改动 → **先建分支**再提交。
   - 提交前按 profile 跑 `commands.lint`/`commands.test` 自检(失败先报、别硬提交)。
   - 写符合项目规范的 commit message;需要时更新 CHANGELOG。
   - 开 PR 用 `gh`(标题/正文按项目模板)。
3. **外向动作先 gate**:`commit` 之外的 **push / 开 PR / 发布 / 打 tag** 都先把将执行的命令和影响告诉用户,**确认后**再做(这些难撤销、对外可见)。
4. 回报:做了什么(commit hash / 分支 / PR 链接)、自检结果、还需用户做什么。

## 约定
只在用户要求时提交/推送;遵守项目 commit/分支规范;不替用户决定合并。涉及凭证/对外发布务必先确认。
