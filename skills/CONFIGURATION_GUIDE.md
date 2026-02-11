# /skills 配置指南

本文档用于约束本仓库 `skills/` 目录下现有与未来技能的配置方式，确保触发稳定、结构统一、可测试。

## 1. 目标与范围

- 目标：让技能被稳定触发，并且可维护、可复用。
- 范围：`skills/*/SKILL.md` 以及对应 `scripts/`、`references/`、`assets/` 目录。
- 当前已覆盖技能：`skills/stjson`。

## 2. 目录规范

每个技能必须独立目录，目录名使用小写加中划线（`kebab-case`）：

```text
skills/
  <skill-name>/
    SKILL.md
    scripts/      # 可选：可执行脚本
    references/   # 可选：参考资料
    assets/       # 可选：模板或资源
```

约束：
- 必须有且仅有一个 `SKILL.md` 作为入口。
- 不新增 `README.md`、`CHANGELOG.md` 等附加说明文件到技能目录内（避免上下文膨胀）。
- 详细材料放 `references/`，`SKILL.md` 只保留流程和导航。

## 3. SKILL.md Frontmatter 规范

`SKILL.md` 顶部 YAML 只保留以下字段：

```yaml
---
name: <skill-name>
description: <触发描述>
---
```

约束：
- `name` 与目录语义一致（建议完全一致）。
- `description` 必须同时说明：
1. 技能能做什么。
2. 何时触发（场景/路径/任务类型）。
3. 关键触发词或明确编号列表。

推荐模板：

```text
Skill for <domain/task>. Trigger when Codex needs to: 
(1) <case-1>; (2) <case-2>; (3) <case-3>.
```

## 4. SKILL.md 正文规范

正文使用“操作导向”写法（祈使句/步骤化）：

- 先写最小工作流（如何查找、如何改动、如何验证）。
- 再写边界（禁止大重构、禁止无关修改）。
- 最后给参考路径和最小示例。

建议结构：
1. Purpose
2. What this skill provides
3. Repository paths worth checking first
4. How to operate
5. Output requirements
6. Forbidden actions

## 5. 现有技能 stjson 的配置落地

`skills/stjson` 当前可作为标准样例：

- 入口文件：`skills/stjson/SKILL.md`
- 参考资料：`skills/stjson/references/usage.md`
- 触发策略：已覆盖 `Source/STJSON`、`Source/AnyCodable`、`Tests` 相关任务。

建议微调（后续可做）：
- 将正文中的 “When to use this skill” 内容进一步收敛进 frontmatter `description`，减少重复。
- 将较长示例优先放入 `references/usage.md`，保持入口简洁。

## 6. BDD 验收场景

### 场景 1：技能结构合法

- Given: 新增或修改了 `skills/<name>/`
- When: 检查目录结构
- Then: 存在 `SKILL.md`，且可选目录只使用 `scripts/`、`references/`、`assets/`

### 场景 2：触发信息完整

- Given: 读取 `SKILL.md` frontmatter
- When: 检查 `description`
- Then: 同时包含能力描述与触发场景（至少 2 个明确场景）

### 场景 3：正文可执行

- Given: 读取 `SKILL.md` 正文
- When: 查找操作步骤
- Then: 至少有“先查找 -> 再修改 -> 最后验证”的闭环流程

## 7. TDD 校验清单（先写校验，再补内容）

在提交前执行以下检查命令：

```bash
# 1) 每个技能目录必须有 SKILL.md
find skills -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/SKILL.md' ';' -print

# 2) frontmatter 必须包含 name/description
rg -n '^name:|^description:' skills/*/SKILL.md

# 3) 目录下不应出现额外说明文档（允许 SKILL.md）
find skills -mindepth 2 -maxdepth 2 -type f \( -name 'README.md' -o -name 'CHANGELOG.md' -o -name 'INSTALLATION_GUIDE.md' \)
```

判定规则：
- 第 1、2 条必须有结果且符合预期。
- 第 3 条应无输出。

## 8. 日常维护约定

- 修改技能前，先更新本指南中的 BDD 场景或 TDD 清单（若规则有变化）。
- 修改后必须跑一次第 7 节检查命令。
- 新技能先最小可用，再按真实任务迭代 `references/` 与脚本。
