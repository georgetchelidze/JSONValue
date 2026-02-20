import Foundation

public enum JSONNumber: Sendable, Equatable {
    case int(Int64)
    case double(Double)
}

// A dynamic JSON value that can represent any valid JSON.
public enum JSONValue: Sendable, Equatable {
    case string(String)
    case number(JSONNumber)
    case bool(Bool)
    case null
    case array([JSONValue])
    case object([String: JSONValue])
}

extension JSONValue: Codable {
    public init(from decoder: any Decoder) throws {
        // Try keyed (object)
        if let container = try? decoder.container(keyedBy: JSONCodingKeys.self) {
            var dict: [String: JSONValue] = [:]
            for key in container.allKeys {
                dict[key.stringValue] = try container.decode(JSONValue.self, forKey: key)
            }
            self = .object(dict)
            return
        }

        // Try unkeyed (array)
        if var arrayContainer = try? decoder.unkeyedContainer() {
            var arr: [JSONValue] = []
            while !arrayContainer.isAtEnd {
                let value = try arrayContainer.decode(JSONValue.self)
                arr.append(value)
            }
            self = .array(arr)
            return
        }

        // Fallback to single value (primitive/null)
        let single = try decoder.singleValueContainer()
        if single.decodeNil() {
            self = .null
        } else if let b = try? single.decode(Bool.self) {
            self = .bool(b)
        } else if let i = try? single.decode(Int64.self) {
            self = .number(.int(i))
        } else if let d = try? single.decode(Double.self) {
            self = .number(.double(d))
        } else if let s = try? single.decode(String.self) {
            self = .string(s)
        } else {
            throw DecodingError.dataCorruptedError(in: single, debugDescription: "Unsupported JSON value")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case .object(let dict):
            var container = encoder.container(keyedBy: JSONCodingKeys.self)
            for (k, v) in dict {
                // CodingKey requires a failable initializer; any String is valid here.
                try container.encode(v, forKey: JSONCodingKeys(stringValue: k)!)
            }
        case .array(let arr):
            var container = encoder.unkeyedContainer()
            for v in arr {
                try container.encode(v)
            }
        case .string(let s):
            var container = encoder.singleValueContainer()
            try container.encode(s)
        case .number(let n):
            var container = encoder.singleValueContainer()
            switch n {
            case .int(let i):
                try container.encode(i)
            case .double(let d):
                try container.encode(d)
            }
        case .bool(let b):
            var container = encoder.singleValueContainer()
            try container.encode(b)
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
}

private struct JSONCodingKeys: CodingKey, Sendable {
    var stringValue: String
    var intValue: Int?

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
}
