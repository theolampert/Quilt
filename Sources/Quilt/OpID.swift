//
//  OpID.swift
//
//
//  Created by Theodore Lampert on 15.12.22.
//

import Foundation

public struct OpID: Comparable, Hashable, Codable {
    public static func < (lhs: OpID, rhs: OpID) -> Bool {
        if lhs.counter == rhs.counter {
            return lhs.id.uuidString < rhs.id.uuidString
        } else {
            return lhs.counter < rhs.counter
        }
    }

    let counter: Int
    let id: UUID
}
