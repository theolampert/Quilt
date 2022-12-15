import Foundation
import SwiftUI

public struct Quilt: Codable {
    private var counter: Int = 0
    private let user: UUID

    public var operations: [Operation] = []
    public var text: AttributedString = .init(stringLiteral: "")

    private var appliedOps: [Operation] = []

    public init(user: UUID) {
        self.user = user
    }

    private func applyOperations() -> [Operation] {
        var ops: [Operation] = []
        /*
         Optimisation: Assume that text is inserted and removed sequentially
         and cache the last known index to avoid scanning the whole document.
         */
        var lastIdx: (OpID, Int)?

        for operation in operations {
            switch operation.type {
            case .insert, .addMark:
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
            case let .remove(removeID):
                if let idx = ops.firstIndex(where: { $0.opId == removeID }) {
                    ops.remove(at: idx)
                    if removeID == lastIdx?.0 {
                        lastIdx = nil
                    }
                }
            case let .removeMark(removeAt):
                print("TODO REMOVE MARK \(removeAt)")
            }
        }
        return ops
    }

    private func getSpanMarkerIndex(marker: SpanMarker) -> Int {
        switch marker {
        case let .before(id):
            return appliedOps.firstIndex(where: { $0.id == id })!
        case let .after(id):
            return appliedOps.firstIndex(where: { $0.id == id })!
        }
    }

    private func getAttributedStringRange(
        string: AttributedString,
        start: SpanMarker,
        end: SpanMarker
    ) -> (AttributedString.Index, AttributedString.Index) {
        let startIdx = string.characters.index(
            string.startIndex,
            offsetBy: getSpanMarkerIndex(marker: start)
        )
        let endIdx = string.characters.index(
            startIdx,
            offsetBy: getSpanMarkerIndex(marker: end)
        )
        return (startIdx, endIdx)
    }

    private mutating func createText() {
        appliedOps = applyOperations()
        text = appliedOps.reduce(AttributedString()) { acc, curr in
            switch curr.type {
            case let .insert(character):
                return acc + AttributedString(stringLiteral: String(character))
            case let .addMark(type, start, end):
                switch type {
                case .bold:
                    let (startIdx, endIdx) = getAttributedStringRange(
                        string: acc, start: start, end: end
                    )
                    var boldedString: AttributedString = acc
                    boldedString[startIdx ..< endIdx].font = .system(
                        size: 16,
                        weight: .bold
                    )
                    return boldedString
                case .italic:
                    let (startIdx, endIdx) = getAttributedStringRange(
                        string: acc, start: start, end: end
                    )
                    var boldedString: AttributedString = acc
                    boldedString[startIdx ..< endIdx].font = .italic(
                        .system(size: 16, weight: .regular)
                    )()
                    return boldedString
                case .underline:
                    let (startIdx, endIdx) = getAttributedStringRange(
                        string: acc, start: start, end: end
                    )
                    var underlinedString: AttributedString = acc
                    underlinedString[startIdx ..< endIdx].underlineStyle = .single
                    return underlinedString
                }
            default:
                return acc
            }
        }
    }

    public mutating func insert(character: String, atIndex: Int) {
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .insert(character),
            afterId: appliedOps[safeIndex: atIndex - 1]?.opId
        )
        operations.append(operation)
        counter += 1
        createText()
    }

    public mutating func remove(atIndex: Int) {
        guard let opID = appliedOps[safeIndex: atIndex]?.opId
            ?? appliedOps.first?.opId else { return }
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .remove(opID)
        )
        operations.append(operation)
        counter += 1
        createText()
    }

    mutating func addMark(
        mark: MarkType,
        fromIndex: Int,
        toIndex: Int
    ) {
        let start: SpanMarker = .before(appliedOps[fromIndex].opId)
        let end: SpanMarker = .before(appliedOps[toIndex].opId)
        let operation = Operation(
            opId: .init(counter: counter, id: user),
            type: .addMark(type: mark, start: start, end: end)
        )
        operations.append(operation)
        counter += 1
        createText()
    }

    public mutating func merge(_ peritext: Quilt) {
        operations += peritext.operations.filter { operation in
            !self.operations.contains(where: { operation.opId == $0.opId })
        }
        if let max = operations.max(by: {
            $0.opId.counter < $1.opId.counter
        })?.opId.counter {
            counter = max + 1
        }
        createText()
    }

    public mutating func set(newText _: String) {
//        for change in newText.difference(from: text) {
//            switch change {
//            case .insert(let offset, let element, _):
//                insert(character: element, at: offset)
//            case .remove(let offset, _, _):
//                remove(at: offset)
//            }
//        }
    }
}
