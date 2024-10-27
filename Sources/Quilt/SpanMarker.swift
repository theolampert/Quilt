/// Marks the boundary of a text formatting span
public enum SpanMarker: Codable, Equatable {
    case before(OpID)
    case after(OpID)
}
