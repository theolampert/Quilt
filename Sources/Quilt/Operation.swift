//
//  Operation.swift
//  
//
//  Created by Theodore Lampert on 15.12.22.
//

public struct Operation: Identifiable, Codable {
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
