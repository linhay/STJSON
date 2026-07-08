# Installation

先确认用户当前使用哪种接入方式，再给最小安装步骤。

## Swift Package Manager

```swift
// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "YourProject",
    dependencies: [
        .package(url: "https://github.com/linhay/STJSON.git", from: "<version>")
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: ["STJSON"]
        )
    ]
)
```

如果用户只是 App 工程接入，说明重点是：

1. 添加 package dependency
2. 让目标链接 `STJSON`
3. 代码里 `import STJSON`

## Manual Integration

只有用户明确要求手动集成时，再建议直接引入源码：

- `Source/STJSON/`
- `Source/AnyCodable/`
- `Source/SwiftyJSON/`

## Install Check

安装完成后，最小验证是：

```swift
import STJSON
```

以及一段最小编码或解码样例能编译通过。
