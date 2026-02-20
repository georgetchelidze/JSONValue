public extension JSONValue {
    static func int(_ value: Int) -> JSONValue {
        .number(.int(Int64(value)))
    }

    static func int(_ value: Int64) -> JSONValue {
        .number(.int(value))
    }

    static func int<T: BinaryInteger>(_ value: T) -> JSONValue {
        .number(.int(Int64(value)))
    }

    static func double(_ value: Double) -> JSONValue {
        .number(.double(value))
    }

    static func double<T: BinaryFloatingPoint>(_ value: T) -> JSONValue {
        .number(.double(Double(value)))
    }
}
