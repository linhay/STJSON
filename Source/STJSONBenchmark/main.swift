import Foundation
import STJSON
import SwiftyJSON

// MARK: - Dataset Generators
func generateTwitterData() -> Data {
    var tweets: [[String: Any]] = []
    for i in 1...2000 {
        tweets.append([
            "id": 1000000000 + i,
            "id_str": "1000000000\(i)",
            "text": "This is a sample tweet message number \(i) with some extra text to make it longer and more realistic.",
            "retweet_count": i * 7 % 100,
            "favorite_count": i * 13 % 200,
            "favorited": i % 5 == 0,
            "retweeted": i % 9 == 0,
            "possibly_sensitive": false,
            "lang": "en",
            "user": [
                "id": 500000 + i,
                "name": "User \(i)",
                "screen_name": "user_screen_\(i)",
                "location": "San Francisco, CA",
                "description": "Short bio about user \(i) that is interesting.",
                "followers_count": i * 10,
                "friends_count": i * 2,
                "statuses_count": i * 3,
                "verified": i % 50 == 0
            ],
            "entities": [
                "hashtags": [
                    ["text": "swift", "indices": [10, 15]],
                    ["text": "json", "indices": [20, 24]]
                ],
                "user_mentions": [
                    ["screen_name": "apple", "name": "Apple", "id": 9999]
                ]
            ]
        ])
    }
    let dict: [String: Any] = [
        "statuses": tweets,
        "search_metadata": [
            "completed_in": 0.035,
            "max_id": 999999999999,
            "query": "swift",
            "count": 2000
        ]
    ]
    return try! JSONSerialization.data(withJSONObject: dict, options: [])
}

func generateCanadaData() -> Data {
    var features: [[String: Any]] = []
    for i in 1...15 {
        var coordinates: [[[Double]]] = []
        for _ in 1...8 {
            var polygon: [[Double]] = []
            for k in 1...40 {
                let lon = -120.0 + Double(i) * 0.1 + Double(k) * 0.01
                let lat = 50.0 + Double(i) * 0.1 + Double(k) * 0.01
                polygon.append([lon, lat])
            }
            coordinates.append(polygon)
        }
        features.append([
            "type": "Feature",
            "properties": [
                "name": "Region \(i)"
            ],
            "geometry": [
                "type": "Polygon",
                "coordinates": coordinates
            ]
        ])
    }
    let dict: [String: Any] = [
        "type": "FeatureCollection",
        "features": features
    ]
    return try! JSONSerialization.data(withJSONObject: dict, options: [])
}

// MARK: - Timing Helper
func measure(iterations: Int, block: () -> Void) -> Double {
    // Warm up
    block()
    
    let start = DispatchTime.now()
    for _ in 0..<iterations {
        block()
    }
    let end = DispatchTime.now()
    let nano = end.uptimeNanoseconds - start.uptimeNanoseconds
    return Double(nano) / 1_000_000_000.0 // in seconds
}

// MARK: - Printing Helper
func printTableHead(title: String, sizeBytes: Int) {
    print("\n" + String(repeating: "=", count: 80))
    print(String(format: "Benchmark: %@ (~%.2f MB)", title, Double(sizeBytes) / 1024.0 / 1024.0))
    print(String(repeating: "=", count: 80))
    print(String(format: "%-20@ | %-12@ | %-12@ | %-12@ | %-8@", "Library", "Iterations", "Time (ms)", "Speed (MB/s)", "Relative"))
    print(String(repeating: "-", count: 80))
}

func printTableRow(name: String, iterations: Int, timeSec: Double, sizeBytes: Int, baselineTimeSec: Double) {
    let timeMs = timeSec * 1000.0
    let speed = (Double(sizeBytes) * Double(iterations) / 1024.0 / 1024.0) / timeSec
    let relative = baselineTimeSec / timeSec
    print(String(format: "%-20@ | %-12d | %-12.2f | %-12.2f | %-8.2fx", name, iterations, timeMs, speed, relative))
}

func printTableFoot() {
    print(String(repeating: "-", count: 80))
}

// MARK: - Main Runner
func run() {
    print("Preparing Datasets...")
    let twitterData = generateTwitterData()
    let canadaData = generateCanadaData()
    print("Datasets prepared.")
    
    let iterations = 100
    
    // ==========================================
    // TWITTER DATASET (API Response Benchmark)
    // ==========================================
    
    // 1. Parse Benchmark
    printTableHead(title: "Twitter Parse", sizeBytes: twitterData.count)
    
    var baselineTime = 1.0
    
    let timeSerializationParse = measure(iterations: iterations) {
        let _ = try? JSONSerialization.jsonObject(with: twitterData, options: [])
    }
    baselineTime = timeSerializationParse
    printTableRow(name: "JSONSerialization", iterations: iterations, timeSec: timeSerializationParse, sizeBytes: twitterData.count, baselineTimeSec: baselineTime)
    
    let timeSTJSONParse = measure(iterations: iterations) {
        let _ = try? STJSON.JSON(data: twitterData)
    }
    printTableRow(name: "STJSON", iterations: iterations, timeSec: timeSTJSONParse, sizeBytes: twitterData.count, baselineTimeSec: baselineTime)
    
    let timeSwiftyJSONParse = measure(iterations: iterations) {
        let _ = try? SwiftyJSON.JSON(data: twitterData)
    }
    printTableRow(name: "SwiftyJSON", iterations: iterations, timeSec: timeSwiftyJSONParse, sizeBytes: twitterData.count, baselineTimeSec: baselineTime)
    printTableFoot()
    
    // 2. Retrieval Benchmark
    printTableHead(title: "Twitter Retrieval (Value Access)", sizeBytes: twitterData.count)
    
    // Parse objects once for retrieval test
    let rawObj = try! JSONSerialization.jsonObject(with: twitterData, options: [])
    let stjsonObj = try! STJSON.JSON(data: twitterData)
    let swiftyjsonObj = try! SwiftyJSON.JSON(data: twitterData)
    
    let timeSerializationRetrieve = measure(iterations: iterations * 10) {
        if let dict = rawObj as? [String: Any],
           let statuses = dict["statuses"] as? [[String: Any]] {
            for k in [100, 500, 1000, 1500] {
                if k < statuses.count {
                    let tweet = statuses[k]
                    let id = tweet["id"] as? Int ?? 0
                    let text = tweet["text"] as? String ?? ""
                    let user = tweet["user"] as? [String: Any]
                    let screenName = user?["screen_name"] as? String ?? ""
                    let verified = user?["verified"] as? Bool ?? false
                    let _ = (id, text, screenName, verified)
                }
            }
        }
    }
    baselineTime = timeSerializationRetrieve
    printTableRow(name: "JSONSerialization", iterations: iterations * 10, timeSec: timeSerializationRetrieve, sizeBytes: twitterData.count, baselineTimeSec: baselineTime)
    
    let timeSTJSONRetrieve = measure(iterations: iterations * 10) {
        let statuses = stjsonObj["statuses"]
        for k in [100, 500, 1000, 1500] {
            let tweet = statuses[k]
            let id = tweet["id"].intValue
            let text = tweet["text"].stringValue
            let screenName = tweet["user"]["screen_name"].stringValue
            let verified = tweet["user"]["verified"].boolValue
            let _ = (id, text, screenName, verified)
        }
    }
    printTableRow(name: "STJSON (Subscript)", iterations: iterations * 10, timeSec: timeSTJSONRetrieve, sizeBytes: twitterData.count, baselineTimeSec: baselineTime)

    let timeSTJSONFastRetrieve = measure(iterations: iterations * 10) {
        for k in [100, 500, 1000, 1500] {
            let id = stjsonObj.int(at: "statuses", k, "id") ?? 0
            let text = stjsonObj.string(at: "statuses", k, "text") ?? ""
            let screenName = stjsonObj.string(at: "statuses", k, "user", "screen_name") ?? ""
            let verified = stjsonObj.bool(at: "statuses", k, "user", "verified") ?? false
            let _ = (id, text, screenName, verified)
        }
    }
    printTableRow(name: "STJSON (Fast Path)", iterations: iterations * 10, timeSec: timeSTJSONFastRetrieve, sizeBytes: twitterData.count, baselineTimeSec: baselineTime)
    
    let timeSwiftyJSONRetrieve = measure(iterations: iterations * 10) {
        let statuses = swiftyjsonObj["statuses"]
        for k in [100, 500, 1000, 1500] {
            let tweet = statuses[k]
            let id = tweet["id"].intValue
            let text = tweet["text"].stringValue
            let screenName = tweet["user"]["screen_name"].stringValue
            let verified = tweet["user"]["verified"].boolValue
            let _ = (id, text, screenName, verified)
        }
    }
    printTableRow(name: "SwiftyJSON", iterations: iterations * 10, timeSec: timeSwiftyJSONRetrieve, sizeBytes: twitterData.count, baselineTimeSec: baselineTime)
    printTableFoot()
    
    // 3. Stringify Benchmark
    printTableHead(title: "Twitter Stringify", sizeBytes: twitterData.count)
    
    let timeSerializationStringify = measure(iterations: iterations) {
        let _ = try? JSONSerialization.data(withJSONObject: rawObj, options: [])
    }
    baselineTime = timeSerializationStringify
    printTableRow(name: "JSONSerialization", iterations: iterations, timeSec: timeSerializationStringify, sizeBytes: twitterData.count, baselineTimeSec: baselineTime)
    
    let timeSTJSONStringify = measure(iterations: iterations) {
        let _ = try? stjsonObj.rawData()
    }
    printTableRow(name: "STJSON", iterations: iterations, timeSec: timeSTJSONStringify, sizeBytes: twitterData.count, baselineTimeSec: baselineTime)
    
    let timeSwiftyJSONStringify = measure(iterations: iterations) {
        let _ = try? swiftyjsonObj.rawData()
    }
    printTableRow(name: "SwiftyJSON", iterations: iterations, timeSec: timeSwiftyJSONStringify, sizeBytes: twitterData.count, baselineTimeSec: baselineTime)
    printTableFoot()
    
    
    // ==========================================
    // CANADA DATASET (Float array Coordinates)
    // ==========================================
    
    // 1. Parse Benchmark
    printTableHead(title: "Canada Parse (Floats)", sizeBytes: canadaData.count)
    
    let timeSerializationCanadaParse = measure(iterations: iterations) {
        let _ = try? JSONSerialization.jsonObject(with: canadaData, options: [])
    }
    baselineTime = timeSerializationCanadaParse
    printTableRow(name: "JSONSerialization", iterations: iterations, timeSec: timeSerializationCanadaParse, sizeBytes: canadaData.count, baselineTimeSec: baselineTime)
    
    let timeSTJSONCanadaParse = measure(iterations: iterations) {
        let _ = try? STJSON.JSON(data: canadaData)
    }
    printTableRow(name: "STJSON", iterations: iterations, timeSec: timeSTJSONCanadaParse, sizeBytes: canadaData.count, baselineTimeSec: baselineTime)
    
    let timeSwiftyJSONCanadaParse = measure(iterations: iterations) {
        let _ = try? SwiftyJSON.JSON(data: canadaData)
    }
    printTableRow(name: "SwiftyJSON", iterations: iterations, timeSec: timeSwiftyJSONCanadaParse, sizeBytes: canadaData.count, baselineTimeSec: baselineTime)
    printTableFoot()
}

run()
