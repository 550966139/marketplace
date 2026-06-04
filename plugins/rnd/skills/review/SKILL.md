---
description: 评审当前改动(找 bug)并做重构/简化/复用清理,按用户批准应用。当用户输入 /rnd:review、或说「评审一下/帮我看看这段/能不能简化/重构这块」时使用。
---

# /rnd:review $ARGUMENTS

对当前 diff(或指定目标)做评审 + 质量清理。

## 步骤
1. 读 `${CLAUDE_PROJECT_DIR}/.claude/rnd-profile.json` 拿 stack/约定(命名、lint、分支规范)。看当前改动范围(`git diff`/指定文件)。
2. **复用内置优先**:
   - 找 bug/正确性 → 委派内置 **`/code-review`**(按需带 effort)。
   - 复用/简化/效率清理 → 委派内置 **`/simplify`**。
   叠加项目 profile 的约定与多语言 lint(`commands.lint`)。
3. 需要更深/项目特定的判断时,派 `rnd:reviewer`(找问题、只读)+ `rnd:refactorer`(提改动)子代理,带上 profile 上下文。
4. **应用前 gate**:把发现/改动 diff 呈现给用户,**批准后**才让 refactorer 落地;改完按 profile 的 `commands.lint`/`commands.test` 自检。
5. 汇总:确认的问题(分严重度)+ 已应用/待应用的清理 + 自检结果。

## 约定
不在评审里夹带无关大改;遵守项目 profile 的约定;破坏性改动先 gate。
