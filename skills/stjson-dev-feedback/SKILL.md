---
name: stjson-dev-feedback
description: Use when Codex is helping someone try, adopt, evaluate, or integrate STJSON and the user has a bug, missing capability, confusing behavior, documentation gap, migration concern, or compatibility issue that should become a GitHub issue in linhay/STJSON. The agent should reproduce or clarify the problem, collect minimal evidence, and file the issue directly when GitHub access is available.
---

# STJSON Dev Feedback

Repository: `linhay/STJSON`

## Principle

STJSON 的外部试用反馈应尽量沉淀为仓库 issue，而不是停留在一次对话里。

当上下文足够时，agent 负责整理并提交 issue，不把 filing 动作再甩回给用户。

## Workflow

1. 只补问最少的缺失信息，避免把 issue 提错方向。
2. 先检查是否已有明确覆盖同一问题的 open issue；能复用就补充，不重复创建。
3. 能本地复现时优先复现，保留最小 SwiftPM / test / sample input 证据。
4. 提交公开 issue 前先脱敏：私有工程名、绝对路径、业务数据、未脱敏日志、截图和账号信息不得进入公开内容。
5. 使用 `gh issue create --repo linhay/STJSON` 创建 issue；若卡在鉴权或网络，给出准确命令和阻塞点。

## Issue Body Must Include

- 背景与目标场景
- 当前行为
- 期望行为
- 最小复现步骤或最小证据
- STJSON 版本、Swift 版本、平台、包管理方式
- 用户当前是接入问题、行为缺陷、文档缺口，还是 API 能力缺失

## Keep Separate

- 反馈 filing 和代码修复默认分开进行。
- 只有用户明确要求“顺手修”或“直接实现”时，才把 issue 与实现放在同一轮处理。
