---
name: stjson-update
description: Use when an external user wants to install, update, or verify STJSON, including upgrading Swift Package Manager dependencies, aligning to a release tag, and replacing the bundled public STJSON skills with the latest usage/update/feedback bundle.
---

# STJSON Update

Use this public skill to update a user's STJSON dependency and public skills bundle with the smallest safe change.

Repository: `linhay/STJSON`

## Identify The Target Version

1. 如果用户指定版本，使用该 release tag。
2. 否则优先使用 `linhay/STJSON` 的最新 release/tag。
3. 不要默认让外部用户跟随未发布的本地 commit，除非对方明确要求验证源码分支。

## Update Package Dependencies

### Swift Package Manager

将依赖版本更新到目标 tag，然后重新解析依赖：

```swift
.package(url: "https://github.com/linhay/STJSON.git", from: "<target-version>")
```

验证时至少检查一次依赖解析和构建是否通过。

### Source-based Integration

如果用户不是通过 SwiftPM 集成，而是直接引入源码，则对齐仓库里的以下目录：

- `Source/STJSON/`
- `Source/AnyCodable/`
- `Source/SwiftyJSON/`

不要默认扩散到不存在的包管理方式。

## Update Public Skills

1. 下载与目标版本对应的 `stjson-skills.tar.gz`，或直接使用本仓库的 `skills/` 目录作为源码。
2. 在 agent skills 目录中，删除旧的顶层 `stjson` skill 安装（如果存在）。
3. 用新的 `STJSON.skills/` bundle 替换旧安装。
4. 验证以下文件存在：
   - `STJSON.skills/stjson-usage/SKILL.md`
   - `STJSON.skills/stjson-dev-feedback/SKILL.md`
   - `STJSON.skills/stjson-update/SKILL.md`

## Report Back

报告这些结果：

- 目标版本与实际更新到的版本
- 更新的是依赖、public skills，还是两者都更新
- 是否移除了旧的单体 `stjson` skill 安装
- 用户还需要手动处理的剩余步骤
