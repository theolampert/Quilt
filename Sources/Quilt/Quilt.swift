import Foundation
import OrderedCollections

extension Character: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let string = try container.decode(String.self)
        guard !string.isEmpty else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Decoder expected a Character but found an empty string.")
        }
        guard string.count == 1 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Decoder expected a Character but found a string: \(string)")
        }
        self = string[string.startIndex]
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(String(self))
    }
}

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}

enum Action: Codable {
    case insert
    case remove
}

struct OpID: Comparable, CustomStringConvertible, Hashable, Codable {
    static func < (lhs: OpID, rhs: OpID) -> Bool {
        if lhs.counter == rhs.counter {
            return lhs.id.uuidString < rhs.id.uuidString
        } else {
            return lhs.counter < rhs.counter
        }
    }

    let counter: Int
    let id: UUID

    var description: String {
        "\(counter)@\(id)"
    }
}

struct Operation: CustomStringConvertible, Identifiable, Codable, Hashable {
    var id: OpID { opId }

    init(
        action: Action,
        opId: OpID,
        afterId: OpID? = nil,
        removeId: OpID? = nil,
        character: Character? = nil
    ) {
        self.action = action
        self.opId = opId
        self.afterId = afterId
        self.removeId = removeId
        self.character = character
    }

    let action: Action
    let opId: OpID
    let afterId: OpID?
    let removeId: OpID?
    let character: Character?

    var description: String {
        if let character {
            return "\(opId) \(character)"
        }
        return "\(opId) \(removeId!)"
    }
}

public struct Quilt: Codable {
    var counter: Int = 0
    let user: UUID

    var operations: [Operation] = []

    private func applyOperations() -> [Operation] {
        var ops: [Operation] = []

        for operation in operations {
            switch operation.action {
            case .insert:
                if operation.afterId == nil {
                    ops.insert(operation, at: 0)
                } else if let idx = ops.firstIndex(where: { $0.opId == operation.afterId }) {
//                    if let _ = operation.character {
                        let newIdx = idx + 1
                        ops.insert(operation, at: newIdx)
//                    }
                }
            case .remove:
                if let idx = ops.firstIndex(where: { $0.opId == operation.removeId }) {
                    ops.remove(at: idx)
                }
            }
        }
        return ops
    }

    private mutating func createText() {
        let ops = applyOperations()
        text = ops.compactMap {
            if let char = $0.character {
                return String(char)
            }
            return nil
        }.joined()
    }

    var text: String = ""

    init(user: UUID) {
        self.user = user
    }


    mutating func insert(character: Character, at: Int) {
        let operation = Operation(
            action: .insert,
            opId: .init(counter: counter, id: user),
            afterId: applyOperations()[safeIndex: at - 1]?.opId,
            character: character
        )
        operations.append(operation)
        counter += 1
        createText()
    }

    mutating func remove(at: Int) {
        let operation = Operation(
            action: .remove,
            opId: .init(counter: counter, id: user),
            removeId: applyOperations()[safeIndex: at]?.opId
        )
        operations.append(operation)
        counter += 1
        createText()
    }

    mutating func merge(_ peritext: Quilt) {
        self.operations += peritext.operations.filter { op in
            !self.operations.contains(where: { op.opId == $0.opId })
        }
        if let max = self.operations.max(by: {
            $0.opId.counter < $1.opId.counter
        })?.opId.counter {
            // TODO: Verify
            self.counter = max + 1
        }
        createText()
    }

    mutating func set(newText: String) {
        for change in newText.difference(from: text) {
            switch change {
            case .insert(let offset, let element, _):
                insert(character: element, at: offset)
            case .remove(let offset, _, _):
                remove(at: offset)
            }
        }
    }
}
