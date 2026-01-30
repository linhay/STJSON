---
name: STJSON
description: "Skill for working with the STJSON Swift library. Trigger when Claude needs to: (1) read or modify code under Source/STJSON or Source/AnyCodable; (2) create/modify Codable / JSON encoding/decoding examples; (3) diagnose or fix failing unit tests that involve STJSON or AnyCodable; (4) add JSONLines support, migrations, or small API docs and usage snippets for Swift projects using this repository."
---

# STJSON Skill

Purpose
- Provide targeted, repeatable assistance for working with the STJSON Swift library in this repository.

When to use this skill (Trigger conditions)
- The user asks to create, update, or explain Swift code that uses STJSON, AnyCodable, JSONLines, or related Codable helper utilities found in this repo.
- The user asks to diagnose, write, or fix unit tests under Tests/ that exercise JSON encoding/decoding behaviors.
- The user asks for migration examples, small reproducible code snippets, or explanation of how STJSON APIs map to standard Codable/SwiftyJSON patterns.

What this skill provides
- Quick code examples for encoding/decoding using STJSON and AnyCodable
- Guidance for common fixes (missing keys, type mismatches, JSONLines streaming)
- Search pointers to repository locations with examples and tests (paths listed below)
- Minimal reproducible test or code snippets to patch or add to the repo when asked

Repository paths worth checking first
- Source/STJSON/
- Source/AnyCodable/
- Source/SwiftyJSON/
- Tests/SwiftJSONTests/

How to operate (procedural guidance for Claude)
1. Before making any code edits, search the repository for existing patterns and tests under the paths above and cite matching files.
2. Reuse existing helper types and extension methods (e.g., AnyCodable, JSONLines, Codable+Ext) rather than introducing new abstractions.
3. When asked to produce code changes:
   - Keep changes minimal and focused (bugfix rule). Do not refactor unrelated code.
   - Prefer adding small unit tests under Tests/ that demonstrate the fix.
4. When asked to explain API usage, include concise Swift snippets (<= 30 lines) and reference the file paths where equivalent logic exists in this repo.

Examples of tasks this skill should handle
- "Show how to decode a JSONLines stream into [MyModel] using STJSON and JSONLines.swift"
- "Fix failing test X in Tests/SwiftJSONTests by adjusting Codable conformance"
- "Add an example that encodes an AnyCodable-wrapped dictionary to JSON and back"

References (suggested files to load when deeper details are required)
- Source/STJSON/STJSON.swift — core APIs
- Source/STJSON/JSONLines.swift — JSONLines handling
- Source/AnyCodable/* — AnyCodable utilities
- Tests/SwiftJSONTests/* — unit test examples and expected behaviors

Output requirements
- When returning code patches: provide a concise summary (one paragraph) describing the change and the minimal code diff (or file path + snippet) to be applied.
- When adding tests: include the exact test file path and full test function code to paste in.

Forbidden actions
- Do not perform large refactors. Keep fixes minimal.
- Do not commit or push changes to git. Create patch suggestions or apply local file edits only when instructed.

Notes for maintainers
- Keep SKILL.md small and focused. If more in-depth reference material is needed (longer API docs or examples), add files under skills/stjson/references/ and reference them here.

Contact patterns (how users typically trigger this skill)
- "Create a test that reproduces a decoding error for STJSON"
- "Explain how AnyCodable handles nested dictionaries in this repo"
- "Add an example showing JSONLines streaming to an array"

Quick examples (copy-paste)

1) AnyCodable — decode to [String: AnyCodable] and access values

```swift
import AnyCodable
import Foundation

let jsonString = "{"id": 1, "name": "Alice", "meta": {"a": 1}}"
let data = Data(jsonString.utf8)

let decoder = JSONDecoder()
let dictionary = try decoder.decode([String: AnyCodable].self, from: data)

// Access typed values
if let id = dictionary["id"]?.value as? Int {
  print("id=\(id)")
}

// Encode back
let encoder = JSONEncoder()
let out = try encoder.encode(dictionary)
print(String(data: out, encoding: .utf8)!)
```

2) JSONLines — decode newline-delimited JSON (ndjson)

```swift
import STJSON

let ndjson = "{"id":1}\n{"id":2}\n"
let lines = try JSONLines().decode(ndjson)

// `lines` is an array of SwiftyJSON.JSON objects
for json in lines {
  print(try json.rawData())
}

// Map to Codable model
struct Item: Codable { let id: Int }
let models: [Item] = try lines.map { json in
  let d = try json.rawData()
  return try JSONDecoder().decode(Item.self, from: d)
}
```

3) SwiftyJSON <-> Codable interop

```swift
import STJSON

// Start from raw Data (network response)
let data: Data = ...
let json = try JSON(data: data)

// Convert SwiftyJSON JSON to Data and decode into a Codable model
struct User: Codable { let id: Int; let name: String }
let raw = try json.rawData()
let user = try JSONDecoder().decode(User.self, from: raw)

// Or encode a Codable model and create a SwiftyJSON value
let model = User(id: 1, name: "Jane")
let encoded = try JSONEncoder().encode(model)
let swifty = try JSON(data: encoded)
```

End of skill
