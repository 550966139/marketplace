---
description: 探测当前项目的技术栈与构建/测试/运行/lint 命令,生成 .claude/rnd-profile.json,让 rnd 通用智能体适配本项目。当用户输入 /rnd:init、或在新项目里第一次用 rnd、或命令报「无 profile」时使用。
---

# /rnd:init — 项目探栈 + 生成 profile

为当前项目建立 rnd 的「项目知识层」。其它 `/rnd:*` 都依赖它。

## 步骤
1. **粗探栈(脚本)**:跑
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-stack.sh" "${CLAUDE_PROJECT_DIR}"`
   得到 JSON:`stacks / primary / package_manager / markers / commands`。这是启发式初值。

2. **精修(agent)**:派 `rnd:explorer` 子代理读项目实情来**校正命令**:README / CONTRIBUTING、CI(`.github/workflows`、`.gitlab-ci.yml`)、Makefile/justfile、`pyproject.toml`/`package.json` scripts、monorepo 子包。重点确认:真实 **test / build / run / lint** 命令、入口、以及"重活在哪跑"(本地 vs 远端/容器/conda env)。

3. **拿不准就问**:命令有歧义或多套(多包/多语言)时,用 **AskUserQuestion** 让用户确认主命令,别猜。

4. **写 profile**:把脚本初值 + agent 精修 + 用户确认合并,写到
   `${CLAUDE_PROJECT_DIR}/.claude/rnd-profile.json`,结构:
   ```json
   {
     "stacks": ["..."], "primary": "...", "package_manager": "...",
     "commands": { "build": "...", "test": "...", "run": "...", "lint": "..." },
     "layout": { "src": "...", "tests": "...", "entrypoints": ["..."] },
     "conventions": ["分支/提交规范、不可降帧率之类的项目硬约束…"],
     "notes": "重活在哪跑、特殊 env、踩坑"
   }
   ```
   先 `mkdir -p ${CLAUDE_PROJECT_DIR}/.claude`。

5. **可选丰富 CLAUDE.md**:若项目已有 `CLAUDE.md`,**只追加**一段「## R&D profile(rnd 维护)」摘要并提示来源,**绝不覆盖**已有内容;若没有,问用户要不要顺便生成一份(可委派内置 `/init`)。

6. 收尾:回显 profile 摘要 + 「现在可用 /rnd:explore | review | test | ship」。

## 约定
profile 是**事实源**,别在各处重复;栈/命令变了就重跑 `/rnd:init` 更新它。写文件前若会覆盖已有 profile,先 diff 给用户看。
