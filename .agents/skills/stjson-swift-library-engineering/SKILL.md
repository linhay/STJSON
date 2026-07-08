---
name: stjson-swift-library-engineering
description: "Maintainer-side skill for working with the STJSON Swift library. Trigger when Codex needs to: (1) read or modify code under Source/STJSON, Source/AnyCodable, or Source/SwiftyJSON; (2) create or update Codable / JSON encoding-decoding behavior and tests; (3) diagnose or fix failing STJSON / AnyCodable / SwiftyJSON unit tests; (4) add or maintain JSONLines, interop, or JSON-RPC 2.0 protocol-layer behavior; (5) update internal implementation guidance or references for this repository."
---

# STJSON Swift Library Engineering

## Purpose

Provide a repeatable maintainer workflow for implementing and validating STJSON, AnyCodable, JSONLines, SwiftyJSON interop, and JSON-RPC 2.0 changes in this repository.

## What this skill provides

- Minimal, focused code-change workflow
- Existing-path-first search strategy
- Test-first guidance for bug fixes and behavior changes
- Reference snippets under `.agents/skills/stjson-swift-library-engineering/references/` (split by topic for progressive loading)

## Repository paths worth checking first

- `Source/STJSON/`
- `Source/AnyCodable/`
- `Source/SwiftyJSON/`
- `Tests/SwiftJSONTests/`
- `Tests/AnyCodableTests/`

## How to operate

1. Locate existing implementation and tests before editing.
2. Reuse existing helper types and extensions; avoid introducing new abstractions unless required.
3. Add or update a focused test first when fixing behavior.
4. Apply the smallest code change that makes the new/updated test pass.
5. Run related test targets and report results.
6. If asked for usage examples, load only one relevant reference file first:
   - `.agents/skills/stjson-swift-library-engineering/references/anycodable.md`
   - `.agents/skills/stjson-swift-library-engineering/references/codable-extensions.md`
   - `.agents/skills/stjson-swift-library-engineering/references/jsonrpc2.md`
   - `.agents/skills/stjson-swift-library-engineering/references/jsonlines.md`
   - `.agents/skills/stjson-swift-library-engineering/references/interop.md`
   - `.agents/skills/stjson-swift-library-engineering/references/troubleshooting.md`
   Keep `.agents/skills/stjson-swift-library-engineering/references/usage.md` as index only.
7. For JSONLines memory-pressure tasks, prefer unified `Source`-based APIs (`decode(from:)`, `forEachLine(from:)`, `compactMapLines(from:)`) or `lines(_:)`, and avoid adding duplicated overloads.
8. When users ask for URL/Data input, always show `Source` wrappers explicitly:
   - `JSONLines.Source.string(ndjson)`
   - `JSONLines.Source.data(data)`
   - `JSONLines.Source.url(fileURL, chunkSize: 64 * 1024)`
9. Explain API simplification clearly: direct `URL`/`Data` overloads were intentionally removed from sync decode/forEach/compactMap entry points to keep one stable call shape (`from: Source`) and reduce external API surface.
10. For JSON-RPC 2.0 tasks:
   - Keep implementation transport-agnostic (protocol layer only; no HTTP/WebSocket coupling unless explicitly requested).
   - Enforce strict protocol rules in decode/validation tests (`jsonrpc == "2.0"`, `params` object/array only, response `result/error` mutual exclusion, batch empty-array invalid).
   - Prefer explicit `JSONEncoder`/`JSONDecoder` injection and avoid relying on mutable global `shared` coders for default behavior.

## Output requirements

- Summarize change intent in one short paragraph.
- List edited file paths explicitly.
- Include the exact test name(s) added or changed.

## Forbidden actions

- Do not perform unrelated refactors.
- Do not modify public API names unless explicitly requested.
- Do not commit or push changes unless explicitly requested.
