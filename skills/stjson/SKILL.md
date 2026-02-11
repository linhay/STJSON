---
name: STJSON
description: "Skill for working with the STJSON Swift library. Trigger when Claude needs to: (1) read or modify code under Source/STJSON or Source/AnyCodable; (2) create/modify Codable / JSON encoding/decoding examples; (3) diagnose or fix failing unit tests that involve STJSON or AnyCodable; (4) add JSONLines support, migrations, or small API docs and usage snippets for Swift projects using this repository."
---

# STJSON Skill

## Purpose

Provide a repeatable workflow for implementing and validating STJSON, AnyCodable, and JSONLines changes in this repository.

## What this skill provides

- Minimal, focused code-change workflow
- Existing-path-first search strategy
- Test-first guidance for bug fixes and behavior changes
- Reference snippets under `skills/stjson/references/` (split by topic for progressive loading)

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
   - `skills/stjson/references/anycodable.md`
   - `skills/stjson/references/jsonlines.md`
   - `skills/stjson/references/interop.md`
   - `skills/stjson/references/troubleshooting.md`
   Keep `skills/stjson/references/usage.md` as index only.
7. For JSONLines memory-pressure tasks, prefer unified `Source`-based APIs (`decode(from:)`, `forEachLine(from:)`, `compactMapLines(from:)`) or `lines(_:)`, and avoid adding duplicated overloads.
8. When users ask for URL/Data input, always show `Source` wrappers explicitly:
   - `JSONLines.Source.string(ndjson)`
   - `JSONLines.Source.data(data)`
   - `JSONLines.Source.url(fileURL, chunkSize: 64 * 1024)`
9. Explain API simplification clearly: direct `URL`/`Data` overloads were intentionally removed from sync decode/forEach/compactMap entry points to keep one stable call shape (`from: Source`) and reduce external API surface.

## Output requirements

- Summarize change intent in one short paragraph.
- List edited file paths explicitly.
- Include the exact test name(s) added or changed.

## Forbidden actions

- Do not perform unrelated refactors.
- Do not modify public API names unless explicitly requested.
- Do not commit or push changes unless explicitly requested.
