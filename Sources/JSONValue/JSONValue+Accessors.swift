import Foundation

public extension JSONValue {
    // MARK: - Type checks

    var isNull: Bool {
        if case .null = self { return true }
        return false
    }

    var asObject: [String: JSONValue]? {
        guard case let .object(obj) = self else { return nil }
        return obj
    }

    var asArray: [JSONValue]? {
        guard case let .array(arr) = self else { return nil }
        return arr
    }

    var asString: String? {
        guard case let .string(s) = self else { return nil }
        return s
    }

    var asInt: Int? {
        switch self {
        case let .number(.int(i)): return Int(exactly: i)
        case let .number(.double(d)): return Int(d)
        case let .string(s): return Int(s)
        default: return nil
        }
    }

    var asInt64: Int64? {
        switch self {
        case let .number(.int(i)): return i
        case let .number(.double(d)): return Int64(d)
        case let .string(s): return Int64(s)
        default: return nil
        }
    }

    var asDouble: Double? {
        switch self {
        case let .number(.double(d)): return d
        case let .number(.int(i)): return Double(i)
        case let .string(s): return Double(s)
        default: return nil
        }
    }

    var asBool: Bool? {
        switch self {
        case let .bool(b):
            return b
        case let .string(s):
            let lowered = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if ["true", "t", "1", "yes", "y"].contains(lowered) { return true }
            if ["false", "f", "0", "no", "n"].contains(lowered) { return false }
            return nil
        case let .number(.int(i)):
            if i == 0 { return false }
            if i == 1 { return true }
            return nil
        case let .number(.double(d)):
            if d == 0 { return false }
            if d == 1 { return true }
            return nil
        default:
            return nil
        }
    }

    // MARK: - Object access

    /// Returns the value for `key` if this is an object, otherwise `nil`.
    func value(_ key: String) -> JSONValue? {
        guard case let .object(obj) = self else { return nil }
        return obj[key]
    }

    /// Returns the value for `key`, or `.null` if missing or not an object.
    /// Useful when chaining accessors.
    func valueOrNull(_ key: String) -> JSONValue {
        return value(key) ?? .null
    }

    // MARK: - Array access

    /// Returns the element at `index` if this is an array and index is in bounds.
    func element(_ index: Int) -> JSONValue? {
        guard case let .array(arr) = self else { return nil }
        guard index >= 0 && index < arr.count else { return nil }
        return arr[index]
    }

    // MARK: - KeyPath style traversal

    /// A lightweight path component for walking through JSON.
    enum PathComponent: Sendable, Equatable {
        case key(String)
        case index(Int)
    }

    /// Traverse a `JSONValue` structure using a sequence of path components.
    ///
    /// Example:
    /// `json.at(.key("contact"), .key("customFields"), .index(0), .key("value"))`
    func at(_ path: PathComponent...) -> JSONValue? {
        at(path)
    }

    /// Traverse a `JSONValue` structure using an array of path components.
    func at(_ path: [PathComponent]) -> JSONValue? {
        var current: JSONValue = self
        for component in path {
            switch component {
            case let .key(k):
                guard let next = current.value(k) else { return nil }
                current = next
            case let .index(i):
                guard let next = current.element(i) else { return nil }
                current = next
            }
        }
        return current
    }

    // MARK: - Convenience typed getters (object)

    func string(_ key: String) -> String? {
        value(key)?.asString
    }

    func int(_ key: String) -> Int? {
        value(key)?.asInt
    }

    func int64(_ key: String) -> Int64? {
        value(key)?.asInt64
    }

    func double(_ key: String) -> Double? {
        value(key)?.asDouble
    }

    func bool(_ key: String) -> Bool? {
        value(key)?.asBool
    }

    func object(_ key: String) -> [String: JSONValue]? {
        value(key)?.asObject
    }

    func array(_ key: String) -> [JSONValue]? {
        value(key)?.asArray
    }

    // MARK: - Convenience typed getters (paths)

    func string(at path: PathComponent...) -> String? {
        at(path)?.asString
    }

    func int(at path: PathComponent...) -> Int? {
        at(path)?.asInt
    }

    func int64(at path: PathComponent...) -> Int64? {
        at(path)?.asInt64
    }

    func double(at path: PathComponent...) -> Double? {
        at(path)?.asDouble
    }

    func bool(at path: PathComponent...) -> Bool? {
        at(path)?.asBool
    }

    func object(at path: PathComponent...) -> [String: JSONValue]? {
        at(path)?.asObject
    }

    func array(at path: PathComponent...) -> [JSONValue]? {
        at(path)?.asArray
    }
}

// MARK: - Array helpers

public extension Array where Element == JSONValue {
    /// Map array elements to strings, skipping non-string values by default.
    func strings() -> [String] {
        compactMap { $0.asString }
    }

    /// Map array elements to `Int`, skipping non-numeric values by default.
    func ints() -> [Int] {
        compactMap { $0.asInt }
    }

    /// Map array elements to `Int64`, skipping non-numeric values by default.
    func int64s() -> [Int64] {
        compactMap { $0.asInt64 }
    }

    /// Map array elements to `Double`, skipping non-numeric values by default.
    func doubles() -> [Double] {
        compactMap { $0.asDouble }
    }

    /// Map array elements to `Bool`, skipping non-bool values by default.
    func bools() -> [Bool] {
        compactMap { $0.asBool }
    }

    /// Returns dictionaries for elements that are objects, skipping others.
    func objects() -> [[String: JSONValue]] {
        compactMap { $0.asObject }
    }
}

// MARK: - Object helpers

public extension Dictionary where Key == String, Value == JSONValue {
    func string(_ key: String) -> String? { self[key]?.asString }
    func int(_ key: String) -> Int? { self[key]?.asInt }
    func int64(_ key: String) -> Int64? { self[key]?.asInt64 }
    func double(_ key: String) -> Double? { self[key]?.asDouble }
    func bool(_ key: String) -> Bool? { self[key]?.asBool }
    func object(_ key: String) -> [String: JSONValue]? { self[key]?.asObject }
    func array(_ key: String) -> [JSONValue]? { self[key]?.asArray }
}
