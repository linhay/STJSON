---
name: stjson
description: Skill for working with the STJSON Swift library. Trigger when Codex needs to: (1) read or modify code under Source/STJSON or Source/AnyCodable; (2) create or update Codable and JSON encoding/decoding examples; (3) diagnose or fix tests involving STJSON, AnyCodable, or JSONLines; (4) implement or explain JSONLines streaming APIs such as forEachLine and lines(_:) Collection usage; (5) add migration notes or small API usage snippets for this repository.
---

# STJSON Skill

## Purpose

Provide a repeatable workflow for implementing and validating STJSON, AnyCodable, and JSONLines changes in this repository.

## What this skill provides

- Minimal, focused code-change workflow
- Existing-path-first search strategy
- Test-first guidance for bug fixes and behavior changes
- Reference snippets in `skills/stjson/references/usage.md` (including JSONLines `forEachLine` and `lines(_:)`)

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
6. If asked for usage examples, prefer `skills/stjson/references/usage.md` and choose the smallest relevant snippet.
7. For JSONLines memory-pressure tasks, prefer unified `Source`-based APIs (`decode(from:)`, `forEachLine(from:)`, `compactMapLines(from:)`) or `lines(_:)`, and avoid adding duplicated overloads.

## Output requirements

- Summarize change intent in one short paragraph.
- List edited file paths explicitly.
- Include the exact test name(s) added or changed.

## Forbidden actions

- Do not perform unrelated refactors.
- Do not modify public API names unless explicitly requested.
- Do not commit or push changes unless explicitly requested.
