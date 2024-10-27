import Foundation

extension Character: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)
        guard let char = str.first, str.count == 1 else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid character string: \(str)"
            )
        }
        self = char
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(self))
    }
}
