import Foundation

public extension JSONValue {
    func findFirst(key: String) -> JSONValue? {
        findFirstInTree { _, keyInObject, _ in
            keyInObject == key
        }
    }

    func findAll(key: String) -> [JSONValue] {
        findAllWithPaths(key: key).map(\ .value)
    }

    func findAllWithPaths(key: String) -> [(path: [PathComponent], value: JSONValue)] {
        var results: [(path: [PathComponent], value: JSONValue)] = []
        walk(path: []) { path, keyInObject, value in
            guard keyInObject == key else { return }
            results.append((path: path, value: value))
        }
        return results
    }

    func findFirst(where predicate: (JSONValue) -> Bool) -> JSONValue? {
        findFirstInTree { _, _, value in
            predicate(value)
        }
    }

    func findAll(where predicate: (JSONValue) -> Bool) -> [JSONValue] {
        findAllWithPaths(where: predicate).map(\ .value)
    }

    func findAllWithPaths(where predicate: (JSONValue) -> Bool) -> [(path: [PathComponent], value: JSONValue)] {
        var results: [(path: [PathComponent], value: JSONValue)] = []
        walk(path: []) { path, _, value in
            guard predicate(value) else { return }
            results.append((path: path, value: value))
        }
        return results
    }

    private func findFirstInTree(_ predicate: ([PathComponent], String?, JSONValue) -> Bool) -> JSONValue? {
        var match: JSONValue?
        walk(path: []) { path, keyInObject, value in
            guard match == nil else { return }
            if predicate(path, keyInObject, value) {
                match = value
            }
        }
        return match
    }

    private func walk(
        path: [PathComponent],
        keyInObject: String? = nil,
        visit: ([PathComponent], String?, JSONValue) -> Void
    ) {
        visit(path, keyInObject, self)

        switch self {
        case .object(let object):
            for key in object.keys.sorted() {
                guard let child = object[key] else { continue }
                child.walk(path: path + [.key(key)], keyInObject: key, visit: visit)
            }
        case .array(let array):
            for (index, child) in array.enumerated() {
                child.walk(path: path + [.index(index)], visit: visit)
            }
        default:
            break
        }
    }
}
