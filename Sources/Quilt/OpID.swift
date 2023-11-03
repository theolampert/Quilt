import Foundation

public struct OpID: Comparable, Hashable, Codable, Equatable, CustomStringConvertible {
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
