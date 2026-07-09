//  ComprehensiveAnyCodableTests.swift
import XCTest
import AnyCodable

class ComprehensiveAnyCodableTests: XCTestCase {

    // MARK: - 字面量初始化测试 (Literal Conformances)
    func testLiteralInitialization() {
        let nilVal: AnyCodable = nil
        XCTAssertTrue(nilVal.value is Void)

        let boolVal: AnyCodable = true
        XCTAssertEqual(boolVal.value as? Bool, true)

        let intVal: AnyCodable = 123
        XCTAssertEqual(intVal.value as? Int, 123)

        let floatVal: AnyCodable = 3.14
        XCTAssertEqual(floatVal.value as? Double, 3.14)

        let stringVal: AnyCodable = "hello"
        XCTAssertEqual(stringVal.value as? String, "hello")

        let arrayVal: AnyCodable = [1, "two", true]
        XCTAssertEqual((arrayVal.value as? [Any])?[0] as? Int, 1)
        XCTAssertEqual((arrayVal.value as? [Any])?[1] as? String, "two")
        XCTAssertEqual((arrayVal.value as? [Any])?[2] as? Bool, true)

        let dictVal: AnyCodable = ["key": "value", "num": 42]
        XCTAssertEqual((dictVal.value as? [AnyHashable: Any])?["key"] as? String, "value")
        XCTAssertEqual((dictVal.value as? [AnyHashable: Any])?["num"] as? Int, 42)
    }

    // MARK: - Equatable & Hashable 深度测试
    func testEqualityAndHashing() {
        let int1: AnyCodable = 42
        let int2: AnyCodable = 42
        let int3: AnyCodable = 43
        let double1: AnyCodable = 42.0

        XCTAssertEqual(int1, int2)
        XCTAssertNotEqual(int1, int3)
        // 浮点数 42.0 与 整数 42 不相等 (由于强类型比对)
        XCTAssertNotEqual(int1, double1)

        let set: Set<AnyCodable> = [int1, int2, int3, double1]
        // 尽管 int1 与 int2 相等会被合并，但 double1 与 int1 不等，所以应为 3 个独立元素
        XCTAssertEqual(set.count, 3)
        XCTAssertTrue(set.contains(int1))
        XCTAssertTrue(set.contains(double1))

        // 深度嵌套字典 Equatable 测试
        let dict1: AnyCodable = ["nested": ["a": 1, "b": 2]]
        let dict2: AnyCodable = ["nested": ["a": 1, "b": 2]]
        let dict3: AnyCodable = ["nested": ["a": 1, "b": 3]]
        
        XCTAssertEqual(dict1, dict2)
        XCTAssertNotEqual(dict1, dict3)
    }

    // MARK: - 数值边界 Roundtrip 编解码测试
    func testNumericBoundariesRoundtrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // 1. Int64.max & Int64.min
        let int64Max = AnyCodable(Int64.max)
        let dataMax = try encoder.encode(int64Max)
        let decodedMax = try decoder.decode(AnyCodable.self, from: dataMax)
        XCTAssertEqual(decodedMax.value as? Int, Int(Int64.max)) // aarch64 上 Int 即 Int64

        // 2. Double 边界值
        let doubleVal = AnyCodable(Double.leastNonzeroMagnitude)
        let dataDouble = try encoder.encode(doubleVal)
        let decodedDouble = try decoder.decode(AnyCodable.self, from: dataDouble)
        XCTAssertEqual(decodedDouble.value as? Double, Double.leastNonzeroMagnitude)
    }

    // MARK: - Date 和 URL 的 Roundtrip 测试
    func testDateAndURLRoundtrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // 1. URL 测试
        let url = URL(string: "https://example.com/api?q=swift")!
        let anyURL = AnyCodable(url)
        let dataURL = try encoder.encode(anyURL)
        let decodedURL = try decoder.decode(AnyCodable.self, from: dataURL)
        // URL 被序列化为 String
        XCTAssertEqual(decodedURL.value as? String, "https://example.com/api?q=swift")

        // 2. Date 测试 (默认以时间戳 Double 序列化)
        let date = Date(timeIntervalSinceReferenceDate: 1600000000)
        let anyDate = AnyCodable(date)
        let dataDate = try encoder.encode(anyDate)
        let decodedDate = try decoder.decode(AnyCodable.self, from: dataDate)
        XCTAssertEqual(decodedDate.value as? Int, 1600000000)
    }

    // MARK: - 描述特性与 Debug 描述
    func testDescription() {
        let stringVal: AnyCodable = "hello"
        XCTAssertEqual(stringVal.description, "hello")
        XCTAssertTrue(stringVal.debugDescription.contains("AnyCodable"))

        let doubleVal: AnyCodable = 3.14
        XCTAssertEqual(doubleVal.description, "3.14")
    }

    // MARK: - 异常类型检测
    func testUnsupportedTypes() {
        struct NonCodableStruct {
            let name: String
        }
        
        let invalid = AnyCodable(NonCodableStruct(name: "test"))
        let encoder = JSONEncoder()
        // 编码不支持的非 Codable 类型应该抛出异常
        XCTAssertThrowsError(try encoder.encode(invalid))
    }
}
