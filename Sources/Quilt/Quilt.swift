import Foundation

public enum Action: Codable {
    case insert
    case remove
}

public struct OpID: Comparable, CustomStringConvertible, Hashable, Codable {
    public static func < (lhs: OpID, rhs: OpID) -> Bool {
        if lhs.counter == rhs.counter {
            return lhs.id.uuidString < rhs.id.uuidString
        } else {
            return lhs.counter < rhs.counter
        }
    }

    let counter: Int
    let id: UUID

    public var description: String {
        "\(counter)@\(id)"
    }
}

public struct Operation: CustomStringConvertible, Identifiable, Codable, Hashable {
    public var id: OpID { opId }

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
    public let opId: OpID
    let afterId: OpID?
    let removeId: OpID?
    let character: Character?

    public var description: String {
        if let character {
            return "\(opId) \(character)"
        }
        return "\(opId) \(removeId!)"
    }
}

public struct Quilt: Codable {
    var counter: Int = 0
    let user: UUID

    public var operations: [Operation] = []
    var appliedOps: [Operation] = []

    private func applyOperations() -> [Operation] {
        var ops: [Operation] = []
        var lastIdx: (OpID, Int)? = nil

        for operation in operations {
            switch operation.action {
            case .insert:
                if operation.afterId == nil {
                    ops.insert(operation, at: 0)
                    lastIdx = (operation.opId, 0)
                } else if lastIdx?.0 == operation.afterId {
                    let newIdx = lastIdx!.1 + 1
                    ops.insert(operation, at: newIdx)
                    lastIdx = (operation.opId, newIdx)
                } else if let idx = ops.firstIndex(where: { $0.opId == operation.afterId }) {
                    let newIdx = idx + 1
                    ops.insert(operation, at: newIdx)
                    lastIdx = (operation.opId, newIdx)
                }
            case .remove:
                if let idx = ops.firstIndex(where: { $0.opId == operation.removeId }) {
                    ops.remove(at: idx)
                    if operation.removeId == lastIdx?.0 {
                        lastIdx = nil
                    }
                }
            }
        }
        return ops
    }

    private mutating func createText() {
        appliedOps = applyOperations()
        text = appliedOps.reduce("", { acc, curr in
            if let char = curr.character {
                return acc + String(char)
            }
            return acc
        })
    }

    public var text: String = ""

    public init(user: UUID) {
        self.user = user
    }

    mutating func insert(character: Character, at: Int) {
        let operation = Operation(
            action: .insert,
            opId: .init(counter: counter, id: user),
            afterId: appliedOps[safeIndex: at - 1]?.opId,
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
            removeId: appliedOps[safeIndex: at]?.opId
        )
        operations.append(operation)
        counter += 1
        createText()
    }

    public mutating func merge(_ peritext: Quilt) {
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

    public mutating func set(newText: String) {
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
