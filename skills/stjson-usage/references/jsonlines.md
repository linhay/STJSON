# JSONLines

当用户处理 NDJSON / JSON Lines 文件时，优先用 `JSONLines` 能力。

```swift
import STJSON
import Foundation

let source = JSONLines.Source.url(fileURL, chunkSize: 64 * 1024)
let jsons = try JSONLines().decode(from: source)
```

## Common Sources

```swift
JSONLines.Source.string(ndjson)
JSONLines.Source.data(data)
JSONLines.Source.url(fileURL, chunkSize: 64 * 1024)
```

## Stream Processing

如果用户要逐行处理，优先介绍 `forEachLine(from:)` 或 `lines(_:)`，不要默认全部读入内存。

```swift
import STJSON

var ids: [Int] = []
try JSONLines().forEachLine(from: .string(#"{"id":1}"# + "\n" + #"{"id":2}"#)) { json in
    ids.append(json["id"].intValue)
}
```

## Guidance

- 输入很大：优先 `forEachLine(from:)` / `compactMapLines(from:)`
- 输入只是小样本：`decode(from:)` 就够了
- 用户直接传 `URL` / `Data` 时报类型不匹配：提醒统一走 `JSONLines.Source`
