/// The different types of operations that can be performed on text
public enum OpType: Codable, Equatable, Sendable, Hashable {
    case insert(Character)
    case remove(OpID)
    case addMark(
        type: MarkType,
        start: SpanMarker,
        end: SpanMarker
    )
    case removeMark(
        type: MarkType,
        start: SpanMarker,
        end: SpanMarker
    )
}
