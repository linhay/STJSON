---
name: stjson-ops-governance
description: STJSON 仓库治理流程。Use when the task touches docs-dev, memory, AGENTS, public/internal skill boundaries, session cleanup, or when repeated maintainer workflows should be extracted into `.agents/skills/` instead of public `skills/`.
---

# STJSON Operations & Governance

## Purpose

Keep repo-wide rules in `AGENTS.md`, repeatable maintainer workflows in `.agents/skills/`, and public user entry points in `skills/`.

## Workflow

1. 先判断规则归属：
   - 面向外部用户的安装、升级、反馈入口 -> `skills/`
   - 维护者反复使用的实现 / 发布 / 治理流程 -> `.agents/skills/`
   - 每次都要遵守的长期规则 -> `AGENTS.md`
2. 文档落位保持稳定：
   - 功能规格 -> `docs-dev/features/`
   - 技术说明、测试矩阵 -> `docs-dev/dev/`
   - 阶段结论 -> `memory/YYYY-MM-DD.md`
3. 修改 public skill 边界时，同步检查 `skills/README.md` 与 release 打包逻辑。
4. 只有某个模式在后续任务里明显会复用时，才新增内部 skill；不要为了这一次会话堆新入口。

## Validation

至少运行：

```sh
git diff --check
find skills -mindepth 1 -maxdepth 1 -type d | sort
rg -n '^name:|^description:' skills/*/SKILL.md .agents/skills/*/SKILL.md
```

## Forbidden Actions

- 不要把 repo 内部实现流程继续放回 public `skills/`。
- 不要把一次性会话笔记直接升级为 `AGENTS.md` 规则。
