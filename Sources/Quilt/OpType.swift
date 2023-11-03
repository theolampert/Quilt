public enum OpType: Codable, Equatable {
    case insert(String)
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
