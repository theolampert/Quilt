/// Represents a single operation in the Quilt system
public struct Operation: Identifiable, Codable, Equatable {
    public var id: OpID { opId }

    init(
        opId: OpID,
        type: OpType,
        afterId: OpID? = nil
    ) {
        self.opId = opId
        self.type = type
        self.afterId = afterId
    }

    public let opId: OpID

    public let type: OpType
    public let afterId: OpID?
}
