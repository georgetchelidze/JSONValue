import Foundation
import Testing
@testable import JSONValue

@Test
func decodeAndEncodeRoundTrip() throws {
    let json = """
    {
      "name": "Automagic",
      "count": 3,
      "rating": 4.5,
      "active": true,
      "meta": null,
      "items": ["a", 2, false]
    }
    """.data(using: .utf8)!

    let decoded = try JSONDecoder().decode(JSONValue.self, from: json)

    #expect(decoded.string("name") == "Automagic")
    #expect(decoded.int("count") == 3)
    #expect(decoded.double("rating") == 4.5)
    #expect(decoded.bool("active") == true)
    #expect(decoded.value("meta")?.isNull == true)

    let encoded = try JSONEncoder().encode(decoded)
    let reparsed = try JSONDecoder().decode(JSONValue.self, from: encoded)
    #expect(reparsed == decoded)
}

@Test
func pathTraversalAndTypedAccessors() {
    let value: JSONValue = .object([
        "contact": .object([
            "customFields": .array([
                .object(["value": .string("hello")]),
                .object(["value": .number(.int(42))])
            ])
        ])
    ])

    let first = value.string(at: .key("contact"), .key("customFields"), .index(0), .key("value"))
    let second = value.int(at: .key("contact"), .key("customFields"), .index(1), .key("value"))

    #expect(first == "hello")
    #expect(second == 42)
    #expect(value.at(.key("missing")) == nil)
}

@Test
func arrayAndDictionaryHelpers() {
    let array: [JSONValue] = [.string("x"), .number(.int(2)), .bool(true), .number(.double(3.5))]
    #expect(array.strings() == ["x"])
    #expect(array.ints() == [2, 3])
    #expect(array.bools() == [true])

    let object: [String: JSONValue] = ["a": .string("b"), "n": .number(.int(7))]
    #expect(object.string("a") == "b")
    #expect(object.int("n") == 7)
}

@Test
func recursiveSearchByKeyAndPredicate() {
    let value: JSONValue = .object([
        "id": .number(.int(1)),
        "items": .array([
            .object([
                "id": .number(.int(2)),
                "meta": .object(["id": .number(.int(3))])
            ]),
            .object(["name": .string("x")])
        ])
    ])

    #expect(value.findFirst(key: "id") == .number(.int(1)))

    let allIDs = value.findAll(key: "id").compactMap(\ .asInt64)
    #expect(allIDs == [1, 2, 3])

    let idPaths = value.findAllWithPaths(key: "id").map(\ .path)
    #expect(idPaths.count == 3)
    #expect(idPaths.contains([.key("id")]))
    #expect(idPaths.contains([.key("items"), .index(0), .key("id")]))
    #expect(idPaths.contains([.key("items"), .index(0), .key("meta"), .key("id")]))

    #expect(value.findFirst(where: { $0.asString == "x" }) == .string("x"))

    let allNumbers = value.findAll(where: {
        if case .number = $0 { return true }
        return false
    })
    #expect(allNumbers.count == 3)

    let allIntPaths = value.findAllWithPaths(where: { $0.asInt64 != nil }).map(\ .path)
    #expect(allIntPaths.contains([.key("id")]))
    #expect(allIntPaths.contains([.key("items"), .index(0), .key("id")]))
    #expect(allIntPaths.contains([.key("items"), .index(0), .key("meta"), .key("id")]))
}

@Test
func numericConstructors() {
    #expect(JSONValue.int(5) == .number(.int(5)))
    #expect(JSONValue.int(Int8(6)) == .number(.int(6)))
    #expect(JSONValue.double(2.5) == .number(.double(2.5)))
    #expect(JSONValue.double(Float(3.25)) == .number(.double(3.25)))
}
