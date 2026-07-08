# Troubleshooting and Tips

- If decoding fails due to type mismatch, inspect runtime shape first via `json.rawString()` or debug logs.
- Prefer strong Codable models in production; use `AnyCodable` for dynamic or exploratory paths.
- When adding tests, align style with:
  - `Tests/SwiftJSONTests/`
  - `Tests/AnyCodableTests/`
- For large JSONLines inputs, prefer:
  - `forEachLine(from: .url(...))`
  - `compactMapLines(from:)`
  - `asyncLines(url:)`
  over eager `decode(from:)` to reduce temporary memory pressure.
