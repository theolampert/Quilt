import Foundation

public enum MarkType: Codable {
    case bold
}

public enum OpType: Codable, Equatable, Hashable {
    case insert(Character)
    case remove(OpID)
    case addMark(MarkType)
    case removeMark(OpID)
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

public struct Operation: Identifiable, Codable, Hashable {
    public var id: OpID { opId }

    init(
        opId: OpID,
        type: OpType,
        afterId: OpID? = nil
    ) {
        self.opId = opId
        self.type = type
        self.afterId = afterId
    }

    public let opId: OpID

    let type: OpType
    let afterId: OpID?
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
            switch operation.type {
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
            case .remove(let removeID):
                if let idx = ops.firstIndex(where: { $0.opId == removeID }) {
                    ops.remove(at: idx)
                    if removeID == lastIdx?.0 {
                        lastIdx = nil
                    }
                }
            case .addMark:
                print("Foo")
            case .removeMark:
                print("Bar")
            }
        }
        return ops
    }

    private mutating func createText() {
        appliedOps = applyOperations()
        text = appliedOps.reduce("", { acc, curr in
            if case let .insert(character) = curr.type {
                return acc + String(character)
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
            opId: .init(counter: counter, id: user),
            type: .insert(character),
            afterId: appliedOps[safeIndex: at - 1]?.opId
        )
        operations.append(operation)
        counter += 1
        createText()
    }

    mutating func remove(at: Int) {
        guard let opID = appliedOps[safeIndex: at]?.opId else { return }
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .remove(opID)
        )
        operations.append(operation)
        counter += 1
        createText()
    }

    mutating func addMark(at: Int, mark: MarkType) {
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .addMark(mark)
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
