public enum SpanMarker: Codable, Equatable {
    case before(OpID)
    case after(OpID)
}
