import Foundation

public struct Quilt: Codable, Sendable {
    private var counter: Int = 0
    private let user: UUID

    public var operationLog: ContiguousArray<Operation> = []

    public private(set) var currentContent: [Operation] = []

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

        for operation in operationLog {
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
        currentContent = ops
    }

    /// Inserts a character at the specified index in the text
    /// - Parameters:
    ///   - character: The character to insert
    ///   - atIndex: The position at which to insert the character
    public mutating func insert(character: Character, atIndex: Int) {
        // Use currentContent since we're interested in the index of a character not action
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .insert(character),
            afterId: currentContent[safeIndex: atIndex - 1]?.opId
        )
        operationLog.append(operation)
        counter += 1
        applyOperations()
    }

    /// Removes the character at the specified index
    /// - Parameter atIndex: The position of the character to remove
    public mutating func remove(atIndex: Int) {
        // Use currentContent since we're interested in the index of a character not action
        guard let opID = currentContent[safeIndex: atIndex]?.opId
            ?? currentContent.first?.opId else { return }
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .remove(opID)
        )
        operationLog.append(operation)
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
        // Use currentContent since we're interested in the index of a character not action
        let start: SpanMarker = .before(currentContent[fromIndex].opId)
        let end: SpanMarker = .before(currentContent[toIndex].opId)
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .addMark(type: mark, start: start, end: end)
        )
        operationLog.append(operation)
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
        let start: SpanMarker = .before(currentContent[fromIndex].opId)
        let end: SpanMarker = .before(currentContent[toIndex].opId)
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .removeMark(
                type: mark,
                start: start,
                end: end
            )
        )
        operationLog.append(operation)
        counter += 1
        applyOperations()
    }

    /// Merges another Quilt document into this one
    /// - Parameter quilt: The Quilt document to merge
    public mutating func merge(_ quilt: Quilt) {
        operationLog += quilt.operationLog.filter { operation in
            !self.operationLog.contains(where: { operation.opId == $0.opId })
        }
        if let max = operationLog.max(by: {
            $0.opId.counter < $1.opId.counter
        })?.opId.counter {
            counter = max + 1
        }
        applyOperations()
    }
}
