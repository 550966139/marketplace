---
description: 按项目 profile 跑测试、复现 bug、验证改动真生效。当用户输入 /rnd:test、或说「跑下测试/为什么挂了/复现这个 bug/验证我的改动有没有用」时使用。
---

# /rnd:test $ARGUMENTS

跑测试 / 复现 / 验证,基于项目 profile 的真实命令。

## 步骤
1. 读 `${CLAUDE_PROJECT_DIR}/.claude/rnd-profile.json` 拿 `commands.test`/`run`/`build` 与"重活在哪跑"(本地 vs 容器/远端/conda env)。**缺 profile 先提示 `/rnd:init`**(否则容易用错命令)。
2. 按意图选路:
   - **跑测试**:执行 `commands.test`(可加用户给的 `$ARGUMENTS` 作为测试选择/路径);失败则派 `rnd:test-runner` 解析失败、定位到 `file:line`。
   - **复现/定位 bug**:派 `rnd:debugger` —— 先写最小复现、再二分定位根因,必要时加临时日志(用完清掉)。
   - **验证改动**:优先委派内置 **`/verify`** / **`/run`**(真跑起来观察行为),叠加 profile 的运行命令。
3. **如实报告**:测试挂就贴关键输出说挂了、挂在哪;别粉饰。跳过/未跑到的步骤也要讲。
4. 给结论 + 下一步(修哪 / 还差哪些验证)。

## 约定
重活/起服务/大算力前若有副作用或要占资源,先跟用户确认。临时调试代码用完即删。
