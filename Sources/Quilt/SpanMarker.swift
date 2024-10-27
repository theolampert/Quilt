/// Marks the boundary of a text formatting span
public enum SpanMarker: Codable, Equatable, Sendable {
    case before(OpID)
    case after(OpID)
}
