import Foundation

public struct Quilt: Codable, Sendable {
    private var counter: Int = 0
    private let user: UUID

    public var operations: [Operation] = []

    public private(set) var appliedOps: [Operation] = []

    public init(user: UUID) {
        self.user = user
    }

    private mutating func applyOperations() {
        var ops: [Operation] = []
        /*
         Optimisation: Assume that text is inserted and removed sequentially
         and cache the last known index to avoid scanning the whole document.
         This was cribbed from how Y.js does it.
         */
        var lastIdx: (OpID, Int)?

        for operation in operations {
            if case .insert = operation.type {
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
            } else if case let .remove(removeID) = operation.type {
                if let idx = ops.firstIndex(where: { $0.opId == removeID }) {
                    ops.remove(at: idx)
                    if removeID == lastIdx?.0 {
                        lastIdx = nil
                    }
                }
            }
        }
        appliedOps = ops
    }

    /// Inserts a character at the specified index in the text
    /// - Parameters:
    ///   - character: The character to insert
    ///   - atIndex: The position at which to insert the character
    public mutating func insert(character: String, atIndex: Int) {
        // Use appliedOps since we're interested in the index of a character not action
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .insert(character),
            afterId: appliedOps[safeIndex: atIndex - 1]?.opId
        )
        operations.append(operation)
        counter += 1
        applyOperations()
    }

    /// Removes the character at the specified index
    /// - Parameter atIndex: The position of the character to remove
    public mutating func remove(atIndex: Int) {
        // Use appliedOps since we're interested in the index of a character not action
        guard let opID = appliedOps[safeIndex: atIndex]?.opId
            ?? appliedOps.first?.opId else { return }
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .remove(opID)
        )
        operations.append(operation)
        counter += 1
        applyOperations()
    }

    /// Adds a formatting mark to a range of text
    /// - Parameters:
    ///   - mark: The type of formatting to apply
    ///   - fromIndex: The starting index of the range
    ///   - toIndex: The ending index of the range
    public mutating func addMark(
        mark: MarkType,
        fromIndex: Int,
        toIndex: Int
    ) {
        // Use appliedOps since we're interested in the index of a character not action
        let start: SpanMarker = .before(appliedOps[fromIndex].opId)
        let end: SpanMarker = .before(appliedOps[toIndex].opId)
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .addMark(type: mark, start: start, end: end)
        )
        operations.append(operation)
        counter += 1
        applyOperations()
    }

    /// Removes a formatting mark from a range of text
    /// - Parameters:
    ///   - mark: The type of formatting to remove
    ///   - fromIndex: The starting index of the range
    ///   - toIndex: The ending index of the range
    public mutating func removeMark(
        mark: MarkType,
        fromIndex: Int,
        toIndex: Int
    ) {
        let start: SpanMarker = .before(appliedOps[fromIndex].opId)
        let end: SpanMarker = .before(appliedOps[toIndex].opId)
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .removeMark(
                type: mark,
                start: start,
                end: end
            )
        )
        operations.append(operation)
        counter += 1
        applyOperations()
    }

    /// Merges another Quilt document into this one
    /// - Parameter peritext: The Quilt document to merge
    public mutating func merge(_ peritext: Quilt) {
        operations += peritext.operations.filter { operation in
            !self.operations.contains(where: { operation.opId == $0.opId })
        }
        if let max = operations.max(by: {
            $0.opId.counter < $1.opId.counter
        })?.opId.counter {
            counter = max + 1
        }
        applyOperations()
    }
}
