---
name: stjson-release-governance
description: Use when preparing or changing STJSON release packaging, especially when the task touches GitHub release automation, public skill bundle contents, asset naming, or the contract between `skills/` and the published `STJSON.skills/` archive.
---

# STJSON Release Governance

This is an internal maintainer skill. Do not package it into the public bundle.

## Release Boundary

A release-facing STJSON change may touch these surfaces:

- Git tag / GitHub Release
- Swift package dependency contract
- Public skills bundle built from `skills/`
- Public install/upgrade instructions in `skills/stjson-update/`

## Required Workflow

1. Treat `skills/` as the only public-skill source directory.
2. Public bundle contents must stay minimal:
   - `skills/README.md`
   - `skills/stjson-usage/`
   - `skills/stjson-dev-feedback/`
   - `skills/stjson-update/`
3. 发布资产必须把仓库内的 `skills/` 打包成归档内的 `STJSON.skills/` 根目录，不能把 `.agents/skills/` 打进去。
4. 如果修改了打包文件名、目录结构或安装契约，同步更新：
   - `skills/README.md`
   - `skills/stjson-update/SKILL.md`
   - `AGENTS.md`
   - `.github/workflows/release.yml`
5. 如果只是文档或 skill 结构调整，至少本地验证归档脚本逻辑能产出预期文件列表。

## Validation

至少运行：

```sh
git diff --check
find skills -mindepth 1 -maxdepth 1 -type d | sort
python3 - <<'PY'
from pathlib import Path
allowed = {"README.md", "stjson-dev-feedback", "stjson-update"}
actual = {p.name for p in Path("skills").iterdir() if p.name not in {".DS_Store", "dist"}}
unexpected = actual - allowed
missing = allowed - actual
assert not unexpected, f"unexpected entries: {sorted(unexpected)}"
assert not missing, f"missing entries: {sorted(missing)}"
print("public skills layout ok")
PY
```

## Reporting

明确说明：

- 发布资产名是否变化
- public bundle 根目录是否仍为 `STJSON.skills/`
- public 与 internal skills 是否保持隔离
