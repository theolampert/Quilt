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

    let type: OpType
    let afterId: OpID?
}
