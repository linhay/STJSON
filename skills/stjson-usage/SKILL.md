---
name: stjson-usage
description: Use when an external user wants to install, adopt, or use STJSON in a project, including Swift Package Manager integration, source-based fallback integration, Codable extensions, AnyCodable usage, JSONLines workflows, JSON-RPC 2.0 protocol models, and common STJSON / SwiftyJSON interop patterns.
---

# STJSON Usage

Use this public skill when the user is trying to get STJSON working in a real project, not when maintaining the STJSON repository itself.

Repository: `linhay/STJSON`

## What This Skill Covers

- 安装 STJSON
- 在项目里引入 `STJSON` / `AnyCodable`
- 常见 Codable / 字典 / JSON 转换
- JSONLines 用法
- JSON-RPC 2.0 模型与编解码
- STJSON 与 SwiftyJSON 的常见互操作

## Installation

先读 `references/install.md`，按用户的包管理方式给最窄安装步骤。

## How To Operate

1. 先确认用户的接入方式：SwiftPM，还是手动源码集成。
2. 给最小可运行接入步骤，不要一次展开所有历史安装方式。
3. 用户问具体能力时，再按主题读取最窄参考文件：
   - `references/install.md`
   - `references/usage.md`
   - `references/anycodable.md`
   - `references/codable-extensions.md`
   - `references/jsonlines.md`
   - `references/jsonrpc2.md`
   - `references/interop.md`
   - `references/troubleshooting.md`
4. 用户是遇到 bug、兼容性问题、缺能力或文档缺口时，转到 `stjson-dev-feedback`。
5. 用户是升级版本或替换 public skills bundle 时，转到 `stjson-update`。

## Routing

- 用户只是“怎么装” -> `references/install.md`
- 用户只是“普通 Codable / Dictionary 转换怎么写” -> `references/codable-extensions.md`
- 用户需要“异构 JSON / 动态字段” -> `references/anycodable.md`
- 用户处理 NDJSON / `.jsonl` -> `references/jsonlines.md`
- 用户做 JSON-RPC 2.0 协议层 -> `references/jsonrpc2.md`
- 用户项目里已经在用 SwiftyJSON -> `references/interop.md`
- 用户遇到类型不匹配、输入源、性能或接入问题 -> `references/troubleshooting.md`

## Output Requirements

- 说明用户当前接入方式
- 给最小安装步骤
- 给一段对应场景的最小示例代码
- 若有已知限制或常见坑，单独点明
