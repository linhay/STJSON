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

- **Linux (Ubuntu) 编译环境与工具链维护**：
  - 推荐通过下载 Swift 官方 Tarball 并解压至 `/opt/swift-X.Y.Z` 来配置多版本环境。
  - 通过更新符号链接 `sudo ln -sfn /opt/swift-X.Y.Z /opt/swift` 实现环境的无缝一键切换。
  - 在 Linux (非 Objective-C 运行时) 上运行测试时，若遇到 `autoreleasepool` 未定义错误，可通过在其测试文件底部定义如下跨平台兼容宏解决：
    ```swift
    #if !canImport(ObjectiveC)
    func autoreleasepool<Result>(_ block: () throws -> Result) rethrows -> Result {
        try block()
    }
    #endif
    ```

- **Linux Foundation 下 NSNumber 的模式匹配缺陷 (Type Coercion Collision)**：
  - 在 Linux Swift 环境下，对任意值为 1 的 `NSNumber` (例如 Bool-based 或者是 Int-based) 进行 `as? Bool` 匹配时，均会返回 `true`。同理，整型匹配分支在 `switch` 中也容易抢先匹配 Boolean 型 `NSNumber` 导致编码错误（如 `true` 被编码为 `1`）。
  - **解决方案**：在 Switch 分支中，必须对 Swift 原生具体数字类型（`Int`, `Bool`, `Double` 等）使用类型严格校验进行拦截限制（如 `case let int as Int where type(of: value) == Int.self`）。
  - 要从 `NSNumber` 中单独判定布尔型，可配合使用 CoreFoundation 原生函数：`CFGetTypeID(nsnumber) == CFBooleanGetTypeID()` 进行识别。
