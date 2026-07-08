# SwiftyJSON and Codable Interop

Convert between `SwiftyJSON.JSON` and Codable models.

```swift
import STJSON

let data: Data = ...
let json = try JSON(data: data)

struct User: Codable { let id: Int; let name: String }

let raw = try json.rawData()
let user = try JSONDecoder().decode(User.self, from: raw)

let model = User(id: 1, name: "Jane")
let encoded = try JSONEncoder().encode(model)
let swifty = try JSON(data: encoded)
```
