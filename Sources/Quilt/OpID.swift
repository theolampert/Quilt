import Foundation

/// A unique identifier for operations in the Quilt system
/// Combines a counter and UUID to ensure uniqueness and proper ordering
public struct OpID: Comparable, Hashable, Codable, Equatable, CustomStringConvertible, Sendable {
    /// Creates a new operation identifier
    /// - Parameters:
    ///   - counter: The sequence number of this operation
    ///   - id: The UUID of the user who created this operation
    public init(counter: Int, userID: UUID) {
        self.counter = counter
        self.userID = userID
    }
    
    public static func < (lhs: OpID, rhs: OpID) -> Bool {
        if lhs.counter == rhs.counter {
            return lhs.userID.uuidString < rhs.userID.uuidString
        } else {
            return lhs.counter < rhs.counter
        }
    }

    public let counter: Int
    public let userID: UUID

    public var description: String {
        "\(counter)@\(userID)"
    }
}
